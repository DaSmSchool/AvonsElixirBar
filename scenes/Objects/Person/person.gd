extends Interactable
class_name Person

@export var assocSeat : Seat
@export var personName : String

@export var askingRecipe : Recipe

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !askingRecipe:
		askingRecipe = Recipe.recipeList.pick_random()
	if assocSeat:
		global_position = assocSeat.seatSpot.global_position
		$AnimationPlayer.play("SitIdle")

func person_clicked(item : Item):
	if Item.holdingItem is Bottle:
		if Item.holdingItem.containedLiquid:
			var score = Recipe.verify_recipe(Item.holdingItem, askingRecipe)
			
