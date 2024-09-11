extends Character

enum DIRECTION {LEFT = -1, RIGHT = 1}

@onready var nav_path: Path3D = %NavigationPath
@onready var nav_path_follower: PathFollow3D = %NavigationPathFollower

var is_moving: bool = false
# Variables de configuración
var max_speed = 2.0  # Velocidad máxima en unidades por segundo
var acceleration_duration = 4.0  # Duración en segundos para alcanzar la velocidad máxima
var deceleration_progress = 0.75  # Distancia desde el final de la curva donde comenzará a desacelerar
var start_time = 0.0  # Tiempo de inicio del movimiento
var acceleration_ratio = 0.0

func _ready():
	nav_path_follower.progress = 0.0
	set_target_position(Vector3(25,0, 25))
	rotation_speed = 1.0
	move_speed = 0.0

func _process(delta):
	if is_moving:
		move(delta)

func get_current_acceleration(progress_ratio: float) -> float:
	var elapsed_time = (Time.get_ticks_msec() / 1000.0) - start_time
	var distance_to_end = 1.0 - progress_ratio
	# Ease-in at first
	if elapsed_time < acceleration_duration:
		acceleration_ratio = elapsed_time / acceleration_duration
	# Ease-in at end
	elif distance_to_end < deceleration_progress:
		acceleration_ratio = distance_to_end / deceleration_progress
		acceleration_ratio = acceleration_ratio if acceleration_ratio > 0.2 else 0.2
	# Max speed otherwise
	else:
		acceleration_ratio = 1.0
	return acceleration_ratio

func get_current_speed(progress_ratio: float) -> float:
	var current_acceleration = get_current_acceleration(progress_ratio)
	return lerp(0.0, max_speed, current_acceleration)

func advance_curve_progress(progress_ratio):
	# If progress ratio does not exceed 1.0, we can progress, otherwise stop
	if nav_path_follower.progress_ratio + progress_ratio <= 1.0:
		nav_path_follower.progress_ratio += progress_ratio
		global_transform.origin = nav_path_follower.global_transform.origin
	else:
		nav_path_follower.progress_ratio = 1.0
		is_moving = false
		move_speed = 0

func get_real_position() -> Vector3:
	return	nav_path_follower.global_transform.origin

func move(delta):
	move_speed = get_current_speed(nav_path_follower.progress_ratio)
	#var new_progress_ratio = move_speed * delta * 0.1
	#advance_curve_progress(new_progress_ratio)
	nav_path_follower.progress += move_speed * delta
	var a_p_ratio = nav_path_follower.progress_ratio
	print(move_speed)
	#look_at(nav_path_follower.global_transform.origin + nav_path_follower.transform.basis.z, Vector3.UP)

		
func get_target_direction(target_pos: Vector3) -> DIRECTION:
	# Get looking at
	var lookin_at = -transform.basis.z
	var direction_vec_from_lookin_point = (target_pos - lookin_at).abs()
	var direction = DIRECTION.RIGHT if direction_vec_from_lookin_point.x >= direction_vec_from_lookin_point.z else DIRECTION.LEFT
	return direction

func get_turn_direction_point(start_pos: Vector3,target_pos: Vector3) -> Vector3:
	var direction_vector = target_pos - start_pos
	# Make sure the y axis doesnt influence the calculus
	direction_vector.y = 0
	var direction = get_target_direction(target_pos)
	var mid_point = (start_pos + target_pos) / 2
	# Get the normal to direction vector
	var normal = Vector3(direction_vector.z, 0, -direction_vector.x)
	normal.x = sign(normal.x)
	normal.z = sign(normal.z)
	mid_point += direction * normal * rotation_speed
	return mid_point

# Para cambiar la curva dinámicamente
func set_target_position(target_pos: Vector3):
	if nav_path_follower:
		var start_pos = global_transform.origin
		var middle_pos = get_turn_direction_point(start_pos, target_pos)

		# Limpiar y añadir nuevos puntos a la curva
		nav_path.curve.clear_points()
		nav_path.curve.add_point(start_pos)
		nav_path.curve.add_point(middle_pos)
		nav_path.curve.add_point(target_pos)
		nav_path_follower.loop = false
		nav_path_follower.progress = 0 # Reinicia el offset para empezar el movimiento
		is_moving = true
		start_time = Time.get_ticks_msec() / 1000.0  # Obtener el tiempo actual en segundos
		acceleration_ratio = 0.0
