extends Node3D

# goal: maintain the initial relative offset from the chassis (parent) by applying
#       dampened forces to the chassis

# the wheel node starts at zero compression (aka the lowest point). it raycasts
# from the point of max_compression down; if it hits something before the point
# of zero compression, it means it's compressed

@export var max_compression: float = 1.0

func _process(delta: float) -> void:
	
	var chassis := get_parent_node_3d()
	var compression := 0.
	var chassis_up := global_transform.basis.y
	
	var max_compression_position = global_position + chassis_up * max_compression
	
	var ray_result = get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(
		max_compression_position,
		global_position
	))
	
	if (ray_result):
		compression = max_compression - (max_compression_position - ray_result.position).length()
		chassis.apply_force(compression * chassis_up * 100., global_position + chassis_up * max_compression - chassis.global_position)
	
	$Mesh.position.y = compression + 0.2
