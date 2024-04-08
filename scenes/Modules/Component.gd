class_name Component
extends Node

var parent
func _ready():
	assert(get_parent() != null, "Parent " + name + " to a parent, dummy!")
	parent = get_parent()
