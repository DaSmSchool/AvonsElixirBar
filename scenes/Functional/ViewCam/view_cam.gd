extends Camera3D
class_name ViewCam

@export var maxRayDist = 2000

@export var raycast_result = {}

@export var camPointsParent : Node
var camPoints = {}
var camIndex = 0
var viewTarget : Node3D
var camSwitchProg = 0
var oldCameraTransitionPosition
var oldCameraTransitionRotation

var preStationPosition
var preStationRotation

static var cam

# Called when the node enters the scene tree for the first time.
func _ready():
	cam = self
	if camPointsParent != null:
		camPoints = camPointsParent.get_children()
		position = camPoints[0].position
		rotation = camPoints[0].rotation
		oldCameraTransitionPosition = position
		oldCameraTransitionRotation = rotation

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	ScreenPointToRay()
	updateCamViewSwitch(delta)
	if Input.is_action_just_pressed("switch_view_left"):
		_on_hud_left_press()
	if Input.is_action_just_pressed("switch_view_right"):
		_on_hud_right_press()
	

func ScreenPointToRay():
	var camera = get_tree().root.get_camera_3d()
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var norm_proj = camera.project_ray_normal(mouse_pos)
	var to = from + norm_proj * maxRayDist
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	ray_query.collide_with_areas = true
	raycast_result = space.intersect_ray(ray_query)
	if (raycast_result.has("position")):
		return raycast_result["position"]

func initTransitionToNextView():
	camSwitchProg = 0
	oldCameraTransitionPosition = position
	oldCameraTransitionRotation = rotation
	
func viewIndUpdate(amnt):
	camIndex += amnt
	if (camIndex < 0):
		camIndex += camPoints.size()
	if camIndex >= camPoints.size():
		camIndex -= camPoints.size()
	viewTarget = camPoints[camIndex]


func updateCamViewSwitch(delta):
	if viewTarget == null: return
	if camSwitchProg < PI/2:
		camSwitchProg += delta*4
		position = oldCameraTransitionPosition.lerp(viewTarget.position, sin(camSwitchProg))
		rotation = oldCameraTransitionRotation.lerp(viewTarget.rotation, sin(camSwitchProg))
	else:
		camSwitchProg = PI/2
		
		
func switch_to_station_view(station : Station):
	viewTarget = station.AssocView
	initTransitionToNextView()


func leave_station_view():
	viewTarget = camPoints[camIndex]
	initTransitionToNextView()


func _on_hud_left_press():
	if Station.activeStation == null:
		viewIndUpdate(-1)
		initTransitionToNextView()


func _on_hud_right_press():
	if Station.activeStation == null:
		viewIndUpdate(1)
		initTransitionToNextView()
