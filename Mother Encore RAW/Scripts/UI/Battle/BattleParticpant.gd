extends Object




var id: = 0
var onScreenId: = 0
var isEnemy: = false
var filename: = ""
var defending: = false
var bashAnim: = "bash"

var stats: = {}
var statMods: = {
	"speed":0, 
	"offense":0, 
	"defense":0, 
	"iq":0, 
	"guts":0, 
}

var overworldObj:Node
var transitionSprite:Sprite
var battleSprite:Control


var partyInfo:Control = null
var statusBubble:Control = null

func select():
	if isEnemy:
		battleSprite.select()
	else :
		partyInfo.select()

func deselect():
	if isEnemy:
		battleSprite.deselect()
	else :
		partyInfo.deselect()

func isConscious():
	return not stats.status.has(globaldata.ailments.Unconscious)

func defeat():
	
	stats.status = [globaldata.ailments.Unconscious]
	if not isEnemy:
		partyInfo.modulate = Color(0.4, 0.4, 0.4)
		battleSprite.hideAway()
	else :
		if statusBubble:
			statusBubble.hide()
		var boss = false
		if stats.has("boss"):
			if stats["boss"]:
				boss = true
		battleSprite.defeat(boss)
		
		if overworldObj != null:
			if overworldObj.get("keepAfterBattle") != null:
				if not overworldObj.keepAfterBattle:
					overworldObj.die()
			else :
				overworldObj.die()

func set_overworldObj_null():
	overworldObj = null

func hasStatus(status):
	return stats.status.has(status)

func setStatus(status, on):
	if on:
		if statusBubble:
			statusBubble.add_status(status)
		stats.status.append(status)
	else :
		if statusBubble:
			statusBubble.remove_status(status)
		stats.status.erase(status)

func get_base_stat(stat:String):
	return stats[stat] + stats.boosts[stat]

func get_stat(stat:String):
	var baseStat = get_base_stat(stat)
	if stat in statMods:
		return baseStat + max(3, floor(baseStat / 8)) * statMods[stat]
	else :
		return baseStat

func add_stat_mod(stat:String, mod:float):
	if stat in statMods:
		statMods[stat] += mod

func reset_stat_mod(stat:String):
	if stat in statMods:
		statMods[stat] = 0

func reset_all_stat_mods():
	for stat in statMods:
		reset_stat_mod(stat)

func hp_stopped_scrolling():
	stats.hp = partyInfo.HP

func pp_stopped_scrolling():
	stats.pp = partyInfo.PP









