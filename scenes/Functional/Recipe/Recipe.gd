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
	var finalRecipe : Recipe
	var finalItem : Item
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
	
	finalItem = item_from_ingredients(baseIngredients, maxMutationAge)
	
	
	
	return finalRecipe


static func get_ingredients_needed(ingAmnt):
	var assembleIngredients : Array[Item] = []
	var availableIngs : Array[Item] = []
	
	for itemSet in int(GameStatus.availableItems.size()/ingAmnt)+1:
		availableIngs = GameStatus.availableItems
		if assembleIngredients.size() < ingAmnt:
			var chosenIng = availableIngs.pick_random()
			availableIngs.erase(chosenIng)
			assembleIngredients.append(chosenIng)
	assembleIngredients.append_array(GameStatus.essentialItems)
	
	return assembleIngredients


static func item_from_ingredients(ingredients : Array[Item], maxMutation):
	var focusItem : Item
	while !check_if_max_reached(ingredients, maxMutation):
		if focusItem:
			focusItem = get_random_excluded(ingredients, focusItem)
			if focusItem.mutationAge > maxMutation:
				get_non_max_mut_item(ingredients, maxMutation)
		else:
			focusItem = ingredients.pick_random()
		
		if focusItem is Bottle:
			if focusItem.containedLiquid:
				var targetItem = get_item_with_property(ingredients, Item.Property.LIQUID_MIXABLE)
				if targetItem:
					focusItem.containedLiquid.mix(targetItem)
			else:
				Oasis.add_water(focusItem)
		else:
			var chosen_property = focusItem.properties.pick_random()
			if chosen_property == Item.Property.GRINDABLE:
				Grinder.apply_grind(focusItem, null)
				focusItem.itemActionsApplied[focusItem.itemActionsApplied.size()-1].accuracy = 100
				Grinder.convert_ground_item(focusItem, null)
			elif chosen_property == Item.Property.COMBINABLE:
				var otherItem = get_similar_item(focusItem, ingredients, focusItem)
				

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


static func get_bottle(items : Array[Item]):
	for item in items:
		if item is Bottle: return item
	assert(false, "No bottle generated!")

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
