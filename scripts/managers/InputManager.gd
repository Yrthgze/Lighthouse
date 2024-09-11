extends Node
var target: Node3D

func set_target(new_target: Node3D):
	target = new_target

func _on_sea_static_body_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		position = Vector3(position.x, 0, position.z)
		target.set_target_position(position)
