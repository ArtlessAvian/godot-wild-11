extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var dimension : int = 0;
var hitlag : float = 0;
export (NodePath) var player_path;
var player_node : Entity;

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in $YSort.get_children():
		var _a = (child as Entity).connect("hit_someone", self, "_Entity_hit_someone");
	self.player_node = self.get_node(player_path);

func _process(delta):
	self.dimension = player_node.dimension;
	if not get_tree().paused:
		for child in $YSort.get_children():
			if (child as Entity).dimension == self.dimension:
				child.modulate.a = min(1, child.modulate.a + delta * 5);
				child.get_node("Hitbox/CollisionShape2D").disabled = false;
			else:
				child.modulate.a = max(0, child.modulate.a - delta * 5);
				child.get_node("Hitbox/CollisionShape2D").disabled = true;
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if hitlag > 0:
		hitlag -= delta;
		if hitlag <= 0:
			get_tree().paused = false

func _Entity_hit_someone(_hitter, _hittee, lag):
	print("wowee")
	self.hitlag = lag;
	get_tree().paused = true