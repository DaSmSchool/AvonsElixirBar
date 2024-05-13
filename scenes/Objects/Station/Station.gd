extends Interactable
class_name Station

signal item_hovering(station:Station)

var stationName : String = "DefStationName"

@export var stationCollisionParent : Node
@export var itemSpotMarker : Node3D
static var hoveringStation : Station

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(stationCollisionParent != null, "Collision for all Stations are not defined! Check the Stack Frames to see which one needs it.")
	super._ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)
	if !mouseRay.is_empty():
		var hoverObj = mouseRay["collider"].get_parent().get_parent()
		if (hoverObj is Station):
			#print("IN!!")
			if (hoverObj == self):
				hoveringStation = self
		else:
			#print("OUT!!")
			hoveringStation = null


func perform_station_action():
	push_warning("Station " + self.get_class() + " needs to have an overloaded version of perform_station_action!")


func set_station_name(name : String):
	stationName = name


func on_just_left_clicked():
	if mouseRay != {}:
		if mouseRay["collider"].get_parent().get_parent() == self:
			perform_station_action()
