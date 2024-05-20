extends Station
class_name Grinder


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	set_station_name("Grinder")
	if assocHud == null:
		set_assoc_hud(load("res://scenes/Functional/HUD/StationHud/GrinderHud.tscn").instantiate())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)
	

func perform_station_action():
	%AnimationPlayer.play("Pickup")

func mash_action():
	%AnimationPlayer.play("Smash")


func leave_station():
	%AnimationPlayer.play_backwards("Pickup")
