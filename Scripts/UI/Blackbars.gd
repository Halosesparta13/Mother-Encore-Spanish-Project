extends CanvasLayer

onready var animaPlayer = $AnimationPlayer
var opened = false

func open():
	if not opened:
		$AnimationPlayer.play("Open")
		opened = true

func close():
	if opened:
		$AnimationPlayer.play("Close")
		opened = false
