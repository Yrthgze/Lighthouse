extends Character
class_name Tentacle

var is_in_attack_range:bool

# Called when the node enters the scene tree for the first time.
func _ready():
	is_in_attack_range = false
	$".".scale = Vector3(0.1,0.1,0.1)
	$tentacle_grouped/AnimationPlayer.play("Idle")
	anim_player = $tentacle_grouped/AnimationPlayer
	#TODO particles = $tentacle_grouped/Particles
	#TODO audio_stream = $tentacle_grouped/AudioStream

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_towards_target_pos(delta, target.position)
	is_in_attack_range = is_in_attack_range()
	if is_attacking and not is_in_attack_range:
		stop_attack()
	if not is_attacking and is_in_attack_range:
		start_attack()
	
func move_towards_target_pos(delta: float, target_position):
	super.move_towards_target_pos(delta, target_position)
	# Rotates the tentacle to look at position
	look_at(target_position, Vector3.UP)

func attack_animation():
	print("Attak animation")
	#TODO anim_player.play("attack")
	if particles:
		particles.emitting = true
	
func attack_sound():
	print("Attak sound")
	if audio_stream:
		audio_stream.play()
