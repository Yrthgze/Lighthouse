# utils.gd
extends Object

enum DIRECTION {LEFT = -1, RIGHT = 1}
enum MODE {TWOD = 0, THREED = 1}

func get_looking_at(node3d: Node3D, dimension: MODE = MODE.THREED):
	var basis_matrix = node3d.transform.basis
	var current_forward = Vector3(-basis_matrix.z.x, 0, -basis_matrix.z.z)
	if dimension == MODE.TWOD:
		return Vector2(current_forward.x, current_forward.z)
	return current_forward

func get_xz(v3:Vector3) -> Vector2:
	return Vector2(v3.x, v3.z)

func normalize_xz(v3:Vector3) -> Vector3:
	var v2 = get_xz(v3)
	v2 = v2.normalized()
	return Vector3(v2.x, 0, v2.y)

func get_target_direction(current_pos: Vector3, looking_at: Vector3, target_pos: Vector3) -> DIRECTION:
	# Calculate direction towards the objective
	var direction_to_target_2d = normalize_xz(target_pos - current_pos)
	# Normalize, just in case
	var current_forward_2d = normalize_xz(looking_at)
	# Calculate the determinant
	var determinant = current_forward_2d.x * direction_to_target_2d.z - current_forward_2d.y * direction_to_target_2d.x
	# Detect the direction from the determinant
	if determinant > 0:
		return DIRECTION.RIGHT
	else:
		return DIRECTION.LEFT
