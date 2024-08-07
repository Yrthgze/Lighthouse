extends Node3D

var TentacleScene = preload("res://scenes/enemies/tentacle.tscn")
var target_position: Vector3

# Called when the node enters the scene tree for the first time.
func _ready():
	target_position = $Scene/Lighthouse.global_transform.origin
	spawn_multiple_tentacles(5, 20.0)  # Crea 5 tentáculos con un radio de 20 unidades

func generate_random_position_around_target(radius: float) -> Vector3:
	var random_offset = Vector3(
		randf_range(-radius, radius),
		0,
		randf_range(-radius, radius)
	)
	return target_position + random_offset

func spawn_tentacle(position: Vector3):
	var tentacle_instance = TentacleScene.instantiate()
	tentacle_instance.get_node("tentacle_grouped/Armature/Skeleton3D/Tentacle").scale = Vector3(0.1,0.1,0.1)
	tentacle_instance.global_transform.origin = position
	add_child(tentacle_instance)
	
	# Activar la animación 'idle'
	var anim_player = tentacle_instance.get_node("tentacle_grouped/AnimationPlayer")

	anim_player.play("Idle")

func spawn_multiple_tentacles(count: int, radius: float):
	for i in range(count):
		var position = generate_random_position_around_target(radius)
		spawn_tentacle(position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
