extends Control
class_name CookbookPage

@export var startingPage : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func add_line(line : String):
	var lastRecipeLine = %RecipeLines.get_children()[0]
	var newRecipeLine : RichTextLabel
	if lastRecipeLine.text:
		newRecipeLine = lastRecipeLine
	else:
		newRecipeLine = RichTextLabel.new()
		%RecipeLines.add_child(newRecipeLine)
	newRecipeLine.text = line
	
	# NEEDS to have noting running after it, since call_deferred is more like a queue addition
	call_deferred("format_line", newRecipeLine)


func can_add_to_page(rtl : RichTextLabel):
	var titleSize = 0.0
	var ingSize = 0.0
	if %RecipeTitle.text:
		titleSize = %RecipeTitle.scale.y
		ingSize = %IngredientsList.scale.y
	var instrSize = 0.0
	var recipeLineTexts : Array = %RecipeLines.get_children()
	for line : RichTextLabel in recipeLineTexts:
		if line == recipeLineTexts[recipeLineTexts.size()-1]:
			continue
		instrSize += line.scale.y
	
	var existingSize = titleSize + ingSize + instrSize
	if existingSize + rtl.scale.y > scale.y:
		return false
	return true
	
func format_line(rtl : RichTextLabel):
	if !can_add_to_page(rtl):
		CookbookMenu.shift_page(false)
	var recipeLineTexts : Array = %RecipeLines.get_children()
	var lastRecipeLine = recipeLineTexts[recipeLineTexts.size()-1]
	rtl.position.y = lastRecipeLine.position.y + lastRecipeLine.scale.y
