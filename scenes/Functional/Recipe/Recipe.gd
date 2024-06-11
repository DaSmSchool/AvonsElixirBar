extends Node
class_name Recipe


static var recipeList : Array[Recipe] = []


var finalItem : Item
var difficulty
var potionName : String
var initIngredientsNeeded : Array

enum RecipeDifficulty {
	EASY,
	MEDIUM,
	HARD
}

static var potionNames = [
	"Mana Potion", 
	"Strength Potion", 
	"Weakness Potion", 
	"Intelligence Potion", 
	"Invisibility Potion", 
	"Healing Potion", 
	"Poisonous Potion", 
	"Love Potion", 
	"Potion of Hatred",  
	"Sleeping Potion", 
	"Night Vision Potion", 
	"Jumping Potion", 
	"Speed Potion", 
	"Potion of Sluggishness", 
	"Luck Potion", 
	"Potion of Misfortune",
	"Happiness Potion", 
	"Sadness Potion"
]


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
	
	finalRecipe.potionName = get_unused_name(potionNames)
	if !finalRecipe.potionName:
		finalRecipe.potionName = "I ran out of potion names"

	baseIngredients = get_ingredients_needed(baseIngredientAmnt)
	finalRecipe.initIngredientsNeeded = baseIngredients.duplicate()
	
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
				var otherItem : Item = get_similar_item(focusItem, ingredients, focusItem)
				if otherItem:
					var newCombine : Item = Powder.combine_two_items(focusItem, otherItem, "Blend")
					ingredients.erase(focusItem)
					ingredients.erase(otherItem)
					ingredients.append(newCombine)
					focusItem.remove()
					otherItem.remove()
			elif chosen_property == Item.Property.LIQUID_MIXABLE:
				var bottle : Bottle = get_bottle(ingredients)
				if bottle.containedLiquid:
					bottle.containedLiquid = bottle.containedLiquid.mix(focusItem)
					ingredients.erase(focusItem)
					
					focusItem.remove()
			elif chosen_property == Item.Property.BOTTLE_ADDABLE:
				var bottle = get_bottle(ingredients)
				if bottle:
					bottle.insert_item(focusItem)
					ingredients.erase(focusItem)
		
		while null in ingredients:
			ingredients.erase(null)


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


static func get_unused_name(nameList : Array, usedNames = []):
	if !nameList: return null
	if !usedNames:
		for recipe in recipeList:
			usedNames.append(recipe.potionName)
		
	var chosenName = nameList.pick_random()
	if chosenName in usedNames:
		var regenList = nameList.duplicate()
		regenList.erase(chosenName)
		return get_unused_name(regenList, usedNames)
	return chosenName

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


static func verify_recipe(item : Item, recipe : Recipe):
	var score = verify_item_scan(item, recipe.finalItem)
	if score:
		return "pass"
	return "fail"

static func verify_item_scan(item : Item, compareItem : Item, verifiedItems = []):
	if item == null or item in verifiedItems: return 0
	var score = 0
	verifiedItems.append(item)
	
	if item is Bottle:
		var result = verify_item_scan(item.containedLiquid, compareItem.containedLiquid, verifiedItems)
		if result == null:
			return null
		else: score += result
		
		
		if item.bottledItems.size() != compareItem.bottledItems.size(): return null
		var itr1 = 0
		var itr2 = 0
		var iAArray : Array[ItemAction] = item.bottledItems.duplicate()
		var cIAARRAY : Array[ItemAction] = compareItem.bottledItems.duplicate()
		while iAArray.size() and itr2 < cIAARRAY.size():
			if iAArray[itr1].itemColor.is_equal_approx(cIAARRAY[itr2].itemColor):
				iAArray.remove_at(itr1)
				cIAARRAY.remove_at(itr2)
				itr2 = 0
			else:
				itr2+=1
		if iAArray.size(): return null
		else:
			for itemAction in compareItem.itemActionsApplied:
				var ind = compareItem.itemActionsApplied.find(itemAction)
				var resultBottled = verify_item_scan(itemAction.assocItem, compareItem.itemActionsApplied[ind].assocItem, verifiedItems)
				if resultBottled == null:
					return null
				else: score += result
		
		#var bottled : Array = item.bottledItems.duplicate().sort()
		#var bottledCheck : Array = compareItem.bottledItems.duplicate().sort()
		#if bottled != bottledCheck:
			#return null
	
	if compareItem.itemActionsApplied.size() != item.itemActionsApplied.size(): return null
	var itr1 = 0
	var itr2 = 0
	var iAArray : Array[ItemAction] = item.itemActionsApplied.duplicate()
	var cIAARRAY : Array[ItemAction] = compareItem.itemActionsApplied.duplicate()
	while iAArray.size() and itr2 < cIAARRAY.size():
		if iAArray[itr1].actionType == cIAARRAY[itr2].actionType:
			iAArray.remove_at(itr1)
			cIAARRAY.remove_at(itr2)
			itr2 = 0
		else:
			itr2+=1
	if iAArray.size(): return null
	else:
		for itemAction in compareItem.itemActionsApplied:
			var ind = compareItem.itemActionsApplied.find(itemAction)
			var result = verify_item_scan(itemAction.assocItem, compareItem.itemActionsApplied[ind].assocItem, verifiedItems)
			if result == null:
				return null
			else: score += result
		
	#for prevItem in item.previousItemsInvolved:
		#if !prevItem in compareItem.previousItemsInvolved:
			#return null
	#for prevItem in compareItem.previousItemsInvolved:
		#if !prevItem in item.previousItemsInvolved:
			#return null
	
	if compareItem.previousItemsInvolved.size() != item.previousItemsInvolved.size(): return null
	itr1 = 0
	itr2 = 0
	var pIArray : Array[Item] = item.previousItemsInvolved.duplicate()
	var cPIARRAY : Array[Item] = compareItem.previousItemsInvolved.duplicate()
	while pIArray.size() and itr2 < cPIARRAY.size():
		if pIArray[itr1].itemColor.is_equal_approx(cPIARRAY[itr2].itemColor):
			pIArray.remove_at(itr1)
			cPIARRAY.remove_at(itr2)
			itr2 = 0
		else:
			itr2+=1
	if pIArray.size(): return null
	else:
		for prevItem in compareItem.previousItemsInvolved:
			var ind = compareItem.previousItemsInvolved.find(prevItem)
			var result = verify_item_scan(prevItem, compareItem.previousItemsInvolved[ind], verifiedItems)
			if result == null:
				return null
			else: score += result
	
	return 5
