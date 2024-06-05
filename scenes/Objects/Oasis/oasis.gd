extends Station
class_name Oasis


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	properties = [
		Station.Property.KEEP_ITEM_HOLD_ON_CLICK
	]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)

static func add_water(item : Item):
	var prodWater = Liquid.new()
	item.containedLiquid = prodWater
	
	if item.bottledItems == null:
		prodWater.itemName = "Water"
		prodWater.itemColor = Color.DODGER_BLUE
		item.update_item_color()
		
		item.itemName = "Water " + item.itemName
	else:
		prodWater.itemName = "Potion Base"
		prodWater.itemColor = item.itemColor
		item.mix_all_contained_items()
		item.itemName = "Raw Potion"
		item.update_item_color()

func perform_station_action():
	if heldItem is Bottle:
		if heldItem.containedLiquid == null:
			add_water(heldItem)
			Item.holdingItem = heldItem
			heldItem.disassociate_station()
	activeStation = null
