extends Interactable
class_name Jar

@export var jarredItem : Item
@export var displayedItem : Item


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)


func on_just_left_clicked():
	print(mouseRay != {})
	print(%StaticBody3D == mouseRay["collider"])
	if mouseRay != {} and mouseRay["collider"] == %StaticBody3D:
		if Item.holdingItem:
			pass
		else:
			var heldItemDupe : Item = jarredItem.duplicate()
			heldItemDupe.itemColor = jarredItem.itemColor
			heldItemDupe.update_item_color()
			heldItemDupe.itemCollisionParent = heldItemDupe.get_child(0).get_node("StaticBody3D")
			heldItemDupe.get_node("MouseInteractableComponent").colCheck = heldItemDupe.itemCollisionParent
			heldItemDupe.insert_to_tree()
			Item.holdingItem = heldItemDupe
			heldItemDupe.itemCollisionParent.get_node("CollisionShape3D").set_deferred("disabled", true)
