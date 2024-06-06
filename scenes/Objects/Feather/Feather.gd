extends Item
class_name Feather


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	set_properties([
		Item.Property.BOTTLE_ADDABLE
	])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)
