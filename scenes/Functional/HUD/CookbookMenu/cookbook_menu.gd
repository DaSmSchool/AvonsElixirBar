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
		var heightTotal = 0
		for copyChild in copyRightPage.get_children():
			var cc = copyChild.duplicate()
			if cc is RichTextLabel:
				cc.size.y = cc.get_content_height()
			else:
				cc.size.y = 50
			cc.position.y = heightTotal
			heightTotal += cc.size.y
			%LeftPageContents.add_child(cc)
			if copyChild.get_children():
				var lastChild = null
				for child in copyChild.get_children():
					var subChild : RichTextLabel = child.duplicate()
					if focusPage.can_add_to_page(subChild):
						if cc.get_children():
							var lastLine : RichTextLabel = cc.get_children().back()
							subChild.position.y = lastLine.get_content_height() + lastLine.position.y
						cc.add_child(subChild)
						subChild.size.x = %PageTemplate.get_node("RecipeLines/RecipeLine").size.x
						subChild.size.y = subChild.get_content_height()
						subChild.bbcode_enabled = true
						print(subChild.size.y)
						lastChild = subChild
					else:
						insert_new_page((currentPageSet * 2), child)
		
			
	
	if (currentPageSet * 2) + 1 < storedPages.size():
		var copyRightPage = storedPages[(currentPageSet * 2) + 1]
		var heightTotal = 0
		for copyChild in copyRightPage.get_children():
			var cc = copyChild.duplicate()
			if cc is RichTextLabel:
				cc.size.y = cc.get_content_height()

			cc.position.y = heightTotal*3
			heightTotal += cc.size.y*3
			%RightPageContents.add_child(cc)
			if copyChild.get_children():
				var lastChild = null
				for child in copyChild.get_children():
					var subChild : RichTextLabel = child.duplicate()
					if focusPage.can_add_to_page(subChild):
						if cc.get_children():
							var lastLine : RichTextLabel = cc.get_children().back()
							subChild.position.y = lastLine.get_content_height() + lastLine.position.y
						cc.add_child(subChild)
						subChild.size.x = %PageTemplate.get_node("RecipeLines/RecipeLine").size.x
						subChild.size.y = subChild.get_content_height()
						subChild.bbcode_enabled = true
						print(subChild.size.y)
						lastChild = subChild
					else:
						insert_new_page((currentPageSet * 2)+1, child)

func insert_new_page(copyIndex, startingChild):
	var newPage : CookbookPage = pageTemplate.instantiate()
	storedPages.insert(copyIndex+1, newPage)
	newPage.startingPage = false
	newPage.get_node("RecipeTitle").queue_free()
	newPage.get_node("IngredientsList").queue_free()
	var prevRecLines = startingChild.get_parent()
	var idx = 0
	while prevRecLines.get_children()[idx] != startingChild:
		idx += 1
	var nextRecLines : Array = prevRecLines.slice(idx)
	for child in nextRecLines:
		var subChild : RichTextLabel = child.duplicate()
		if focusPage.can_add_to_page(subChild):
			
			var lastLine : RichTextLabel = prevRecLines[idx-1]
			if lastLine in nextRecLines:
				subChild.position.y = lastLine.get_content_height() + lastLine.position.y
			newPage.get_node("RecipeLines").add_child(subChild)
			subChild.size.x = %PageTemplate.get_node("RecipeLines/RecipeLine").size.x
			subChild.size.y = subChild.get_content_height()
			subChild.bbcode_enabled = true
			print(subChild.size.y)
			idx += 1
		else:
			insert_new_page(copyIndex+1, child)

static func shift_page(newRecipe: bool):
	var writingPage: CookbookPage = pageTemplate.instantiate()
	focusPage = writingPage
	storedPages.append(writingPage)
	Hud.hud.add_child(writingPage)
	Hud.hud.remove_child(writingPage)
	
	var recipeTitle = writingPage.get_node("RecipeTitle") as RichTextLabel
	var recipeIngredients = writingPage.get_node("IngredientsList") as RichTextLabel
	var recipeLines = writingPage.get_node("RecipeLines") as Control

	if newRecipe:
		writingPage.startingPage = true
		recipeTitle.text = focusRecipe.potionName
		recipeIngredients.text += get_init_ingredient_text(focusRecipe.initIngredientsNeeded)
		
		await Hud.hud.get_tree().process_frame
		
		writingPage.format_recipe_header(focusRecipe)
	else:
		writingPage.startingPage = false
		recipeLines.position.y = 0

static func add_action(itemAction: ItemAction, item1: Item, item2: Item = null):
	var recipeLineText = ""
	match itemAction.actionType:
		ItemAction.Action.GRIND:
			recipeLineText = "Grind %s into a powder-like consistency." % item1.display_name()
		ItemAction.Action.BOIL:
			recipeLineText = "Boil the bottled liquid to a simmer, and make sure not to overboil it!"
		ItemAction.Action.COMBINE:
			recipeLineText = "Mix the %s with the %s." % [item1.display_name(), item2.display_name()]
		ItemAction.Action.MIX_LIQUID:
			recipeLineText = "Mix the %s into the %s." % [item2.display_name(), item1.display_name()]
	
	focusPage.add_line(recipeLineText)

static func traverse_item_tree(item: Item, contactedItems = []):
	if item in contactedItems: return
	
	if item is Bottle:
		traverse_item_tree(item.containedLiquid)
		for contItem in item.bottledItems:
			traverse_item_tree(contItem)
	
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
