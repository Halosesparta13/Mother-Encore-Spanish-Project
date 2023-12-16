extends Control

var portraitSprites = {
	"ninten":preload("res://Graphics/UI/Inventory/characters/ninten.png"), 
	"ana":preload("res://Graphics/UI/Inventory/characters/ana.png"), 
	"lloyd":preload("res://Graphics/UI/Inventory/characters/lloyd.png"), 
	"teddy":preload("res://Graphics/UI/Inventory/characters/teddy.png"), 
	"pippi":preload("res://Graphics/UI/Inventory/characters/pippi.png"), 
	"flyingman":preload("res://Graphics/UI/Inventory/characters/flyingman.png"), 
	"eve":preload("res://Graphics/UI/Inventory/characters/eve.png"), 
	"canarychick":preload("res://Graphics/UI/Inventory/characters/canarychick.png"), 
}

var hlportraitSprites = {
	"ninten":preload("res://Graphics/UI/Inventory/characters/ninten_hl.png"), 
	"ana":preload("res://Graphics/UI/Inventory/characters/ana_hl.png"), 
	"lloyd":preload("res://Graphics/UI/Inventory/characters/lloyd_hl.png"), 
	"teddy":preload("res://Graphics/UI/Inventory/characters/teddy_hl.png"), 
	"pippi":preload("res://Graphics/UI/Inventory/characters/pippi_hl.png"), 
	"flyingman":preload("res://Graphics/UI/Inventory/characters/flyingman_hl.png"), 
	"eve":preload("res://Graphics/UI/Inventory/characters/eve_hl.png"), 
	"canarychick":preload("res://Graphics/UI/Inventory/characters/canarychick_hl.png")
}

const cursorCloseSfx = preload("res://Audio/Sound effects/M3/curshoriz.wav")
const registerSfx = preload("res://Audio/Sound effects/M3/register.wav")


onready var descNoDialog = $DescBox / DescriptionPanel
onready var descDialog = $DescBox / DescriptionDialog
onready var shopBox = {
	"header":$ShopBox / Header, 
	"separater":$ShopBox / Separator, 
	"buy":$ShopBox / BuyMenu, 
	"sell":$ShopBox / SellMenu
}
onready var buySellCursor = $BuySellDialog / arrow
onready var descDialogCursor = $DescBox / DescriptionDialog / arrow
onready var characterPortraits = $CharacterSelect / CharacterPortraits


var _currentCharacter
var _selectedItem
var _prevEquip
var _characterOrder = ["ninten", "llyod", "ana", "teddy", "pippi", "flyingman", "eve", "canarychick"]
var _characterIdx = 0



var shopJsonName = ""
var shopList = []

var currentInv = []

var descInput = false
var descDialogState = - 1
enum DialogState{
	BUY, 
	EQUIP_BOUGHT, 
	SELL_OLD_EQUIP, 
	SELL_EQUIP_NO_SPACE, 
	SELL_FOR_CASH, 
	SELL, 
}




















func _ready():
	buySellCursor.connect("selected", self, "_on_buysell_select")
	buySellCursor.connect("cancel", self, "_on_arrow_cancel")
	shopBox.buy.connect("exited", self, "_on_exit_buy")
	shopBox.buy.connect("entered", self, "_on_enter_buy")
	shopBox.buy.connect("moved", self, "_on_buy_cursor_moved")
	shopBox.buy.connect("selected", self, "_on_buy_item_selected")
	shopBox.sell.connect("exited", self, "_on_exit_sell")
	shopBox.sell.connect("entered", self, "_on_enter_sell")
	shopBox.sell.connect("moved", self, "_on_sell_cursor_moved")
	shopBox.sell.connect("selected", self, "_on_sell_item_selected")
	descDialogCursor.connect("selected", self, "_on_desc_dialog_select")
	descDialogCursor.connect("cancel", self, "_on_desc_dialog_cancel")
	
	
	_characterOrder.clear()
	for partyMem in global.party:
		_characterOrder.append(partyMem.name)
	
	
	if shopJsonName in globaldata.shopLists:
		shopList = globaldata.shopLists[shopJsonName]
		shopBox.buy.itemList = shopList
		
	
	enter_buysell()
	
	$BuySellDialog / VBoxContainer / YesLabel.highlight(1)
	changeCharacter(0)
	_update_cash()

func _input(event):
	if event.is_action_pressed("ui_focus_next"):
		get_tree().set_input_as_handled()
		if not descDialogCursor.on:
			changeCharacter(1)
	elif event.is_action_pressed("ui_focus_prev"):
		get_tree().set_input_as_handled()
		if not descDialogCursor.on:
			changeCharacter( - 1)

func close():
	if uiManager.dialogueBox:
		uiManager.dialogueBox.call_deferred("next_dialog")
		queue_free()

func _update_cash():
	$ShopBox / Header / CashBox / Label.text = str(globaldata.cash).pad_zeros(6)
	
	shopBox.buy.restrictions.clear()
	
	for itemName in shopList:
		if itemName in globaldata.items:
			if InventoryManager.isInventoryFull(_currentCharacter.name) or globaldata.items[itemName].cost > globaldata.cash:
				shopBox.buy.restrictions.append(itemName)

func enter_buysell():
	
	$DescBox.hide()
	descDialog.hide()
	descNoDialog.hide()
	shopBox.separater.hide()
	shopBox.buy.hide()
	shopBox.sell.hide()
	_selectedItem = ""
	_prevEquip = ""
	updatePortraits()
	buySellCursor.on = true

func enter_buy(reset = true):
	
	buySellCursor.set_cursor_from_index(0, false)
	buySellCursor.on = false
	$DescBox.show()
	descNoDialog.show()
	shopBox.separater.show()
	shopBox.buy.enter(reset)
	descNoDialog.setItem(shopBox.buy.get_current_item())
	updatePortraits(shopBox.buy.get_current_item())

func enter_sell(reset = true):
	
	buySellCursor.set_cursor_from_index(1, false)
	buySellCursor.on = false
	shopBox.sell.itemList.clear()
	var inv = InventoryManager.getInventory(_currentCharacter.name)
	for item in inv:
		var itemData = globaldata.items[item.ItemName]
		if itemData.value <= 0:
			shopBox.sell.restrictions.append(item.ItemName)
		shopBox.sell.itemList.append(item.ItemName)
	$DescBox.show()
	descNoDialog.show()
	shopBox.separater.show()
	shopBox.sell.enter(reset)
	descNoDialog.setItem(shopBox.sell.get_current_item())
	updatePortraits(shopBox.sell.get_current_item())

func enter_desc_dialog(state:int):
	$DescBox / DescriptionDialog / YesNoDialog.get_child(0).highlight(1)
	$DescBox / DescriptionDialog / YesNoDialog.get_child(1).highlight(0)
	descDialogState = state
	descDialogCursor.on = true
	descDialog.show()
	if _selectedItem == "":
		_selectedItem = "error"
	descDialog.setItem(_selectedItem)
	var item = globaldata.items[_selectedItem]
	match (state):
		DialogState.BUY:
			descDialog.setText("Buy %s %s?" % [item.article.english, item.name.english])
		DialogState.EQUIP_BOUGHT:
			descDialog.setText("Equip now?")
		DialogState.SELL_OLD_EQUIP:
			item = globaldata.items[_prevEquip]
			descNoDialog.setItem(_prevEquip)
			descDialog.setText("Sell your old %s?" % item.name.english)
		DialogState.SELL:
			descDialog.setText("Sell your %s?" % item.name.english)
		DialogState.SELL_EQUIP_NO_SPACE:
			item = globaldata.items[_prevEquip]
			descNoDialog.setItem(_prevEquip)
			descDialog.setText("Your inventory is full.\nSell %s?" % item.name.english)
		DialogState.SELL_FOR_CASH:
			descDialog.setText("You don't have enough cash.\nSell something?")

func desc_dialog_answer(yes:bool):
	descDialogCursor.on = false
	descDialog.hide()
	if _selectedItem == "":
		_selectedItem = "error"
	var item = globaldata.items[_selectedItem]
	match (descDialogState):
		DialogState.BUY:
			if yes:
				buy_something()
				if InventoryManager.doesItemHaveFunction(_selectedItem, "equip") and checkCanEquip(_selectedItem, _currentCharacter):
					
					enter_desc_dialog(DialogState.EQUIP_BOUGHT)
					return 
			
			enter_buy(false)
		DialogState.EQUIP_BOUGHT:
			if yes:
				_prevEquip = _currentCharacter["equipment"][item.slot]
				
				var recentItem = InventoryManager.getInventory(_currentCharacter.name).back()
				InventoryManager.equipItemFromUID(_currentCharacter, recentItem.uid)
				audioManager.play_sfx(load("res://Audio/Sound effects/M3/equip.wav"), "menu")
				if _prevEquip != "":
					enter_desc_dialog(DialogState.SELL_OLD_EQUIP)
					return 
			enter_buy(false)
		DialogState.SELL_OLD_EQUIP:
			if yes:
				sell_something(_prevEquip)
			_prevEquip = ""
			enter_buy(false)
		DialogState.SELL:
			if yes:
				sell_something()
			enter_sell(false)
		DialogState.SELL_EQUIP_NO_SPACE:
			if yes:
				
				var inv = InventoryManager.getInventory(_currentCharacter.name)
				var idx = - 1
				for i in inv.size():
					if inv[i].ItemName == _prevEquip and inv[i].equiped:
						idx = i
				sell_something(_prevEquip, idx)
				enter_desc_dialog(DialogState.BUY)
				_prevEquip = ""
				return 
			_prevEquip = ""
			enter_buy(false)
		DialogState.SELL_FOR_CASH:
			if yes:
				shopBox.buy.exit()
				enter_sell()
			else :
				enter_buy(false)

func buy_something():
	$AudioStreamPlayer.stream = registerSfx
	$AudioStreamPlayer.play()
	var item = globaldata.items[_selectedItem]
	globaldata.cash -= item.cost
	var itemIdx = InventoryManager.getInventory(_currentCharacter.name)
	InventoryManager.addItem(_currentCharacter.name, _selectedItem)
	
	_update_cash()

func sell_something(item_name = _selectedItem, idx = - 1):
	$AudioStreamPlayer.stream = registerSfx
	$AudioStreamPlayer.play()
	var item = globaldata.items[item_name]
	globaldata.cash += item.value
	if item_name == _prevEquip:
		InventoryManager.dropItem(_currentCharacter.name, InventoryManager.findItemIdx(_currentCharacter.name, item_name))
	else :
		if idx > 0:
			InventoryManager.dropItem(_currentCharacter.name, idx)
		else :
			InventoryManager.dropItem(_currentCharacter.name, shopBox.sell.cursor.cursor_index + shopBox.sell.page)
	
	_update_cash()

func updatePortraits(highlighted_item = null):
	for i in 4:
		var portraitNode = characterPortraits.get_node(str("Party", i + 1))
		if i >= _characterOrder.size():
			portraitNode.texture = null
		elif i == _characterIdx:
			portraitNode.texture = hlportraitSprites[_characterOrder[i]]
		else :
			portraitNode.texture = portraitSprites[_characterOrder[i]]
		
		
		var is_suitable = false
		var is_equiped = false
		var is_better = false
		var is_lower = false
		if i < _characterOrder.size():
			if highlighted_item and not InventoryManager.isInventoryFull(_characterOrder[i]):
				var current_item_data = globaldata.items[highlighted_item]
				var character = _characterOrder[i]
				if InventoryManager.doesItemHaveFunction(highlighted_item, "equip"):
					is_suitable = current_item_data["usable"][character]
					var current_item_slot = current_item_data["slot"]
					
					is_equiped = global.party[i]["equipment"][current_item_slot] == highlighted_item
					
					
					if not is_equiped:
						var res = InventoryManager.is_the_item_better(global.party[i], highlighted_item)
						match res:
							1:
								is_better = true
							- 1:
								is_lower = true
		is_suitable = is_suitable and not is_equiped
		portraitNode.show_is_item_suitable(is_suitable)
		portraitNode.show_is_item_equiped(is_equiped)
		portraitNode.show_is_item_better(is_better)
		portraitNode.show_is_item_lower(is_lower)

func changeCharacter(dir):
	_characterIdx = wrapi(_characterIdx + dir, 0, _characterOrder.size())
	
	for partyMem in global.party:
		if partyMem.name == _characterOrder[_characterIdx]:
			_currentCharacter = partyMem
	
	if shopBox.sell.visible:
		shopBox.sell.exit()
		buySellCursor.on = false
		enter_sell()
	
	updatePortraits()

func checkCanEquip(itemname, character):
	var itemdata = globaldata.items[itemname]
	return itemdata.usable[character.name]




func _on_buysell_select(idx):
	if idx == 0:
		enter_buy()
	else :
		enter_sell()

func _on_exit_buy():
	enter_buysell()
	$AudioStreamPlayer.stream = cursorCloseSfx
	$AudioStreamPlayer.play()

func _on_exit_sell():
	enter_buysell()
	$AudioStreamPlayer.stream = cursorCloseSfx
	$AudioStreamPlayer.play()

func _on_buy_cursor_moved(item):
	updatePortraits(item)
	descNoDialog.setItem(item)

func _on_buy_item_selected(item):
	var itemData = globaldata.items[item]
	if InventoryManager.isInventoryFull(_currentCharacter.name):
		if checkCanEquip(item, _currentCharacter) and InventoryManager.doesItemHaveFunction(item, "equip") and _currentCharacter.equipment[itemData.slot] != "":
			_prevEquip = _currentCharacter.equipment[itemData.slot]
			_selectedItem = item
			shopBox.buy.cursor.on = false
			enter_desc_dialog(DialogState.SELL_EQUIP_NO_SPACE)
	elif itemData.cost > globaldata.cash:
		_selectedItem = item
		shopBox.buy.cursor.on = false
		enter_desc_dialog(DialogState.SELL_FOR_CASH)
	else :
		_selectedItem = item
		shopBox.buy.cursor.on = false
		enter_desc_dialog(DialogState.BUY)

func _on_sell_cursor_moved(item):
	updatePortraits(item)
	descNoDialog.setItem(item)

func _on_sell_item_selected(item):
	var itemData = globaldata.items[item]
	if itemData.value <= 0:
		return 
	_selectedItem = item
	shopBox.sell.cursor.on = false
	enter_desc_dialog(DialogState.SELL)

func _on_desc_dialog_select(idx):
	
	desc_dialog_answer(idx == 0)

func _on_enter_buy():
	if shopBox.buy.itemList.empty():
		$DescBox.hide()
	else :
		$DescBox.show()

func _on_enter_sell():
	if shopBox.sell.itemList.empty():
		$DescBox.hide()
	else :
		$DescBox.show()

func _on_arrow_cancel():
	uiManager.remove_ui(self)

func _on_desc_dialog_cancel():
	desc_dialog_answer(false)
