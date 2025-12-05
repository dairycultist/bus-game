extends Node3D

# the wheel node indicates the positions at zero compression (aka the lowest point)
# it should be the child of a rigidbody representing the car's chassis

# https://sketchfab.com/3d-models/cartoon-car-09431a8df4344a84aa83a4095bef10fc

@export_category("Suspension")
@export var max_compression_distance: float = 1.0
@export var stiffness: float = 1500.0
@export var dampening: float = 150.0

@export_category("Handling")

## Decreases drift and allows for sharper turns, but increases likelihood of rollover.
@export var antislip: float = 100.0
@export var steered: SteerType = SteerType.NotSteered
@export_range(0.0, 90.0) var max_turn_angle: float = 30.0

@export_category("Drive")
@export var powered: bool = true
@export var drive_force: float = 50.0

enum SteerType {
	NotSteered,
	RightTurnsRight,
	RightTurnsLeft
}

func _process(delta: float) -> void:
	
	_turn_wheels(delta)
	_compress_suspension()
	
	# get relative wheel contact position for applying forces to the chassis
	#var chassis_to_wheel_contact_position = global_position + compression_distance * chassis_up - chassis.global_position

func _turn_wheels(delta):
	
	var steer_rotation := 0.0
	
	if (steered == SteerType.RightTurnsRight):
		
		if (Input.is_action_pressed("ui_left")):
			steer_rotation += deg_to_rad(max_turn_angle)
		
		if (Input.is_action_pressed("ui_right")):
			steer_rotation -= deg_to_rad(max_turn_angle)
	
	elif (steered == SteerType.RightTurnsLeft):
		
		if (Input.is_action_pressed("ui_left")):
			steer_rotation -= deg_to_rad(max_turn_angle)
		
		if (Input.is_action_pressed("ui_right")):
			steer_rotation += deg_to_rad(max_turn_angle)
	
	rotation.y = lerp(rotation.y, steer_rotation, delta * 10)

func _compress_suspension() -> float: # returns amount of compression, [0..1]
	
	# TODO completely remove max_compression_distance
	# have suspension mount position be determined by a parent node
	# have spring force be based on compression distance, not amount
	
	var chassis                   := get_parent_node_3d()
	var chassis_up                := chassis.global_transform.basis.y
	var suspension_mount_position := global_position + chassis_up * max_compression_distance - chassis.global_position
	
	var max_compression_global_position := global_position + chassis_up * max_compression_distance
	
	# raycast somewhere above max_compression_position down (to prevent
	# clipping through the ground), ignoring the chassis's collider
	var query = PhysicsRayQueryParameters3D.create(
		max_compression_global_position + chassis_up * 0.5,
		global_position
	)
	query.exclude = [chassis]
	
	var ray_result = get_world_3d().direct_space_state.intersect_ray(query)
	
	# if the ray hits something before the point of zero compression, it means
	# the suspension is compressed, the wheel is grounded, and we should apply a
	# relevant forces to the chassis
	var compression_distance := 0.0
	var compression_amount := 0.0
	
	if (ray_result):
		
		compression_distance = (global_position - ray_result.position).length()
		compression_amount = compression_distance / max_compression_distance
		
		# apply spring force at the suspension_mount_position based on compression_amount
		chassis.apply_force(compression_amount * chassis_up * stiffness, suspension_mount_position)
		
		# apply dampening force at the suspension_mount_position opposite
		# to the vertical velocity at the suspension_mount_position
		var velocity_at_position = chassis.linear_velocity + chassis.angular_velocity.cross(suspension_mount_position)
		var vertical_velocity_at_position = velocity_at_position.dot(chassis_up)
		
		chassis.apply_force(vertical_velocity_at_position * -chassis_up * dampening, suspension_mount_position)
	
	# visibly push our mesh up during compression
	$Mesh.position.y = compression_distance + 0.2
	
	return compression_amount
