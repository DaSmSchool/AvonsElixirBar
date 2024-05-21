extends Station
class_name Grinder

@export var grindAmnt : float = 20

var powderScene = load("res://scenes/Objects/Powder/Powder.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	set_station_name("Grinder")
	if assocHud == null:
		set_assoc_hud(load("res://scenes/Functional/HUD/StationHud/GrinderHud.tscn").instantiate())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)
	

func perform_station_action():
	%AnimationPlayer.play("Pickup")


func mash_action():
	%AnimationPlayer.stop(true)
	%AnimationPlayer.play("Smash")
	if heldItem != null:
		item_mash()


func item_mash():
	if heldItem.has_property(Item.Property.GRINDABLE):
		var latestItemAction : ItemAction
		if heldItem.itemActionsApplied.size() != 0:
			latestItemAction = heldItem.itemActionsApplied[heldItem.itemActionsApplied.size()-1]
		else:
			latestItemAction = ItemAction.new()
		print(latestItemAction.actionType)
		if latestItemAction.actionType != ItemAction.Action.GRIND or latestItemAction.actionType == 0:
			print("newgrind")
			var grindComplete = grindAmnt
			var newGrindAction = ItemAction.new()
			heldItem.itemActionsApplied.append(newGrindAction)
			newGrindAction.assign_vals(ItemAction.Action.GRIND, "Ground: " + str(grindComplete), 0, null, self, grindComplete)
		else:
			print("overloadact")
			latestItemAction.accuracy += grindAmnt
			if latestItemAction.accuracy >= 100:
				convert_ground_item()
			latestItemAction.accuracy = min(latestItemAction.accuracy, 100)
			latestItemAction.actionMessage = "Ground: " + str(latestItemAction.accuracy)


func convert_ground_item():
	
	var newPowder : Powder = powderScene.instantiate()
	newPowder.insert_to_tree()
	newPowder.itemColor = heldItem.itemColor
	newPowder.update_item_color()
	newPowder.itemName = heldItem.itemName + " Powder"
	newPowder.position = heldItem.position
	var groundItemAction : ItemAction = heldItem.itemActionsApplied[heldItem.itemActionsApplied.size()-1]
	groundItemAction.assocItem = newPowder
	heldItem.hide()
	heldItem.itemCollisionParent.get_node("CollisionShape3D").set_deferred("disabled", true)
	heldItem.disassociate_station()
	newPowder.associate_station(self)
	
func leave_station():
	%AnimationPlayer.play_backwards("Pickup")
