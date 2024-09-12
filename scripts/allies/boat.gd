extends Character

enum DIRECTION {LEFT = -1, RIGHT = 1}

@onready var nav_path: Path3D = %NavigationPath
@onready var nav_path_follower: PathFollow3D = %NavigationPathFollower

var is_moving: bool = true
# Variables de configuración
var max_speed = 2.0  # Velocidad máxima en unidades por segundo
var acceleration_duration = 4.0  # Duración en segundos para alcanzar la velocidad máxima
var deceleration_progress = 0.25  # Distancia desde el final de la curva donde comenzará a desacelerar
var start_time = 0.0  # Tiempo de inicio del movimiento
var acceleration_ratio = 0.0

func _ready():
	nav_path_follower.progress = 0.0
	rotation_speed = 1.0
	move_speed = 0.0

func _process(delta):
	if is_moving:
		move(delta)

func get_current_acceleration(progress_ratio: float) -> float:
	var elapsed_time = (Time.get_ticks_msec() / 1000.0) - start_time
	var distance_to_end = 1.0 - progress_ratio
	var current_acceleration = 0
	# Ease-in at first, only if not accelerated yet
	if elapsed_time < acceleration_duration:
		current_acceleration = elapsed_time / acceleration_duration
	# Ease-in at end
	elif distance_to_end < deceleration_progress:
		current_acceleration = distance_to_end / deceleration_progress
		current_acceleration = current_acceleration if current_acceleration > 0.2 else 0.2
	# Max speed otherwise
	else:
		current_acceleration = 1.0
	return current_acceleration

func get_current_speed(progress_ratio: float) -> float:
	acceleration_ratio = get_current_acceleration(progress_ratio)
	return lerp(0.0, max_speed, acceleration_ratio)

func advance_curve_progress(progress):
	nav_path_follower.progress += progress
	# If progress ratio does not exceed 1.0, we can progress, otherwise stop
	if nav_path_follower.progress_ratio >= 1.0:
		nav_path_follower.progress_ratio = 1.0
		is_moving = false
		move_speed = 0		

func get_real_position() -> Vector3:
	return	nav_path_follower.global_transform.origin

func move(delta):
	move_speed = get_current_speed(nav_path_follower.progress_ratio)
	advance_curve_progress(move_speed * delta)
		
func get_target_direction(target_pos: Vector3) -> DIRECTION:
	var actual_pos = get_real_position()
	var current_pos_2d = Vector2(actual_pos.x, actual_pos.z)
	var basis_matrix = nav_path_follower.transform.basis
	var current_forward_2d = Vector2(-basis_matrix.z.x, -basis_matrix.z.z)
	var target_pos_2d = Vector2(target_pos.x, target_pos.z)

	# Calculate direction towards the objective
	var direction_to_target_2d = (target_pos_2d - current_pos_2d).normalized()
	# Normalize, just in case
	current_forward_2d = current_forward_2d.normalized()
	# Calculate the determinant
	var determinant = current_forward_2d.x * direction_to_target_2d.y - current_forward_2d.y * direction_to_target_2d.x
	# Detect the direction from the determinant
	if determinant > 0:
		return DIRECTION.RIGHT
	else:
		return DIRECTION.LEFT

func get_turn_direction_point(start_pos: Vector3,target_pos: Vector3) -> Vector3:
	var direction_vector = target_pos - start_pos
	# Make sure the y axis doesnt influence the calculus
	direction_vector.y = 0
	var direction = get_target_direction(target_pos)
	var direction_normalized = direction_vector.normalized()
	var mid_point = (start_pos + target_pos) / 2
	
	# Get the normal to direction vector, I THINK THIS ONE
	#var normal = Vector3(direction_vector.z, 0, -direction_vector.x)
	#normal.x = sign(normal.x)
	#normal.z = sign(normal.z)
	#3. Obtener la normal (perpendicular) al vector de dirección para definir la base de cálculo
	var normal_vector = Vector3(direction_normalized.z, 0, -direction_normalized.x)
	
	mid_point += direction * normal_vector * rotation_speed
	return mid_point

func calculate_in_points(start_point: Vector3, mid_point: Vector3, target_point: Vector3, distance_factor: float) -> Dictionary:
	var points_in = {}

	# Calcula la dirección del punto "in" del punto medio
	var direction_to_mid = (mid_point - start_point).normalized()
	var mid_in_point = mid_point - direction_to_mid * distance_factor
	points_in["mid_in"] = -mid_in_point

	# Calcula la dirección del punto "in" del punto objetivo
	var direction_to_target = (target_point - mid_point).normalized()
	var target_in_point = target_point - direction_to_target * distance_factor
	points_in["target_in"] = -target_in_point

	return points_in

# Para cambiar la curva dinámicamente
func set_target_position(target_pos: Vector3):
	if nav_path_follower:
		var real_pos = get_real_position()
		var start_pos = real_pos
		var middle_pos = get_turn_direction_point(start_pos, target_pos)
		
		#TBD, get the IN points for middle and target points
		var points_in = calculate_in_points(start_pos, middle_pos, target_pos, 5.0)
		# Limpiar y añadir nuevos puntos a la curva
		nav_path.curve.clear_points()
		nav_path.curve.add_point(start_pos)
		nav_path.curve.add_point(middle_pos, points_in["mid_in"])
		nav_path.curve.add_point(target_pos, points_in["target_in"])
		nav_path.curve.bake_interval
		nav_path_follower.loop = false
		nav_path_follower.progress = 0 # Reinicia el offset para empezar el movimiento
		#Reset acceleration only if not moving
		if not is_moving:
			is_moving = true
			start_time = Time.get_ticks_msec() / 1000.0  # Obtener el tiempo actual en segundos
			acceleration_ratio = 0.0
		
		%curveVisualizer.set_path(nav_path)
