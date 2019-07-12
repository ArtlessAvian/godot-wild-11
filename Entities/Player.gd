extends Entity

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var attacking : bool;
var can_transition : bool;
var transitions_into : Array; # of strings

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _physics_process(delta):
	
	# Get a list of strings given the current controller input?
