extends Node3D

@export var path: Path3D
@export var curve_color: Color = Color(1, 0, 0)
@export var in_color: Color = Color(1, 0, 0)  # Verde para puntos "in"
@export var out_color: Color = Color(1, 0.5, 0)  # Azul para puntos "out"
@export var thickness: float = 0.1  # Grosor de la línea
@export var resolution: int = 50  # Número de segmentos para la curva visible

var curve_instance: MeshInstance3D = null
var in_points_instance: MeshInstance3D = null
var out_points_instance: MeshInstance3D = null

func _ready():
	set_path(%NavigationPath)

func set_path(new_path: Path3D):
	path = new_path
	if path:
		clear_visualizations()
		_draw_curve()
		_draw_control_points()

func clear_visualizations():
	# Elimina las instancias de malla existentes
	if curve_instance:
		curve_instance.queue_free()
		curve_instance = null

	if in_points_instance:
		in_points_instance.queue_free()
		in_points_instance = null

	if out_points_instance:
		out_points_instance.queue_free()
		out_points_instance = null

func _draw_curve():
	if not path or not path.curve:
		return
	
	var curve = path.curve
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_LINE_STRIP)
	surface_tool.set_color(curve_color)

	# Calculamos el tamaño del paso para muestrear la curva.
	var curve_length = curve.get_baked_length()
	var step_size = curve_length / resolution
	
	# Dibujamos puntos en la curva en función de la longitud.
	for i in range(resolution + 1):
		var point = curve.sample(i * step_size, 0)
		surface_tool.add_vertex(point)

	# Crear el mesh de la curva
	var curve_mesh = surface_tool.commit()
	curve_instance = MeshInstance3D.new()
	curve_instance.mesh = curve_mesh
	add_child(curve_instance)

func _draw_control_points():
	if not path or not path.curve:
		return
	
	var curve = path.curve
	var surface_tool_in = SurfaceTool.new()
	var surface_tool_out = SurfaceTool.new()
	
	# Dibujar los puntos "in"
	surface_tool_in.begin(Mesh.PRIMITIVE_POINTS)
	surface_tool_in.set_color(in_color)

	# Dibujar los puntos "out"
	surface_tool_out.begin(Mesh.PRIMITIVE_POINTS)
	surface_tool_out.set_color(out_color)

	for i in range(curve.get_point_count()):
		var pos = curve.get_point_position(i)
		var in_vec = curve.get_point_in(i)
		var out_vec = curve.get_point_out(i)

		# Añadir el punto in (en verde)
		surface_tool_in.add_vertex(pos + in_vec)

		# Añadir el punto out (en azul)
		surface_tool_out.add_vertex(pos + out_vec)
	
	# Crear las mallas de puntos "in" y "out"
	var in_mesh = surface_tool_in.commit()
	var out_mesh = surface_tool_out.commit()

	# Crear instancias de malla para los puntos "in" y "out"
	in_points_instance = MeshInstance3D.new()
	in_points_instance.mesh = in_mesh
	add_child(in_points_instance)

	out_points_instance = MeshInstance3D.new()
	out_points_instance.mesh = out_mesh
	add_child(out_points_instance)
