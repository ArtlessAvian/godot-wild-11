extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var dimension : int = 0;
var visual_dimension : float = 0;
var hitlag : float = 0;
export (NodePath) var player_path;
var player_node : Entity;

var comboing = [];
var combo_grace : float = 0;
var combo_counter : int = 0;

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
			else:
				child.modulate.a = max(0, child.modulate.a - delta * 5);
	
	# TODO: TEMPORARY.
	if abs(self.visual_dimension - self.dimension) < delta * 5:
		self.visual_dimension = self.dimension;
	else:
		self.visual_dimension += sign(self.dimension - self.visual_dimension) * delta * 5;
	$"0effort".modulate = Color.from_hsv(visual_dimension/PI, 0.5-cos(visual_dimension)/2, 1, 1);
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	if Input.is_action_just_pressed("ui_page_up"):
		self.dimension += 1;
		player_node.dimension += 1;
		self.combo_grace = 2;
	if Input.is_action_just_pressed("ui_page_down"):
		self.dimension -= 1;
		player_node.dimension -= 1;
		self.combo_grace = 2;
	
	for child in $YSort.get_children():
		if (child as Entity).dimension == self.dimension:
			child.get_node("Hitbox/CollisionShape2D").disabled = false;
		else:
			child.get_node("Hitbox/CollisionShape2D").disabled = true;
	
	if not get_tree().paused:
		for index in range(len(self.comboing)-1, -1, -1):
			var entity : Entity = self.comboing[index];
#			print(entity.state_machine.get_current_node())
			if not entity.state_machine.get_current_node() in ["Oof", "Knockdown"]:
				self.comboing.remove(index);
				print("Not comboing ", entity)
		if combo_counter != 0 and self.comboing.empty():
			print("Combo Ended at ", self.combo_counter);
			self.combo_counter = 0;
		
		if combo_grace > 0:
			if self.comboing.empty():
				self.combo_grace -= delta;
		else:
			self.dimension = 0;
			player_node.dimension = 0;
	else:
		hitlag -= delta;
		if hitlag <= 0:
			get_tree().paused = false


func _Entity_hit_someone(hitter, hittee, lag):
	self.hitlag = lag;
	get_tree().paused = true;
	if hitter == player_node:
		self.combo_grace = 2;
		if not hittee in self.comboing:
			self.comboing.append(hittee)
		self.combo_counter += 1;
		print(self.combo_counter);
