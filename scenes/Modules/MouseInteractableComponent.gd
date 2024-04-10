class_name MouseInteractable
extends Component

signal left_clicked
signal right_clicked

@export var hasMouseOver = false
@export var staticColCheck : StaticBody3D
@export var raycastResult = {}
var camera
var colID

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	var read_camera = get_tree().root.get_camera_3d()
	assert(read_camera.name == "ViewCam", "You should be using a ViewCam scene! Or you just renamed your Camera3D object.")
	camera = read_camera
	
	if (staticColCheck != null):
		colID = staticColCheck.get_instance_id()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if camera != null and camera.raycast_result.has("collider_id"):
		hasMouseOver = camera.raycast_result["collider_id"] == colID
		raycastResult = camera.raycast_result
		if (hasMouseOver): 
			if (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
				emit_signal("left_clicked", raycastResult["collider"])
				get_node(raycastResult[colID])
			if (Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)):
				emit_signal("right_clicked", raycastResult["collider"])
			print(raycastResult)
		
	else:
		raycastResult = {}
	
