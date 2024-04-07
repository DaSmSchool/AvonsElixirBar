extends Control
signal left_press
signal right_press

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_move_left_view_pressed():
	emit_signal("left_press")


func _on_move_right_view_pressed():
	emit_signal("right_press")
