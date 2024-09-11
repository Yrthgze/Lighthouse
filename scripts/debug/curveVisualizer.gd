extends MeshInstance3D
@export var path: Path3D
@export var color: Color = Color(1, 0, 0)
@export var thickness: float = 0.1  # Grosor de la línea
@export var resolution: int = 50  # Número de segmentos para la curva visible

func _ready():
	set_path(%NavigationPath)

func set_path(new_path: Path3D):
	path = new_path
	if path:
		_draw_curve()

func _draw_curve():
	if not path or not path.curve:
		return
	
	var curve = path.curve
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_LINE_STRIP)
	surface_tool.set_color(color)

	# Calculamos el tamaño del paso para muestrear la curva.
	var curve_length = curve.get_baked_length()
	var step_size = curve_length / resolution
	
	# Dibujamos puntos en la curva en función de la longitud.
	for i in range(resolution + 1):
		var point = curve.sample(i * step_size, 0)
		surface_tool.add_vertex(point)

	# Crea el mesh y asígnalo al MeshInstance3D.
	var mesh = surface_tool.commit()
	self.mesh = mesh

