tool
extends Label

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export (NodePath) var nodepath;
export (String) var property;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	self.text = str(self.get_node(nodepath).get(property));
