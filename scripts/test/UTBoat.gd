extends Node

func _ready():
	run_tests()

func run_tests():
	test_get_turn_direction_point()
	
func assert_vector3(p1: Vector3, p2: Vector3, msg: String):
	assert(p1.is_equal_approx(p2), msg)

func test_get_turn_direction_point():
	var boat = $".."
	boat.look_at(Vector3(0, 0, 4))
	var turn_dir_point1 = boat.get_turn_direction_point(Vector3(0, 0, 0), Vector3(6, 0, 6))
	#assert_vector3(Vector3(4, 0, 2), turn_dir_point1, "Turning point is not the expected")
	
	boat.look_at(Vector3(4, 0, 0))
	var turn_dir_point2 = boat.get_turn_direction_point(Vector3(0, 0, 0), Vector3(6, 0, 6))
	#assert_vector3(Vector3(2, 0, 4), turn_dir_point2, "Turning point is not the expected")
