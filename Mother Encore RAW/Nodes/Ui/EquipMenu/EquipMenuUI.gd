extends CanvasLayer

signal back


onready var boost_icon_empty = preload("res://Graphics/UI/EquipMenu/empty.png")
onready var boost_icon_bonus = preload("res://Graphics/UI/EquipMenu/red_arrow.png")
onready var boost_icon_malus = preload("res://Graphics/UI/EquipMenu/blue_arrow.png")

var soundEffects = {
	"back":load("res://Audio/Sound effects/M3/curshoriz.wav"), 
	"cursor2":load("res://Audio/Sound effects/Cursor 2.mp3"), 
	"cursor1":load("res://Audio/Sound effects/Cursor 1.mp3")
}

	

const stats = [
	"maxhp", 
	"maxpp", 
	"speed", 
	"offense", 
	"defense", 
	"iq", 
	"guts"
]
	
	

onready var item_label_template = preload("res://Nodes/Ui/HighlightLabel.tscn")


onready var SelectPanel = $EquipMenu / InventorySelect
onready var SlotArrow = $EquipMenu / Slots / EquippeditemsNames / SlotArrow
onready var ItemArrow = $EquipMenu / Slots / ItemListPanel / ItemArrow
onready var ItemPanel = $EquipMenu / Slots / ItemListPanel
onready var ItemPanelList = $EquipMenu / Slots / ItemListPanel / ItemList
onready var Description = $EquipMenu / Description / DescriptionPanel
onready var BoostStatsValueElements = {
					"maxhp":$EquipMenu / Stats / BoostStatsValue / MaxHPValue, 
					"maxpp":$EquipMenu / Stats / BoostStatsValue / MaxPPValue, 
					"offense":$EquipMenu / Stats / BoostStatsValue / OffenseValue, 
					"defense":$EquipMenu / Stats / BoostStatsValue / DefenseValue, 
					"iq":$EquipMenu / Stats / BoostStatsValue / IQValue, 
					"speed":$EquipMenu / Stats / BoostStatsValue / SpeedValue, 
					"guts":$EquipMenu / Stats / BoostStatsValue / GutsValue
					}
onready var BoostIconsElements = {
					"maxhp":$EquipMenu / Stats / BoostIcons / MaxHPIcon, 
					"maxpp":$EquipMenu / Stats / BoostIcons / MaxPPIcon, 
					"offense":$EquipMenu / Stats / BoostIcons / OffenseIcon, 
					"defense":$EquipMenu / Stats / BoostIcons / DefenseIcon, 
					"iq":$EquipMenu / Stats / BoostIcons / IQIcon, 
					"speed":$EquipMenu / Stats / BoostIcons / SpeedIcon, 
					"guts":$EquipMenu / Stats / BoostIcons / GutsIcon
					}
					
var current_character = globaldata.ninten
var current_slot = InventoryManager.slots[0]
var itemList = []


var item_selection = false


var pause_description_update = false


var active = false setget _setActive
func _setActive(val):
	active = val
	SelectPanel.active = val
	
func _physics_process(delta):
	if active:
		_inputs()
		update_slots()
		if not pause_description_update:
			update_description()
			_update_portraits()
		update_stats()


func update_description():
	if item_selection:
		var selected_item = itemList[ItemArrow.cursor_index]
		
		if selected_item != "None":
			Description.Set_item(selected_item)
		else :
			Description.Set_item("")
	else :
		
		var selected_item = current_character["equipment"][InventoryManager.slots[SlotArrow.cursor_index]]
		if selected_item != "______":
			Description.Set_item(selected_item)
		else :
			Description.Set_item("")
		



func update_stats():
	$EquipMenu / Stats / StatsLabels / CharacterName.text = current_character["nickname"]
	$EquipMenu / Stats / StatsValue / LevelValue.text = str(current_character["level"])
	$EquipMenu / Stats / StatsValue / MaxHPValue.text = str(current_character["maxhp"] + current_character["boosts"]["maxhp"])
	$EquipMenu / Stats / StatsValue / MaxPPValue.text = str(current_character["maxpp"] + current_character["boosts"]["maxpp"])
	$EquipMenu / Stats / StatsValue / OffenseValue.text = str(current_character["offense"] + current_character["boosts"]["offense"])
	$EquipMenu / Stats / StatsValue / DefenseValue.text = str(current_character["defense"] + current_character["boosts"]["defense"])
	$EquipMenu / Stats / StatsValue / IQValue.text = str(current_character["iq"] + current_character["boosts"]["iq"])
	$EquipMenu / Stats / StatsValue / SpeedValue.text = str(current_character["speed"] + current_character["boosts"]["speed"])
	$EquipMenu / Stats / StatsValue / GutsValue.text = str(current_character["guts"] + + current_character["boosts"]["guts"])
	
	$EquipMenu / Stats / BoostIcons / MaxHPIcon.texture_normal = boost_icon_empty
	
	for icon in BoostIconsElements.values():
		icon.texture_normal = boost_icon_empty
	
	if item_selection:
		var current_item_name = itemList[ItemArrow.cursor_index]
		var uid = ItemArrow.get_menu_item_at_index(ItemArrow.cursor_index).uid
		var item_data = InventoryManager.Load_item_data(current_item_name)
		
		if current_item_name != "":
			
			var item = InventoryManager.getItemFromUID(current_character["name"], uid)
			var current_boost = InventoryManager.calculate_stats_boost_from_slot(current_character, InventoryManager.slots[current_slot])
			
			if not item.equiped:
				
				var item_boost = item_data["boost"]
				for stat in stats:
					
					var projected_value = 0
					if item_boost.has(stat):
						projected_value = current_character[stat] + current_character["boosts"][stat] - current_boost[stat] + item_boost[stat]
					
						if projected_value == 0 or projected_value == current_character[stat] + current_character["boosts"][stat]:
							BoostStatsValueElements[stat].text = ""
							BoostIconsElements[stat].texture_normal = boost_icon_empty
						else :
							BoostStatsValueElements[stat].text = str(projected_value)
							
							if projected_value > current_character[stat] + current_character["boosts"][stat]:
								BoostIconsElements[stat].texture_normal = boost_icon_bonus
							elif projected_value < current_character[stat] + current_character["boosts"][stat]:
								BoostIconsElements[stat].texture_normal = boost_icon_malus
							else :
								BoostIconsElements[stat].texture_normal = boost_icon_empty
			else :
				for stat in stats:
					BoostStatsValueElements[stat].text = ""
					BoostIconsElements[stat].texture_normal = boost_icon_empty
		else :
			
			var item_name = current_character["equipment"][InventoryManager.slots[current_slot]]
			var current_boost = InventoryManager.calculate_stats_boost_from_slot(current_character, InventoryManager.slots[current_slot])
			
			for stat in stats:
				
				var projected_value = current_character[stat] + current_character["boosts"][stat] - current_boost[stat]
					
				if projected_value == 0 or projected_value == current_character[stat] + current_character["boosts"][stat]:
					BoostStatsValueElements[stat].text = ""
					BoostIconsElements[stat].texture_normal = boost_icon_empty
				else :
					BoostStatsValueElements[stat].text = str(projected_value)
						
					if projected_value > current_character[stat] + current_character["boosts"][stat]:
						BoostIconsElements[stat].texture_normal = boost_icon_bonus
					elif projected_value < current_character[stat] + current_character["boosts"][stat]:
						BoostIconsElements[stat].texture_normal = boost_icon_malus
					else :
						BoostIconsElements[stat].texture_normal = boost_icon_empty
	else :
		for stat in stats:
			BoostStatsValueElements[stat].text = ""
			BoostIconsElements[stat].texture_normal = boost_icon_empty


func update_slots():
	var index = 0
	var equipment = current_character["equipment"]
	var slots_texts = $EquipMenu / Slots / EquippeditemsNames.get_children()
	
	for i in slots_texts.size() - 1:
		slots_texts[i].text = "______"
	
	for piece in equipment.values():
		if piece != "":
			match InventoryManager.Load_item_data(piece)["slot"]:
				"weapon":
					index = 0
				"body":
					index = 1
				"head":
					index = 2
				"other":
					index = 3
			slots_texts[index].text = InventoryManager.Load_item_data(piece)["name"][globaldata.language]



func Show_equipMenu(party_member):
	$AnimationPlayer.play("Open")
	current_character = party_member
	SelectPanel.InitFromCharacter(current_character["name"])
	update_stats()
	
	active = true
	SelectPanel.visible = true
	SlotArrow.on = true
	SlotArrow.cursor_index = 0
	SlotArrow.set_cursor_from_index(0, false)
	

func _inputs():
	if Input.is_action_just_pressed(("ui_accept")):
		Input.action_release("ui_accept")
		if item_selection:
			
			if ItemArrow.get_menu_item_at_index(ItemArrow.cursor_index).text == "None":
				InventoryManager.unequip_slot(current_character, InventoryManager.slots[current_slot])
				audioManager.play_sfx(load("res://Audio/Sound effects/EB/close.wav"), "menu")
			else :
				InventoryManager.equipItemFromUID(current_character, ItemArrow.get_menu_item_at_index(ItemArrow.cursor_index).uid)
				audioManager.play_sfx(load("res://Audio/Sound effects/M3/equip.wav"), "menu")
			update_stats()
			item_selection = false
			SlotArrow.on = true
			ItemPanel.visible = false
			ItemArrow.on = false
			$EquipMenu / InventorySelect.inhibit_chara_change = false
			pass
		else :
			pause_description_update = true
			item_selection = true
			$EquipMenu / InventorySelect.inhibit_chara_change = true
			current_slot = SlotArrow.cursor_index
			show_items_for_slot(current_character["name"], InventoryManager.slots[current_slot])
			pause_description_update = false
			SlotArrow.on = false
			ItemArrow.cursor_index = 0
			ItemArrow.on = true
			ItemPanel.visible = true
			
			
		
	if Input.is_action_just_pressed("ui_cancel") or Input.is_action_just_pressed("ui_toggle"):
		if item_selection:
			item_selection = false
			SlotArrow.on = true
			ItemPanel.visible = false
			ItemArrow.play_sfx("back")
			ItemArrow.on = false
			$EquipMenu / InventorySelect.inhibit_chara_change = false
			pass
		else :
			Input.action_release("ui_cancel")
			Input.action_release("ui_toggle")
			SelectPanel.visible = false
			SelectPanel.active = false
			SlotArrow.on = false
			$AnimationPlayer.play("Close")
			active = false
			emit_signal("back")
			return 
	


func _on_InventorySelect_character_changed(character):
	current_character = search_through_party(character)
	update_stats()
	




func search_through_party(character):
	for chara in global.party:
		if chara["name"] == character:
			return chara
			


func show_items_for_slot(character, slot):
	var items = InventoryManager.getItemsForSlot(character, slot)
	global.delete_children(ItemPanelList)
	itemList.clear()
	for item in items:
		var item_data = InventoryManager.Load_item_data(item.ItemName)
		var is_suitable = item_data["usable"][current_character.name]
		if is_suitable:
			var item_label = item_label_template.instance()
			itemList.append(item.ItemName)
			item_label.text = item_data["name"][globaldata.language]
			item_label.uid = item.uid
			ItemPanelList.add_child(item_label)
	
	var item_label = item_label_template.instance()
	itemList.append("")
	item_label.text = "None"
	ItemPanelList.add_child(item_label)
		

func _update_portraits():
	var selected_item
	var current_item_name
	
	if item_selection:
		selected_item = itemList[ItemArrow.cursor_index]
	else :
		selected_item = current_character["equipment"][InventoryManager.slots[SlotArrow.cursor_index]]
	if not selected_item in ["None", "______", ""]:
		
		current_item_name = selected_item
	else :
		
		for character in global.party:
			var is_suitable = false
			var is_equiped = false
			var is_better = false
			var is_lower = false
			var chara_nam = character["name"].to_lower()
			SelectPanel.Update_portrait_modifiers(chara_nam, is_suitable, is_equiped, is_better, is_lower)
		return 
			
	
	
	for character in global.party:
		var is_suitable = false
		var is_equiped = false
		var is_better = false
		var is_lower = false
		
		var chara_nam = character["name"].to_lower()
		
		if not (chara_nam in InventoryManager.no_inventory_characters):
			var current_item_data = InventoryManager.Load_item_data(current_item_name)
			is_suitable = current_item_data["usable"][chara_nam]
			
			if InventoryManager.doesItemHaveFunction(current_item_name, "equip"):
				var current_item_slot = current_item_data["slot"]
				is_equiped = (InventoryManager.Get_global_data(chara_nam)["equipment"][current_item_slot] == current_item_name)
				
				
				if not is_equiped:
					var res = InventoryManager.is_the_item_better(character, current_item_name)
					match res:
						1:
							is_better = true
							is_lower = false
						- 1:
							is_better = false
							is_lower = true
						0:
							is_better = false
							is_lower = false
				else :
					
					is_better = false
					is_lower = false
			else :
				
				is_equiped = false
			
			
			SelectPanel.Update_portrait_modifiers(chara_nam, is_suitable, is_equiped, is_better, is_lower)
	
