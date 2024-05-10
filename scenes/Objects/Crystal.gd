extends Item
class_name Crystal


var crystalMat = load("res://materials/crystalshards.material")

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	set_used_mat(crystalMat)
	give_random_color()
	set_item_name("Crystal")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)
