extends CharacterBody3D

var speed : float = 10.0
@onready var nav_path: PathFollow3D = %NavigationPath
@onready var nav_path_follower: PathFollow3D = %NavigationPathFollower

func _ready():
	nav_path_follower.unit_offset = 0

func _process(delta):
	if nav_path_follower:
		# Avanzar a lo largo de la curva
		nav_path_follower.unit_offset += speed * delta * 0.01
		global_transform.origin = nav_path_follower.global_transform.origin

		# Opcional: hacer que el barco mire en la dirección en la que se mueve
		look_at(nav_path_follower.global_transform.origin + nav_path_follower.transform.basis.z, Vector3.UP)

# 5,0 -> 0,5 (-5,5)  0-5, 5-0
# (x1 + x2) / 2, (y1 + y2) / 2
#
#
#

func get_turn_direction_point(start_pos: Vector3,target_pos: Vector3) -> Vector3:
	var turn_vector = target_pos - start_pos
	var mid_point = (start_pos + target_pos) / 2
	var turn_point = mid_point + turn_vector 
	return turn_vector

# Para cambiar la curva dinámicamente
func set_target_position(target_pos: Vector3):
	var start_pos = global_transform.origin
	var middle_pos = get_turn_direction_point(start_pos, target_pos)

	# Limpiar y añadir nuevos puntos a la curva
	nav_path.curve.clear_points()
	nav_path.curve.add_point(start_pos)
	nav_path.curve.add_point(middle_pos)
	nav_path.curve.add_point(target_pos)

	nav_path_follower.unit_offset = 0 # Reinicia el offset para empezar el movimiento
