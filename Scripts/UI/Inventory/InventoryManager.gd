extends Node




const MAX_INVENTORY_SIZE = 16
const items_data_path = "res://Data/Items/"


var used_uids_tab = []


class Item:
	var ItemName = ""
	var uid = 0
	var equiped = false
	
	func _init(item_name, is_equiped, new_uid):
		ItemName = item_name
		equiped = is_equiped
		uid = new_uid
		
	static func get_uid(used_uids)->int:
		var Uid = - 1
		randomize()
		while (1):
			Uid = randi()
			if not (Uid in used_uids):
				break
		
		return Uid
		
	static func add_uid(new_uid, used_uids):
		if not (new_uid in used_uids):
			used_uids.append(new_uid)


var no_inventory_characters = [
	"canarychick", 
	"flyingman", 
	"eve"
	]



var Inventories = {
	"ninten":[
		Item.new("Bread", false, Item.get_uid(used_uids_tab)), 
		Item.new("Bread", false, Item.get_uid(used_uids_tab)), 
		Item.new("Slingshot", false, Item.get_uid(used_uids_tab)), 
		Item.new("BatWooden", false, Item.get_uid(used_uids_tab)), 
		Item.new("CourageBadge", false, Item.get_uid(used_uids_tab))
		], 
	"lloyd":[
		Item.new("Bread", false, Item.get_uid(used_uids_tab)), 
		Item.new("Bread", false, Item.get_uid(used_uids_tab)), 
		Item.new("Bread", false, Item.get_uid(used_uids_tab)), 
		], 
	"ana":[
		Item.new("Bread", false, Item.get_uid(used_uids_tab)), 
		Item.new("Bread", false, Item.get_uid(used_uids_tab)), 
		Item.new("Bread", false, Item.get_uid(used_uids_tab)), 
		], 
	"teddy":[
		Item.new("Bread", false, Item.get_uid(used_uids_tab)), 
		Item.new("Bread", false, Item.get_uid(used_uids_tab)), 
		Item.new("Bread", false, Item.get_uid(used_uids_tab)), 
		Item.new("Bread", false, Item.get_uid(used_uids_tab)), 
		Item.new("Bread", false, Item.get_uid(used_uids_tab)), 

	], 
	"pippi":[], 
	"canarychick":[], 
	"flyingman":[], 
	"key":[
		Item.new("CashCard", false, Item.get_uid(used_uids_tab)), 
		]
}



func _load_inventories(serialized_inv):
	for inventory in serialized_inv.keys():
		var inv_content = []
		for serialized_item in serialized_inv[inventory]:
			inv_content.append(Item.new(serialized_item["ItemName"], serialized_item["equiped"], int(serialized_item["uid"])))
			Item.add_uid(int(serialized_item["uid"]), used_uids_tab)
			
		Inventories[inventory] = inv_content
	

func _save_inventories():
	var serialized_inv = {}
	for inventory in Inventories.keys():
		var inv_content = []
		for item in Inventories[inventory]:
			var serialised_item = {"ItemName":item.ItemName, "equiped":item.equiped, "uid":item.uid}
			inv_content.append(serialised_item)
		serialized_inv[inventory] = inv_content
	return serialized_inv


func addItem(character, item):
	if character in Inventories.keys():
		Inventories[character].append(Item.new(item, false, Item.get_uid(used_uids_tab)))
	
	

func dropItem(character, item_idx):
	if character in Inventories.keys():
		var inventory = Inventories[character]
		if inventory[item_idx].equiped == true:
			var chara_data = Get_global_data(character)
			var item_name = inventory[item_idx].ItemName
			removeBoost(character, item_name)
			var item_data = Load_item_data(item_name)
			if chara_data["equipment"][item_data["slot"]] != "":
				chara_data["equipment"][item_data["slot"]] = ""
			
		inventory.remove(item_idx)
		

func getInventory(character)->Array:
	return Inventories[character]


func getItemsForSlot(character, slot)->Array:
	var sortedItems = []
	var inv = Inventories[character]
	for item in inv:
		var item_data = Load_item_data(item.ItemName)
		if item_data.has("slot"):
			if item_data["slot"] == slot:
				if item.equiped == false:
					sortedItems.append(item)
	return sortedItems
	

func getItemFromUID(character, uid):
	var inv = Inventories[character]
	for item in inv:
		if item.uid == uid:
			return item
	return - 1


func checkItemForAll(itemName):
	var characters = []
	var hasItem = false
	for i in global.party:
		characters.append(i.name)
	characters.append("key")
	for character in Inventories:
		var hasPartyMember = false
		for i in characters:
			if i == character or character == "key":
				hasPartyMember = true
		var inv = Inventories[character]
		if hasPartyMember:
			for item in inv:
				if item.ItemName == itemName:
					hasItem = true
	return hasItem

func checkItem(character, itemName):
	for item in Inventories[character]:
		if item.ItemName == itemName:
			return true
	return false


func removeItem(itemName):
	var characters = []
	for i in global.party:
		characters.append(i.name)
	characters.append("key")
	for character in Inventories:
		var hasPartyMember = false
		for i in characters:
			if i == character or character == "key":
				hasPartyMember = true
		var inv = Inventories[character]
		var id = 0
		if hasPartyMember:
			for item in inv:
				if item.ItemName == itemName:
					dropItem(character, id)
					break
				id += 1

func removeItemFromChar(character, itemName):
	var inv = Inventories[character]
	var id = 0
	for item in inv:
		if item.ItemName == itemName:
			dropItem(character, id)
			break
		id += 1


func isInventoryFull(character)->bool:
	if Inventories[character.to_lower()].size() == MAX_INVENTORY_SIZE:
		return true
	else :
		return false


func hasInventorySpace():
	var has_space = false
	for i in global.party.size():
		if not isInventoryFull(global.party[i]["name"]):
			has_space = true
	if has_space:
		return (true)
	else :
		return (false)


func giveItemAvailable(item):
	var item_given = false
	var item_data = Load_item_data(item)
	if item_data.has("keyitem"):
		if item_data["keyitem"]:
			addItem("key", item)
			item_given = true
			global.receiver = global.party[0]["nickname"]
	if not item_given and hasInventorySpace():
		for i in global.party.size():
			if not isInventoryFull(global.party[i]["name"]) and not item_given:
				addItem(global.party[i]["name"], item)
				global.receiver = global.party[i]["nickname"]
				item_given = true

func doesItemHaveFunction(item, function):
	var item_data = Load_item_data(item)
	var hasFunction = false
	if item_data["action_one"] != null:
		if item_data["action_one"]["function"] == function:
			hasFunction = true
	if item_data["action_two"] != null:
		if item_data["action_two"]["function"] == function:
			hasFunction = true
	return hasFunction


func switchItems(character, item1_idx, item2_idx):
	if character in Inventories.keys():
		var item1 = Inventories[character][item1_idx]
		var item2 = Inventories[character][item2_idx]
		
		Inventories[character][item2_idx] = item1
		Inventories[character][item1_idx] = item2
		


func swapBetweenCharacters(source, target, source_idx, target_idx):
	var item1 = Inventories[source][source_idx].ItemName
	var item2 = Inventories[target][target_idx].ItemName
	
	if Inventories[source][source_idx].equiped == true:
		unequip(source, item1)
	
	Inventories[source].remove(source_idx)
	addItem(source, item2)
	
	Inventories[target].remove(target_idx)
	addItem(target, item1)

class sort_alphabetical:
	static func sort(a, b):
		if a["ItemName"] < b["ItemName"]:
			return true
		return false

class sort_hp:
	static func sort(a, b):
		if a["ItemName"] < b["ItemName"]:
			return true
		return false


func sortAuto(character):
	var temp_array = Inventories[character]
	var temp_array2 = []
	var temp_array3 = []
	var temp_array4 = []
	
	
	
	temp_array.sort_custom(sort_alphabetical, "sort")
	
	
	for item in temp_array:
		var item_data = Load_item_data(item.ItemName)
		if ( not doesItemHaveFunction(item.ItemName, "equip")) and item_data["HPrecover"] >= 1 and item_data["boost"]["maxhp"] < 1:
			temp_array3.append(item_data["HPrecover"])
	
	
	
	temp_array3.sort()
	temp_array3.invert()
	
	for i in temp_array3:
		for item in temp_array:
			var item_data = Load_item_data(item.ItemName)
			if item_data["HPrecover"] == i and item_data["boost"]["maxhp"] < 1:
				temp_array2.append(item)
				temp_array.erase(item)
				break
	
	temp_array3.clear()
	
	
	for item in temp_array:
		var item_data = Load_item_data(item.ItemName)
		if ( not doesItemHaveFunction(item.ItemName, "equip")) and item_data["PPrecover"] >= 1 and item_data["boost"]["maxpp"] < 1:
			temp_array3.append(item_data["PPrecover"])
	
	
	temp_array3.sort()
	temp_array3.invert()
	
	for i in temp_array3:
		for item in temp_array:
			var item_data = Load_item_data(item.ItemName)
			if item_data["PPrecover"] == i and item_data["boost"]["maxpp"] < 1:
				temp_array2.append(item)
				temp_array.erase(item)
				break
	
	temp_array3.clear()
	
	
	for item in temp_array:
		var item_data = Load_item_data(item.ItemName)
		if (doesItemHaveFunction(item.ItemName, "equip") == false) and (item_data.has("battle_action")) and (item_data["HPrecover"] < 1) and (item_data["PPrecover"] < 1):
			temp_array2.append(item)
	
	
	for item in temp_array:
		var item_data = Load_item_data(item.ItemName)
		if (doesItemHaveFunction(item.ItemName, "equip") == false) and not item_data.has("battle_action") and (item_data["HPrecover"] < 1) and (item_data["PPrecover"] < 1) and (item_data["boost"]["maxhp"] == 0) and (item_data["boost"]["maxpp"] == 0) and (item_data["boost"]["offense"] == 0) and (item_data["boost"]["defense"] == 0) and (item_data["boost"]["speed"] == 0) and (item_data["boost"]["iq"] == 0) and (item_data["boost"]["guts"] == 0):
			temp_array2.append(item)
	
	
	for item in temp_array:
		var item_data = Load_item_data(item.ItemName)
		if not doesItemHaveFunction(item.ItemName, "equip") and item_data["boost"]["maxhp"] >= 1:
			temp_array2.append(item)
	
	for item in temp_array:
		var item_data = Load_item_data(item.ItemName)
		if not doesItemHaveFunction(item.ItemName, "equip") and item_data["boost"]["maxpp"] >= 1:
			temp_array2.append(item)
	
	for item in temp_array:
		var item_data = Load_item_data(item.ItemName)
		if not doesItemHaveFunction(item.ItemName, "equip") and item_data["boost"]["offense"] >= 1:
			temp_array2.append(item)
	
	for item in temp_array:
		var item_data = Load_item_data(item.ItemName)
		if not doesItemHaveFunction(item.ItemName, "equip") and item_data["boost"]["defense"] >= 1:
			temp_array2.append(item)
	
	for item in temp_array:
		var item_data = Load_item_data(item.ItemName)
		if not doesItemHaveFunction(item.ItemName, "equip") and item_data["boost"]["speed"] >= 1:
			temp_array2.append(item)
	
	for item in temp_array:
		var item_data = Load_item_data(item.ItemName)
		if not doesItemHaveFunction(item.ItemName, "equip") and item_data["boost"]["iq"] >= 1:
			temp_array2.append(item)
	
	for item in temp_array:
		var item_data = Load_item_data(item.ItemName)
		if not doesItemHaveFunction(item.ItemName, "equip") and item_data["boost"]["guts"] >= 1:
			temp_array2.append(item)
	
	
	for item in temp_array:
		var item_data = Load_item_data(item.ItemName)
		if item_data["slot"] == slots[0] and doesItemHaveFunction(item.ItemName, "equip") == true and not item.equiped:
			temp_array3.append(equipBoostTotal(item_data["boost"]))
	
	temp_array3.sort()
	temp_array3.invert()
	
	for i in temp_array3:
		for item in temp_array:
			var item_data = Load_item_data(item.ItemName)
			if equipBoostTotal(item_data["boost"]) == i and item_data["slot"] == slots[0]:
				temp_array2.append(item)
				temp_array.erase(item)
				break
	
	temp_array3.clear()
	
	
	for item in temp_array:
		var item_data = Load_item_data(item.ItemName)
		if item_data["slot"] == slots[1] and doesItemHaveFunction(item.ItemName, "equip") == true and not item.equiped:
			temp_array3.append(equipBoostTotal(item_data["boost"]))
	
	temp_array3.sort()
	temp_array3.invert()
	
	for i in temp_array3:
		for item in temp_array:
			var item_data = Load_item_data(item.ItemName)
			if equipBoostTotal(item_data["boost"]) == i and item_data["slot"] == slots[1] and not item.equiped:
				temp_array2.append(item)
				temp_array.erase(item)
				break
	
	temp_array3.clear()
	
	
	for item in temp_array:
		var item_data = Load_item_data(item.ItemName)
		if item_data["slot"] == slots[2] and doesItemHaveFunction(item.ItemName, "equip") == true and not item.equiped:
			temp_array3.append(equipBoostTotal(item_data["boost"]))
	
	temp_array3.sort()
	temp_array3.invert()
	
	for i in temp_array3:
		for item in temp_array:
			var item_data = Load_item_data(item.ItemName)
			if equipBoostTotal(item_data["boost"]) == i and item_data["slot"] == slots[2] and not item.equiped:
				temp_array2.append(item)
				temp_array.erase(item)
				break
	
	temp_array3.clear()
	
	
	for item in temp_array:
		var item_data = Load_item_data(item.ItemName)
		if item_data["slot"] == slots[3] and doesItemHaveFunction(item.ItemName, "equip") == true and not item.equiped:
			temp_array3.append(equipBoostTotal(item_data["boost"]))
	
	temp_array3.sort()
	temp_array3.invert()
	
	for i in temp_array3:
		for item in temp_array:
			var item_data = Load_item_data(item.ItemName)
			if equipBoostTotal(item_data["boost"]) == i and item_data["slot"] == slots[3] and not item.equiped:
				temp_array2.append(item)
				temp_array.erase(item)
				break
	
	temp_array3.clear()
	
	
	for item in temp_array:
		if item.equiped:
			temp_array2.append(item)
	
	Inventories[character] = temp_array2

func equipBoostTotal(item_boost):
	var total = 0
	total = int(item_boost["maxhp"] * 2 + item_boost["maxpp"] * 2 + item_boost["offense"] * 3 + item_boost["defense"] * 2 + item_boost["iq"] + item_boost["speed"] + item_boost["guts"])
	return total


func giveItem(sourceCharacter, targetCharacter, Sourceitem_idx):
	if (sourceCharacter in Inventories.keys()) and (targetCharacter in Inventories.keys()) and (sourceCharacter != targetCharacter):
		var item = Inventories[sourceCharacter][Sourceitem_idx]
		if item.equiped == true:
			unequip(sourceCharacter, item.ItemName)
		addItem(targetCharacter, item.ItemName)
		Inventories[sourceCharacter].remove(Sourceitem_idx)
		


func consumeItem(character, item_idx, receiver = ""):
	if receiver == "":
		receiver = character
	var chara_data = Get_global_data(receiver)
	var item_name = Inventories[character][item_idx].ItemName
	var item_data = Load_item_data(item_name)
	
	applyBoost(receiver, item_name)
	
	chara_data["hp"] += int(item_data["HPrecover"])
	if chara_data["hp"] > chara_data["maxhp"] + chara_data.boosts["maxhp"]:
		chara_data["hp"] = (chara_data["maxhp"] + chara_data.boosts["maxhp"])
	
	chara_data["pp"] += int(item_data["PPrecover"])
	if chara_data["pp"] > chara_data["maxpp"] + chara_data.boosts["maxpp"]:
		chara_data["pp"] = chara_data["maxpp"] + chara_data.boosts["maxpp"]
	
	
	if item_data.has("status_heals"):
		for status in item_data["status_heals"]:
			if characterHasStatus(character, globaldata.status_name_to_enum(status)):
				chara_data["status"].erase(globaldata.status_name_to_enum(status))
	
	dropItem(character, item_idx)




func characterHasStatus(character, status):
	var chara_data = Get_global_data(character)
	if chara_data["status"].has(status):
		return true
	else :
		return false


func useItem(character, item_idx):
	var chara_data = Get_global_data(character)
	var item_name = Inventories[character][item_idx].ItemName
	var item_data = Load_item_data(item_name)
	
	if item_data["transform"] != "":
		addItem(character, item_data["transform"])
	
	
	dropItem(character, item_idx)


func transformItem(character, item_idx):
	var chara_data = Get_global_data(character)
	var item_name = Inventories[character][item_idx].ItemName
	var item_data = Load_item_data(item_name)
	
	if item_data["transform"] != "":
		addItem(character, item_data["transform"])
	
	
	dropItem(character, item_idx)


func equipItem(character, item_idx):
	var chara_data = Get_global_data(character)
	var item_name = Inventories[character][item_idx].ItemName
	var item_data = Load_item_data(item_name)
	if doesItemHaveFunction(item_name, "equip") == true:
		if chara_data["equipment"][item_data["slot"]] != "":
			
			unequip(character, chara_data["equipment"][item_data["slot"]])
		chara_data["equipment"][item_data["slot"]] = item_name
		Inventories[character][item_idx].equiped = true
		applyBoost(character, item_name)
		if "passive_skills" in item_data:
			add_passives(chara_data, item_data.passive_skills)
		return true
	else :
		return false
		

func equipItemFromUID(character, uid):
	var item = getItemFromUID(character["name"], uid)
	var item_name = item.ItemName
	var item_data = Load_item_data(item_name)
	if doesItemHaveFunction(item_name, "equip") == true:
		if character["equipment"][item_data["slot"]] != "":
			
			unequip(character["name"], character["equipment"][item_data["slot"]])
		character["equipment"][item_data["slot"]] = item_name
		item.equiped = true
		applyBoost(character["name"], item_name)
		var chara_data = character
		if "passive_skills" in item_data:
			add_passives(chara_data, item_data.passive_skills)
		return true
	else :
		return false
		

func unequip(character, item_name):
	var chara_data = Get_global_data(character)
	var item_data = Load_item_data(item_name)
	chara_data["equipment"][item_data["slot"]] = ""
	if "passive_skills" in item_data:
		remove_passives(chara_data, item_data.passive_skills)
	removeBoost(character, item_name)
	for item in Inventories[character]:
		if item.ItemName == item_name:
			item.equiped = false
		

func unequip_slot(character, slot):
	var chara_data = character
	var item_name = chara_data["equipment"][slot]
	if chara_data["equipment"][slot] != "":
		chara_data["equipment"][slot] = ""
		var item_data = Load_item_data(item_name)
		if "passive_skills" in item_data:
			remove_passives(chara_data, item_data.passive_skills)
		removeBoost(character["name"], item_name)
	for item in Inventories[character["name"]]:
		if item.ItemName == item_name:
			item.equiped = false


func applyBoost(character, item_name):
	var chara_data = Get_global_data(character)
	var item_data = Load_item_data(item_name)
	var boosts = item_data["boost"]
	for boost in boosts.keys():
		if chara_data.boosts.keys().find(boost) != - 1:
			chara_data.boosts[boost] += boosts[boost]
	

func removeBoost(character, item_name):
	var chara_data = Get_global_data(character)
	var item_data = Load_item_data(item_name)
	var boosts = item_data["boost"]
	for boost in boosts.keys():
		if chara_data.boosts.keys().find(boost) != - 1:
			chara_data.boosts[boost] -= boosts[boost]


func findItemIdx(character, item_name):
	var inv = getInventory(character)
	for i in inv.size():
		if inv[i].ItemName == item_name:
			return i
	return - 1


func Load_item_data(item_name):
	if globaldata.items.has(item_name):
		return globaldata.items[item_name]
	else :
		return {}


func Get_global_data(character_name):
	var ret = null
	for chara in global.party:
		if chara["name"].to_lower() == character_name:
			return chara
	return ret


func resetInventories():
	for i in Inventories:
		Inventories[i].clear()
	addItem("key", "CashCard")





const slots = [
	"weapon", 
	"body", 
	"head", 
	"other"
]
	


func calculate_stats_boost_from_slot(character, slot):
	var boost = {
	"maxhp":0, 
	"maxpp":0, 
	"speed":0, 
	"offense":0, 
	"defense":0, 
	"iq":0, 
	"guts":0
	}

	for stat in boost.keys():
		if character["equipment"][slot] != "":
			var item_data = Load_item_data(character["equipment"][slot])
			if item_data["boost"].has(stat):
				boost[stat] += item_data["boost"][stat]
	return boost




func is_the_item_better(character, item_name):
	var item_data = Load_item_data(item_name)
	if character["equipment"][item_data["slot"]] == "":
		return 1
	else :
		
		var actual_boost = calculate_stats_boost_from_slot(character, item_data["slot"])
		
		if equipBoostTotal(actual_boost) < equipBoostTotal(item_data["boost"]):
			return 1
		elif equipBoostTotal(actual_boost) == equipBoostTotal(item_data["boost"]):
			return 0
		else :
			return - 1

func add_passives(character, passives):
	for passiveSkill in passives:
		if not passiveSkill in character.passiveSkills:
			character.passiveSkills.append(passiveSkill)

func remove_passives(character, passives):
	for passive in passives:
		character.passiveSkills.erase(passive)
