extends Station
class_name Grinder

@export var grindAmnt : float = 20

static var powderScene = load("res://scenes/Objects/Powder/Powder.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
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
			apply_grind(heldItem, self)
		else:
			print("overloadact")
			latestItemAction.accuracy += grindAmnt
			if latestItemAction.accuracy >= 100:
				convert_ground_item(heldItem, self)
			latestItemAction.accuracy = min(latestItemAction.accuracy, 100)
			latestItemAction.actionMessage = "Ground: " + str(latestItemAction.accuracy)


static func convert_ground_item(item : Item, station : Station):
	
	var newPowder : Powder = powderScene.instantiate()
	newPowder.insert_to_tree()
	newPowder.itemColor = item.itemColor
	newPowder.update_item_color()
	newPowder.itemName = item.itemName + " Powder"
	newPowder.position = item.position
	var groundItemAction : ItemAction = item.itemActionsApplied[item.itemActionsApplied.size()-1]
	groundItemAction.assocItem = newPowder
	newPowder.mutationAge = item.mutationAge
	item.remove()
	newPowder.associate_station(station)
	return newPowder
	
	
static func apply_grind(item : Item, station : Station):
	var newGrindAction = ItemAction.new()
	item.itemActionsApplied.append(newGrindAction)
	newGrindAction.assign_vals(ItemAction.Action.GRIND, "Ground: " + str(100), 0, null, station, 0)
	item.mutationAge += 1
	
func leave_station():
	%AnimationPlayer.play_backwards("Pickup")
