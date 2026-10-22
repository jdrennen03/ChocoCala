.class public Lcom/chococala/game/MainActivity$Bridge;
.super Ljava/lang/Object;
.source "MainActivity.java"

# Exposed to the page as window.ChocoCalaApp. Calls arrive on a WebView thread.

.field private final act:Lcom/chococala/game/MainActivity;


.method public constructor <init>(Lcom/chococala/game/MainActivity;)V
    .registers 2

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lcom/chococala/game/MainActivity$Bridge;->act:Lcom/chococala/game/MainActivity;

    return-void
.end method


.method public setGameMode(Z)V
    .registers 4
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation

    new-instance v0, Lcom/chococala/game/MainActivity$ModeTask;
    iget-object v1, p0, Lcom/chococala/game/MainActivity$Bridge;->act:Lcom/chococala/game/MainActivity;
    invoke-direct {v0, v1, p1}, Lcom/chococala/game/MainActivity$ModeTask;-><init>(Lcom/chococala/game/MainActivity;Z)V
    invoke-virtual {v1, v0}, Lcom/chococala/game/MainActivity;->runOnUiThread(Ljava/lang/Runnable;)V

    return-void
.end method


.method public exitApp()V
    .registers 2
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation

    iget-object v0, p0, Lcom/chococala/game/MainActivity$Bridge;->act:Lcom/chococala/game/MainActivity;
    invoke-virtual {v0}, Lcom/chococala/game/MainActivity;->finish()V

    return-void
.end method
