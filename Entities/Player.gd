extends Entity

const P_C : String = "parameters/conditions/"
const DEADZONE : float = 0.2;

export (bool) var attack_dimensional : bool = false;
var has_hit : bool = false;

static func get_input() -> Vector2:
	var input : Vector2 = Vector2();
	input.x = Input.get_action_strength("right") - Input.get_action_strength("left");
	input.y = Input.get_action_strength("up") - Input.get_action_strength("down");
	if input.length_squared() > 1:
		input = input.normalized();
	return input;

func _physics_process(_delta):
	var input : Vector2 = self.get_input();
	
	$AnimationTree.set(P_C + "input", input != Vector2.ZERO);
	$AnimationTree.set(P_C + "!input", input == Vector2.ZERO);
	$AnimationTree.set(P_C + "run", Input.is_action_pressed("run"));
	$AnimationTree.set(P_C + "jump", Input.is_action_pressed("jump"));
	$AnimationTree.set(P_C + "light", Input.is_action_just_pressed("light"));
	$AnimationTree.set(P_C + "heavy", Input.is_action_just_pressed("heavy"));
	$AnimationTree.set(P_C + "light_cancel", Input.is_action_just_pressed("light") and has_hit);
	$AnimationTree.set(P_C + "heavy_cancel", Input.is_action_just_pressed("heavy") and has_hit);
	$AnimationTree.set(P_C + "jump_cancel", Input.is_action_pressed("jump") and has_hit);
	$AnimationTree.set(P_C + "grounded", self.grounded);
	
	if Input.is_action_just_pressed("ui_page_up"):
		self.dimension += 1;
	if Input.is_action_just_pressed("ui_page_down"):
		self.dimension -= 1;
	
#	._physics_process(delta);

func RunRun(_delta : float):
	self.input_vel = get_input() * 400;
	if self.input_vel.x != 0:
		self.scale.x = sign(self.input_vel.x);
	self.has_hit = false;
	self.strong_friction = true;

func WalkRun(_delta : float):
	self.input_vel = get_input() * 200;
	if self.input_vel.x != 0:
		self.scale.x = sign(self.input_vel.x);
	self.has_hit = false;

func IdleRun(_delta : float):
	self.input_vel = Vector2.ZERO;
	self.has_hit = false;

func JumpRun(_delta : float):
	if self.grounded:
		self.grounded = false;
		self.true_vel.y += 300;
	self.has_hit = false;
	
func Light1Run(_delta : float):
	self.input_vel = Vector2.ZERO;
	self.light2_time = 0;
	
var light2_time : float = 0;
func Light2Run(delta : float):
	light2_time += delta;
	self.input_vel = Vector2(100 - 100 * light2_time, 0) * self.scale;

func Heavy1Run(_delta : float):
	self.input_vel = Vector2.ZERO;



func _on_Hurtboxes_area_entered(area : Area2D):
	._on_Hurtboxes_area_entered(area);
	if self.attack_dimensional:
		area.get_parent().dimension += 1;
	self.has_hit = true;

#func WalkExit():
#	self.input_vel = Vector3.ZERO;
#
#func RunExit():
#	self.input_vel = Vector3.ZERO;
	
