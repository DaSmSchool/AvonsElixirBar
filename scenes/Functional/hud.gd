extends Control
class_name Hud
##UI functionality for the main game loop

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
		update_item_action_panels()
	elif not $"ItemDescribe/ItemActionDrawPanels".get_children().is_empty():
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
			itemBoxText.text = hit_obj.itemName
		elif (hit_obj is Station):
			itemBox.show()
			itemBoxText.text = hit_obj.stationName
		else:
			itemBox.hide()


func update_item_action_panels():
	var itemBox : Panel = $"ItemDescribe"
	var hit_obj = ViewCameraReference.raycast_result["collider"].get_parent().get_parent()
	if hit_obj is Item:
		var heightOffset = itemBox.size.y
		var deepItemActionList = get_item_actions_deep(hit_obj)
		for objInd in deepItemActionList.size():
			var currItemAction : ItemAction = deepItemActionList[objInd]
			var currPanel = itemActionPanel.instantiate()
			itemBox.get_node("ItemActionDrawPanels").add_child(currPanel)
			currPanel.position.y = heightOffset + (objInd*currPanel.size.y)
			
			currPanel.get_node("Text").text = currItemAction.actionMessage
			var textGet : RichTextLabel = currPanel.get_node("Text")
			print(textGet)
			if currPanel.get_node("Text") != null:
				print(textGet.get_class())
				print(textGet.text)
			print_rich("[wave amp=50.0 freq=5.0 connected=1][b]" + str(objInd) + "[/b] " + str(currPanel.position.y) + "[/wave]")

## Returns a list of all [ItemAction] within an [Item]
func get_item_actions_deep(item : Item):
	var itemActionList = []
	var furtherItems = []
	for action in item.itemActionsApplied:
		itemActionList.append(action)
		if action.assocItem != null:
			furtherItems.append(action.assocItem)
	for deepItem in furtherItems:
		itemActionList.append_array(get_item_actions_deep(deepItem))
	return itemActionList


func _on_move_left_view_pressed():
	emit_signal("left_press")


func _on_move_right_view_pressed():
	emit_signal("right_press")
