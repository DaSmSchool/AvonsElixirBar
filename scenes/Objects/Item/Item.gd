extends Interactable
class_name Item


enum Property {
	GRINDABLE,
	ENCHANTABLE,
	COMBINABLE
}

@export var properties = []

static var holdingItem : Item

var itemColor : Color = Color()

@export var itemName : String = "DefItemName"
@export var itemCollisionParent : Node
@export var itemActionsApplied = []
@export var previousItemsInvolved : Array[Item] = []
@export var mutationAge = 1

var stationIn : Station

static var itemsNode

var matTemplate = load("res://materials/toonmaterial.material")

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	itemActionsApplied = []
	previousItemsInvolved = []
	mutationAge = 1
	if itemsNode == null:
		itemsNode = get_tree().current_scene.get_node("Items")
		print(itemsNode.get_children())
	assert(itemCollisionParent != null, "Collision for all Items are not defined! Check the Stack Frames to see which one needs it.")
	
	set_base_material()
	give_random_color()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)
	if !mouseRay.is_empty():
		holding_item_logic()

func has_property(prop : int):
	return prop in properties

func set_base_material():
	var mat : Material = matTemplate.duplicate()
	itemCollisionParent.get_parent().set_surface_override_material(0, mat)


func insert_to_tree():
	var par = self.get_parent()
	if par != null:
		par.remove_child(self)
	itemsNode.add_child(self)
	par = self.get_parent()
	print(par.is_inside_tree())
	print(self.is_inside_tree())



func give_random_color():
	itemColor.r = randf()
	itemColor.g = randf()
	itemColor.b = randf()
	update_item_color()


func update_item_color():
	var mat : Material = itemCollisionParent.get_parent().get_surface_override_material(0)
	mat.albedo_color = itemColor
	itemCollisionParent.get_parent().set_surface_override_material(0, mat)


func disassociate_station():
	if stationIn != null:
		stationIn.heldItem = null
		stationIn = null


func associate_station(station : Station):
	station.heldItem = self
	stationIn = station


func holding_item_logic():
	#behavior when not held
	if holdingItem == null:
		position = position
	#behavior when held
	elif holdingItem == self:
		#when no station being hovered
		if (Station.hoveringStation == null):
			position = mouseRay["position"]
			disassociate_station()
		#when a station is being hovered, and the hovered station has self or has no item 
		#both item and station should be tied to mouse, so the held item should be the one that is on top of the hovered station
		elif Station.hoveringStation.heldItem in [null, self]:
			if Station.hoveringStation.itemSpotMarker != null:
				position = Station.hoveringStation.itemSpotMarker.global_position
			else:
				position = mouseRay["position"]
			Station.hoveringStation.heldItem = self
			stationIn = Station.hoveringStation
		#when the hovered station has another item
		elif Station.hoveringStation.heldItem != null:
			position = mouseRay["position"]
		
		if Input.is_action_just_pressed("action"):
			var hitNode = mouseRay["collider"].get_parent().get_parent()
			if hitNode is Item:
				item_interact(hitNode)
			elif hitNode is Station:
				if Station.Property.KEEP_ITEM_HOLD_ON_CLICK not in hitNode.properties:
					let_item_go()
			else:
				let_item_go()


func let_item_go():
	holdingItem = null
	itemCollisionParent.get_node("CollisionShape3D").set_deferred("disabled", false)


func item_interact(itemHit : Item):
	pass

func on_just_left_clicked():
	var colNode : CollisionShape3D = itemCollisionParent.get_node("CollisionShape3D")
	if !mouseRay.is_empty():
		print(mouseRay["collider"].get_parent())
		print(itemCollisionParent.get_parent())
		if (mouseRay["collider"] == itemCollisionParent) and !holdingItem:
			colNode.set_deferred("disabled", true)
			if (holdingItem == null):
				holdingItem = self
				if stationIn != null:
					stationIn.heldItem = null
					stationIn = null
			elif (holdingItem == self):
				print("Self!")
			else:
				print("Mix!")


func on_just_right_clicked():
	pass


func set_item_name(newName : String):
	itemName = newName


func set_used_mat(mat : Material):
	mat = matTemplate
	set_base_material()
