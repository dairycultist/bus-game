extends Node3D

# the wheel node indicates the positions at zero compression (aka the lowest point)
# it should be the child of a rigidbody representing the car's chassis

# default values work good enough for a 100kg car
@export var max_compression_distance: float = 1.0
@export var stiffness: float = 1500.0
@export var dampening: float = 150.0
@export var powered: bool = true
@export var drive_force: float = 50.0

func _process(delta: float) -> void:
	
	var chassis                        := get_parent_node_3d()
	var chassis_up                     :=  global_transform.basis.y
	var chassis_forward                := -global_transform.basis.z # -z direction is forward
	var chassis_to_suspension_position := global_position + chassis_up * max_compression_distance - chassis.global_position
	
	# raycast from the point of max_compression_distance down
	var max_compression_position = global_position + chassis_up * max_compression_distance
	
	var ray_result = get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(
		max_compression_position,
		global_position
	))
	
	# if the ray hits something before the point of zero compression, it means
	# the suspension is compressed and we should apply a suspension force to
	# the chassis
	var compression_distance := 0.0
	
	if (ray_result):
		
		compression_distance   = max_compression_distance - (max_compression_position - ray_result.position).length()
		var compression_amount = compression_distance / max_compression_distance
		
		# apply spring force at the chassis_to_suspension_position based on compression_amount
		chassis.apply_force(compression_amount * chassis_up * stiffness, chassis_to_suspension_position)
		
		# apply dampening force at the chassis_to_suspension_position opposite
		# to the vertical velocity at the chassis_to_suspension_position
		var velocity_at_position = chassis.linear_velocity + chassis.angular_velocity.cross(chassis_to_suspension_position)
		var vertical_velocity_at_position = velocity_at_position.dot(chassis_up)
		
		chassis.apply_force(vertical_velocity_at_position * -chassis_up * dampening, chassis_to_suspension_position)
		
		# input/powering (only when compressed/grounded)
		# drive forces are applied at the wheel_contact_position
		var chassis_to_wheel_contact_position = global_position + compression_distance * chassis_up - chassis.global_position
		
		if (powered):
			
			if (Input.is_action_pressed("ui_up")):
				chassis.apply_force(chassis_forward * drive_force, chassis_to_wheel_contact_position)
			
			if (Input.is_action_pressed("ui_down")):
				chassis.apply_force(-chassis_forward * drive_force, chassis_to_wheel_contact_position)
	
	# visibly push our mesh up during compression
	$Mesh.position.y = compression_distance + 0.2
