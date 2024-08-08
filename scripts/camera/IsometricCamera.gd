extends Node3D

# Variables para controlar la cámara
@export var target: Node3D # El objetivo que la cámara sigue
@export var distance: float = 10.0 # Distancia de la cámara al objetivo
@export var rotation_speed: float = 1.0 # Velocidad de rotación de la cámara
@export var height: float = 15.0 # Altura de la cámara respecto al objetivo

# Variables internas
var angle: float = 0.0

func _ready():
	target = $"../Movable"

func _process(delta: float) -> void:
	if target != null:
		# Actualiza el ángulo según la entrada del usuario
		angle += Input.get_action_strength("rotate_left") * rotation_speed * delta
		angle -= Input.get_action_strength("rotate_right") * rotation_speed * delta

		# Calcula la nueva posición de la cámara
		var offset: Vector3 = Vector3(sin(angle) * distance, height, cos(angle) * distance)
		global_transform.origin = target.global_transform.origin + offset

		# Apunta la cámara hacia el objetivo
		look_at(target.global_transform.origin, Vector3.UP)
