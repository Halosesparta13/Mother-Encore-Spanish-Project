extends Control

onready var itemSprite = $ColorRect / CenterContainer / TextureRect / Item
onready var descLabel = $ColorRect / CenterContainer2 / Desc


func setItem(itemName):
	if itemName == null:
		hide()
		return 
	else :
		show()
	var item
	if itemName in globaldata.items:
		item = globaldata.items[itemName]
	else :
		setText("")
		itemSprite.texture = null
		return 
	
	setText(item.description.english)
	
	var itemImage = load("res://Graphics/Objects/Items/" + itemName + ".png") as StreamTexture
	if itemImage:
		itemSprite.texture = itemImage
	else :
		itemSprite.texture = null

func setText(text):
	descLabel.text = text
