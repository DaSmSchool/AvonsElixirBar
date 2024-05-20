extends Interactable
class_name Station

signal item_hovering(station:Station)

var stationName : String = "DefStationName"

@export var stationCollisionParent : Node
@export var itemSpotMarker : Node3D
@export var AssocView : Node3D
@export var assocHud : StationHud
@export var heldItem : Item
static var hoveringStation : Station
static var activeStation : Station

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(stationCollisionParent != null, "Collision for all Stations are not defined! Check the Stack Frames to see which one needs it.")
	super._ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)
	print(heldItem)
	if !mouseRay.is_empty():
		var hoverObj = mouseRay["collider"].get_parent().get_parent()
		if (hoverObj is Station):
			#print("IN!!")
			if (hoverObj == self):
				hoveringStation = self
		else:
			#print("OUT!!")
			hoveringStation = null


func enter_hud_behaviour():
	var hud : Hud = get_tree().current_scene.get_node("HUD")
	assert(hud != null, "Could not find the HUD in the root scene!")
	hud.on_station_update(true)
	
	
func enter_cam_behaviour():
	if AssocView != null:
		var cam : ViewCam = get_assoc_cam()
		assert(cam != null, "Could not find a ViewCam object in the root scene!")
		cam.switch_to_station_view(self)
	

func enter_station_outside_action():
	enter_hud_behaviour()
	enter_cam_behaviour()


func perform_station_action():
	push_warning("Station " + self.get_class() + " needs to have an overloaded version of perform_station_action!")


func set_station_name(newName : String):
	stationName = newName


func set_assoc_hud(hud : StationHud):
	assocHud = hud
	hud.assocStation = self


func get_assoc_hud():
	return assocHud


func on_just_left_clicked():
	if mouseRay != {}:
		if mouseRay["collider"].get_parent().get_parent() == self:
			if Item.holdingItem == null:
				perform_station_action()
				if assocHud:
					assocHud.enter_station_hud()
				enter_station_outside_action()
				activeStation = self
