extends Node3D

var TentacleScene = preload("res://scenes/characters/enemies/tentacle.tscn")
var target_position: Vector3
@onready var lighthouse: Node3D = %Lighthouse

# Called when the node enters the scene tree for the first time.
func _ready():
	target_position = lighthouse.global_transform.origin
	spawn_multiple_tentacles(8, 20.0) 

func generate_random_position_around_target(radius: float) -> Vector3:
	var random_offset = Vector3(
		randf_range(-radius, radius),
		0,
		randf_range(-radius, radius)
	)
	return target_position + random_offset

func spawn_tentacle(spawn_position: Vector3):
	var tentacle_instance = TentacleScene.instantiate()
	tentacle_instance.set_target($Movable)
	tentacle_instance.global_transform.origin = spawn_position
	add_child(tentacle_instance)


func spawn_multiple_tentacles(count: int, radius: float):
	for i in range(count):
		var spawn_position = generate_random_position_around_target(radius)
		spawn_tentacle(spawn_position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
