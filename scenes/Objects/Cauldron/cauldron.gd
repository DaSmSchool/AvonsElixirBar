extends Station
class_name Cauldron


@export var containedLiquid : Liquid
@export var containedItems : Array[Item]

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)
	handle_filled_cauldron()

func handle_filled_cauldron():
	if containedLiquid:
		print("WithLiq!")
		%LiquidVis.show()
	else:
		%LiquidVis.hide()


func perform_station_action():
	print(heldItem)
	if heldItem and heldItem is Bottle:
		if containedLiquid and not heldItem.containedLiquid:
			transfer_to_bottle(heldItem)
		else:
			heldItem.bottle_transfer(self)
		Item.holdingItem = heldItem
		Item.holdingItem.itemCollisionParent.get_node("CollisionShape3D").set_deferred("disabled", true)
		heldItem = null
	activeStation = null


func transfer_to_bottle(bottle : Bottle):
	if bottle.containedLiquid:
		bottle.containedLiquid = bottle.containedLiquid.mix(containedLiquid)
	else:
		bottle.containedLiquid = containedLiquid
	
	bottle.update_item_color()
	containedLiquid = null
	bottle.bottledItems.append_array(containedItems)
	bottle.mix_all_contained_items()
	containedItems = []

func add_to_cauldron(bottle : Bottle):
	if containedLiquid:
		containedLiquid = containedLiquid.mix(bottle.containedLiquid)
	else:
		containedLiquid = bottle.containedLiquid
		
	containedItems.append_array(bottle.bottledItems)
