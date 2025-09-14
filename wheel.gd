extends RigidBody3D

# goal: maintain the initial relative offset from the chassis (parent) by applying
#       dampened forces to the chassis

var target_position: Vector3

func _ready() -> void:
	target_position = position
	
	axis_lock_angular_x = true
	axis_lock_angular_y = true
	axis_lock_angular_z = true

func _process(delta: float) -> void:
	
	var chassis := get_parent_node_3d()
	
	chassis.apply_force((position - target_position) * 100., target_position)
	
	rotation = chassis.rotation
