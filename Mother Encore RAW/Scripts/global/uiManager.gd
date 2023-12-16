extends Node

signal menuFlavorUpdated

const gameover = preload("res://Nodes/Ui/GameOver.tscn")

onready var commandsMenuNode = preload("res://Nodes/Ui/Pause menu.tscn")
var dialogueBoxNode = preload("res://Nodes/Ui/DialogueBox.tscn")
var battleMenuNode = preload("res://Nodes/Ui/Battle/Battle.tscn")
var battleBGNode = preload("res://Nodes/Ui/Battle/BattleBG.tscn")
var blackBarsNode = preload("res://Nodes/Ui/Blackbars.tscn")
var atmMenuNode = preload("res://Nodes/Ui/ATM/ATM Menu.tscn")
var cashNode = preload("res://Nodes/Ui/CashBox.tscn")
var keyNode = preload("res://Nodes/Ui/KeyCount.tscn")
var shopNode = preload("res://Nodes/Ui/Shop/ShopUI.tscn")
var saveNode = preload("res://Maps/SaveSelect.tscn")
onready var cash = cashNode.instance()
onready var key = keyNode.instance()
onready var blackBars = blackBarsNode.instance()
var menuFlavorShader = preload("res://Shaders/MenuFlavors.tres")
var battleTransitionNode = preload("res://Nodes/Ui/Battle/Battle Transition.tscn")
var battleBGs = {}
var queuedBattle = false
var battleWinCutscene = ""
var battleFleeCutscene = ""
var battleLoseCutscene = ""
var battleWinFlag = ""
var battleLoseHeal = ""
var queueSetCrumbs = false


var commandsMenu
var commandsMenuActive = false
var uiActive = false
var fade = null
var stableCanvasLayer = null
var uiStack = []
var onScreenEnemies = []
var dialogueBox



var menuFlavors = {
	"Plain":["f3f2f4", "bfb4cd", "7a6c86", "141117", "ba53e4", "d6cedf", "332943"], 
	"Mint":["a9fff1", "4ca8b0", "5d6fa5", "230c24", "945ffa", "69c3c4", "36182e"], 
	"Strawberry":["ffa2b5", "e47089", "b8425a", "361115", "2fc05c", "ee8399", "4f1e15"], 
	"Banana":["ffd152", "d4722c", "ad552f", "220a07", "d85123", "e08b37", "3c1a14"], 
	"Peanut":["fa8a52", "c2473c", "993131", "33161a", "c92727", "d86146", "432822"], 
	"Grape":["eab3ff", "a669c6", "304280", "171b32", "de3995", "b97ed6", "2e2743"], 
	"Melon":["81e06e", "4bb367", "963948", "29101c", "ff4f75", "a8c469", "362126"]
}



func _ready():
	randomize()
	var canvasLayerNode = load("res://Nodes/Ui/mainCanvasLayer.tscn")
	
	set_menu_flavors(globaldata.menuFlavor)
	
	
	load_battle_bgs()
	
	if stableCanvasLayer == null:
		stableCanvasLayer = canvasLayerNode.instance()
		global.currentScene.add_child(stableCanvasLayer)
		global.add_persistent(stableCanvasLayer)
		add_to_canvas(blackBars, 0)
		add_to_canvas(cash, 1)
		add_to_canvas(key, 2)
	
	if fade == null:
		var transitionNode = load("res://Nodes/Ui/effects/Fade.tscn")
		var transition = transitionNode.instance()
		transition.set_name("fade")
		stableCanvasLayer.add_child(transition)
		fade = transition

func set_menu_flavors(flavor):
	menuFlavorShader.set_shader_param("NEWCOLOR1", Color(menuFlavors[flavor][0]))
	menuFlavorShader.set_shader_param("NEWCOLOR2", Color(menuFlavors[flavor][1]))
	menuFlavorShader.set_shader_param("NEWCOLOR3", Color(menuFlavors[flavor][2]))
	menuFlavorShader.set_shader_param("NEWCOLOR4", Color(menuFlavors[flavor][3]))
	menuFlavorShader.set_shader_param("NEWCOLOR5", Color(menuFlavors[flavor][4]))
	menuFlavorShader.set_shader_param("NEWCOLOR6", Color(menuFlavors[flavor][5]))
	menuFlavorShader.set_shader_param("NEWCOLOR7", Color(menuFlavors[flavor][6]))
	emit_signal("menuFlavorUpdated")

func add_ui(ui, addChild = true):
	uiStack.push_front(ui)
	uiActive = true
	if addChild:
		stableCanvasLayer.call_deferred("add_child", ui)

func remove_ui(ui = uiStack[0]):
	if ui in uiStack:
		uiStack.erase(ui)
	if is_instance_valid(ui):
		close_item(ui)
	if uiStack.empty():
		uiActive = false

func close_current():
	remove_ui()

func close_item(item):
	if item.has_method("close"):
		item.close()
	else :
		item.queue_free()

func open_dialogue_box():
	dialogueBox = dialogueBoxNode.instance()
	add_ui(dialogueBox)
	commandsMenuActive = false
	return dialogueBox


func check_keys(scene):
	if globaldata.keys.has(scene):
		return globaldata.keys[scene]
	else :
		return - 1

func open_commands_menu():
	global.persistPlayer.pause()
	commandsMenu = commandsMenuNode.instance()
	add_ui(commandsMenu)
	commandsMenuActive = true

func close_commands_menu(unpause = true):
	audioManager.set_audio_player_bus(0, "Master")
	remove_ui(commandsMenu)
	commandsMenuActive = false
	commandsMenu.queue_free()
	print(unpause)
	if unpause:
		global.persistPlayer.unpause()

func start_battle(type = 0, canRun = true):
	if global.inBattle:
		return 
	global.persistPlayer.pause()
	queuedBattle = true
	
	
	
	var root = get_tree().root
	var battleui = battleMenuNode.instance()
	
	
	for enemy in onScreenEnemies:

		if enemy[1] != null:
			if enemy[1].get("eventRayCaster") != null and not enemy[1].drafted:
				enemy[1].eventRayCaster.look_at(global.persistPlayer.global_position + global.persistPlayer.get_node("CollisionShape2D").position * 2)
				if enemy[1].eventRayCaster.get_collider() == global.persistPlayer:
					enemy[1].emotes.hide()
					enemy[1].emotes.frame = 0
					battleui.add_enemy(enemy[0], enemy[1])
			else :
				enemy[1].emotes.hide()
				enemy[1].emotes.frame = 0
				battleui.add_enemy(enemy[0], enemy[1])
				enemy[1].drafted = false
		else :
			battleui.add_enemy(enemy[0], enemy[1])
	
	
	var bg = battleBGs["lamp"]
	var musicIntro = ""
	var music = ""
	
	var firstEnemy = battleui.enemyBPs[0]
	if firstEnemy.stats.get("bg") != null:
		if firstEnemy.stats.bg in battleBGs:
			bg = battleBGs[firstEnemy.stats.bg]
	if "musicintro" in firstEnemy.stats:
		musicIntro = firstEnemy.stats.musicintro
	if "music" in firstEnemy.stats:
		music = firstEnemy.stats.music
	
	battleui.music = music
	battleui.musicIntro = musicIntro
	
	
	match type:
		1:
			battleui.playerAdv = true
		2:
			battleui.enemyAdv = true
	
	battleui.canRun = canRun
	
	if global.currentCamera.shaking:
		yield (global.currentCamera, "stoped_shaking")
	
	
	var battleBG = CanvasLayer.new()
	battleBG.add_child(bg.instance())
	battleBG.layer = - 1
	add_ui(battleBG)
	battleui.battleBG = battleBG
	
	
	
	print("add battle")
	add_ui(battleui)
	
	
	
	var backBuffer = BackBufferCopy.new()
	backBuffer.copy_mode = BackBufferCopy.COPY_MODE_VIEWPORT
	root.add_child(backBuffer)
	root.move_child(backBuffer, root.get_children().size() - 2)
	
	
	var transition = battleTransitionNode.instance()
	transition.battleui = battleui
	root.add_child(transition)
	
	transition.position = - get_viewport().canvas_transform.origin
	
	
	var transparency = 130
	match type:
		0:
			transition.set_color(Color8(0, 0, 255, transparency))
			
		1:
			transition.set_color(Color8(0, 255, 0, transparency))
			
		2:
			transition.set_color(Color8(255, 0, 0, transparency))
			
	
	
	transition.connect("done", backBuffer, "queue_free")
	
	transition.connect("done", battleBG, "set", ["layer", 1])

	queuedBattle = false



func update_enemy_ids():
	for enemy in onScreenEnemies:
		if enemy[1].has_method("updateId"):
			enemy[1].updateId(onScreenEnemies.find(enemy))

func add_to_canvas(node, layer = 0):
	stableCanvasLayer.add_child(node)
	if layer != - 1:
		stableCanvasLayer.move_child(node, layer)

func load_battle_bgs():
	var dir = Directory.new()
	var path = "res://Graphics/Battle BGS/"
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				
				if file_name.ends_with(".bbg.import"):
					battleBGs[file_name.replace(".bbg.import", "")] = load(path + file_name.replace(".import", ""))
				elif file_name.ends_with(".dsp.import"):
					battleBGs[file_name.replace(".dsp.import", "")] = load(path + file_name.replace(".import", ""))
			file_name = dir.get_next()

func reset_battle_cutscenes():
	battleFleeCutscene = ""
	battleLoseCutscene = ""
	battleWinCutscene = ""
	battleWinFlag = ""
	battleLoseHeal = ""

func scene_changed():
	if check_keys(global.currentScene.name) <= 0:
		key.close()
	else :
		key.open()

func open_shop(shop):
	var shopui = shopNode.instance()
	shopui.shopJsonName = shop
	commandsMenuActive = false
	add_ui(shopui)

func open_atm():
	var atmui = atmMenuNode.instance()
	commandsMenuActive = false
	add_ui(atmui)

func open_save():
	var saveui = saveNode.instance()
	commandsMenuActive = false
	saveui.state = 1
	saveui.index = globaldata.saveFile
	add_ui(saveui)

func set_telepathy_effect(enabled, object = global.persistPlayer):
	if enabled:
		fade.focus_object(object)
		fade.set_color(Color(0, 0, 0, 0.5))
		fade.set_cut(0.1, 0.3, 1, Tween.EASE_OUT)
		fade.set_spin(true, 0.5)
	else :
		fade.set_cut(1, 0.3, 1, Tween.EASE_IN)
		yield (fade, "cut_done")
		print("DONE")
		fade.set_spin(false)

func create_flying_num(text, targetPos):
	var flyingNumTscn = load("res://Nodes/Ui/Battle/FlyingNumber.tscn")
	var flyingNum = flyingNumTscn.instance()
	flyingNum.text = str(text)
	global.currentScene.add_child(flyingNum)
	flyingNum.rect_position = targetPos - Vector2(16, 0)
	flyingNum.run()

func clearOnScreenEnemies():
	onScreenEnemies.clear()

func game_over():
	audioManager.play_sfx(load("res://Audio/Sound effects/PartyLose.mp3"), "PartyLose")
	var gameOver = gameover.instance()
	uiManager.add_ui(gameOver)
	yield (gameOver, "fade_done")
