extends Control
class_name CookbookMenu

static var currentPageSet : int = 0

static var storedPages : Array[CookbookPage] = []
static var focusPage : CookbookPage
static var focusRecipe : Recipe
static var pageTemplate = preload("res://scenes/Functional/HUD/CookbookMenu/page_template.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%PageTemplate.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	handle_arrows()


func handle_arrows():
	print(storedPages.size())
	if currentPageSet == 0:
		%FlipLeft.hide()
	else:
		%FlipLeft.show()
	if currentPageSet == ((storedPages.size()-1)/2) as int:
		%FlipRight.hide()
	else:
		%FlipRight.show()

static func generate_pages():
	var currentPage = 0
	
	for recipe : Recipe in Recipe.recipeList:
		focusRecipe = recipe
		shift_page(true)
		
		
		traverse_item_tree(recipe.finalItem)
		

func switch_displayed_pages(pageChangeAmnt):
	currentPageSet += pageChangeAmnt
	
	for child in %LeftPageContents.get_children():
		%LeftPageContents.remove_child(child)
	for child in %RightPageContents.get_children():
		%RightPageContents.remove_child(child)
		
	if currentPageSet*2 < storedPages.size():
		var copyLeftPage = storedPages[(currentPageSet*2)]
		for copyChild in copyLeftPage.get_children():
			%LeftPageContents.add_child(copyChild)
			
	if (currentPageSet*2)+1 < storedPages.size():
		var copyRightPage = storedPages[(currentPageSet*2)+1]
		for copyChild in copyRightPage.get_children():
			%RightPageContents.add_child(copyChild)


static func shift_page(newRecipe : bool):
	var writingPage : CookbookPage = pageTemplate.instantiate()
	focusPage = writingPage
	storedPages.append(writingPage)
	var recipeTitle : RichTextLabel = writingPage.get_node("RecipeTitle")
	var recipeIngredients : RichTextLabel = writingPage.get_node("IngredientsList")
	var recipeLines : Control = writingPage.get_node("RecipeLines")
	if newRecipe:
		writingPage.startingPage = true
		recipeTitle.text = focusRecipe.potionName
		
		
		recipeIngredients.position.y = recipeTitle.position.y + recipeTitle.scale.y
		recipeIngredients.text += get_init_ingredient_text(focusRecipe.initIngredientsNeeded)
		
		
		recipeLines.position.y = recipeIngredients.position.y + recipeIngredients.scale.y
	else:
		writingPage.startingPage = false
		recipeLines.position.y = 0


static func add_action(itemAction : ItemAction, item1 : Item, item2 : Item = null):
	var recipeLineText = ""
	if itemAction.actionType == ItemAction.Action.GRIND:
		recipeLineText = "Grind " + item1.display_name() + " into a powder-like consistency."
	elif itemAction.actionType == ItemAction.Action.BOIL:
		recipeLineText = "Boil the bottled liquid to a simmer, and make sure not to overboil it!"
	elif itemAction.actionType == ItemAction.Action.COMBINE:
		recipeLineText = "Mix the " + item1.display_name() + " with the " + item2.display_name() + "."
	elif itemAction.actionType == ItemAction.Action.MIX_LIQUID:
		recipeLineText = "Mix the " + item2.display_name() + " into the " + item1.display_name() + "."
	
	focusPage.add_line(recipeLineText)
	

static func traverse_item_tree(item : Item, contactedItems = []):
	if item in contactedItems: return
	
	if item is Bottle:
		traverse_item_tree(item.containedLiquid)
		for contItem in item.bottledItems:
			traverse_item_tree(contItem)
	
	for prevItem in item.previousItemsInvolved:
		traverse_item_tree(prevItem)
		
	#combination detection
	if item.previousItemsInvolved:
		
		var prevItem1 = item.previousItemsInvolved[0]
		var lastAct = prevItem1.itemActionsApplied[prevItem1.itemActionsApplied.size()-1]
		
		var typeCheck
		if item is Liquid:
			typeCheck = ItemAction.Action.MIX_LIQUID
		elif item is Powder:
			typeCheck = ItemAction.Action.COMBINE
		
		if lastAct.actionType == typeCheck:
			var prevItem2 = item.previousItemsInvolved[1]
			if prevItem2.itemActionsApplied[prevItem2.itemActionsApplied.size()-1] == lastAct:
				add_action(lastAct, prevItem1, prevItem2)
	
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


func _on_flip_left_pressed() -> void:
	switch_displayed_pages(-1)


func _on_flip_right_pressed() -> void:
	switch_displayed_pages(1)
