extends "res://scenes/characters/character.gd"

@export var rotation_speed: float = 90.0 # Velocidad de rotación en grados por segundo
	
func _process(delta: float) -> void:
	var rotation_amount = 0.0

	# Detectar entrada de las teclas
	if Input.is_action_pressed("rotate_lighthouse_left"):
		rotation_amount -= rotation_speed * delta
	if Input.is_action_pressed("rotate_lighthouse_right"):
		rotation_amount += rotation_speed * delta

	# Aplicar la rotación al faro
	$Lightbulb/SpotLight3D.rotate_y(rotation_amount * deg_to_rad(1))
