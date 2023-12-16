extends NinePatchRect




func _ready():
	pass



func _process(delta):
	$VBoxContainer / FPS.text = "FPS: " + var2str(Engine.get_frames_per_second())
