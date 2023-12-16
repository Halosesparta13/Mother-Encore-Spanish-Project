extends Area2D

export (String) var dialog
export  var appear_flag = ""
export  var disappear_flag = ""

func _ready():
	set_process(false)

func _process(delta):
	if not global.cutscene and not global.inBattle and check_flags() and not uiManager.commandsMenuActive:
		start_cutscene()
		set_process(false)
	if global.cutscene:
		_on_Cutscene_Area_body_exited(global.persistPlayer)

func _on_Cutscene_Area_body_entered(body):
	if body == global.persistPlayer:
		if dialog != "":
			if check_flags():
				if not global.cutscene and not global.inBattle:
					print("yippie")
					set_process(true)
			else :
				
				set_process(true)

func _on_Cutscene_Area_body_exited(body):
	if body == global.persistPlayer and not global.inBattle:
		set_process(false)

func start_cutscene():
	global.persistPlayer.pause()
	global.set_dialog(dialog, null)
	uiManager.open_dialogue_box()

func check_flags():
	var flagOn = true
	if appear_flag != "":
		if globaldata.flags.has(appear_flag):
			if globaldata.flags[appear_flag] == true:
				flagOn = true
			else :
				flagOn = false
	if disappear_flag != "":
		if globaldata.flags.has(disappear_flag):
			if globaldata.flags[disappear_flag] == true:
				flagOn = false
	return flagOn
