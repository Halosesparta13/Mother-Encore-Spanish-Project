tool 

extends Area2D

export (String) var dialog
export (String) var thoughts
export  var appear_flag = ""
export  var disappear_flag = ""
export  var player_turn = {
	"y":true, 
	"x":true
}
export (Vector2) var button_offset = Vector2.ZERO setget set_button_offset

func _ready():
	check_flags()

func check_flags():
	if appear_flag != "":
		if globaldata.flags.has(appear_flag):
			if globaldata.flags[appear_flag]:
				show()
			else :
				hide()
	if disappear_flag != "":
		if globaldata.flags.has(disappear_flag):
			if globaldata.flags[disappear_flag]:
				hide()
			else :
				show()
	if not visible:
		queue_free()

func set_button_offset(offset):
	button_offset = offset
	$ButtonPrompt.offset = button_offset

func interact():
	$ButtonPrompt.press_button()
	global.set_dialog(dialog, null)
	uiManager.open_dialogue_box()

func telepathy():
	global.set_dialog(thoughts, null)
	uiManager.set_telepathy_effect(true)
	uiManager.open_dialogue_box()

func show_button():
	$ButtonPrompt.show_button()

func hide_button():
	$ButtonPrompt.hide_button()
