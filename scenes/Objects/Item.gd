extends Interactable
class_name Item

static var holdingItem : Item
@export var itemCollisionParent : Node

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)
	if !mouseRay.is_empty():
		holding_item_logic()

func holding_item_logic():
	if holdingItem == null:
		position = position
	elif holdingItem == self:
		if (Station.hoveringStation == null):
			position = mouseRay["position"]
		else:
			position = Station.hoveringStation.itemSpotMarker.global_position


func on_just_left_clicked():
	print("Hi there!")
	print(mouseRay["collider"])
	print(itemCollisionParent)
	var colNode : CollisionShape3D = itemCollisionParent.get_node("CollisionShape3D")
	if !mouseRay.is_empty():
		if (mouseRay["collider"] == itemCollisionParent):
			colNode.set_deferred("disabled", true)
			if (holdingItem == null):
				holdingItem = self
			elif (holdingItem == self):
				print("Self!")
			else:
				print("Mix!")
		else:
			print("gh...")
			holdingItem = null
			itemCollisionParent.get_node("CollisionShape3D").set_deferred("disabled", false)

	print(holdingItem)


func on_just_right_clicked():
	pass # Replace with function body.
