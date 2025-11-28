extends Camera3D

@export var follow_speed: float = 10.0

var angle := 0.0

# TODO camera should always stay above bus looking down, even if it leans or tips over

#func _ready() -> void:
	#global_position = target.global_position
	#global_rotation = target.global_rotation

func _process(delta: float) -> void:
	
	var camera_pivot := get_parent_node_3d()
	var car := camera_pivot.get_parent_node_3d()
	
	angle = lerp_angle(angle, car.global_rotation.y, delta * 4.0)
	
	camera_pivot.global_rotation = Vector3(0, angle, 0)
	
	#global_position = lerp(global_position, target.global_position, delta * follow_speed)
	#global_basis = Basis(Quaternion(global_basis).slerp(Quaternion(target.global_basis), delta * follow_speed))
	
	# FOV
	self.fov = 60 + car.linear_velocity.length() * 4
