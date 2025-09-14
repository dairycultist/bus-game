extends Node3D

# the wheel node indicates the positiona at zero compression (aka the lowest point).

# values that work good enough for a 100kg car with 0 linear damp and 5 angular damp
@export var max_compression_distance: float = 1.0
@export var stiffness: float = 1500.0
@export var dampening: float = 150.0
@export var powered: bool = true
@export var drive_force: float = 50.0

func _process(delta: float) -> void:
	
	var chassis := get_parent_node_3d()
	var chassis_up := global_transform.basis.y
	var chassis_forward := -global_transform.basis.z # -z direction is forward
	var chassis_force_position := global_position + chassis_up * max_compression_distance - chassis.global_position
	
	# raycast from the point of max_compression_distance down
	var max_compression_position = global_position + chassis_up * max_compression_distance
	
	var ray_result = get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(
		max_compression_position,
		global_position
	))
	
	# if the ray hits something before the point of zero compression, it means
	# the suspension is compressed and we should apply a suspension force to
	# the chassis
	var compression_distance := 0.
	var compression_amount   := 0.
	
	if (ray_result):
		
		compression_distance = max_compression_distance - (max_compression_position - ray_result.position).length()
		compression_amount = compression_distance / max_compression_distance
		
		# apply spring force
		chassis.apply_force(compression_amount * chassis_up * stiffness, chassis_force_position)
		
		# apply dampening force opposite to current up-down speed
		var updown_speed = chassis.linear_velocity.dot(chassis_up)
		chassis.apply_force(updown_speed * -chassis_up * dampening, chassis_force_position)
	
	# visibly push our mesh up during compression
	$Mesh.position.y = compression_distance + 0.2
	
	# input/powering
	if (powered and compression_amount > 0.02):
		
		if (Input.is_action_pressed("ui_up")):
			chassis.apply_force(chassis_forward * drive_force, chassis_force_position)
