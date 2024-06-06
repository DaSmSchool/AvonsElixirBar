extends Control
class_name Hud
##UI functionality for the main game loop

signal left_press
signal right_press
signal item_changed(ray_result : Dictionary)

@export var ViewCameraReference : ViewCam
var oldRayDict = {}

var itemActionPanel = preload("res://scenes/Functional/item_action_panel.tscn")
var lastObj

static var viewButtonsHidden : bool
static var viewButtonsHiddenProg : float

static var hud : Hud

# Called when the node enters the scene tree for the first time.
func _ready():
	hud = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if oldRayDict != ViewCameraReference.raycast_result:
		item_changed.emit(ViewCameraReference.raycast_result)
		update_item_hover_hud()
	
	process_view_buttons()
	
	oldRayDict = ViewCameraReference.raycast_result


func update_item_hover_hud():
	update_item_name_draw()
	if $"ItemDescribe".visible:
		update_item_action_panels()
	elif not $"ItemDescribe/ItemActionDrawPanels".get_children().is_empty():
		reset_item_action_panels()


func update_item_name_draw():
	var itemBox : Panel = $"ItemDescribe"
	var itemBoxText : RichTextLabel = $"ItemDescribe/Text"
	
	if (ViewCameraReference.raycast_result == {} or ViewCameraReference.raycast_result == null):
		itemBoxText.text = ""
	else:
		var hit_obj = ViewCameraReference.raycast_result["collider"].get_parent().get_parent()
		itemBox.show()
		if Item.holdingItem != null:
			change_name_text(itemBoxText, Item.holdingItem, Item.holdingItem.display_name())
		elif (hit_obj is Item):
			change_name_text(itemBoxText, hit_obj, hit_obj.display_name())
		elif (hit_obj is Station):
			change_name_text(itemBoxText, hit_obj, hit_obj.stationName)
		else:
			itemBox.hide()


func update_item_action_panels():
	reset_item_action_panels()
	var itemBox : Panel = $"ItemDescribe"
	if ViewCameraReference.raycast_result in [null, {}]: return
	var hit_obj = ViewCameraReference.raycast_result["collider"].get_parent().get_parent()
	if Item.holdingItem != null:
		hit_obj = Item.holdingItem
	if hit_obj is Item:
		var heightOffset = itemBox.size.y
		var deepItemActionList = []
		if hit_obj is Bottle:
			if hit_obj.containedLiquid:
				deepItemActionList.append("Liquid: " + hit_obj.containedLiquid.itemName)
				deepItemActionList.append_array(get_item_actions_deep(hit_obj.containedLiquid))
			if hit_obj.bottledItems:
				deepItemActionList.append("Items:")
				for item:Item in hit_obj.bottledItems:
					deepItemActionList.append(item.display_name())
					deepItemActionList.append_array(get_item_actions_deep(item))
		else:
			deepItemActionList.append_array(get_item_actions_deep(hit_obj))
		
		for objInd in deepItemActionList.size():
			var currItemAction = deepItemActionList[objInd]
			print(currItemAction)
			var currPanel = itemActionPanel.instantiate()
			itemBox.get_node("ItemActionDrawPanels").add_child(currPanel)
			currPanel.position.y = heightOffset + (objInd*currPanel.size.y)
			if currItemAction is ItemAction:
				currPanel.get_node("Text").text = currItemAction.actionMessage
			elif currItemAction is String:
				currPanel.get_node("Text").text = currItemAction
			#var textGet : RichTextLabel = currPanel.get_node("Text")
			#print(textGet)
			#if currPanel.get_node("Text") != null:
				#print(textGet.get_class())
				#print(textGet.text)
			#print_rich("[wave amp=50.0 freq=5.0 connected=1][b]" + str(objInd) + "[/b] " + str(currPanel.position.y) + "[/wave]")

func change_name_text(rtl : RichTextLabel, nameParent, newName : String):
	if lastObj == null:
		rtl.text = newName
		lastObj = nameParent
	else:
		if nameParent != lastObj:
			if newName != rtl.text:
				rtl.text = newName
			reset_item_action_panels()
			lastObj = nameParent


func reset_item_action_panels():
	# remove all panels related to drawing ItemAtion related material
	for child in $"ItemDescribe/ItemActionDrawPanels".get_children():
		child.queue_free()

## Returns a list of all [ItemAction] within an [Item]
func get_item_actions_deep(item : Item):
	var itemActionList = []
	var furtherItems = []
	#item.itemActionsApplied
	for action in item.itemActionsApplied:
		itemActionList.append(action)
	for deepItem in item.previousItemsInvolved:
		itemActionList.append_array(get_item_actions_deep(deepItem))
	return get_unique_list(itemActionList)


func get_unique_list(getList : Array):
	var uniqueArray = []
	for item in getList:
		if !uniqueArray.has(item):
			uniqueArray.append(item)
	return uniqueArray


func on_station_update(enteringStation : bool):
	viewButtonsHidden = enteringStation
	view_switch_buttons_on_station_change()


func process_view_buttons():
	var viewButtonGroup : Control = $ViewSwitchButtonControl
	var timer : Timer = $ViewSwitchButtonControl/PosSwitch
	var timerProgress = timer.time_left/timer.wait_time
	if viewButtonsHidden:
		viewButtonGroup.position = viewButtonGroup.position.lerp(Vector2(0, 80), 1-timerProgress)
	else:
		viewButtonGroup.position = viewButtonGroup.position.lerp(Vector2(0, 0), 1-timerProgress)


func view_switch_buttons_on_station_change():
	var viewButtonGroup = $ViewSwitchButtonControl
	var timer : Timer = viewButtonGroup.get_node("PosSwitch")
	timer.start()


func _on_move_left_view_pressed():
	emit_signal("left_press")


func _on_move_right_view_pressed():
	emit_signal("right_press")
