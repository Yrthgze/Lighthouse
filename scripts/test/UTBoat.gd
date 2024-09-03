extends Node

func _ready():
	# Ejecutar las pruebas al iniciar la escena
	run_tests()

func run_tests():
	test_get_turn_direction_point()
	
func assert_vector3(p1: Vector3, p2: Vector3, msg: String):
	assert(p1.is_equal_approx(p2), msg)

func test_get_turn_direction_point():
	var boat = $"../CharacterBody3D"
	boat.look_at(Vector3(0, 0, 4))
	var turn_dir_point1 = boat.get_turn_direction_point(Vector3(0, 0, 0), Vector3(6, 0, 6))
	assert_vector3(Vector3(4, 0, 2), turn_dir_point1, "Turning point is not the expected")
