tool
extends Node2D
class_name Entity
signal hit_someone # self, who i hit, hitlag

# Has a position in 3D space.
# Handles where the Entity should be drawn.

const Z_DISTANCE = 0;
const GRAVITY = 1200;
const HITSTUN_FRICTION = 100;
const KNOCKDOWN_RECOVERY = 50;

var true_pos : Vector3;
var grounded : bool;
#var dimension : int; # Probably could be just a bool

# If its good enough for SM64, it's good enough for me.
var ground_vel : Vector3 = Vector3.ZERO;
var air_vel : Vector3 = Vector3.ZERO;
var knockback : Vector2 = Vector2.ZERO; # Generally only X and Y

var hitstun : float = 0;
var knockdown : bool = false;

func _ready():
	self.true_pos = Vector3(self.position.x, 0, self.position.y);
#	self.air_vel = Vector3(300, 300, 0);
	
func _process(_delta : float):
	if not Engine.editor_hint:
		self.position.x = self.true_pos.x;
		self.position.y = -self.true_pos.y - self.true_pos.z * 0.5;
	if Input.is_action_just_pressed("ui_home"):
		self.air_vel.y = 600;
		self.grounded = false;

func _physics_process(_delta):
	if self.hitstun <= 0 and not knockdown:
		if grounded:
			self.true_pos += self.ground_vel * _delta;
		else:
			self.true_pos += self.air_vel * _delta;
			self.air_vel.y -= GRAVITY * _delta;
	else:
		self.true_pos.x += self.knockback.x * _delta;
		if grounded:
			self.knockback.x -= sign(self.knockback.x) * max(0, 10 * _delta)
		else:
			self.true_pos.y += self.knockback.y * _delta;
			self.knockback.y -= GRAVITY * _delta;
		
		hitstun -= _delta
		if hitstun <= 0:
			if not self.grounded:
				self.air_vel.x = self.knockback.x;
				self.air_vel.y = self.knockback.y;
			$AnimationPlayer.play("Idle");
	
	if self.true_pos.y <= 0:
		if not knockdown or self.knockback.y < KNOCKDOWN_RECOVERY:
			self.grounded = true;
			self.true_pos.y = 0;
			self.air_vel = Vector3.ZERO;
		else:
			self.knockback.y *= -0.5;
	
	self.true_pos.z = clamp(self.true_pos.z, -200, 200);

func check_relevance(player : Entity):
	var relevant : bool = abs(player.true_pos.z - self.true_pos.z) < Z_DISTANCE;
	if relevant:
		pass

# Hitting each other
func _on_Hurtboxes_area_entered(area : Area2D):
	var entity : Entity = area.get_parent();
	self.emit_signal("hit_someone", self, entity, 0.2)
	print(self.name, " hit someone!")
#	entity.receive_knockback(self, Vector2(5, 0), 0.3);
	entity.call_deferred("receive_knockback", self, Vector2(300, 600), 0.5, false);

func receive_knockback(hitter : Entity, kb : Vector2, hs : float, kd : bool):
	self.knockback = kb;
	print(self.name, " got hit!")
	if hitter.true_pos.x > self.true_pos.x:
		self.knockback.x *= -1;
	if self.knockback.y > 0:
		self.grounded = false;
	self.hitstun = hs;
	self.knockdown = kd;
	$Hurtboxes/CollisionShape2D.disabled = true;
	$AnimationPlayer.play("Oof");
