extends Node3D

@export var flip_mesh: bool

func _ready() -> void:
	
	if flip_mesh:
		$WheelContact/Mesh.scale.x *= -1.0

func _process(delta: float) -> void:
	
	if $ContactRay.is_colliding():
		$WheelContact.global_position = $ContactRay.get_collision_point()
	else:
		$WheelContact.global_position = $ContactRay.to_global($ContactRay.target_position)
