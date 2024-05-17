class_name MouseInteractable
extends Component

signal mouse_left_clicked
signal mouse_right_clicked
signal mouse_just_left_clicked
signal mouse_just_right_clicked

@export var hasMouseOver = false
@export var colCheck : Node
@export var raycastResult = {}
static var clickResults = {
	"just_press_left" : false,
	"press_left" : false,
	"just_press_right" : false,
	"press_right" : false
}
static var camera
var colID

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	set_block_signals(false)
	if camera == null:
		var read_camera = get_tree().root.get_camera_3d()
		assert(read_camera.name == "ViewCam", "You should be using a ViewCam scene! Or you just renamed your Camera3D object.")
		camera = read_camera
	
	if (colCheck != null):
		colID = colCheck.get_instance_id()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if camera == null or camera.raycast_result == null: return
	if camera != null and camera.raycast_result.has("collider_id"):
		hasMouseOver = camera.raycast_result["collider_id"] == colID
		raycastResult = camera.raycast_result
		if (hasMouseOver): 
			if (Input.is_action_pressed("action")):
				clickResults["press_left"] = true
				print("Clicked on " + raycastResult["collider"].name + "!")
			else:
				clickResults["press_left"] = false
			if (Input.is_action_pressed("back_action")):
				clickResults["press_right"] = true
				print("Right Clicked on " + raycastResult["collider"].name + "!")
			else:
				clickResults["press_right"] = false
			if (Input.is_action_just_pressed("action")):
				clickResults["just_press_left"] = true
				print("Just clicked on " + raycastResult["collider"].name + "!")
			else:
				clickResults["just_press_left"] = false
			if (Input.is_action_just_pressed("back_action")):
				clickResults["just_press_right"] = true
				print("Just right Clicked on " + raycastResult["collider"].name + "!")
			else:
				clickResults["just_press_right"] = false
			#print(raycastResult)
		
	else:
		raycastResult = {}
	
