extends Camera3D

@export var follow_speed: float = 10.0

@export var camera_pos_a: Node3D # at a standstill
@export var camera_pos_b: Node3D # moving very fast (pulled in)

var angle := 0.0

func _process(delta: float) -> void:
	
	var camera_pivot := get_parent_node_3d()
	var car := camera_pivot.get_parent_node_3d()
	
	angle = lerp_angle(angle, car.global_rotation.y, delta * 4.0)
	
	# ensure camera is always above the car (even if tipped over) and
	# (generally) facing where the car is facing
	camera_pivot.global_rotation = Vector3(0, angle, 0)
	
	## speed fac
	#var speed_fac = pow(min(car.linear_velocity.length() * 0.05, 1.0), 0.8)
	#
	## FOV (60 - 100)
	#fov = 60 + speed_fac * 40
	#
	## position
	#position = lerp(position, lerp(camera_pos_a.position, camera_pos_b.position, speed_fac), delta * 5)
	#
	## shake
	#var shake = 0.02 * speed_fac * speed_fac
	#h_offset = randf_range(-shake, shake)
	#v_offset = randf_range(-shake, shake)
