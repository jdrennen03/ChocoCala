import com.reandroid.apk.ApkModule;
import com.reandroid.archive.FileInputSource;
import com.reandroid.arsc.chunk.PackageBlock;
import com.reandroid.arsc.chunk.TableBlock;
import com.reandroid.arsc.chunk.xml.AndroidManifestBlock;
import com.reandroid.arsc.chunk.xml.ResXmlAttribute;
import com.reandroid.arsc.chunk.xml.ResXmlElement;
import com.reandroid.arsc.value.Entry;
import com.reandroid.arsc.value.ValueType;
import com.reandroid.dex.model.DexFile;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

/**
 * Assembles the unsigned ChocoCala APK without the Android SDK:
 * smali -> classes.dex, a one-icon resource table, a binary manifest and the web game in assets/.
 *
 * Usage: java BuildApk <android-dir> <out.apk> <versionCode> <versionName>
 */
public class BuildApk {
    static final String PKG = "com.chococala.game";

    // android.R.attr ids
    static final int ATTR_THEME = 0x01010000;
    static final int ATTR_EXPORTED = 0x01010010;
    static final int ATTR_SCREEN_ORIENTATION = 0x0101001e;
    static final int ATTR_CONFIG_CHANGES = 0x0101001f;
    static final int ATTR_HARDWARE_ACCELERATED = 0x010102d3;
    // android.R.style.Theme_NoTitleBar
    static final int THEME_NO_TITLE_BAR = 0x01030006;
    // keyboard|keyboardHidden|orientation|screenLayout|uiMode|screenSize|smallestScreenSize
    static final int CONFIG_CHANGES = 0x10 | 0x20 | 0x80 | 0x100 | 0x200 | 0x400 | 0x800;

    public static void main(String[] args) throws Exception {
        File root = new File(args[0]);
        File out = new File(args[1]);
        int versionCode = Integer.parseInt(args[2]);
        String versionName = args[3];

        // 1. Code
        DexFile dex = DexFile.createDefault();
        dex.parseSmaliDirectory(new File(root, "smali"));
        dex.clearEmptySections();
        dex.sort();
        dex.refreshFull();
        File dexFile = new File(out.getParentFile(), "classes.dex");
        dex.write(dexFile);
        fixDexHeader(dexFile);

        // 2. Resources: launcher icon and app name
        TableBlock table = new TableBlock();
        PackageBlock pkg = table.newPackage(0x7f, PKG);
        Entry icon = pkg.getOrCreate("", "mipmap", "ic_launcher");
        icon.setValueAsString("res/mipmap/ic_launcher.png");
        Entry label = pkg.getOrCreate("", "string", "app_name");
        label.setValueAsString("ChocoCala");
        table.refresh();

        // 3. Manifest
        AndroidManifestBlock manifest = new AndroidManifestBlock();
        manifest.setPackageName(PKG);
        manifest.setVersionCode(versionCode);
        manifest.setVersionName(versionName);
        manifest.setCompileSdkVersion(34);
        manifest.setMinSdkVersion(24);
        manifest.setTargetSdkVersion(34);
        manifest.addUsesPermission("android.permission.INTERNET");
        manifest.setIconResourceId(icon.getResourceId());
        manifest.setApplicationLabel(label.getResourceId());

        ResXmlElement app = manifest.getOrCreateApplicationElement();
        setRef(app, "theme", ATTR_THEME, THEME_NO_TITLE_BAR);
        app.getOrCreateAndroidAttribute("hardwareAccelerated", ATTR_HARDWARE_ACCELERATED).setValueAsBoolean(true);

        ResXmlElement activity = manifest.getOrCreateMainActivity(PKG + ".MainActivity");
        activity.getOrCreateAndroidAttribute("exported", ATTR_EXPORTED).setValueAsBoolean(true);
        ResXmlAttribute cfg = activity.getOrCreateAndroidAttribute("configChanges", ATTR_CONFIG_CHANGES);
        cfg.setValueType(ValueType.HEX);
        cfg.setData(CONFIG_CHANGES);
        manifest.refresh();

        // 4. Package it
        ApkModule apk = new ApkModule();
        apk.setManifest(manifest);
        apk.setTableBlock(table);
        apk.add(new FileInputSource(dexFile, "classes.dex"));
        apk.add(new FileInputSource(new File(root, "icon.png"), "res/mipmap/ic_launcher.png"));
        Path assets = new File(root, "assets").toPath();
        List<Path> files;
        try (Stream<Path> walk = Files.walk(assets)) {
            files = walk.filter(Files::isRegularFile).sorted().collect(Collectors.toList());
        }
        for (Path f : files) {
            String name = "assets/" + assets.relativize(f).toString().replace(File.separatorChar, '/');
            apk.add(new FileInputSource(f.toFile(), name));
        }
        apk.writeApk(out);
        System.out.println("Wrote " + out + " (" + out.length() + " bytes, " + files.size() + " asset files)");
    }

    /** Recomputes the DEX header's file size, SHA-1 signature and Adler-32 checksum, which ART verifies on install. */
    static void fixDexHeader(File f) throws Exception {
        byte[] b = Files.readAllBytes(f.toPath());
        java.nio.ByteBuffer.wrap(b).order(java.nio.ByteOrder.LITTLE_ENDIAN).putInt(32, b.length);
        java.security.MessageDigest sha1 = java.security.MessageDigest.getInstance("SHA-1");
        sha1.update(b, 32, b.length - 32);
        System.arraycopy(sha1.digest(), 0, b, 12, 20);
        java.util.zip.Adler32 adler = new java.util.zip.Adler32();
        adler.update(b, 12, b.length - 12);
        java.nio.ByteBuffer.wrap(b).order(java.nio.ByteOrder.LITTLE_ENDIAN).putInt(8, (int) adler.getValue());
        Files.write(f.toPath(), b);
    }

    static void setRef(ResXmlElement el, String name, int attrId, int ref) {
        ResXmlAttribute a = el.getOrCreateAndroidAttribute(name, attrId);
        a.setValueType(ValueType.REFERENCE);
        a.setData(ref);
    }
}
