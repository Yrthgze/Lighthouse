extends Character
class_name Tentacle

var in_attack_range:bool

# Called when the node enters the scene tree for the first time.
func _ready():
	in_attack_range = false
	attacking_timer = Timer.new()
	add_child(attacking_timer)
	attacking_timer.set_wait_time(0.5)
	attacking_timer.connect("timeout", _on_attack_timeout)
	$".".scale = Vector3(0.1,0.1,0.1)
	anim_player = %TentacleAnimation
	anim_player.play("Idle")
	#TODO particles = $tentacle_grouped/Particles
	#TODO audio_stream = $tentacle_grouped/AudioStream

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target != null:
		move_towards_target_pos(delta, target.position)
		in_attack_range = is_in_attack_range()
		if is_attacking and not in_attack_range:
			stop_attack()
		elif not is_attacking and in_attack_range:
			start_attack()
	
func move_towards_target_pos(delta: float, target_position):
	if not is_attacking:
		super.move_towards_target_pos(delta, target_position)
		# Rotates the tentacle to look at position
	look_at(target_position, Vector3.UP)

func _on_attack_timeout() -> void:
	print("Attacking again")
	apply_damage_to_target()

func attack_animation():
	print("Attack animation")
	#TODO anim_player.play("attack")
	if particles:
		particles.emitting = true
	
func attack_sound():
	print("Attack sound")
	if audio_stream:
		audio_stream.play()
