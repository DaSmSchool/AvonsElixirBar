extends Node
class_name GameStatus

static var powderScene = preload("res://scenes/Objects/Powder/Powder.tscn")
static var crystalScene = preload("res://scenes/Objects/Crystal/Crystal.tscn")
static var bottleScene = preload("res://scenes/Objects/Bottle/Bottle.tscn")
static var featherScene = preload("res://scenes/Objects/Feather/Feather.tscn")

static var availableItems : Array[Item] = []

static var essentialItems : Array[Item] = [
	bottleScene.instantiate()
]

##Pool of items that are used as templates for the available items
var iterableScenes : Array[PackedScene] = [
	crystalScene,
	featherScene
]

var itemAmnt = 3

var currentDay = 1
var recipePerDay = 2

func _ready():
	init_available_items()
	print(availableItems)
	generate_recipes()
	

func generate_recipes():
	var recipeCount = currentDay * recipePerDay
	for currRecipeItr in recipeCount - Recipe.recipeList.size():
		var currRecipe = Recipe.generate_potion_recipe(floor(randf_range(0, 2.25)) as int)
		Recipe.recipeList.append(currRecipe)
		print("\n\nRecipe Printing time!\n\n")
		Recipe.print_recipe(currRecipe.finalItem)
		print("\n\nPrinting Time over!\n\n")

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
