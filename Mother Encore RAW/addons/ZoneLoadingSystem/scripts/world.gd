extends Node


signal world_loaded

onready var zone_loader = $ZoneLoader

export  var player_scene:PackedScene


export (String) var starting_zone


const GROUP_PLAYER_SPAWN = "PLAYER_SPAWN"

var player


func _input(event):
	
	if event is InputEventKey and event.pressed and not event.is_echo():
		
		if event.scancode == KEY_ESCAPE:

			
			BackgroundLoader.request_stop()
			yield (BackgroundLoader, "loading_process_stopped")

			
			get_tree().change_scene("res://demo/menu.tscn")


func _ready():
	
	
	zone_loader.connect("zone_attached", self, "_on_first_zone_attached", [], CONNECT_ONESHOT)
	
	zone_loader.connect("zone_loaded", self, "_on_zone_loaded")
	zone_loader.connect("zone_about_to_unload", self, "_on_zone_about_to_unload")
	
	
	zone_loader.enter_zone(starting_zone)

	get_tree().paused = true




func _on_first_zone_attached(zone_id):
	
	
	
	
	
	
	
	get_tree().paused = false
	
	
	yield (get_tree(), "idle_frame")
	
	emit_signal("world_loaded")




func _on_zone_loaded(zone_id, zone_node):

	pass





func _on_zone_about_to_unload(zone_id, zone_node):

	pass

