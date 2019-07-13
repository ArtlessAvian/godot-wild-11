extends Node2D

func _process(_delta):
	# Insertion sort is best for mostly sorted items.
	# I don't think it will get too unruly, otherwise itll suck.
	for i in range(1, self.get_child_count()):
		var cursor = i;
		while cursor != 0 and is_behind(self.get_child(cursor), self.get_child(cursor-1)):
			self.move_child(self.get_child(cursor), cursor-1);
			cursor -= 1;
	if Input.is_action_just_pressed("ui_home"):
		for child in self.get_children():
			print(child.true_pos.z);

static func is_behind(entity, other):
	return entity.true_pos.z > other.true_pos.z;
