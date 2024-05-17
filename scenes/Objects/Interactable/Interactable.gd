extends Node3D
class_name Interactable

signal left_clicked
signal right_clicked
signal just_left_clicked
signal just_right_clicked

@export var mouseRay = {}
var preLoadMouseInteract = load("res://scenes/Modules/MouseInteractableComponent.tscn")
var instMouseInteract : MouseInteractable
#var mouseInteract: MouseInteractable

# Called when the node enters the scene tree for the first time.
func _ready():
	instMouseInteract = preLoadMouseInteract.instantiate()
	instMouseInteract.name = "mouse_interact"
	add_child(instMouseInteract)
	#instMouseInteract.mouse_just_left_clicked.connect(_on_just_left_clicked)
	#instMouseInteract.connect("mouse_just_left_clicked", _on_just_left_clicked)
	#print(instMouseInteract.mouse_just_left_clicked.is_connected(_on_just_left_clicked))
	#instMouseInteract.connect("mouse_just_right_clicked", _on_just_right_clicked)
	#instMouseInteract.mouse_left_clicked.connect(_on_left_clicked)
	#instMouseInteract.connect("mouse_left_clicked", _on_left_clicked)
	#instMouseInteract.mouse_right_clicked.connect(_on_right_clicked)
	#instMouseInteract.connect("mouse_right_clicked", _on_right_clicked)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	mouseRay = instMouseInteract.raycastResult
	if (instMouseInteract.clickResults["just_press_left"]):
		just_left_clicked.emit()
		on_just_left_clicked()
	if (instMouseInteract.clickResults["just_press_right"]):
		just_right_clicked.emit()
		on_just_right_clicked()
	if (instMouseInteract.clickResults["press_left"]):
		left_clicked.emit()
		on_left_clicked()
	if (instMouseInteract.clickResults["press_right"]):
		right_clicked.emit()
		on_right_clicked()

func on_just_left_clicked():
	pass
	
	
func on_just_right_clicked():
	pass
	
	
func on_left_clicked():
	pass


func on_right_clicked():
	pass
	

func get_assoc_cam():
	return instMouseInteract.camera
