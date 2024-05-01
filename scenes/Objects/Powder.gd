extends Item
class_name Powder

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()


func item_interact(itemHit : Item):
	if itemHit is Powder:
		itemHit.itemColor = itemHit.itemColor.lerp(itemColor, 0.5)
		var combineItemAction = ItemAction.new()
		combineItemAction.assign_vals("ItemCombine", 0, self, null, 100)
		itemHit.itemActionsApplied.append_array(itemActionsApplied)
		itemHit.itemColor = ColorHelper.average_color(self.itemColor, itemHit.itemColor)
		holdingItem = null
		hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)
