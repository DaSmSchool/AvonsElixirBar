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


func perform_station_action():
	if heldItem is Bottle:
		if heldItem.containedLiquid == null:
			var prodWater = Liquid.new()
			heldItem.containedLiquid = prodWater
			
			if heldItem.bottledItems == null:
				prodWater.itemName = "Water"
				prodWater.itemColor = Color.DODGER_BLUE
				heldItem.update_item_color()
				
				heldItem.itemName = "Water " + heldItem.itemName
			else:
				prodWater.itemName = "Potion Base"
				prodWater.itemColor = heldItem.itemColor
				heldItem.update_item_color()
				heldItem.mix_all_contained_items()
				heldItem.itemName = "Raw Potion"
				
			Item.holdingItem = heldItem
			heldItem.disassociate_station()
	activeStation = null
