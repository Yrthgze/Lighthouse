extends Node3D

# Camera controlling variabel
@export var target: Node3D # El objetivo que la cámara sigue
@export var distance: float = 10.0 # Distancia de la cámara al objetivo
@export var rotation_speed: float = 1.0 # Velocidad de rotación de la cámara
@export var height: float = 15.0 # Altura de la cámara respecto al objetivo

#Private variables
var angle: float = 0.0

func _ready():
	target = $"../Boat"

func _process(delta: float) -> void:
	if target != null:
		# Update the angle from input
		angle += Input.get_action_strength("rotate_left") * rotation_speed * delta
		angle -= Input.get_action_strength("rotate_right") * rotation_speed * delta

		# Calculates the camera new position
		var offset: Vector3 = Vector3(sin(angle) * distance, height, cos(angle) * distance)
		global_transform.origin = target.global_transform.origin + offset

		# Makes the camera look at the position
		look_at(target.get_real_position(), Vector3.UP)
