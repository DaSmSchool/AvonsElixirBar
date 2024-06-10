extends Control
class_name CookbookMenu

static var currentPageSet: int = 0
static var storedPages: Array[CookbookPage] = []
static var focusPage: CookbookPage
static var focusRecipe: Recipe
static var pageTemplate = preload("res://scenes/Functional/HUD/CookbookMenu/page_template.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%PageTemplate.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	handle_arrows()

func handle_arrows():
	%FlipLeft.visible = currentPageSet > 0
	%FlipRight.visible = currentPageSet < ((storedPages.size() - 1) / 2) as int

static func generate_pages():
	for recipe in Recipe.recipeList:
		focusRecipe = recipe
		shift_page(true)
		traverse_item_tree(recipe.finalItem)

func switch_displayed_pages(pageChangeAmnt):
	currentPageSet += pageChangeAmnt
	
	var lpc = %LeftPageContents
	
	# Clear existing children
	for child in %LeftPageContents.get_children():
		%LeftPageContents.remove_child(child)
	for child in %RightPageContents.get_children():
		%RightPageContents.remove_child(child)
	
	if (currentPageSet * 2) < storedPages.size():
		var copyRightPage = storedPages[(currentPageSet * 2)]
		for copyChild in copyRightPage.get_children():
			var cc = copyChild.duplicate()
			%LeftPageContents.add_child(cc)
	
	if (currentPageSet * 2) + 1 < storedPages.size():
		var copyRightPage = storedPages[(currentPageSet * 2) + 1]
		for copyChild in copyRightPage.get_children():
			var cc = copyChild.duplicate()
			%RightPageContents.add_child(cc)


#func insert_new_page(copyIndex, startingChild):
	#var newPage : CookbookPage = pageTemplate.instantiate()
	#storedPages.insert(copyIndex+1, newPage)
	#newPage.startingPage = false
	#newPage.get_node("RecipeTitle").queue_free()
	#newPage.get_node("IngredientsList").queue_free()
	#var prevRecLines = startingChild.get_parent()
	#var idx = 0
	#while prevRecLines.get_children()[idx] != startingChild:
		#idx += 1
	#var nextRecLines : Array = prevRecLines.slice(idx)
	#for child in nextRecLines:
		#var subChild : RichTextLabel = child.duplicate()
		#if focusPage.can_add_to_page(subChild):
			#
			#var lastLine : RichTextLabel = prevRecLines[idx-1]
			#if lastLine in nextRecLines:
				#subChild.position.y = lastLine.get_content_height() + lastLine.position.y
			#newPage.get_node("RecipeLines").add_child(subChild)
			#subChild.size.x = %PageTemplate.get_node("RecipeLines/RecipeLine").size.x
			#subChild.size.y = subChild.get_content_height()
			#subChild.bbcode_enabled = true
			#print(subChild.size.y)
			#idx += 1
		#else:
			#insert_new_page(copyIndex+1, child)

static func shift_page(newRecipe: bool, text = ""):
	var writingPage: CookbookPage = pageTemplate.instantiate()
	focusPage = writingPage
	storedPages.append(writingPage)
	Hud.hud.add_child(writingPage)
	Hud.hud.remove_child(writingPage)
	
	var recipeTitle = writingPage.get_node("RecipeTitle") as RichTextLabel
	var recipeIngredients = writingPage.get_node("IngredientsList") as RichTextLabel
	var recipeLines = writingPage.get_node("RecipeLines") as Control

	if newRecipe and !text:
		writingPage.startingPage = true
		recipeTitle.text = focusRecipe.potionName
		recipeIngredients.text += get_init_ingredient_text(focusRecipe.initIngredientsNeeded)
		
		await Hud.hud.get_tree().process_frame
		
		writingPage.format_recipe_header(focusRecipe)
	else:
		writingPage.startingPage = false
		recipeTitle.text = text
		recipeIngredients.hide()
		recipeLines.hide()

static func add_action(itemAction: ItemAction, item1: Item, item2: Item = null):
	var recipeLineText = ""
	match itemAction.actionType:
		ItemAction.Action.GRIND:
			recipeLineText = "Grind a %s into a powder-like consistency." % item1.display_name()
		ItemAction.Action.BOIL:
			recipeLineText = "Boil the bottled liquid to a simmer, and make sure not to overboil it!"
		ItemAction.Action.COMBINE:
			recipeLineText = "Mix the %s with the %s." % [item1.display_name(), item2.display_name()]
		ItemAction.Action.MIX_LIQUID:
			recipeLineText = "Mix the %s into the %s." % [item1.display_name(), item2.display_name()]
		ItemAction.Action.BOTTLE_ADD:
			recipeLineText = "Put the %s into the bottle." % [item1.display_name()]
		ItemAction.Action.ADD_WATER_TO_BOTTLE:
			recipeLineText = "Fill the bottle with %s." % [item1.display_name()]
	
	add_page(recipeLineText)
	
static func add_page(str : String):
	shift_page(false, str)

static func traverse_item_tree(item: Item, contactedItems = []):
	if item in contactedItems: return
	
	if item is Bottle:
		var addWaterIA = ItemAction.new()
		addWaterIA.actionType = ItemAction.Action.ADD_WATER_TO_BOTTLE
		var waterLiquid = Liquid.new()
		waterLiquid.itemColor = Color.AQUA
		waterLiquid.itemName = "Water"
		
		add_action(addWaterIA, waterLiquid)
		traverse_item_tree(item.containedLiquid)
		for contItem in item.bottledItems:
			traverse_item_tree(contItem)
			var bottleAddIA = ItemAction.new()
			bottleAddIA.assign_vals(ItemAction.Action.BOTTLE_ADD, "add bottle", 0, null, null, 100)
			add_action(bottleAddIA, contItem)
	
	for prevItem in item.previousItemsInvolved:
		traverse_item_tree(prevItem)
	
	if item.previousItemsInvolved:
		var prevItem1 = item.previousItemsInvolved[0]
		var lastAct = prevItem1.itemActionsApplied.back()
		var typeCheck = ItemAction.Action.COMBINE if item is Powder else ItemAction.Action.MIX_LIQUID
		if lastAct.actionType == typeCheck:
			var prevItem2 = item.previousItemsInvolved[1]
			if prevItem2.itemActionsApplied.back() == lastAct:
				add_action(lastAct, prevItem1, prevItem2)
	
	for itemAction in item.itemActionsApplied:
		if itemAction.actionType in [ItemAction.Action.GRIND, ItemAction.Action.BOIL]:
			add_action(itemAction, item)
	
	contactedItems.append(item)

static func get_init_ingredient_text(initItems: Array) -> String:
	var textAssemble = "\n"
	for item in initItems:
		textAssemble += "  %s\n" % item.display_name()
	return textAssemble

func _on_flip_left_pressed() -> void:
	switch_displayed_pages(-1)

func _on_flip_right_pressed() -> void:
	switch_displayed_pages(1)
