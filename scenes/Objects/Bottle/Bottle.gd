extends Item
class_name Bottle


@export var bottledItems : Array[Item] = []

@export var containedLiquid : Liquid

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	set_base_material()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)
	handle_filled_status()


func handle_filled_status():
	if containedLiquid:
		%Full.show()
		%PartFull.hide()
	elif (!bottledItems.is_empty()):
		%PartFull.show()
		%Full.hide()
	else:
		%PartFull.hide()
		%Full.hide()


func item_interact(itemHit : Item):
	if (itemHit.has_property(Item.Property.LIQUID_MIXABLE) or itemHit.has_property(Item.Property.BOTTLE_ADDABLE)):
		insert_item(itemHit)
			

func insert_item(itemHit : Item):
	if (itemHit.has_property(Item.Property.LIQUID_MIXABLE)):
		if containedLiquid:
			var combItemAction = ItemAction.new()
			combItemAction.assign_vals(ItemAction.Action.COMBINE, "Mixed with " + itemHit.itemName, 0, containedLiquid, null, 100)
			containedLiquid.previousItemsInvolved.append(itemHit)
			containedLiquid.itemColor = ColorHelper.average_color(containedLiquid.itemColor, itemHit.itemColor)
			update_item_color()
			itemHit.remove()
			itemHit.itemActionsApplied.append(combItemAction)
	if itemHit.has_property(Item.Property.BOTTLE_ADDABLE):
		if !(itemHit.has_property(Item.Property.LIQUID_MIXABLE) and containedLiquid):
			bottledItems.append(itemHit)
			update_item_color()
			itemHit.remove()


func bottle_mix(bottle : Liquid):
	bottle.bottledItems.append_array(bottledItems)
	bottle.containedLiquid = bottle.containedLiquid.mix(containedLiquid)
	
	containedLiquid = null
	bottledItems = []
	
	
func bottle_transfer(transferTo):
	if transferTo is Bottle:
		bottle_mix(transferTo)

	elif transferTo is Cauldron:
		transferTo.add_to_cauldron(self)
		bottledItems = []
		containedLiquid = null


func mix_all_contained_items():
	if !containedLiquid: return
	for item in bottledItems:
		if item.has_property(Item.Property.LIQUID_MIXABLE):
			containedLiquid.mix(item)
	update_item_color()


func set_base_material():
	var mat : Material = matTemplate.duplicate()
	%PartFull.set_surface_override_material(0, mat)
	%Full.set_surface_override_material(0, mat)


func give_random_color():
	pass


func update_item_color():
	var tarColor : Color
	var itemsAvgColor : Color
	if !bottledItems and !containedLiquid: return
	
	if bottledItems:
		itemsAvgColor = bottledItems[0].itemColor
		for item : Item in bottledItems:
			itemsAvgColor = ColorHelper.average_color(item.itemColor, itemsAvgColor)
	if containedLiquid:
		tarColor = containedLiquid.itemColor
	
	if tarColor and itemsAvgColor:
		tarColor = ColorHelper.average_color(tarColor, itemsAvgColor)
	elif itemsAvgColor and !tarColor:
		tarColor = itemsAvgColor

	var mat : Material = %Full.get_surface_override_material(0)
	mat.albedo_color = tarColor
	%Full.set_surface_override_material(0, mat)
	%PartFull.set_surface_override_material(0, mat)
