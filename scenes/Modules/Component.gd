class_name Component
extends Node

@export var parent : Node
func _ready():
	assert(get_parent() != null, "Parent " + name + " to a parent, dummy!")
	parent = get_parent()
	print(parent.name)
