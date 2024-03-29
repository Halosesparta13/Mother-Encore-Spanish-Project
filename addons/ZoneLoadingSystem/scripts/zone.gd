extends Node

signal zone_entered(zone_id, zone_path)
signal zone_exited(zone_id)

export (String, FILE) var zone_path
export (bool) var preview: = false setget set_preview

var zone_id
var zone_trigger
var _preview_node:Node = null


func _get_configuration_warning():
	
	var trigger

	for child in get_children():
		if child is Area or child is Area2D:
			trigger = child
			break

	if trigger == null:
		return "Area or Area2D child expected for zone trigger"

	return ""


func _ready():
	
	if Engine.editor_hint:
		return 
		
	zone_id = self.name
	
	var trigger

	for child in get_children():
		if child is Area or child is Area2D:
			trigger = child
			break

	assert (trigger != null)
	
	zone_trigger = trigger

	
	trigger.connect("area_entered", self, "zone_entered")
	
	trigger.connect("area_exited", self, "zone_exited")
	
	trigger.add_to_group("zone_trigger")



func zone_entered(area):
	
	if Engine.editor_hint:
		return 
		
	
	if area != null and area.is_in_group("zone_trigger"):
		return 
		
	emit_signal("zone_entered", zone_id, zone_path)



func zone_exited(area):
	
	if Engine.editor_hint:
		return 
		
	
	if area != null and area.is_in_group("zone_trigger"):
		return 
		
	emit_signal("zone_exited", zone_id)


func set_preview(value:bool):
	
	if not Engine.editor_hint or preview == value:
		return 
		
	preview = value

	
	if _preview_node:
		_preview_node.queue_free()
		_preview_node = null

	
	if preview and zone_path:
		
		var scene:PackedScene = load(zone_path)
		
		
		if not scene:
			return 
			
		_preview_node = scene.instance()
		
		add_child(_preview_node)
		
		
		_preview_node.owner = null
