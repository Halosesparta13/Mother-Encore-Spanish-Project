extends TextureRect


class Digit:
	func _init(_sprite):
		sprite = _sprite
	
	var sprite:Sprite
	var num = 0
	
	func set(row, fr = 0):
		sprite.frame_coords.x = wrapi(fr, 0, transitionFrames)
		num = wrapi(row, 0, 10)
		sprite.frame_coords.y = num



const ppLessBG = preload("res://Graphics/UI/Battle/PartyInfoPlate_NoPP.png")

var pName:String = "YourMom"
var maxHP: = 999
var maxPP: = 999
var HP: = 999
var DHP: = 999
var DHP_frame: = 0

onready var hunsDigitHP = Digit.new($HP_H)
onready var tensDigitHP = Digit.new($HP_T)
onready var onesDigitHP = Digit.new($HP_O)

var PP:int = 999
var DPP: = 999
var DPP_frame: = 0

onready var hunsDigitPP = Digit.new($PP_H)
onready var tensDigitPP = Digit.new($PP_T)
onready var onesDigitPP = Digit.new($PP_O)

var processHP = false
var processPP = false
var HP_timer:float = 0
var PP_timer:float = 0
var HP_increasing: = false
var PP_increasing: = false

const transitionFrames = 8
var _frameTime = 1.0 / 30.0
var scrollSpeed = 1.0
var incScrollSpeedMod = 1.0
var decScrollSpeedMod = 1.0

var tensFramePP:int
var onesFramePP:int

signal hp_scroll_done
signal pp_scroll_done



func _ready():
	$Name.text = pName
	hide_maxNum()
	connect("hp_scroll_done", self, "hide_exclamation")


func _process(delta):
	if processHP:
		_process_HP(delta)
	if processPP:
		_process_PP(delta)

func setHP(value:int, setNumbers: = false):
	HP = int(clamp(value, 0, maxHP))
	if HP == 0:
		$HPExclamation.show()
		$HPExclamation / AnimationPlayer.play("Shake")
	else :
		hide_exclamation()
	if setNumbers:
		DHP = value
		var ones = DHP % 10
		var tens = int(DHP / 10.0) % 10
		var huns = int(DHP / 100.0) % 10
		onesDigitHP.set(ones)
		tensDigitHP.set(tens)
		hunsDigitHP.set(huns)
		
		if hunsDigitHP.sprite.frame == 0:
			hunsDigitHP.sprite.hide()
			if tensDigitHP.sprite.frame == 0:
				tensDigitHP.sprite.hide()
			else :
				tensDigitHP.sprite.show()
		else :
			hunsDigitHP.sprite.show()
	else :
		
		HP_increasing = HP > DHP
		processHP = true
	print(pName, "'s HP has been set to ", value, ". (setNumbers = ", setNumbers, ")")

func setPP(value:int, setNumbers: = false):
	if maxPP == 0:
		$PP_O.hide()
		$PP_T.hide()
		$PP_H.hide()
		texture = ppLessBG
	PP = int(clamp(value, 0, maxPP))
	if setNumbers:
		DPP = value
		var ones = DPP % 10
		var tens = int(DPP / 10.0) % 10
		var huns = int(DPP / 100.0) % 10
		onesDigitPP.set(ones)
		tensDigitPP.set(tens)
		hunsDigitPP.set(huns)
		
		if hunsDigitPP.sprite.frame == 0:
			hunsDigitPP.sprite.hide()
			if tensDigitPP.sprite.frame == 0:
				tensDigitPP.sprite.hide()
			else :
				tensDigitPP.sprite.show()
		else :
			hunsDigitPP.sprite.show()
	else :
		PP_increasing = PP > DPP
		processPP = true
	print(pName, "'s PP has been set to ", value, ". (setNumbers = ", setNumbers, ")")

func _process_HP(delta):
	HP_timer += delta
	var moddedScrollSpeed
	if HP_increasing:
		moddedScrollSpeed = scrollSpeed * incScrollSpeedMod
	else :
		moddedScrollSpeed = scrollSpeed * decScrollSpeedMod
	
	
	if HP_timer >= (_frameTime / moddedScrollSpeed):
		var framesPassed = floor(HP_timer / (_frameTime / moddedScrollSpeed))
		HP_timer -= framesPassed * (_frameTime / moddedScrollSpeed)
		
		for i in framesPassed:
			
			if DHP_frame == 0 and HP == DHP:
				HP_timer = 0.0
				processHP = false
				$HPExclamation.hide()
				$HPExclamation / AnimationPlayer.stop()
				setHP(HP, true)
				emit_signal("hp_scroll_done")
				break
			
			
			var increment = 0
			if HP_increasing:
				increment = 1
			else :
				increment = - 1
			
			
			
			DHP_frame += increment
			DHP_frame = wrapi(DHP_frame, 0, transitionFrames)
			
			
			
			if (HP_increasing and DHP_frame == 0) or ( not HP_increasing and DHP_frame == 7):
				DHP += increment
			
			
			
			
			
			
			
			var ones = DHP % 10
			var tens = int(DHP / 10.0) % 10
			var huns = int(DHP / 100.0) % 10
			
			onesDigitHP.set(ones, DHP_frame)
			if ones == 9 or (ones == 0 and DHP_frame == 0):
				tensDigitHP.set(tens, DHP_frame)
				if tens == 9 or (ones == 0 and DHP_frame == 0):
					hunsDigitHP.set(huns, DHP_frame)
			
			if hunsDigitHP.sprite.frame == 0:
				hunsDigitHP.sprite.hide()
				if tensDigitHP.sprite.frame == 0:
					tensDigitHP.sprite.hide()
				else :
					tensDigitHP.sprite.show()
			else :
				hunsDigitHP.sprite.show()


func _process_PP(delta):
	PP_timer += delta
	var moddedScrollSpeed
	if PP_increasing:
		moddedScrollSpeed = scrollSpeed * incScrollSpeedMod
	else :
		moddedScrollSpeed = scrollSpeed * decScrollSpeedMod
	
	if PP_timer >= (_frameTime / moddedScrollSpeed):
		var framesPassed = floor(PP_timer / (_frameTime / moddedScrollSpeed))
		PP_timer -= framesPassed * (_frameTime / moddedScrollSpeed)
		
		for i in framesPassed:
			
			if DPP_frame == 0 and PP == DPP:
				PP_timer = 0.0
				processPP = false
				setPP(PP, true)
				emit_signal("pp_scroll_done")
				break
			
			
			var increment = 0
			if PP_increasing:
				increment = 1
			else :
				increment = - 1
			
			DPP_frame += increment
			DPP_frame = wrapi(DPP_frame, 0, transitionFrames)
			
			if (PP_increasing and DPP_frame == 0) or ( not PP_increasing and DPP_frame == 7):
				DPP += increment
			
			var ones = DPP % 10
			var tens = int(DPP / 10.0) % 10
			var huns = int(DPP / 100.0) % 10
			
			onesDigitPP.set(ones, DPP_frame)
			if ones == 9 or (ones == 0 and DPP_frame == 0):
				tensDigitPP.set(tens, DPP_frame)
				if tens == 9 or (ones == 0 and DPP_frame == 0):
					hunsDigitPP.set(huns, DPP_frame)
			
			if hunsDigitPP.sprite.frame == 0:
				hunsDigitPP.sprite.hide()
				if tensDigitPP.sprite.frame == 0:
					tensDigitPP.sprite.hide()
				else :
					tensDigitPP.sprite.show()
			else :
				hunsDigitPP.sprite.show()

func set_poisoned():
	$HP_H.modulate = Color("ebbaff")
	$HP_T.modulate = Color("ebbaff")
	$HP_O.modulate = Color("ebbaff")

func set_cured_poison():
	$HP_H.modulate = Color.white
	$HP_T.modulate = Color.white
	$HP_O.modulate = Color.white

func show_maxNum():
	$BasicPlate / MaxHP.text = str(HP) + "/" + str(maxHP)
	$BasicPlate / MaxHP.show()
	if maxPP > 0:
		$BasicPlate / MaxPP.text = str(PP) + "/" + str(maxPP)
		$BasicPlate / MaxPP.show()
	$BasicPlate.show()

func hide_maxNum():
	$BasicPlate.hide()
	$BasicPlate / MaxHP.hide()
	$BasicPlate / MaxPP.hide()

func stopScrolling():
	
	DHP = get_current_HP()
	if DHP == 0:
		DHP = 1
	processHP = false
	$HPExclamation.hide()
	$HPExclamation / AnimationPlayer.stop()
	setHP(DHP, true)
	emit_signal("hp_scroll_done")
	emit_signal("pp_scroll_done")


func hide_exclamation():
	$HPExclamation.hide()
	$HPExclamation / AnimationPlayer.stop()

func quake(delay = 0, intensity = 1):
	var offset = 8 * intensity
	$Tween.reset_all()
























	$Tween.interpolate_property(self, "rect_position:y", rect_position.y, rect_position.y + offset, 0.05, Tween.TRANS_LINEAR, Tween.EASE_OUT, delay)
	$Tween.interpolate_property(self, "rect_position:y", rect_position.y + offset, rect_position.y - offset, 0.1, Tween.TRANS_QUAD, Tween.EASE_OUT, delay + 0.05)
	$Tween.interpolate_property(self, "rect_position:y", rect_position.y - offset / 2, rect_position.y + offset / 2, 0.1, Tween.TRANS_QUAD, Tween.EASE_OUT, delay + 0.15)
	$Tween.interpolate_property(self, "rect_position:y", rect_position.y + offset / 2, rect_position.y - offset / 2, 0.1, Tween.TRANS_QUAD, Tween.EASE_OUT, delay + 0.25)
	$Tween.interpolate_property(self, "rect_position:y", rect_position.y - offset / 2, rect_position.y, 0.15, Tween.TRANS_QUAD, Tween.EASE_OUT, delay + 0.35)
	$Tween.start()




















func select():
	$Highlight.show()

func deselect():
	$Highlight.hide()
	$Name.add_color_override("font_color", Color.black)

func get_current_HP():
	return DHP + min(DHP_frame, 1)

