extends Area2D


export (Array, NodePath) var object_paths = []

export (NodePath) var new_parent

export (bool) var copy_collisions


onready var objectNodes = []
onready var newParentNode = get_node_or_null(new_parent)

func _ready():
	for object in object_paths:
		objectNodes.append(get_node_or_null(object))

func _on_Reparenter_body_entered(body):
	if body == global.persistPlayer:
		reparent()


func reparent():
	for item in objectNodes:
		if item != null and newParentNode != null:
			if item.get_parent() != newParentNode and item.get_parent() != null:
				item.get_parent().remove_child(item)
				newParentNode.call_deferred("add_child", item)
				if copy_collisions:
					item.set_deferred("collision_mask", newParentNode.collision_mask)
					item.set_deferred("collision_layer", newParentNode.collision_layer)
		
