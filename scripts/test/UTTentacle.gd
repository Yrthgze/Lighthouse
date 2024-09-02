extends Node

func _ready():
	# Ejecutar las pruebas al iniciar la escena
	run_tests()

func run_tests():
	test_get_turn_direction_point()

func test_get_turn_direction_point():
	var boat = $".."
	#var turn_dir_point1 = boat.get_turn_direction_point()
	#assert(boat.health == 10, "La vida del tentáculo debería ser 90 después de recibir 10 de daño")
