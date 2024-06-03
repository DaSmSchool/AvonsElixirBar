extends Node
class_name GameStatus

static var powderScene = load("res://scenes/Objects/Powder/Powder.tscn")
static var crystalScene = load("res://scenes/Objects/Crystal/Crystal.tscn")
static var bottleScene = load("res://scenes/Objects/Bottle/Bottle.tscn")

static var availableItems : Array[Item] = []

static var essentialItems : Array[Item] = [
	bottleScene.instantiate()
]

##Pool of items that are used as templates for the available items
var iterableScenes : Array[PackedScene] = [
	crystalScene
]

var itemAmnt = 2

var currentDay = 1

func _ready():
	init_available_items()
	print(availableItems)


func _process(delta):
	pass
	#print(Item.holdingItem)


func get_random_item() -> Item:
	var chosenItem : Item = iterableScenes.pick_random().instantiate()
	chosenItem.generate_random()
	return chosenItem


func init_available_items():
	availableItems.append_array(essentialItems)
	for itemItr in itemAmnt:
		availableItems.append(get_random_item())

func update_available_items():
	print(availableItems.size())
	print(itemAmnt)
	print(essentialItems.size())
	if availableItems.size() < itemAmnt + essentialItems.size():
		for itr in (itemAmnt + essentialItems) - availableItems.size():
			availableItems.append(get_random_item())
