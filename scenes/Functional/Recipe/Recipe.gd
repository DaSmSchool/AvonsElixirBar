extends Node
class_name Recipe


static var recipeList : Array[Recipe] = []


var finalItem : Item
var difficulty

enum RecipeDifficulty {
	EASY,
	MEDIUM,
	HARD
}
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


static func generate_potion_recipe(difficulty) -> Recipe:
	var finalRecipe : Recipe = Recipe.new()
	finalRecipe.difficulty = difficulty
	
	var baseIngredientAmnt : int
	var baseIngredients : Array[Item] = []
	var maxMutationAge
	
	
	if difficulty == RecipeDifficulty.EASY:
		baseIngredientAmnt = 2
		maxMutationAge = 3
	elif difficulty == RecipeDifficulty.MEDIUM:
		baseIngredientAmnt = 3
		maxMutationAge = 4
	elif difficulty == RecipeDifficulty.HARD:
		baseIngredientAmnt = 4
		maxMutationAge = 5
	

	baseIngredients = get_ingredients_needed(baseIngredientAmnt)
	
	finalRecipe.finalItem = item_from_ingredients(baseIngredients, maxMutationAge)
	
	
	
	return finalRecipe


static func get_ingredients_needed(ingAmnt):
	var assembleIngredients : Array[Item] = []
	var availableIngs : Array[Item] = []
	
	var copyArr = GameStatus.availableItems.duplicate()
	
	for itemSet in int(copyArr.size()/ingAmnt)+1:
		availableIngs = copyArr.duplicate()
		
		
		if assembleIngredients.size() < ingAmnt:
			var chosenIng : Item = availableIngs.pick_random()
			while chosenIng is Bottle:
				availableIngs.erase(chosenIng)
				chosenIng = availableIngs.pick_random()
			
			var itemCopy : Item = chosenIng.duplicate()
			itemCopy.itemColor = chosenIng.itemColor
				
			itemCopy.insert_to_tree()
			itemCopy.get_parent().remove_child(chosenIng)
			availableIngs.erase(chosenIng)
			assembleIngredients.append(itemCopy)
	#assembleIngredients.append_array(GameStatus.essentialItems)
	
	for item in GameStatus.essentialItems:
		var essItem : Item = item.duplicate()
		essItem.insert_to_tree()
		essItem.get_parent().remove_child(essItem)
		assembleIngredients.append(essItem)
	
	print(assembleIngredients)
	return assembleIngredients


static func item_from_ingredients(ingredients : Array[Item], maxMutation):
	ingredients = ingredients.duplicate()
	item_ingredients_loop(ingredients, maxMutation)
	final_boil_process(ingredients)
	return get_bottle(ingredients)
	
	
static func item_ingredients_loop(ingredients : Array[Item], maxMutation):
	print(ingredients)
	var focusItem : Item
	while !check_if_max_reached(ingredients, maxMutation) and !(ingredients.size() == 1) and !(get_non_max_mut_array(ingredients, maxMutation).size() == 1 and ingredients[0] is Bottle and ingredients[0].containedLiquid):
		
		if focusItem:
			focusItem = get_random_excluded(ingredients, focusItem)
			if focusItem.mutationAge > maxMutation:
				get_non_max_mut_item(ingredients, maxMutation)
		else:
			focusItem = get_bottle(ingredients)
		
		if focusItem is Bottle:
			if focusItem.containedLiquid:
				var targetItem = get_item_with_property(ingredients, Item.Property.LIQUID_MIXABLE)
				if targetItem:
					focusItem.containedLiquid = focusItem.containedLiquid.mix(targetItem)
					ingredients.erase(targetItem)
			else:
				Oasis.add_water(focusItem)
		else:
			print(focusItem.itemName)
			print(focusItem.properties)
			var chosen_property = focusItem.properties.pick_random()
			if chosen_property == Item.Property.GRINDABLE:
				Grinder.apply_grind(focusItem, null)
				focusItem.itemActionsApplied[focusItem.itemActionsApplied.size()-1].accuracy = 100
				ingredients.append(Grinder.convert_ground_item(focusItem, null))
				ingredients.erase(focusItem)
			elif chosen_property == Item.Property.COMBINABLE:
				var otherItem = get_similar_item(focusItem, ingredients, focusItem)
				if otherItem:
					var newCombine : Item = Powder.combine_two_items(focusItem, otherItem, "Blend")
					ingredients.erase(focusItem)
					ingredients.erase(otherItem)
					ingredients.append(newCombine)
			elif chosen_property == Item.Property.LIQUID_MIXABLE:
				var bottle : Bottle = get_bottle(ingredients)
				if bottle.containedLiquid:
					bottle.containedLiquid = bottle.containedLiquid.mix(focusItem)
					ingredients.erase(focusItem)
			elif chosen_property == Item.Property.BOTTLE_ADDABLE:
				var bottle = get_bottle(ingredients)
				if bottle:
					bottle.insert_item(focusItem)
					ingredients.erase(focusItem)


static func final_boil_process(ingredients : Array[Item]):
	var itr = 0
	while itr < ingredients.size():
		if ingredients[itr].has_property(Item.Property.LIQUID_MIXABLE):
			var bottle : Bottle = get_bottle(ingredients)
			if bottle.containedLiquid:
				bottle.containedLiquid = bottle.containedLiquid.mix(ingredients[itr])
				ingredients.remove_at(itr)
				itr -= 1
		elif ingredients[itr].has_property(Item.Property.BOTTLE_ADDABLE):
			var bottle = get_bottle(ingredients)
			if bottle:
				bottle.insert_item(ingredients[itr])
				ingredients.remove_at(itr)
				itr -= 1
		itr += 1
	var bottle = get_bottle(ingredients)
	var boilingPoint = Item.get_boiling_point(bottle.containedLiquid)
	var boilAction : ItemAction = ItemAction.new()
	var boilAmnt = 100
	boilAction.assign_vals(ItemAction.Action.BOIL, "Boiled: " + str(boilAmnt) + "%", boilingPoint*2, null, null, 100)
	bottle.containedLiquid.itemActionsApplied.append(boilAction)
	bottle.containedLiquid.itemName = "Potion"
	bottle.containedLiquid.mutationAge += 1


static func get_non_max_mut_array(ingredients : Array[Item], maxMutation):
	var retArray : Array[Item] = ingredients.duplicate()
	var itr = 0
	while itr < retArray.size():
		if retArray[itr].mutationAge >= maxMutation:
			retArray.remove_at(itr)
			itr -= 1
		itr += 1
	return retArray


static func get_item_with_property(items : Array[Item], property : int):
	if items.is_empty(): return null
	var chosenItem : Item = items.pick_random()
	if chosenItem.has_property(property):
		return chosenItem
	else:
		var passArray = items.duplicate()
		passArray.erase(chosenItem)
		return get_item_with_property(passArray, property)


static func get_similar_item(targetItem : Item, array : Array[Item], exclude : Item):
	if !array: return null
	array = array.duplicate()
	array.erase(exclude)
	if !array: return null
	var chosenItem : Item = array.pick_random()
	if chosenItem.get_script() != targetItem.get_script():
		get_similar_item(targetItem, array, chosenItem)
	else:
		return chosenItem


static func get_non_max_mut_item(items : Array[Item], maxMutation : int):
	if items.is_empty(): return null
	var chosenItem : Item = items.pick_random()
	if chosenItem.mutationAge < maxMutation:
		return chosenItem
	else:
		var passArray = items.duplicate()
		passArray.erase(chosenItem)
		return get_non_max_mut_item(passArray, maxMutation)


static func get_bottle(items : Array[Item]) -> Bottle:
	for item in items:
		if item is Bottle: return item
	assert(false, "No bottle generated!")
	return null


static func check_if_max_reached(ingredients : Array[Item], maxMutation):
	for item in ingredients:
		if item.mutationAge < maxMutation:
			return false
	return true


static func get_random_excluded(list : Array, item : Variant):
	var newList : Array = list.duplicate()
	newList.erase(item)
	if list.is_empty():
		return null
	return newList.pick_random()


static func unique_array(array : Array):
	var newArr = []
	for itemItr in array.size():
		var canAdd = true
		for checkItr in array.size():
			if itemItr != checkItr and array[checkItr].get_instance_id() == array[itemItr].get_instance_id():
				canAdd == false
		if canAdd:
			newArr.append(array[itemItr])
	return newArr


static func print_recipe(item : Item, previousItemsPrinted = []):
	if item in previousItemsPrinted: return
	print_recipe_item(item)
	previousItemsPrinted.append(item)
	if item is Bottle and item.containedLiquid:
		print_recipe(item.containedLiquid, previousItemsPrinted)
	for prevItem in item.previousItemsInvolved:
		print_recipe(prevItem, previousItemsPrinted)
	
	for itemAction in item.itemActionsApplied:
		if itemAction.assocItem and !(itemAction.assocItem in previousItemsPrinted):
			print_recipe(itemAction.assocItem, previousItemsPrinted)
	
static func print_recipe_item(item : Item):
	print_rich("Item: " + item.display_name())
	if item is Bottle:
		if item.containedLiquid:
			print_rich("Contained Liquid: " + item.containedLiquid.display_name())
		else:
			print_rich("No Contained Liquid!")
		if item.bottledItems:
			print("Bottled Items:")
		for botItem in item.bottledItems:
			print_rich("(" + str(botItem) + ", " + botItem.display_name() + ")")
	print("ItemActions:")
	for itemAction in item.itemActionsApplied:
		print_rich("(" + str(itemAction) + ", " + itemAction.actionMessage + ")")
	print("Previous Items")
	for prevItem : Item in item.previousItemsInvolved:
		print_rich("(" + str(prevItem) + ", " + prevItem.display_name() + ")")
	print("Mutation Age:")
	print(item.mutationAge)
