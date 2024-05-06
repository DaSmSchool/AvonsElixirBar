extends Control
class_name Hud

signal left_press
signal right_press
signal item_changed(ray_result : Dictionary)

@export var ViewCameraReference : ViewCam
var oldRayDict = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if oldRayDict != ViewCameraReference.raycast_result:
		item_changed.emit(ViewCameraReference.raycast_result)
	oldRayDict = ViewCameraReference.raycast_result


func _on_move_left_view_pressed():
	emit_signal("left_press")


func _on_move_right_view_pressed():
	emit_signal("right_press")
