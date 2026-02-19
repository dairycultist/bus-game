extends RigidBody3D

func _process(_delta: float) -> void:
	
	var input = Input.get_vector("ui_left", "ui_right", "ui_down", "ui_up")
	
	apply_force(-global_basis.z * 5000.0 * input.y)
	
	apply_torque(-global_basis.y * 2000.0 * input.x)
	
	# oppose motion at the front and back of car
	_oppose_at(Vector3.FORWARD)
	_oppose_at(Vector3.BACK)

func _oppose_at(pos: Vector3):
	
	var velocity_at_position := linear_velocity + angular_velocity.cross(global_basis * pos)
	
	var antislip = global_basis.x.dot(velocity_at_position) * 300.0
	
	apply_force(-global_basis.x * antislip, global_basis * pos)
