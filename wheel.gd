extends Node3D

# the wheel node indicates the positiona at zero compression (aka the lowest point).

# -z direction is forward

@export var max_compression_distance: float = 1.0
@export var stiffness: float = 50.0
@export var powered: bool = true

func _process(delta: float) -> void:
	
	var chassis := get_parent_node_3d()
	var chassis_up := global_transform.basis.y
	
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
		
		chassis.apply_force(compression_amount * chassis_up * stiffness, global_position + chassis_up * max_compression_distance - chassis.global_position)
	
	# visibly push our mesh up during compression
	$Mesh.position.y = compression_distance + 0.2
