tool 
extends VBoxContainer

var graph = null



func _ready():
	pass







func _on_Add_pressed():
	$HBoxContainer / Add / WindowDialog.popup_centered(Vector2(490, 370))
	

func _on_Button2_pressed():
	print("fuck!!!!!!!!!")


func _on_IF_pressed():
	graph = load("res://addons/Purrini/Nodes/Actions/if statement.tscn")
	$GraphEdit.add_child(graph.instance())
	graph = null


func _on_GraphEdit_connection_request(from, from_slot, to, to_slot):
	$GraphEdit.connect_node(from, from_slot, to, to_slot)


func _on_GraphEdit_disconnection_request(from, from_slot, to, to_slot):
	$GraphEdit.disconnect_node(from, from_slot, to, to_slot)
