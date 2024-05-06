extends Control
class_name Hud

signal left_press
signal right_press
signal item_changed(ray_result : Dictionary)

@export var ViewCameraReference : ViewCam
var oldRayDict = {}

var itemActionPanel = preload("res://scenes/Functional/item_action_panel.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if oldRayDict != ViewCameraReference.raycast_result:
		item_changed.emit(ViewCameraReference.raycast_result)
		update_item_hover_hud()
	
	oldRayDict = ViewCameraReference.raycast_result


func update_item_hover_hud():
	update_item_name_draw()
	if $"ItemDescribe".visible:
		pass
	elif $"ItemDescribe/ItemActionDrawPanels".get_children().is_empty():
		# remove all panels related to drawing ItemAtion related material
		for child in $"ItemDescribe/ItemActionDrawPanels".get_children():
			child.queue_free()

func update_item_name_draw():
	var itemBox : Panel = $"ItemDescribe"
	var itemBoxText : RichTextLabel = $"ItemDescribe/Text"
	
	if (ViewCameraReference.raycast_result == {}):
		itemBoxText.text = ""
	else:
		var hit_obj = ViewCameraReference.raycast_result["collider"].get_parent().get_parent()
		if (hit_obj is Item):
			itemBox.show()
			itemBoxText.text = hit_obj.name
		else:
			itemBox.hide()


func update_item_action_panels():
	var itemBox : Panel = $"ItemDescribe"
	var hit_obj = ViewCameraReference.raycast_result["collider"].get_parent().get_parent()
	if hit_obj is Item:
		var heightOffset = itemBox.size.y
		for objInd in hit_obj.itemActionsApplied.size():
			var currItemAction : ItemAction = hit_obj.itemActionsApplied[objInd]
			var currPanel = itemActionPanel.instantiate()
			currPanel.position.y = heightOffset + (objInd*currPanel.position.size.y)
			currPanel.get_node("Text").text = currItemAction.actionMessage


func _on_move_left_view_pressed():
	emit_signal("left_press")


func _on_move_right_view_pressed():
	emit_signal("right_press")
