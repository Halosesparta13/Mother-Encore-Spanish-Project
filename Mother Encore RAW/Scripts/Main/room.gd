extends Node2D

class_name AreaRoom

export  var player_map_offset: = Vector2.ZERO


export  var map_name_override: = ""



export  var map_item: = ""


export  var is_sub_area: = false


var mapScreen:CanvasLayer



func _physics_process(delta):
	if mapScreen != null:
		if check_map_item():
			if map_name_override == "" and mapScreen.loaded_map != self.name:
				mapScreen.load_map(self.name, is_sub_area)
			elif map_name_override != "" and mapScreen.loaded_map != map_name_override:
				mapScreen.load_map(map_name_override, is_sub_area)

func check_map_item():
	if map_item != "":
		if not InventoryManager.checkItemForAll(map_item):
			return false
	return true
