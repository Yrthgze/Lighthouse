extends CharacterBody3D

var speed : float = 300.0
@onready var nav_path: Path3D = %NavigationPath
@onready var nav_path_follower: PathFollow3D = %NavigationPathFollower
var rotation_speed = 1.0

func _ready():
	nav_path_follower.progress = 0.0
	set_target_position(Vector3(10,0, 10))

func _process(delta):
	if nav_path_follower:
		# Avanzar a lo largo de la curva
		nav_path_follower.progress += speed * delta * 0.01
		global_transform.origin = nav_path_follower.global_transform.origin

		# Opcional: hacer que el barco mire en la dirección en la que se mueve
		look_at(nav_path_follower.global_transform.origin + nav_path_follower.transform.basis.z, Vector3.UP)

# 5,0 -> 0,5 (-5,5)  0-5, 5-0
# (x1 + x2) / 2, (y1 + y2) / 2
# (2.5, 2.5) - (-5, 5) = 7.5, -2.5
# (-5,5) normal -> (5, 5)
#

func get_turn_direction_point(start_pos: Vector3,target_pos: Vector3) -> Vector3:
	var direction_vector = target_pos - start_pos
	# Make sure the y axis doesnt influence the calculus
	direction_vector.y = 0
	# Producto cruzado para determinar si el objetivo está a la izquierda o derecha
	var lookin_at = -transform.basis.z
	var direction_vec_from_lookin_point = (target_pos - lookin_at).abs()
	var direction = 1
	if direction_vec_from_lookin_point.x < direction_vec_from_lookin_point.z:
		direction = -1
	
	var mid_point = (start_pos + target_pos) / 2
	# Get the normal to direction vector
	var normal = Vector3(direction_vector.z, 0, -direction_vector.x)
	normal.x /= abs(normal.x)
	normal.z /= abs(normal.z)
	mid_point += direction * normal * rotation_speed
	return mid_point

# Para cambiar la curva dinámicamente
func set_target_position(target_pos: Vector3):
	var start_pos = global_transform.origin
	var middle_pos = get_turn_direction_point(start_pos, target_pos)

	# Limpiar y añadir nuevos puntos a la curva
	nav_path.curve.clear_points()
	nav_path.curve.add_point(start_pos)
	nav_path.curve.add_point(middle_pos)
	nav_path.curve.add_point(target_pos)

	nav_path_follower.progress = 0 # Reinicia el offset para empezar el movimiento
