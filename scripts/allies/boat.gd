extends CharacterBody3D

var current_speed = 0.0 
@onready var nav_path: Path3D = %NavigationPath
@onready var nav_path_follower: PathFollow3D = %NavigationPathFollower
var rotation_speed = 1.0
var is_moving: bool = false
# Variables de configuración
var max_speed = 10.0  # Velocidad máxima en unidades por segundo
var acceleration_duration = 2.0  # Duración en segundos para alcanzar la velocidad máxima
var deceleration_distance = 5.0  # Distancia desde el final de la curva donde comenzará a desacelerar

func _ready():
	nav_path_follower.progress = 0.0
	set_target_position(Vector3(10,0, 10))

func _process(delta):
	if is_moving:
		var progress_ratio = nav_path_follower.progress_ratio
		var distance_to_end = 1.0 - progress_ratio
		 # Aceleración suave al principio
		if progress_ratio < (acceleration_duration * max_speed):
			# Ease-in al inicio
			var acceleration_ratio = progress_ratio / (acceleration_duration / nav_path.curve.get_baked_length())
			current_speed = lerp(0.0, max_speed, acceleration_ratio)
		# Desaceleración suave al final
		elif distance_to_end < deceleration_distance:
			# Ease-out al final
			current_speed = lerp(0.0, max_speed, distance_to_end / deceleration_distance)
		else:
			# Mantener la velocidad máxima
			current_speed = max_speed
		# Avanzar a lo largo de la curva
		nav_path_follower.progress_ratio += current_speed * delta * 0.01
		global_transform.origin = nav_path_follower.global_transform.origin

		look_at(nav_path_follower.global_transform.origin + nav_path_follower.transform.basis.z, Vector3.UP)
		
		if progress_ratio >= 0.9:
			nav_path_follower.progress_ratio = 1.0
			is_moving = false


func get_turn_direction_point(start_pos: Vector3,target_pos: Vector3) -> Vector3:
	var direction_vector = target_pos - start_pos
	# Make sure the y axis doesnt influence the calculus
	direction_vector.y = 0
	# Producto cruzado para determinar si el objetivo está a la izquierda o derecha
	var lookin_at = -transform.basis.z
	var direction_vec_from_lookin_point = (target_pos - lookin_at).abs()
	var direction = 1 if direction_vec_from_lookin_point.x >= direction_vec_from_lookin_point.z else -1

	
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

		nav_path_follower.progress = 0 # Reinicia el offset para empezar el movimiento
		is_moving = true
