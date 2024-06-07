extends Node
class_name JarLogic


static var jarScene : PackedScene = preload("res://scenes/Objects/Jar/Jar.tscn")
static var jarList : Array[Node] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	jarList = get_children()
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

static func update_shelf_jars():
	clear_jar_shelf()
	print(GameStatus.availableItems)
	for itr in GameStatus.availableItems.size():
		var newJar : Jar = jarScene.instantiate()
		jarList[itr].add_child(newJar)
		newJar.global_position = jarList[itr].global_position
		newJar.jarredItem = GameStatus.availableItems[itr]
		newJar.displayedItem = GameStatus.availableItems[itr]
		newJar.add_child(newJar.displayedItem)
		newJar.displayedItem.update_item_color()
		newJar.displayedItem.global_position = newJar.get_node("ItemSpot").global_position
		newJar.displayedItem.scale = Vector3(0.75, 0.75, 0.75)


static func clear_jar_shelf():
	for jar in jarList:
		if jar.get_children() != []:
			for node : Node in jar.get_children():
				node.queue_free()
			
