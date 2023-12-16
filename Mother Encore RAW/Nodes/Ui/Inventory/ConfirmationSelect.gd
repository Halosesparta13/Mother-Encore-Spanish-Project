extends NinePatchRect

signal back(accept, current_action, current_character, target_character, current_item)

const arrow_move_offset_y = 14

onready var arrow = $arrow
onready var ConfirmationLabel = $ConfirmationLabel

var current_character = "ninten"
var target_character = "ninten"
var current_action = "give"
var back_action = "back"
var current_item = - 1
var max_item_rows = 2

var active = false
var selected_item_nb = 0


func _ready():
	visible = false
	
func Show_confirmation_select(pos, curr_action, back_act, cur_char, target_char, item_idx):
	current_action = curr_action
	selected_item_nb = 0
	if curr_action == "equipgive":
		ConfirmationLabel.text = "Equip?"
	else :
		ConfirmationLabel.text = curr_action.capitalize() + "?"
	current_item = item_idx
	back_action = back_act
	current_character = cur_char
	target_character = target_char
	visible = true
	active = true
	arrow.on = true
	
	

func _physics_process(_delta):
	if active:
		_inputs()


func _inputs():
	if Input.is_action_just_pressed("ui_up"):
		selected_item_nb -= 1
		if selected_item_nb < 0:
			selected_item_nb = max_item_rows - 1
	elif Input.is_action_just_pressed("ui_down"):
		selected_item_nb += 1
		if selected_item_nb > max_item_rows - 1:
			selected_item_nb = 0
			
	if Input.is_action_just_pressed("ui_cancel") or Input.is_action_just_pressed("ui_toggle"):
		Input.action_release("ui_cancel")
		Input.action_release("ui_toggle")
		visible = false
		active = false
		arrow.on = false
		emit_signal("back", false, back_action, current_character, target_character, current_item)
		return 
		
	if Input.is_action_just_pressed("ui_accept"):
		visible = false
		active = false
		arrow.on = false
		if selected_item_nb == 0:
			emit_signal("back", true, current_action, current_character, target_character, current_item)
		else :
			emit_signal("back", false, current_action, current_character, target_character, current_item)
		
	
	var items = $MarginContainer / VBoxContainer.get_children()
	for item_idx in items.size():
		if item_idx == selected_item_nb:
			items[selected_item_nb].highlight(1)
		else :
			items[item_idx].highlight(0)
