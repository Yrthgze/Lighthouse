extends Path3D
@onready var curves_manager = $"."
@onready var curves_follower = %CurvesFollower
var Utils = load("res://scripts/utils/utils.gd").new()
var follower_node: Node3D

var is_moving: bool = false
# Variables de configuración
var max_speed = 2.0  # Velocidad máxima en unidades por segundo
var acceleration_duration = 4.0  # Duración en segundos para alcanzar la velocidad máxima
var deceleration_progress = 0.25  # Distancia desde el final de la curva donde comenzará a desacelerar
var start_time = 0.0  # Tiempo de inicio del movimiento
var acceleration_ratio = 0.0
var rotation_speed = 2.0
var final_pos
var curve_rotation_degrees = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	curves_follower.progress = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func get_real_position() -> Vector3:
	return	curves_follower.global_transform.origin
	
func get_real_rotation() -> Vector3:
	return	curves_follower.get_global_rotation_degrees()

func get_progress_ratio() -> float:
	return curves_follower.progress_ratio
	
func get_turn_direction_point(start_pos: Vector3,target_pos: Vector3) -> Vector3:
	var direction_vector = target_pos - start_pos
	var direction = Utils.get_target_direction(get_real_position(), Utils.get_looking_at(curves_follower), target_pos)
	var direction_normalized = Utils.normalize_xz(direction_vector)
	var mid_point = (start_pos + target_pos) / 2
	# Get the normal to direction vector, I THINK THIS ONE
	#var normal = Vector3(direction_vector.z, 0, -direction_vector.x)
	#normal.x = sign(normal.x)
	#normal.z = sign(normal.z)
	#3. Obtener la normal (perpendicular) al vector de dirección para definir la base de cálculo
	var normal_vector = Vector3(direction_normalized.y, 0, -direction_normalized.x)
	
	mid_point += direction * normal_vector * rotation_speed
	return mid_point

func advance_curve_progress(progress):
	var last_prog_rat = curves_follower.progress_ratio
	curves_follower.progress += progress
	var new_prog_rat = curves_follower.progress_ratio
	var prog_ratio = new_prog_rat - last_prog_rat
	var rotation = curve_rotation_degrees * prog_ratio
	follower_node.global_transform.origin = get_real_position()
	follower_node.set_global_rotation_degrees(get_real_rotation())
	# If progress ratio does not exceed 1.0, we can progress, otherwise stop
	if curves_follower.progress_ratio >= 1.0:
		curves_follower.progress_ratio = 1.0
		is_moving = false

func calculate_in_points(start_point: Vector3, mid_point: Vector3, target_point: Vector3, distance_factor: float) -> Dictionary:
	var points_in = {}

	# Calcula la dirección del punto "in" del punto medio
	var direction_to_mid = Utils.normalize_xz(mid_point - start_point)
	var mid_in_point = mid_point - direction_to_mid * distance_factor
	points_in["mid_in"] = -mid_in_point

	# Calcula la dirección del punto "in" del punto objetivo
	var direction_to_target = Utils.normalize_xz(target_point - mid_point)
	var target_in_point = target_point - direction_to_target * distance_factor
	points_in["target_in"] = -target_in_point

	return points_in

func calculate_rotation_degrees(start: Vector2, lookin_at: Vector2, target: Vector2):
	var lookin_at_vector = lookin_at - start
	curve_rotation_degrees = rad_to_deg(lookin_at_vector.angle_to(target))

func set_target_position(new_follower_node: Node3D, target_pos: Vector3):
	if curves_follower:
		final_pos = target_pos
		follower_node = new_follower_node
		var real_pos = get_real_position()
		var start_pos = real_pos
		var middle_pos = get_turn_direction_point(start_pos, target_pos)
		
		#TBD, get the IN points for middle and target points
		var points_in = calculate_in_points(start_pos, middle_pos, target_pos, 5.0)
		# Limpiar y añadir nuevos puntos a la curva
		curves_manager.curve.clear_points()
		curves_manager.curve.add_point(start_pos)
		curves_manager.curve.add_point(middle_pos)#, points_in["mid_in"])
		curves_manager.curve.add_point(target_pos)#, points_in["target_in"])
		
		calculate_rotation_degrees(Utils.get_xz(start_pos), Utils.get_looking_at(curves_follower, Utils.MODE.TWOD), Utils.get_xz(target_pos))

		curves_follower.loop = false
		curves_follower.progress = 0 # Reinicia el offset para empezar el movimiento
		
		%curveVisualizer.set_path(curves_manager)
