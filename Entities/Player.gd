extends Entity

var attacking : bool = false;

func _physics_process(_delta):
	var input : Vector3 = self.get_input()
	
	if attacking:
		if not $AnimationPlayer.is_playing():
			attacking = false;
		
	if not attacking:
		if grounded:
			if (input.length_squared() < 0.4):
				if not $AnimationPlayer.current_animation in ["StopWalking", "Idle"]:
					$AnimationPlayer.play("StopWalking");
					$AnimationPlayer.queue("Idle");
				else:
					match $AnimationPlayer.current_animation:
						"StopWalking":
							self.ground_vel *= 0.9;
						"Idle":
							self.ground_vel = Vector3.ZERO;
			else:
				match $AnimationPlayer.current_animation:
					"StopWalking":
						$AnimationPlayer.play("Run");
						self.ground_vel = input * 400;
					"Idle":
						$AnimationPlayer.play("Walk");
						self.ground_vel = input * 200;
					"Walk":
						self.ground_vel = input * 200;
					"Run":
						self.ground_vel = input * 400;
						
				if self.ground_vel.x != 0:
					self.scale.x = sign(self.ground_vel.x);
		
	if Input.is_action_just_pressed("ui_accept"):
		attacking = true;
		self.ground_vel = Vector3.ZERO;
		$AnimationPlayer.play("Light1");
	
#	._physics_process(delta);

static func get_input() -> Vector3:
	var input : Vector3 = Vector3();
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left");
	input.z = Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down");
	if input.length_squared() > 1:
		input = input.normalized();
	return input;
