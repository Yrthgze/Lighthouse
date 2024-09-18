extends MeshInstance3D

# Variable para el tiempo
var time = 0.0

func _process(delta):
	# Actualizamos el tiempo en cada frame
	time += delta

	# Accedemos al material del shader y actualizamos el valor de la uniform 'time'
	if mesh.material:
		mesh.material.set_shader_parameter("time", time)
