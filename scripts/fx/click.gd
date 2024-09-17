extends MeshInstance3D

var visible_time = 0.5  # Duración visible del efecto
var timer = 0.0
var effect_active = false

func _ready():
	# Crear un cilindro hueco
	var cylinder_mesh = CylinderMesh.new()
	cylinder_mesh.bottom_radius = 1.0  # Radio inferior
	cylinder_mesh.top_radius = 1.0  # Radio superior
	cylinder_mesh.height = 0.1  # Altura del cilindro
	mesh = cylinder_mesh

	# Crear el material con resplandor (emisión)
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.2, 0.8, 1.0, 0.5)  # Color azul con transparencia
	material.emission_enabled = true
	material.emission = Color(0.2, 0.8, 1.0)  # Color de emisión
	material.emission_energy = 1.5  # Intensidad del resplandor
	mesh.material_override = material

	visible = false  # Ocultar el efecto al inicio

func _process(delta):
	if effect_active:
		timer -= delta
		if timer <= 0.0:
			visible = false  # Ocultar el efecto
			effect_active = false
		else:
			# Aquí podrías agregar efectos como aumentar la altura del cilindro
			scale.y += delta * 2.0  # Ejemplo: hacer que crezca hacia arriba

# Activar el efecto en una posición dada
func activate_effect(position: Vector3):
	global_transform.origin = position
	visible = true
	timer = visible_time
	effect_active = true
	scale = Vector3(1, 1, 1)  # Reiniciar escala
