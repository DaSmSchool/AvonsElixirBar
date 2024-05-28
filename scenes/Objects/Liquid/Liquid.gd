extends Item
class_name Liquid

var scene_path = load("res://scenes/Objects/Liquid/Liquid.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)


func give_random_color():
	pass


func mix(liquid):
	var newLiq : Liquid = scene_path.instantiate()
	newLiq.itemColor = ColorHelper.average_color(itemColor, liquid.itemColor)
	var mixAction = ItemAction.new()
	mixAction.assign_vals(ItemAction.Action.MIX_LIQUID, itemName + " mixed with " + liquid.itemName, 0, newLiq, null, 100)
	liquid.itemActionsApplied.append(mixAction)
	itemActionsApplied.append(mixAction)
	
	
	newLiq.previousItemsInvolved.append(liquid)
	newLiq.previousItemsInvolved.append(self)
	return newLiq
