.class public Lcom/chococala/game/MainActivity$ModeTask;
.super Ljava/lang/Object;
.source "MainActivity.java"

# Applies game mode on the UI thread.
.implements Ljava/lang/Runnable;

.field private final act:Lcom/chococala/game/MainActivity;

.field private final on:Z


.method public constructor <init>(Lcom/chococala/game/MainActivity;Z)V
    .registers 3

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lcom/chococala/game/MainActivity$ModeTask;->act:Lcom/chococala/game/MainActivity;
    iput-boolean p2, p0, Lcom/chococala/game/MainActivity$ModeTask;->on:Z

    return-void
.end method


.method public run()V
    .registers 3

    iget-object v0, p0, Lcom/chococala/game/MainActivity$ModeTask;->act:Lcom/chococala/game/MainActivity;
    iget-boolean v1, p0, Lcom/chococala/game/MainActivity$ModeTask;->on:Z
    invoke-virtual {v0, v1}, Lcom/chococala/game/MainActivity;->applyMode(Z)V

    return-void
.end method
