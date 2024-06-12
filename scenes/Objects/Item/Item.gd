extends Interactable
class_name Item


enum Property {
	GRINDABLE,
	ENCHANTABLE,
	COMBINABLE,
	LIQUID_MIXABLE,
	BOTTLE_ADDABLE
}

@export var properties : Array

@export var assocScene : PackedScene

static var holdingItem : Item

var itemColor : Color = Color()

@export var itemName : String
@export var itemCollisionParent : Node
@export var itemActionsApplied : Array[ItemAction]
@export var previousItemsInvolved : Array[Item]
@export var mutationAge : int

@export var boilTime : int

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
	if !(self is Liquid):
		assert(itemCollisionParent != null, "Collision for all Items are not defined! Check the Stack Frames to see which one needs it.")
	
	set_base_material()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)
	if !mouseRay.is_empty():
		holding_item_logic()
	if self == holdingItem:
		if self is Bottle and (self as Bottle).containedLiquid:
			
			print((self as Bottle).containedLiquid.itemName + " mutationAge: " + str((self as Bottle).containedLiquid.mutationAge))
		else:
			print(itemName + " mutationAge: " + str(mutationAge))


func has_property(prop : int):
	return prop in properties
	
func set_properties(props : Array):
	properties = []
	for prop in props:
		properties.append(prop)

func set_base_material():
	var mat : Material = matTemplate.duplicate()
	itemCollisionParent.get_parent().set_surface_override_material(0, mat)


func insert_to_tree():
	var par = self.get_parent()
	if par != null:
		par.remove_child(self)
	itemsNode.add_child(self)
	par = self.get_parent()


func remove_from_tree():
	if get_parent() != null:
		get_parent().remove_child(self)


func generate_random():
	give_random_color()
	update_item_color()


func give_random_color():
	itemColor.r = randf()
	itemColor.g = randf()
	itemColor.b = randf()
	itemColor.v = (randf()/2)+0.5
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
	if station:
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
			
			if mouseRay["collider"].get_parent() is Person:
				mouseRay["collider"].get_parent().person_clicked(self)
			
			if hitNode is Item:
				item_interact(hitNode)
			elif hitNode is Station:
				if Station.Property.KEEP_ITEM_HOLD_ON_CLICK not in hitNode.properties:
					let_item_go()
			else:
				let_item_go()


func let_item_go():
	if holdingItem == self:
		holdingItem = null
	if itemCollisionParent:
		itemCollisionParent.get_node("CollisionShape3D").set_deferred("disabled", false)


static func get_boiling_point(item:Item):
	var boilPoint = item.boilTime
	if item.previousItemsInvolved:
		for prevItem in item.previousItemsInvolved:
			boilPoint += get_boiling_point(prevItem)
	return boilPoint

func item_interact(itemHit : Item):
	pass

func on_just_left_clicked():
	var colNode : CollisionShape3D = itemCollisionParent.get_node("CollisionShape3D")
	if !mouseRay.is_empty():
		if (mouseRay["collider"] == itemCollisionParent) and !holdingItem:
			#colNode.set_deferred("disabled", true)
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


func remove():
	let_item_go()
	disassociate_station()
	if itemCollisionParent:
		itemCollisionParent.get_node("CollisionShape3D").set_deferred("disabled", true)
	hide()
	remove_from_tree()
	
func display_name():
	return "[color=#" + itemColor.to_html(false) + "]" + itemName + "[/color]"
	
