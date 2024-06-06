extends Item
class_name Powder


static var itemInst : PackedScene = preload("res://scenes/Objects/Powder/Powder.tscn")



# Called when the node enters the scene tree for the first time.
func _ready():
	properties = [
		Item.Property.COMBINABLE,
		Item.Property.LIQUID_MIXABLE,
		Item.Property.BOTTLE_ADDABLE
	]
	super._ready()
	set_item_name("Powder")
	

func item_interact(itemHit : Item):
	if itemHit is Powder:
		combine_two_items(self, itemHit, "Blend")
		remove()
		itemHit.remove()
	if itemHit is Bottle:
		itemHit.insert_item(self)
		

static func combine_two_items(item1 : Item, item2 : Item, itemName : String):
	var combineItemAction : ItemAction = ItemAction.new()
	var newItem : Item = itemInst.instantiate()
	newItem.insert_to_tree()
	newItem.set_item_name("Blend")
	
	item1.disassociate_station()
	item2.disassociate_station()
	
	combineItemAction.assign_vals(ItemAction.Action.COMBINE, item2.itemName + " + " + item1.itemName, 0, newItem, null, 100)
	newItem.previousItemsInvolved.append(item2)
	newItem.previousItemsInvolved.append(item1)
	item2.itemActionsApplied.append(combineItemAction)
	item1.itemActionsApplied.append(combineItemAction)
	
	print_rich("[color=#FF0000]" + str(item2.itemActionsApplied) + "[/color]")
	newItem.itemColor = ColorHelper.average_color(item1.itemColor, item2.itemColor)
	print(item2.itemColor)
	newItem.update_item_color()
	holdingItem = newItem
	
	newItem.itemCollisionParent.get_node("CollisionShape3D").set_deferred("disabled", true)
	newItem.global_position = item2.global_position
	newItem.mutationAge = max(item1.mutationAge, item2.mutationAge) + 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)

