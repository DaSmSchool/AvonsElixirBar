extends TextureButton

var inBook : bool
var bookTransitionProgress = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	bookTransitionProgress += delta
	
	bookTransitionProgress = min(PI/2, bookTransitionProgress)
	print(bookTransitionProgress)
	
	if inBook:
		%CookbookMenu.position.y = lerpf(%CookbookMenu.position.y, 0, sin(bookTransitionProgress))
	else:
		%CookbookMenu.position.y = lerpf(%CookbookMenu.position.y, 720, sin(bookTransitionProgress))


func _on_toggled(toggled_on: bool) -> void:
	inBook = toggled_on
	bookTransitionProgress = 0
