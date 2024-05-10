extends Interactable
class_name Station

signal item_hovering(station:Station)

@export var stationCollisionParent : Node
@export var itemSpotMarker : Node3D
static var hoveringStation : Station

# Called when the node enters the scene tree for the first time.
func _ready():
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

func _on_just_left_clicked():
	perform_station_action()
