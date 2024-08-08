extends Node3D

class_name Character

@export var health: int = 100
@export var move_speed: float = 0.5
@export var attack_damage: int = 10
@export var attack_range: float = 2.0
var target: Character
var is_attacking: bool = false
var anim_player:AnimationPlayer
var particles:GPUParticles3D
var audio_stream:AudioStreamPlayer3D
var this_name

func set_target(new_target: Character):
	target = new_target

func reduce_health(amount: int):
	health -= amount
	print(self.name + " healt: " + str(health))
	if health <= 0:
		destroy_character()

func destroy_character():
	print("Character destroyed")
	queue_free()  # Elimina el nodo del faro o puedes desencadenar una animación de destrucción

func move_towards_target_pos(delta: float, target_position):
	# Mueve el tentáculo hacia el objetivo
	var direction = (target_position - global_transform.origin).normalized()
	global_transform.origin += direction * move_speed * delta

func is_in_attack_range():
	if global_transform.origin.distance_to(target.position) <= attack_range:
		return true
	return false
	
func attack_animation():
	push_error("This character requires an attack animation")
	
func attack_sound():
	push_error("This character requires an attack sound")

func start_attack():
	is_attacking = true
	attack_animation()
	attack_sound()
	apply_damage_to_target()
	
func stop_attack():
	#TODO
	pass

func apply_damage_to_target():
	if target.position.distance_to(global_transform.origin) <= attack_range:
		target.reduce_health(attack_damage)
