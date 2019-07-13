tool
extends Node2D
class_name Entity
signal hit_someone # self, who i hit, hitlag

# Has a position in 3D space.
# Handles where the Entity should be drawn.

const Z_DISTANCE = 0;
const GRAVITY = 1200;
const FRICTION = 10;
const KNOCKDOWN_RECOVERY = 50;

var true_pos : Vector3;
var grounded : bool;
# warning-ignore:unused_class_variable
var dimension : int; # Probably could be just a bool

var input_vel : Vector2 = Vector2.ZERO;
var true_vel : Vector3 = Vector3.ZERO;

var hitstun : float = 0;
var knockdown : bool = false;
var health : int = 5;
export (bool) var friendly : bool = false;

var state_machine : AnimationNodeStateMachinePlayback;
var last_state : String = "";

export (Vector2) var attack_kb : Vector2 = Vector2(50, 0);
export (float) var attack_hitstun : float = 0.1;
export (bool) var attack_knocksdown : bool = false;

func _ready():
	self.true_pos = Vector3(self.position.x, 0, self.position.y * 2);
	self.state_machine = $AnimationTree.get("parameters/playback");

func _process(_delta : float):
	if not Engine.editor_hint:
		self.position.x = self.true_pos.x;
		self.position.y = -self.true_pos.y - self.true_pos.z * 0.5;

func _physics_process(delta):
	if Engine.editor_hint:
		# Hack, to stop the below statement from spamming debug
		return;
	
	if self.last_state != self.state_machine.get_current_node():	
		self.propagate_call(self.last_state + "Exit");
		self.propagate_call("anyTransition");
		self.propagate_call(self.state_machine.get_current_node() + "Enter");
		self.last_state = self.state_machine.get_current_node();
	self.propagate_call(self.state_machine.get_current_node() + "Run", [delta]);
	
	if hitstun <= 0 and self.grounded:
		self.true_vel.x = input_vel.x;
		self.true_vel.z = input_vel.y;
	else:
		if hitstun <= 0:
			self.accelerate_to(Vector2.ZERO);
		else:
			self.accelerate_to(self.input_vel);
#
#			var old_vel : Vector2 = Vector2(self.true_vel.x, self.true_vel.z);
#			var altered_vel : Vector2 = Vector2(self.true_vel.x, self.true_vel.z);
#			altered_vel += (self.input_vel - altered_vel).normalized() * FRICTION;
#			if (self.input_vel - altered_vel).dot(self.input_vel - old_vel) <= 0:
#				self.true_vel.x = self.input_vel.x;
#				self.true_vel.z = self.input_vel.y;
#			else:
#				self.true_vel.x = altered_vel.x;
#				self.true_vel.z = altered_vel.y;

	if not grounded:
		self.true_vel.y -= GRAVITY * delta;

	self.true_pos += self.true_vel * delta;

	# Reminder for myself:
	# Repeating myself here is correct.
	
	if not grounded:
		if self.true_pos.y <= 0:
			if knockdown:
				if self.true_vel.y < -50:
					print(self.true_vel.y);
					self.true_pos.y *= -1;
					self.true_vel.y *= -0.5;
				else:
					self.true_pos.y = 0;
					self.true_vel.y = 0;
					self.grounded = true;
			else:
				self.true_pos.y = 0;
				self.true_vel.y = 0;
				self.grounded = true;
				if not self.state_machine.get_current_node() in ["Oof"]:
					self.state_machine.start("Idle");
	
	if hitstun > 0 and (not knockdown or grounded):
		hitstun -= delta;
		if hitstun <= 0:
			if self.grounded:
				self.state_machine.start("Idle");
			else:
				self.state_machine.start("Idle");
	
#	else:
#		self.true_pos.x += self.knockback.x * delta;
#		if grounded:
#			self.true_vel.x -= sign(self.true_vel.x) * max(0, FRICTION * delta)
#		else:
#			self.true_pos.y += self.knockback.y * delta;
#			self.knockback.y -= GRAVITY * delta;
#
#		hitstun -= delta
#		if hitstun <= 0:
#			if not self.grounded:
#				self.air_vel.x = self.knockback.x;
#				self.air_vel.y = self.knockback.y;
#			self.state_machine.start("Idle");
#
#	if self.true_pos.y <= 0:
#		if not knockdown or self.knockback.y < KNOCKDOWN_RECOVERY:
#			self.grounded = true;
#			self.true_pos.y = 0;
#			self.air_vel = Vector3.ZERO;
#		else:
#			self.knockback.y *= -0.5;
	
	self.true_pos.z = clamp(self.true_pos.z, -200, 200);

func accelerate_to(target_velocity : Vector2):
	var old_vel : Vector2 = Vector2(self.true_vel.x, self.true_vel.z);
	var altered_vel : Vector2 = Vector2(self.true_vel.x, self.true_vel.z);
	altered_vel += (target_velocity - altered_vel).normalized() * FRICTION;
	if (target_velocity - altered_vel).dot(target_velocity - old_vel) <= 0:
		self.true_vel.x = target_velocity.x;
		self.true_vel.z = target_velocity.y;
	else:
		self.true_vel.x = altered_vel.x;
		self.true_vel.z = altered_vel.y;

func check_relevance(player : Entity):
	var relevant : bool = abs(player.true_pos.z - self.true_pos.z) < Z_DISTANCE;
	if relevant:
		pass

func anyTransition():
	self.attack_knocksdown = false;
	$Hurtboxes/CollisionShape2D.disabled = true;

# Hitting each other
func _on_Hurtboxes_area_entered(area : Area2D):
	var entity : Entity = area.get_parent();
	if (entity.friendly == self.friendly):
		return;
	
	self.emit_signal("hit_someone", self, entity, 0.2)
	print(self.name, " hit someone!")
#	entity.receive_knockback(self, Vector2(5, 0), 0.3);
	entity.call_deferred("receive_knockback", self, self.attack_kb, self.attack_hitstun, self.attack_knocksdown);

func receive_knockback(hitter : Entity, knockback : Vector2, hs : float, kd : bool):
	print(self.name, " got hit!")
	
	if hitter.true_pos.x > self.true_pos.x:
		knockback.x *= -1;
	if knockback.y > 0:
		self.grounded = false;
	self.true_vel.x = knockback.x;
	self.true_vel.y = knockback.y;
	self.true_vel.z = 0;
	self.input_vel = Vector2.ZERO;
	
	self.knockdown = kd;
	$Hurtboxes/CollisionShape2D.disabled = true;
	health -= 1;
	if health <= 0:
		self.state_machine.start("Dead");
		$Hitbox.collision_mask = 0;
	else:
		self.hitstun = hs;
		if kd:
			self.state_machine.start("Knockdown");
		else:
			self.state_machine.start("Oof");
	

# Animation Shenangians
# This would work, but https://github.com/godotengine/godot/issues/28311
#func _on_AnimationPlayer_animation_changed(old_name, new_name):
#	self.propagate_call(old_name + "Exit");
#	self.propagate_call(new_name + "Enter");
