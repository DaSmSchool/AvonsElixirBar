extends Item
class_name Bottle


@export var bottledItems = []

@export var containedLiquid : Liquid

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)
	handle_filled_status()


func handle_filled_status():
	if (bottledItems.is_empty()):
		%PartFull.hide()
		%Full.hide()
	elif containedLiquid:
		%Full.show()
		%PartFull.hide()
	else:
		%PartFull.show()
		%Full.hide()


func set_base_material():
	var mat : Material = matTemplate.duplicate()
	%PartFull.set_surface_override_material(0, mat)
	%Full.set_surface_override_material(0, mat)

func give_random_color():
	pass

func update_item_color():
	var mat : Material = %Part.get_surface_override_material(0)
	mat.albedo_color = itemColor
	%Part.set_surface_override_material(0, mat)
	%PartFull.set_surface_override_material(0, mat)
