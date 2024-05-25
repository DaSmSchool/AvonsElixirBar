extends Item
class_name Bottle


@export var bottledItems = []

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
		print("WithLiq!")
		%Full.show()
		%PartFull.hide()
	elif (!bottledItems.is_empty()):
		%PartFull.show()
		%Full.hide()
	else:
		%PartFull.hide()
		%Full.hide()


func set_base_material():
	var mat : Material = matTemplate.duplicate()
	%PartFull.set_surface_override_material(0, mat)
	%Full.set_surface_override_material(0, mat)

func give_random_color():
	pass

func update_item_color():
	print(%Full)
	var mat : Material = %Full.get_surface_override_material(0)
	mat.albedo_color = itemColor
	%Full.set_surface_override_material(0, mat)
	%PartFull.set_surface_override_material(0, mat)
