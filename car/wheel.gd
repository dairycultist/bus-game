extends Node3D

func _process(delta: float) -> void:
	
	if $ContactRay.is_colliding():
		$WheelContact.global_position = $ContactRay.get_collision_point()
