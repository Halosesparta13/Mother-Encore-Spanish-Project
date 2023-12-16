extends Control

export (bool) var auto_start = false
export (float) var wait_time = 4.0
export (float) var wait_margin = 0.5
export (float) var magnitude = 2.0
export (float) var length = 0.8
export (Vector2) var direction = Vector2.ONE
export (String) var sound = "M3/PK_Thunder_a_b_y_O_hit.wav"

onready var timer = $Timer
onready var audioPlayer = $AudioStreamPlayer

func _ready():
	timer.wait_time = wait_time
	audioPlayer.stream = load("res://Audio/Sound effects/" + sound)
	if auto_start:
		timer.start()

func start_shake():
	if timer.time_left == 0:
		_on_Timer_timeout()
		timer.start()

func stop_shake():
	timer.stop()

func _on_Timer_timeout():
	if not global.queuedBattle and not global.inBattle and not global.gameover and global.persistPlayer.state != global.persistPlayer.CAMERA:
		global.currentCamera.shake_camera(magnitude, length, direction)
		audioPlayer.play()
		Input.start_joy_vibration(0, 0.6, 0.8, length)
		timer.wait_time = rand_range(wait_time - wait_margin, wait_time + wait_margin)
