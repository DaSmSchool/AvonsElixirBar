extends Control
class_name CookbookPage

@export var startingPage: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func add_line(line: String):
	#if %RecipeLines.get_children().size() > 0:
		#var lastRecipeLine = %RecipeLines.get_children().back()
		#if not lastRecipeLine.text:
			#lastRecipeLine.get_parent().remove_child(lastRecipeLine)
#
	#var newRecipeLine = RichTextLabel.new()
	#newRecipeLine.text = line
	#%RecipeLines.add_child(newRecipeLine)
	#
	#await Hud.hud.get_tree().process_frame
	#
	#format_line(newRecipeLine)
	pass

func can_add_to_page(rtl: RichTextLabel) -> bool:
	print(%RecipeTitle.get_content_height())
	var titleSize = %RecipeTitle.get_content_height()
	var ingSize = %IngredientsList.get_content_height()
	var instrSize = 0.0
	
	for line in %RecipeLines.get_children():
		if line != %RecipeLines.get_children().back():
			instrSize += line.get_content_height()
	
	var existingSize = titleSize + ingSize + instrSize
	return existingSize + rtl.get_content_height() <= size.y

func format_line(rtl: RichTextLabel):
	if not can_add_to_page(rtl):
		CookbookMenu.shift_page(false)
		CookbookMenu.focusPage.add_line(rtl.text)
	else:
		var updPos = 0
		if %RecipeLines.get_children().size() > 0:
			updPos = %RecipeLines.get_children().back().size.y + %RecipeLines.get_children().back().position.y
		rtl.position.y = updPos
		rtl.show()
		
func format_recipe_header(recipe: Recipe):
	var ingList = %IngredientsList
	var recTitle = %RecipeTitle
	var recLines = %RecipeLines
	
	ingList.position.y = recTitle.position.y + recTitle.size.y
	recLines.position.y = ingList.position.y + ingList.size.y
