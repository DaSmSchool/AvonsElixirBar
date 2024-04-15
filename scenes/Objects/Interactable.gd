extends Node3D
class_name Interactable

signal left_clicked
signal right_clicked
signal just_left_clicked
signal just_right_clicked

@export var mouseRay = {}
var preLoadMouseInteract = load("res://scenes/Modules/MouseInteractableComponent.tscn")
var instMouseInteract
#var mouseInteract: MouseInteractable

# Called when the node enters the scene tree for the first time.
func _ready():
	instMouseInteract = preLoadMouseInteract.instantiate()
	instMouseInteract.name = "mouse_interact"
	add_child(instMouseInteract)
	print(instMouseInteract.name)
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
		_on_just_left_clicked()


func _on_left_clicked():
	print("hi!")
	left_clicked.emit()


func _on_right_clicked():
	print("tg!")
	right_clicked.emit()


func _on_just_left_clicked():
	print("xcv?!")
	just_left_clicked.emit()


func _on_just_right_clicked():
	print("tgasd!")
	just_right_clicked.emit()
