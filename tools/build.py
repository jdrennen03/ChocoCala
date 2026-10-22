#!/usr/bin/env python3
"""Build the ChocoCala web bundles from src/chococala.html.

Outputs
  docs/index.html          Desktop / web version (loads three.js from docs/vendor, works offline).
  dist/ChocoCala.html      The same game as one self-contained file (double-click to play).
  android/assets/          The web version copied in for the Android app.
  build/artifact.html      CDN-based single file (for hosting where vendor files aren't available).
"""
import base64
import pathlib
import shutil

ROOT = pathlib.Path(__file__).resolve().parent.parent
SRC = ROOT / "src" / "chococala.html"
GLB = ROOT / "src" / "assets" / "chocobo.glb"
VENDOR = ROOT / "docs" / "vendor"

CDN_TAGS = {
    "three.min.js": '<script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>',
    "GLTFLoader.js": '<script src="https://cdn.jsdelivr.net/npm/three@0.128.0/examples/js/loaders/GLTFLoader.js"></script>',
    "OrbitControls.js": '<script src="https://cdn.jsdelivr.net/npm/three@0.128.0/examples/js/controls/OrbitControls.js"></script>',
}

RESET = """<style>
html, body { margin: 0; height: 100%; }
:root { padding-top: env(safe-area-inset-top, 0px); padding-bottom: env(safe-area-inset-bottom, 0px); }
body { font-size: 14px; font-family: system-ui, -apple-system, "Segoe UI", sans-serif; }
img { max-width: 100%; }
[hidden] { display: none !important; }
</style>"""


def page(body_html: str) -> str:
    """Wrap the template (title + style + markup + scripts) in a full HTML document."""
    split = body_html.index("</style>") + len("</style>")
    head, body = body_html[:split], body_html[split:]
    return ("<!doctype html>\n<html lang=\"en\">\n<head>\n<meta charset=\"utf-8\">\n"
            "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1, viewport-fit=cover\">\n"
            "<meta name=\"theme-color\" content=\"#17140f\">\n"
            f"{RESET}\n{head}\n</head>\n<body>\n{body}\n</body>\n</html>\n")


def main() -> None:
    src = SRC.read_text(encoding="utf-8")
    glb64 = base64.b64encode(GLB.read_bytes()).decode("ascii")
    src = src.replace("__GLB_B64__", glb64)
    for name in ("hop", "fanfare", "chirp"):
        snd = ROOT / "src" / "assets" / "sounds" / f"{name}.mp3"
        src = src.replace(f"__SND_{name.upper()}__", base64.b64encode(snd.read_bytes()).decode("ascii"))

    local = src
    inline = src
    for name, tag in CDN_TAGS.items():
        assert tag in src, f"missing script tag for {name}"
        local = local.replace(tag, f'<script src="vendor/{name}"></script>')
        code = (VENDOR / name).read_text(encoding="utf-8")
        inline = inline.replace(tag, "<script>\n" + code + "\n</script>")

    docs = ROOT / "docs" / "index.html"
    docs.write_text(page(local), encoding="utf-8")

    dist = ROOT / "dist"
    dist.mkdir(exist_ok=True)
    (dist / "ChocoCala.html").write_text(page(inline), encoding="utf-8")

    build = ROOT / "build"
    build.mkdir(exist_ok=True)
    (build / "artifact.html").write_text(src, encoding="utf-8")

    assets = ROOT / "android" / "assets"
    if assets.exists():
        shutil.rmtree(assets)
    (assets / "vendor").mkdir(parents=True)
    shutil.copy(docs, assets / "index.html")
    for name in CDN_TAGS:
        shutil.copy(VENDOR / name, assets / "vendor" / name)

    print("Built docs/index.html, dist/ChocoCala.html, android/assets/, build/artifact.html")


if __name__ == "__main__":
    main()
