extends Node2D


onready var animation = $AnimationPlayer
onready var train = $Objects / Path2D / PathFollow2D / Train / Camera2D



func _ready():
	animation.play("TrainMoveRight")
	global.persistPlayer.camera.current = false
	train.current = true
	global.persistPlayer.visible = false
	

