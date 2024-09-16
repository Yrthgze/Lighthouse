extends Character

var Utils = load("res://scripts/utils/utils.gd").new()
@onready var boat = %Boat

var is_moving: bool = false
# Variables de configuración
var max_speed = 2.0  # Velocidad máxima en unidades por segundo
var acceleration_duration = 4.0  # Duración en segundos para alcanzar la velocidad máxima
var deceleration_progress = 0.25  # Distancia desde el final de la curva donde comenzará a desacelerar
var start_time = 0.0  # Tiempo de inicio del movimiento
var acceleration_ratio = 0.0

func _ready():
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

func get_real_position() -> Vector3:
	return	%CurvesManager.get_real_position()

func move(delta):
	move_speed = get_current_speed(%CurvesManager.get_progress_ratio())
	%CurvesManager.advance_curve_progress(move_speed * delta)

# Para cambiar la curva dinámicamente
func set_target_position(target_pos: Vector3):
	#Reset acceleration only if not moving
	if not is_moving:
		is_moving = true
		start_time = Time.get_ticks_msec() / 1000.0  # Obtener el tiempo actual en segundos
		acceleration_ratio = 0.0
	%CurvesManager.set_target_position(boat, target_pos)
