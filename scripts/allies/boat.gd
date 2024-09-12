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
	#set_target_position(Vector3(0,0, 5))
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
	
	#var new_progress_ratio = move_speed * delta * 0.1
	advance_curve_progress(move_speed * delta)
	"var current_position = get_real_position()
	var future_progress = nav_path_follower.progress + (move_speed * delta * 0.1)
	var future_position = nav_path.curve.get_point_in(future_progress)
	# Calcula la dirección hacia la que el bote debe mirar
	var direction_to_look = (future_position - current_position).normalized()
	direction_to_look.y = 0  # Ignorar el eje Y para mantener el barco en el plano horizontal
	# Interpola suavemente la rotación del bote hacia la dirección calculada
	%RealBoat.look_at(current_position + direction_to_look, Vector3.UP)"

		
func get_target_direction(target_pos: Vector3) -> int:
	# Obtener la posición actual del objeto en 2D (X, Z)
	var actual_pos = get_real_position()
	var current_pos_2d = Vector2(actual_pos.x, actual_pos.z)
	# Obtener la dirección actual del objeto en 2D (X, Z)
	var basis_matrix = nav_path_follower.transform.basis
	var current_forward_2d = Vector2(-basis_matrix.z.x, -basis_matrix.z.z)
	# Obtener la posición objetivo en 2D (X, Z)
	var target_pos_2d = Vector2(target_pos.x, target_pos.z)

	# Calcular el vector de dirección hacia el objetivo
	var direction_to_target_2d = (target_pos_2d - current_pos_2d).normalized()
	# Normalizar la dirección actual (por seguridad, aunque ya debería estar normalizado)
	current_forward_2d = current_forward_2d.normalized()

	# Calcular el determinante para decidir la dirección
	var determinant = current_forward_2d.x * direction_to_target_2d.y - current_forward_2d.y * direction_to_target_2d.x

	# Determinar la dirección basándose en el signo del determinante
	if determinant > 0:
		return 1  # Derecha
	else:
		return -1  # Izquierda

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

# Para cambiar la curva dinámicamente
func set_target_position(target_pos: Vector3):
	if nav_path_follower:
		var real_pos = get_real_position()
		var start_pos = real_pos
		var middle_pos = get_turn_direction_point(start_pos, target_pos)

		# Limpiar y añadir nuevos puntos a la curva
		nav_path.curve.clear_points()
		nav_path.curve.add_point(start_pos)
		nav_path.curve.add_point(middle_pos)
		nav_path.curve.add_point(target_pos)
		nav_path.curve.bake_interval
		nav_path_follower.loop = false
		nav_path_follower.progress = 0 # Reinicia el offset para empezar el movimiento
		#Reset acceleration only if not moving
		if not is_moving:
			is_moving = true
			start_time = Time.get_ticks_msec() / 1000.0  # Obtener el tiempo actual en segundos
			acceleration_ratio = 0.0
		
		%curveVisualizer.set_path(nav_path)
