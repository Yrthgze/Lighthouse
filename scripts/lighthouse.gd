extends "res://scenes/characters/character.gd"

@export var rotation_speed: float = 90.0 # Rotation speed
	
func _process(delta: float) -> void:
	var rotation_amount = 0.0

	# Detect input
	if Input.is_action_pressed("rotate_lighthouse_left"):
		rotation_amount -= rotation_speed * delta
	if Input.is_action_pressed("rotate_lighthouse_right"):
		rotation_amount += rotation_speed * delta

	# Rotate the Lighthouse
	$Lightbulb/SpotLight3D.rotate_y(rotation_amount * deg_to_rad(1))
