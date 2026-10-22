.class public Lcom/chococala/game/MainActivity$Client;
.super Landroid/webkit/WebViewClient;
.source "MainActivity.java"

# Keeps the game's own pages in the WebView and opens web links (like the model credit) in the browser.

.field private final act:Lcom/chococala/game/MainActivity;


.method public constructor <init>(Lcom/chococala/game/MainActivity;)V
    .registers 2

    invoke-direct {p0}, Landroid/webkit/WebViewClient;-><init>()V
    iput-object p1, p0, Lcom/chococala/game/MainActivity$Client;->act:Lcom/chococala/game/MainActivity;

    return-void
.end method


.method public shouldOverrideUrlLoading(Landroid/webkit/WebView;Ljava/lang/String;)Z
    .registers 6

    const-string v0, "file:"
    invoke-virtual {p2, v0}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v0
    if-eqz v0, :external

    const/4 v0, 0x0
    return v0

    :external
    :try_start
    new-instance v0, Landroid/content/Intent;
    const-string v1, "android.intent.action.VIEW"
    invoke-static {p2}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;
    move-result-object v2
    invoke-direct {v0, v1, v2}, Landroid/content/Intent;-><init>(Ljava/lang/String;Landroid/net/Uri;)V
    iget-object v1, p0, Lcom/chococala/game/MainActivity$Client;->act:Lcom/chococala/game/MainActivity;
    invoke-virtual {v1, v0}, Lcom/chococala/game/MainActivity;->startActivity(Landroid/content/Intent;)V
    :try_end
    .catch Ljava/lang/Exception; {:try_start .. :try_end} :handled

    :handled
    const/4 v0, 0x1
    return v0
.end method
