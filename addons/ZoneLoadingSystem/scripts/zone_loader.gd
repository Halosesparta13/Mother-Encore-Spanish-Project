extends Node

signal zone_entered(zone_id)
signal zone_attached(zone_id)


signal zone_loaded(zone_id, zone_node)

signal zone_about_to_unload(zone_id, zone_node)

export  var show_debug = false

export  var unload_delay = 1.0

var current_zones = {}
var current_zone


var loaded_zones = {}

func _ready():
	
	
	BackgroundLoader.connect("resource_instance_available", self, "_on_zone_instance_available")
	
	
	BackgroundLoader.connect("resource_instanced", self, "_on_zone_loaded")
	
	
	for zone in get_children():
		
		if zone.get("zone_id"):
			zone.connect("zone_entered", self, "_on_zone_entered")
			zone.connect("zone_exited", self, "_on_zone_exited")

	if show_debug:
		BackgroundLoader.show_debug = true
	
	
	BackgroundLoader.start()

func _print(text):
	
	if show_debug:
		print(text)
	
func get_zone_path(zone_id):
	return loaded_zones[zone_id]
		
func is_in_zone(zone_id):
	return current_zones.has(zone_id)

func enter_zone(zone_id):
	get_node(zone_id).zone_entered(null)

func _on_zone_entered(zone_id, zone_path):
	
	_print(str("zone ", zone_id, " entered"))
	
	current_zone = zone_id
	current_zones[zone_id] = zone_id
	
	
	BackgroundLoader.request_instance(zone_id, zone_path, true)

	
	call_deferred("_load_connected_zones", zone_id)

	emit_signal("zone_entered", zone_id)
	
func _load_connected_zones(zone_id):
	
	var zone = get_node(zone_id)
	
	
	for connected_area in zone.zone_trigger.get_overlapping_areas():
	
		var connected_zone = connected_area.get_parent()
	
		
		if connected_zone.get("zone_id"):
		
			if not loaded_zones.has(connected_zone.zone_id):
				_print(str("load connected zone ", connected_zone.zone_id))
				BackgroundLoader.request_instance(connected_zone.zone_id, connected_zone.zone_path)
		
func _on_zone_exited(zone_id):
	
	_print(str("zone ", zone_id, " exited"))
	
	current_zones.erase(zone_id)
	
	
	if current_zones.size() >= 1:
		current_zone = current_zones.values()[0]
	else :
		current_zone = null
		
	
	
	
	get_tree().create_timer(unload_delay).connect("timeout", self, "_remove_zone", [zone_id])

func _remove_zone(zone_id):
	
	if not is_in_zone(zone_id):
		detach_zone(zone_id)

	
	var keep_zones = current_zones.keys()

	for zone_id in current_zones.keys():
		
		var zone = get_node(zone_id)
		
		
		for connected_area in zone.zone_trigger.get_overlapping_areas():
			
			var connected_zone = connected_area.get_parent()
			
			
			if connected_zone.get("zone_id"):
				
				keep_zones.append(connected_zone.zone_id)
	
	for zone_id in loaded_zones:

		if not zone_id in keep_zones:
			
			_print(str("prunning: request unload ", zone_id))
			
			emit_signal("zone_about_to_unload", zone_id, loaded_zones[zone_id])
			
			BackgroundLoader.request_unload(zone_id)

			loaded_zones.erase(zone_id)
	
func _on_zone_loaded(zone_id, instance):
	
	emit_signal("zone_loaded", zone_id, instance)
	




	
func _on_zone_instance_available(zone_id, instance):
	
	instance.name = zone_id
	
	loaded_zones[zone_id] = instance

	
	if is_in_zone(zone_id):

		
		
		
		get_tree().create_timer(0.0).connect("timeout", self, "attach_zone", [zone_id, instance])


func get_zone(zone_id):

	return get_node(zone_id).get_node_or_null(zone_id)


func attach_zone(zone_id, zone_instance):

	if not get_zone(zone_id):

		get_node(zone_id).add_child(zone_instance)
		_print(str("zone ", zone_id, " attached"))
		
		emit_signal("zone_attached", zone_id)
		

func detach_zone(zone_id):
	
	var area = get_node(zone_id)
	var zone = area.get_node_or_null(zone_id)
	
	if zone:
		
		area.remove_child(zone)
		_print(str("zone ", zone_id, " detached"))
