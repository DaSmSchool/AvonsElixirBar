extends Control
class_name CookbookMenu

var currentPageSet : int = 0

static var storedPages : Array[CookbookPage] = []
static var focusPage : CookbookPage
static var focusRecipe : Recipe
static var pageTemplate = preload("res://scenes/Functional/HUD/CookbookMenu/page_template.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


static func generate_pages():
	var currentPage = 0
	
	for recipe : Recipe in Recipe.recipeList:
		focusRecipe = recipe
		shift_page(true)
		
		
		traverse_item_tree(recipe.finalItem)
		

static func shift_page(newRecipe : bool):
	var writingPage : CookbookPage = pageTemplate.instantiate()
	storedPages.append(writingPage)
	if newRecipe:
		var recipeLines : Control = writingPage.get_node("RecipeLines")
		var recipeTitle : RichTextLabel = writingPage.get_node("RecipeTitle")
		recipeTitle.show()
		recipeTitle.text = focusRecipe.potionName
		
		var recipeIngredients : RichTextLabel = writingPage.get_node("IngredientsList")
		recipeIngredients.show()
		recipeIngredients.position.y = recipeTitle.position.y + recipeTitle.scale.y
		recipeIngredients.text += focusRecipe.get_init_ingredient_text(focusRecipe.initIngredientsNeeded)
		
		
		recipeLines.position.y = recipeIngredients.position.y + recipeIngredients.scale.y


static func add_action(item1 : Item, item2 : Item, itemAction : ItemAction):
	pass
	

static func traverse_item_tree(item : Item, contactedItems = []):
	if item in contactedItems: return
	
	if item is Bottle:
		traverse_item_tree(item.containedLiquid)
		for contItem in item.bottledItems:
			traverse_item_tree(contItem)
	
	for prevItem in item.previousItemsInvolved:
		traverse_item_tree(prevItem)
	
	for itemAction in item.itemActionsApplied:
		pass
	
	contactedItems.append(item)
	

static func get_init_ingredient_text(initItems : Array):
	var textAssemble = "\n"
	for item : Item in initItems:
		textAssemble += "  "
		textAssemble += item.display_name()
		textAssemble += "\n"
	return textAssemble
