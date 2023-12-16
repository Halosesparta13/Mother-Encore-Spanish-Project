extends Control

export  var fps = 5
export  var loopsBeforeCycle = 4
var status = []
var index = 0

var t = 0.0
var frame = 0
var loops = 0

func _ready():
	for status_node in get_children():
		status_node.hide()

func _process(delta):
	t += delta
	while (t >= 1.0 / fps):
		t -= 1.0 / fps
		frame += 1
		if frame == 3:
			frame = 0
			loops += 1
			
			if loops >= loopsBeforeCycle:
				loops = 0
				if not status.empty():
					rotate_status()
		for status_node in get_children():
			status_node.frame_coords.x = frame














func set_status_shown(status_to_show):
	var status_name = globaldata.status_enum_to_name(status_to_show)
	for status_node in get_children():
		if status_node.name.to_lower() == status_name:
			status_node.show()
		else :
			status_node.hide()

func add_status(new_status):
	
	if new_status == globaldata.ailments.Unconscious:
		return 
	var i = status.find(new_status)
	if i > - 1:
		return 
	status.append(new_status)
	set_status_shown(status[index])

func remove_status(new_status):
	
	if new_status == globaldata.ailments.Unconscious:
		return 
	var i = status.find(new_status)
	if i == - 1:
		return 
	status.remove(i)
	if status.empty():
		index = 0
		for status_node in get_children():
			status_node.hide()
	elif i == index:
		index -= 1
		rotate_status()

func rotate_status():
	index = wrapi(index + 1, 0, status.size())
	set_status_shown(status[index])
