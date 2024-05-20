extends StationHud
class_name GrinderHud


var stationEntering = false
var readyToDelete = false

# Called when the node enters the scene tree for the first time.
func _ready():
	init_action_button_control()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	process_view_buttons()
	
	
	#if readyToDelete:
		#queue_free()

func enter_station_hud():
	if self not in Hud.hud.get_node("StationHudControl").get_children():
		Hud.hud.get_node("StationHudControl").add_child(self)
	stationEntering = true
	action_buttons_timer_init()


func exit_station_hud():
	Hud.hud.on_station_update(false)
	ViewCam.cam.leave_station_view()
	stationEntering = false
	action_buttons_timer_init()
	Station.activeStation = null


func process_view_buttons():
	var actionButtonGroup : Control = $StationActionButtonControl
	var timer : Timer = $StationActionButtonControl/MoveTransitionTimer
	var timerProgress = timer.time_left/timer.wait_time
	if stationEntering:
		actionButtonGroup.position = actionButtonGroup.position.lerp(Vector2(0, 0), 1-timerProgress)
	else:
		actionButtonGroup.position = actionButtonGroup.position.lerp(Vector2(0, 150), 1-timerProgress)
		if timerProgress == 0:
			readyToDelete = true


func _on_leave_pressed():
	exit_station_hud()
	if assocStation is Grinder:
		assocStation.leave_station()


func _on_mash_pressed():
	if assocStation is Grinder:
		assocStation.mash_action()


func init_action_button_control():
	$StationActionButtonControl.position = Vector2(0, 150)


func action_buttons_timer_init():
	var actionButtonGroup = $StationActionButtonControl
	var timer : Timer = $StationActionButtonControl/MoveTransitionTimer
	timer.start()
