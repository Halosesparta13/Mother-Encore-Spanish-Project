extends Control

const maxNameCharacters: = 7
const maxFoodCharcter: = 13
const finalStep = 5

var maxCharacters: = 7

var step = - 1
var text = ""
var dontCare = [
	["Ninten", "Ken", "Douglas", "Jeremy", "Mark", "Ryu", "Colin"], 
	["Ana", "Jill", "Sylvia", "Catrine", "Carrie", "Nina", "Emily"], 
	["Lloyd", "Brian", "Albert", "Louis", "Kenny", "Jean", "Maxwell"], 
	["Pippi", "Alex", "Penny", "Ferris", "Natalie", "Katt", "Ashley"], 
	["Teddy", "Joe", "Leo", "Jeb", "Alec", "Rand", "Dallas"], 
	["Bistec", "Frijoles", "Galletas", "Fideos", "Tortillas", "Natilla", "Salmón"],
]

var biographies = [
	"¿El nombre de este chico?", 
	"¿El nombre de esta chica?", 
	"¿Este otro chico?", 
	"¿Esta otra chica?", 
	"¿El nombre de este último?", 
	"¿Cúal es tu comida casera favorita?"
]

var information = [
	"", 
	"", 
	"", 
	"", 
	"", 
	"", 
	"", 
]

var soundEffects = {
	"set_upper":load("res://Audio/Sound effects/M3/menu_open2.wav"), 
	"set_lower":load("res://Audio/Sound effects/M3/menu_close2.wav"), 
	"next":load("res://Audio/Sound effects/M3/menu_open.wav"), 
	"prev":load("res://Audio/Sound effects/M3/menu_close.wav")
}

var currentOtherOption = null
var menuFlavor


onready var bioLabel = $CanvasLayer / NameBox / Label
onready var nameLabel = $CanvasLayer / NameBox / name / Label
onready var arrow = $CanvasLayer / NamingBox / arrow
onready var othersArrow = $CanvasLayer / Others / OthersArrow
onready var textSpeedArrow = $CanvasLayer / TextSpeed / TextSpeedArrow
onready var flavorsArrow = $CanvasLayer / Flavors / FlavorsArrow
onready var buttonPromptsArrow = $CanvasLayer / ButtonPrompts / ButtonPromptsArrow
onready var confirmArrow = $CanvasLayer / ConfirmationRight / Surely / ConfirmationArrow
onready var topGrid = $CanvasLayer / NamingBox / Grid
onready var grid = $CanvasLayer / NamingBox / Grid / GridContainer
onready var grid2 = $CanvasLayer / NamingBox / Grid / GridContainer2
onready var grid3 = $CanvasLayer / NamingBox / Grid / GridContainer3
onready var grid4 = $CanvasLayer / NamingBox / Grid / GridContainer4
onready var grid5 = $CanvasLayer / NamingBox / Grid / GridContainer5
onready var flavorsMenu = $CanvasLayer / Flavors
onready var textSpeedMenu = $CanvasLayer / TextSpeed
onready var buttonPromptsMenu = $CanvasLayer / ButtonPrompts
onready var charAnims = $CharAnims
onready var menuAnims = $MenuAnims
onready var tween = $Tween




func _ready():
	$CanvasLayer / Others / VBoxContainer2 / Flavor.text = globaldata.menuFlavor
	$CanvasLayer / Others / VBoxContainer2 / Prompts.text = globaldata.buttonPrompts
	currentOtherOption = textSpeedMenu
	global.cutscene = true
	global.persistPlayer.pause()
	global.persistPlayer.hide()
	set_dots()
	charAnims.play("Start")
	audioManager.add_audio_player()
	audioManager.play_music_from_id("", "Mother_Earth_Piano.mp3", audioManager.get_audio_player_count() - 1)
	audioManager.set_audio_player_volume(audioManager.get_audio_player_count() - 1, 8)
	yield (get_tree().create_timer(0.5), "timeout")
	step = 0

func _process(delta):
	if step < 6:
		if step > 0:
			$CanvasLayer / NameBox / Indicator.show()
		else :
			$CanvasLayer / NameBox / Indicator.hide()
		if text == "":
			$CanvasLayer / NameBox / Indicator2.hide()
		else :
			$CanvasLayer / NameBox / Indicator2.show()
	

func create_lower():
	for parent in topGrid.get_children():
		if not parent in [grid4, grid5]:
			for i in parent.get_child_count():
				var label = parent.get_child(i)
				if label.text.to_lower() != label.text:
					var lowerLabel = label.duplicate()
					
					lowerLabel.text = label.text.to_lower()
					label.add_child(lowerLabel)
					label.percent_visible = 0
					lowerLabel.rect_position = Vector2.ZERO

func erase_lower():
	for parent in topGrid.get_children():
		for i in parent.get_child_count():
			var label = parent.get_child(i)
			if label.get_child_count() != 0:
				label.get_child(0).queue_free()
				label.percent_visible = 1

func toggle_lower_upper():
	if grid.get_child(0).get_child_count() == 0:
		create_lower()
		audioManager.play_sfx(soundEffects["set_lower"], "casing")
	else :
		erase_lower()
		audioManager.play_sfx(soundEffects["set_upper"], "casing")
			
func backspace():
	if text != "":
		text = text.left(text.length() - 1)
		set_dots()
		arrow.play_sfx("back")
	elif step != 0:
		set_prev_step()
		set_info()
	else :
		arrow.on = false
		audioManager.stop_all_music()
		global.cutscene = false
		
		$Objects / Door.enter()

func set_prev_step():
	if not tween.is_active():
		information[step] = text
		step -= 1
		text = information[step]
		if step < 5:
			maxCharacters = maxNameCharacters
		set_info()
		tween.interpolate_property($Objects / Actors, "position:x", 
			$Objects / Actors.position.x, $Objects / Actors.position.x + 320, 1.0, 
			Tween.TRANS_QUART, Tween.EASE_IN_OUT)
		tween.start()
		audioManager.play_sfx(soundEffects["prev"], "swish")
		if charAnims.current_animation == "FavFoodLoop":
			charAnims.play("FavFoodEnd")
		
		if step == 5:
			charAnims.play("FavFoodStart")
			yield (charAnims, "animation_finished")
			charAnims.play("FavFoodLoop")

func set_next_step():
	if not tween.is_active():
		$OkDesuka.play()
		tween.interpolate_property($Objects / Actors, "position:x", 
			$Objects / Actors.position.x, $Objects / Actors.position.x - 320, 1.0, 
			Tween.TRANS_QUART, Tween.EASE_IN_OUT)
		tween.start()
		information[step] = text
		match step:
			4:
				maxCharacters = maxFoodCharcter
				step += 1
				text = information[step]
				set_info()
				charAnims.play("FavFoodStart")
				yield (charAnims, "animation_finished")
				charAnims.play("FavFoodLoop")
			5:
				step += 1
				charAnims.play("FavFoodEnd")
				show_others()
			_:
				maxCharacters = maxNameCharacters
				step += 1
				text = information[step]
				set_info()
		

func set_info():
	arrow.change_parent(grid, false)
	arrow.cursor_index = 0
	arrow.set_cursor_from_index(0, true)
	set_dots()
	set_bios()

func set_dots():
	nameLabel.text = text
	if len(nameLabel.text) != maxCharacters:
		nameLabel.text += "@"
		for i in maxCharacters - len(nameLabel.text):
			nameLabel.text += "`"

func set_bios():
	bioLabel.text = biographies[step]

func set_dont_care():
	if text in dontCare[step]:
		var index = dontCare[step].find(text) + 1
		if index >= dontCare[step].size():
			index = 0
		text = dontCare[step][index]
	else :
		text = dontCare[step][0]
	set_dots()

func show_others():
	arrow.on = false
	menuAnims.play("OthersOpen")
	othersArrow.hide()
	show_other_option(textSpeedMenu)
	if tween.is_active():
		yield (tween, "tween_all_completed")
		othersArrow.set_cursor_from_index(0, false)
		othersArrow.on = true
		othersArrow.show()

func show_other_option(menu):
	hide_all_other_options()
	currentOtherOption = menu
	if tween.is_active():
		yield (tween, "tween_all_completed")
	if currentOtherOption == menu:
		tween.interpolate_property(menu, "rect_position:x", 
			menu.rect_position.x, 184, 0.2, 
			Tween.TRANS_QUART, Tween.EASE_OUT)
		tween.start()

func hide_all_other_options():
	currentOtherOption = null
	tween.stop_all()
	for i in [textSpeedMenu, flavorsMenu, buttonPromptsMenu]:
		tween.interpolate_property(i, "rect_position:x", 
			i.rect_position.x, 328, 0.2, 
			Tween.TRANS_QUART, Tween.EASE_OUT)
	tween.start()

func show_confirmation():
	othersArrow.on = false
	confirmArrow.hide()
	$CanvasLayer / ConfirmationLeft / Ninten / Label.text = information[0]
	$CanvasLayer / ConfirmationLeft / Ana / Label.text = information[1]
	$CanvasLayer / ConfirmationLeft / Lloyd / Label.text = information[2]
	$CanvasLayer / ConfirmationLeft / Pippi / Label.text = information[3]
	$CanvasLayer / ConfirmationLeft / Teddy / Label.text = information[4]
	$CanvasLayer / ConfirmationRight / Food / Label.text = information[5]
	menuAnims.play("ConfirmationOpen")
	hide_all_other_options()
	yield (menuAnims, "animation_finished")
	confirmArrow.set_cursor_from_index(0, false)
	confirmArrow.show()
	confirmArrow.on = true

func restart_sequence():
	arrow.on = true
	confirmArrow.on = false
	step = 0
	maxCharacters = maxNameCharacters
	text = information[step]
	set_info()
	menuAnims.play("Naming Open")
	tween.interpolate_property($Objects / Actors, "position:x", 
		$Objects / Actors.position.x, 0, 1.5, 
		Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()

func end_sequence():
	arrow.on = false
	global.cutscene = false
	globaldata.ninten.nickname = information[0]
	globaldata.ana.nickname = information[1]
	globaldata.lloyd.nickname = information[2]
	globaldata.pippi.nickname = information[3]
	globaldata.teddy.nickname = information[4]
	globaldata.favoriteFood = information[5]
	menuAnims.play("ConfirmationClose")
	global.cutscene = false
	$OkDesuka.play()
	$Objects / Door2.enter()

func _input(event):
	if step < 6 and step >= 0:
		if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_toggle"):
			backspace()
		if event.is_action_pressed("ui_ctrl"):
			toggle_lower_upper()
		if event.is_action_pressed("ui_select"):
			arrow.change_parent(grid4)
		if event.is_action_pressed("ui_focus_next") and text != "":
			set_next_step()
		if event.is_action_pressed("ui_focus_prev") and step != 0:
			set_prev_step()
	elif step == 7:
		if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_toggle"):
			restart_sequence()

func _on_arrow_selected(cursor_index):
	match arrow.menu_parent.get_child(cursor_index).text:
		"Decidelo":
			set_dont_care()
			arrow.play_sfx("cursor2")
		"Borrar":
			backspace()
		"OK":
			if text != "":
				set_next_step()
		_:
			if len(text) != maxCharacters:
				var character = ""
				if arrow.menu_parent.get_child(cursor_index).percent_visible == 1:
					character = arrow.menu_parent.get_child(cursor_index).text
				else :
					character = arrow.menu_parent.get_child(cursor_index).get_child(0).text
				text += character
				set_dots()
				arrow.play_sfx("cursor2")

func _on_arrow_failed_move(dir):
	var index = 0
	match arrow.menu_parent:
		grid:
			match dir:
				Vector2( - 1, 0):
					arrow.change_parent(grid3)
					arrow.set_cursor_from_index(arrow.cursor_index + grid3.columns - 1)
				Vector2(1, 0):
					arrow.change_parent(grid2)
				Vector2(0, - 1):
					arrow.change_parent(grid4)
				Vector2(0, 1):
					arrow.change_parent(grid4)
		grid2:
			match dir:
				Vector2( - 1, 0):
					arrow.change_parent(grid)
				Vector2(1, 0):
					arrow.change_parent(grid3)
				Vector2(0, - 1):
					if arrow.cursor_index % grid2.columns > grid2.columns / 2:
						arrow.change_parent(grid5)
						arrow.set_cursor_from_index(0)
					else :
						arrow.change_parent(grid4)
						arrow.set_cursor_from_index(0)
				Vector2(0, 1):
					if arrow.cursor_index > 25:
						arrow.change_parent(grid5)
					else :
						arrow.change_parent(grid4)
		grid3:
			match dir:
				Vector2( - 1, 0):
					arrow.change_parent(grid2)
				Vector2(1, 0):
					arrow.change_parent(grid)
					arrow.set_cursor_from_index(arrow.cursor_index - grid.columns + 1)
				Vector2(0, - 1):
					arrow.change_parent(grid5)
				Vector2(0, 1):
					arrow.change_parent(grid5)
		grid4:
			match dir:
				Vector2( - 1, 0):
					arrow.change_parent(grid5)
					arrow.set_cursor_from_index(arrow.cursor_index + grid5.columns - 1)
				Vector2(1, 0):
					arrow.change_parent(grid5)
				Vector2(0, - 1):
					arrow.change_parent(grid)
				Vector2(0, 1):
					arrow.change_parent(grid)
					arrow.set_cursor_from_index(0)
		grid5:
			match dir:
				Vector2( - 1, 0):
					arrow.change_parent(grid4)
				Vector2(1, 0):
					arrow.change_parent(grid4)
					arrow.set_cursor_from_index(arrow.cursor_index - grid4.columns + 1)
				Vector2(0, - 1):
					arrow.change_parent(grid3)
				Vector2(0, 1):
					arrow.change_parent(grid3)
					if arrow.cursor_index == 0:
						arrow.set_cursor_from_index(0)
					else :
						arrow.set_cursor_from_index(grid3.columns - 1)

func _on_OthersArrow_moved(dir):
	match othersArrow.cursor_index:
		0:
			show_other_option(textSpeedMenu)
		1:
			show_other_option(flavorsMenu)
		2:
			show_other_option(buttonPromptsMenu)
		3:
			hide_all_other_options()

func _on_OthersArrow_selected(cursor_index):
	othersArrow.on = false
	if tween.is_active():
		yield (tween, "tween_all_completed")
		if tween.is_active():
			yield (tween, "tween_all_completed")
	match cursor_index:
		0:
			textSpeedArrow.on = true
			textSpeedArrow.show()
			match globaldata.textSpeed:
				0.02:
					textSpeedArrow.set_cursor_from_index(0, false)
				0.035:
					textSpeedArrow.set_cursor_from_index(1, false)
				0.05:
					textSpeedArrow.set_cursor_from_index(2, false)
			textSpeedMenu._on_TextSpeedArrow_moved(null)
		1:
			flavorsArrow.on = true
			flavorsArrow.show()
			match globaldata.menuFlavor:
				"Básico":
					flavorsArrow.set_cursor_from_index(0, false)
				"Menta":
					flavorsArrow.set_cursor_from_index(1, false)
				"Fresa":
					flavorsArrow.set_cursor_from_index(2, false)
				"Banana":
					flavorsArrow.set_cursor_from_index(3, false)
				"Maní":
					flavorsArrow.set_cursor_from_index(4, false)
				"Uva":
					flavorsArrow.set_cursor_from_index(5, false)
				"Melón":
					flavorsArrow.set_cursor_from_index(6, false)
		2:
			buttonPromptsArrow.on = true
			buttonPromptsArrow.show()
			match globaldata.buttonPrompts:
				"Ambos":
					buttonPromptsArrow.set_cursor_from_index(0, false)
				"Objectos":
					buttonPromptsArrow.set_cursor_from_index(1, false)
				"NPCs":
					buttonPromptsArrow.set_cursor_from_index(2, false)
				"Ninguno":
					buttonPromptsArrow.set_cursor_from_index(3, false)
			buttonPromptsMenu._on_ButtonPromptsArrow_moved(null)
		3:
			step += 1
			show_confirmation()

func _on_OthersArrow_cancel():
	hide_all_other_options()
	othersArrow.on = false
	arrow.on = true
	arrow.hide()
	arrow.set_cursor_from_index(0, false)
	menuAnims.play("OthersClose")
	if tween.is_active():
		yield (tween, "tween_all_completed")
	set_prev_step()
	
	


func _on_TextSpeedArrow_selected(cursor_index):
	othersArrow.on = true
	textSpeedArrow.on = false
	textSpeedArrow.hide()
	match cursor_index:
		0:
			$CanvasLayer / Others / VBoxContainer2 / Speed.text = "Rápido"
			globaldata.textSpeed = 0.02
		1:
			$CanvasLayer / Others / VBoxContainer2 / Speed.text = "Media"
			globaldata.textSpeed = 0.035
		2:
			$CanvasLayer / Others / VBoxContainer2 / Speed.text = "Lento"
			globaldata.textSpeed = 0.05


func _on_TextSpeedArrow_cancel():
	othersArrow.on = true
	textSpeedArrow.on = false
	textSpeedArrow.hide()
	textSpeedArrow.get_menu_item_at_index(textSpeedArrow.cursor_index).percent_visible = 1


func _on_FlavorsArrow_selected(cursor_index):
	match cursor_index:
		0:
			globaldata.menuFlavor = "Básico"
		1:
			globaldata.menuFlavor = "Menta"
		2:
			globaldata.menuFlavor = "Fresa"
		3:
			globaldata.menuFlavor = "Banana"
		4:
			globaldata.menuFlavor = "Maní"
		5:
			globaldata.menuFlavor = "Uva"
		6:
			globaldata.menuFlavor = "Melón"
	othersArrow.on = true
	flavorsArrow.on = false
	$CanvasLayer / Others / VBoxContainer2 / Flavor.text = globaldata.menuFlavor
	flavorsArrow.hide()

func _on_FlavorsArrow_cancel():
	uiManager.set_menu_flavors(globaldata.menuFlavor)
	othersArrow.on = true
	flavorsArrow.on = false
	flavorsArrow.hide()

func _on_ButtonPromptsArrow_selected(cursor_index):
	globaldata.buttonPrompts = buttonPromptsArrow.get_menu_item_at_index(cursor_index).text
	$CanvasLayer / Others / VBoxContainer2 / Prompts.text = globaldata.buttonPrompts
	othersArrow.on = true
	buttonPromptsArrow.on = false
	buttonPromptsArrow.hide()

func _on_ButtonPromptsArrow_cancel():
	othersArrow.on = true
	buttonPromptsArrow.on = false
	buttonPromptsArrow.hide()
	match globaldata.buttonPrompts:
		"Ambos":
			buttonPromptsMenu._on_ButtonPromptsArrow_moved(Vector2.ZERO)
		"Objectos":
			buttonPromptsMenu._on_ButtonPromptsArrow_moved(Vector2.ZERO)
		"NPCs":
			buttonPromptsMenu._on_ButtonPromptsArrow_moved(Vector2.ZERO)
		"Ninguno":
			buttonPromptsMenu._on_ButtonPromptsArrow_moved(Vector2.ZERO)

func _on_ConfirmationArrow_selected(cursor_index):
	confirmArrow.on = false
	match cursor_index:
		0:
			end_sequence()
		1:
			restart_sequence()


func _on_ConfirmationArrow_cancel():
	restart_sequence()
