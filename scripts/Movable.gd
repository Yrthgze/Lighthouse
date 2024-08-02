extends Node3D

@export var move_speed: float = 5.0

func _process(delta: float) -> void:
	var direction = Vector3.ZERO
	
	# Detectar entrada de las teclas de flecha
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	elif Input.is_action_pressed("ui_right"):
		direction.x += 1
	
	# Mover el target en la dirección indicada
	global_transform.origin += direction * move_speed * delta
