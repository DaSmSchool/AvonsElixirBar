extends Station
class_name Cauldron


@export var containedLiquid : Liquid
@export var conatinedItems : Array[Item]

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)


func perform_station_action():
	if Item.holdingItem and Item.holdingItem is Bottle:
		if containedLiquid and not Item.holdingItem.containedLiquid:
			Item.holdingItem.bottle_transfer(self, Item.holdingItem)
		else:
			Item.holdingItem.bottle_transfer(Item.holdingItem, self)
	activeStation = null


func add_to_cauldron(bottle : Bottle):
	containedLiquid = containedLiquid.mix(bottle.containedLiquid)
