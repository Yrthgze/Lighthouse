extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	$tentacle_grouped/Armature/Skeleton3D/Tentacle.scale = Vector3(0.1,0.1,0.1)
	$tentacle_grouped/AnimationPlayer.play("Idle")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
