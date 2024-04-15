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
		if holdingItem == null:
			position = position
		elif holdingItem == self:
			position = mouseRay["position"]
			if Input.is_action_just_pressed("action"):
				holdingItem = null
				itemCollisionParent.get_node("CollisionShape3D").set_deferred("disabled", false)


func _on_just_left_clicked():
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
	print(holdingItem)


func _on_just_right_clicked():
	pass # Replace with function body.
