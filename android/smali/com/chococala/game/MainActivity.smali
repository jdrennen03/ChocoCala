.class public Lcom/chococala/game/MainActivity;
.super Landroid/app/Activity;
.source "MainActivity.java"

# Full-screen WebView that plays the bundled game from assets/index.html.

.field private web:Landroid/webkit/WebView;

.field private gameMode:Z


.method public constructor <init>()V
    .registers 1

    invoke-direct {p0}, Landroid/app/Activity;-><init>()V

    return-void
.end method


.method protected onCreate(Landroid/os/Bundle;)V
    .registers 6

    invoke-super {p0, p1}, Landroid/app/Activity;->onCreate(Landroid/os/Bundle;)V

    new-instance v0, Landroid/webkit/WebView;
    invoke-direct {v0, p0}, Landroid/webkit/WebView;-><init>(Landroid/content/Context;)V
    iput-object v0, p0, Lcom/chococala/game/MainActivity;->web:Landroid/webkit/WebView;

    invoke-virtual {v0}, Landroid/webkit/WebView;->getSettings()Landroid/webkit/WebSettings;
    move-result-object v1

    const/4 v2, 0x1
    const/4 v3, 0x0

    invoke-virtual {v1, v2}, Landroid/webkit/WebSettings;->setJavaScriptEnabled(Z)V
    invoke-virtual {v1, v2}, Landroid/webkit/WebSettings;->setDomStorageEnabled(Z)V
    invoke-virtual {v1, v2}, Landroid/webkit/WebSettings;->setAllowFileAccess(Z)V
    invoke-virtual {v1, v3}, Landroid/webkit/WebSettings;->setMediaPlaybackRequiresUserGesture(Z)V

    new-instance v1, Lcom/chococala/game/MainActivity$Client;
    invoke-direct {v1, p0}, Lcom/chococala/game/MainActivity$Client;-><init>(Lcom/chococala/game/MainActivity;)V
    invoke-virtual {v0, v1}, Landroid/webkit/WebView;->setWebViewClient(Landroid/webkit/WebViewClient;)V

    # window.ChocoCalaApp: lets the game switch to landscape full screen and exit the app
    new-instance v1, Lcom/chococala/game/MainActivity$Bridge;
    invoke-direct {v1, p0}, Lcom/chococala/game/MainActivity$Bridge;-><init>(Lcom/chococala/game/MainActivity;)V
    const-string v2, "ChocoCalaApp"
    invoke-virtual {v0, v1, v2}, Landroid/webkit/WebView;->addJavascriptInterface(Ljava/lang/Object;Ljava/lang/String;)V

    invoke-virtual {p0, v0}, Lcom/chococala/game/MainActivity;->setContentView(Landroid/view/View;)V

    const-string v1, "file:///android_asset/index.html"
    invoke-virtual {v0, v1}, Landroid/webkit/WebView;->loadUrl(Ljava/lang/String;)V

    return-void
.end method


.method protected onPause()V
    .registers 2

    invoke-super {p0}, Landroid/app/Activity;->onPause()V

    iget-object v0, p0, Lcom/chococala/game/MainActivity;->web:Landroid/webkit/WebView;
    if-eqz v0, :done
    invoke-virtual {v0}, Landroid/webkit/WebView;->onPause()V

    :done
    return-void
.end method


.method protected onResume()V
    .registers 2

    invoke-super {p0}, Landroid/app/Activity;->onResume()V

    iget-object v0, p0, Lcom/chococala/game/MainActivity;->web:Landroid/webkit/WebView;
    if-eqz v0, :mode
    invoke-virtual {v0}, Landroid/webkit/WebView;->onResume()V

    :mode
    iget-boolean v0, p0, Lcom/chococala/game/MainActivity;->gameMode:Z
    if-eqz v0, :done
    invoke-virtual {p0, v0}, Lcom/chococala/game/MainActivity;->applyMode(Z)V

    :done
    return-void
.end method


# Re-hide the system bars after dialogs, notifications or app switches.
.method public onWindowFocusChanged(Z)V
    .registers 3

    invoke-super {p0, p1}, Landroid/app/Activity;->onWindowFocusChanged(Z)V
    if-eqz p1, :done
    iget-boolean v0, p0, Lcom/chococala/game/MainActivity;->gameMode:Z
    if-eqz v0, :done
    invoke-virtual {p0, v0}, Lcom/chococala/game/MainActivity;->applyMode(Z)V

    :done
    return-void
.end method


# Game mode: landscape (either way round) with immersive full screen. Off: any orientation, normal bars.
.method public applyMode(Z)V
    .registers 5

    iput-boolean p1, p0, Lcom/chococala/game/MainActivity;->gameMode:Z
    if-eqz p1, :normal

    # ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE
    const/4 v0, 0x6
    invoke-virtual {p0, v0}, Lcom/chococala/game/MainActivity;->setRequestedOrientation(I)V
    # LAYOUT_STABLE | LAYOUT_HIDE_NAVIGATION | LAYOUT_FULLSCREEN | HIDE_NAVIGATION | FULLSCREEN | IMMERSIVE_STICKY
    const/16 v1, 0x1706
    goto :apply

    :normal
    # ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED
    const/4 v0, -0x1
    invoke-virtual {p0, v0}, Lcom/chococala/game/MainActivity;->setRequestedOrientation(I)V
    const/4 v1, 0x0

    :apply
    invoke-virtual {p0}, Lcom/chococala/game/MainActivity;->getWindow()Landroid/view/Window;
    move-result-object v2
    invoke-virtual {v2}, Landroid/view/Window;->getDecorView()Landroid/view/View;
    move-result-object v2
    invoke-virtual {v2, v1}, Landroid/view/View;->setSystemUiVisibility(I)V
    return-void
.end method


# Back: the game decides (game -> title screen -> exit) via window.chococalaBack().
.method public onBackPressed()V
    .registers 4

    iget-object v0, p0, Lcom/chococala/game/MainActivity;->web:Landroid/webkit/WebView;
    if-eqz v0, :fallback
    const-string v1, "window.chococalaBack ? window.chococalaBack() : false"
    const/4 v2, 0x0
    invoke-virtual {v0, v1, v2}, Landroid/webkit/WebView;->evaluateJavascript(Ljava/lang/String;Landroid/webkit/ValueCallback;)V
    return-void

    :fallback
    invoke-super {p0}, Landroid/app/Activity;->onBackPressed()V
    return-void
.end method


.method protected onDestroy()V
    .registers 2

    iget-object v0, p0, Lcom/chococala/game/MainActivity;->web:Landroid/webkit/WebView;
    if-eqz v0, :done
    invoke-virtual {v0}, Landroid/webkit/WebView;->destroy()V

    :done
    invoke-super {p0}, Landroid/app/Activity;->onDestroy()V
    return-void
.end method
