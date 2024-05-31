extends Item
class_name Liquid

var scene_path = load("res://scenes/Objects/Liquid/Liquid.tscn")

@export var boilingPoint : float

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)


func give_random_color():
	pass


func mix(item):
	if !item is Liquid and !item.has_property(Item.Property.LIQUID_MIXABLE): return
	var newItem : Liquid = scene_path.instantiate()
	newItem.itemColor = ColorHelper.average_color(itemColor, item.itemColor)
	var mixAction = get_mix_item_action(item,newItem)
	item.itemActionsApplied.append(mixAction)
	itemActionsApplied.append(mixAction)
	
	
	newItem.previousItemsInvolved.append(item)
	newItem.previousItemsInvolved.append(self)
	return newItem


		
func get_mix_item_action(item:Item, newItem:Item):
	var mixAction = ItemAction.new()
	mixAction.assign_vals(ItemAction.Action.MIX_LIQUID, itemName + " mixed with " + item.itemName, 0, newItem, null, 100)
	return mixAction
