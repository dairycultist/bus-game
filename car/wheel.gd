extends Node3D

@export var flip_mesh: bool
@export var stiffness: float = 30.0
@export var dampening: float = 30.0

@onready var body: RigidBody3D = get_parent()

func _ready() -> void:
	
	if flip_mesh:
		$WheelContact/Mesh.scale.x *= -1.0

func _process(_delta: float) -> void:
	
	if $ContactRay.is_colliding():
		$WheelContact.global_position = $ContactRay.get_collision_point()
	else:
		$WheelContact.global_position = $ContactRay.to_global($ContactRay.target_position)

func _physics_process(_delta: float) -> void:
	
	if not $ContactRay.is_colliding():
		return
	
	# resist compression
	var compression_fac: float = 1.0 - $ContactRay.global_position.distance_to($ContactRay.get_collision_point()) / $ContactRay.target_position.length()
	
	body.apply_force(global_basis.y * compression_fac * stiffness, global_position)
	
	# resist velocity
	var local_velocity: Vector3 = body.linear_velocity + body.angular_velocity.cross(global_position - body.global_position)
	
	body.apply_force(-local_velocity * dampening, global_position)
