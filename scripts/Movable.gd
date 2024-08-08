extends Character

func _process(delta: float) -> void:
	var direction = Vector3.ZERO
	
	# Detect user input
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	elif Input.is_action_pressed("ui_right"):
		direction.x += 1
	
	# Move 
	global_transform.origin += direction * move_speed * delta
