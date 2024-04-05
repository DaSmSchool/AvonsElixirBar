extends Camera3D

@export var maxRayDist = 2000

@export var raycast_result = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	ScreenPointToRay()

func ScreenPointToRay():
	var camera = get_tree().root.get_camera_3d()
	print(camera)
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * maxRayDist
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	ray_query.collide_with_areas = true
	raycast_result = space.intersect_ray(ray_query)
	if (raycast_result.has("position")):
		return raycast_result["position"]
