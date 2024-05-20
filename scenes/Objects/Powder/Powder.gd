extends Item
class_name Powder


var itemInst : PackedScene = load("res://scenes/Objects/Powder/Powder.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	set_item_name("Powder")
	

func item_interact(itemHit : Item):
	if itemHit is Powder:
		var combineItemAction : ItemAction = ItemAction.new()
		var newItem : Item = itemInst.instantiate()
		newItem.insert_to_tree()
		newItem.set_item_name("Blend")
		
		disassociate_station()
		itemHit.disassociate_station()
		
		combineItemAction.assign_vals("ItemCombine", itemHit.itemName + " + " + self.itemName, 0, newItem, null, 100)
		newItem.previousItemsInvolved.append(itemHit)
		newItem.previousItemsInvolved.append(self)
		itemHit.itemActionsApplied.append(combineItemAction)
		self.itemActionsApplied.append(combineItemAction)
		
		print_rich("[color=#FF0000]" + str(itemHit.itemActionsApplied) + "[/color]")
		newItem.itemColor = ColorHelper.average_color(self.itemColor, itemHit.itemColor)
		print(itemHit.itemColor)
		newItem.update_item_color()
		holdingItem = newItem
		
		newItem.itemCollisionParent.get_node("CollisionShape3D").set_deferred("disabled", true)
		newItem.global_position = itemHit.global_position
		itemCollisionParent.get_node("CollisionShape3D").set_deferred("disabled", true)
		hide()
		itemHit.itemCollisionParent.get_node("CollisionShape3D").set_deferred("disabled", true)
		itemHit.hide()
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)
