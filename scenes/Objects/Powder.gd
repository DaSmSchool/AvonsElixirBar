extends Item
class_name Powder


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	set_item_name("Powder")
	

func item_interact(itemHit : Item):
	if itemHit is Powder:
		var combineItemAction = ItemAction.new()
		combineItemAction.assign_vals("ItemCombine", "Combined with " + self.itemName, 0, self, null, 100)
		itemHit.itemActionsApplied.append(combineItemAction)
		print_rich("[color=#FF0000]" + str(itemHit.itemActionsApplied) + "[/color]")
		itemHit.itemColor = ColorHelper.average_color(self.itemColor, itemHit.itemColor)
		print(itemHit.itemColor)
		itemHit.update_item_color()
		holdingItem = null
		itemCollisionParent.get_node("CollisionShape3D").set_deferred("disabled", true)
		hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)
