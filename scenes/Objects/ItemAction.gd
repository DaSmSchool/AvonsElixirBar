## Describes an action performed onto an Item.
extends Node
class_name ItemAction

## Set to true if this action hasn't actually been performed. 
##[br]
## False should be used for actions that have been valid, and performed.
var blankAction = true
## The action performed.
@export var actionType : String
## The message used for displaying this ItemAction.
@export var actionMessage : String
## How long the action was performed.
@export var duration : float
## An associated item that was referenced during the action.
@export var assocItem : Item
## The station used to perform the action.
@export var stationPerformed : Station
## Accuracy of the action out of 100
@export var accuracy : int


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


## Provides the action with all action variables.
func assign_vals(action:String, msg:String, dur:float, assoc:Item, statPerf:Station, acc:int):
	clear_blank()
	actionType = action
	actionMessage = msg
	duration = dur
	assocItem = assoc
	stationPerformed = statPerf
	accuracy = acc


func clear_blank():
	blankAction = false
