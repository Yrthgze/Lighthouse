extends Node3D

var target: Node3D
var move_speed: float = 0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	$".".scale = Vector3(0.1,0.1,0.1)
	$tentacle_grouped/AnimationPlayer.play("Idle")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_towards_target(delta)

func set_target(new_target: Node3D):
	target = new_target

func move_towards_target(delta: float):
	# Mueve el tentáculo hacia el objetivo
	var direction = (target.position - global_transform.origin).normalized()
	global_transform.origin += direction * move_speed * delta

	# Gira el tentáculo para que mire hacia el objetivo
	look_at(target.position, Vector3.UP)
