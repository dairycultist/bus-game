extends Node3D

@export var flip_mesh: bool
@export var stiffness: float = 30.0
@export var dampening: float = 30.0

@onready var body: RigidBody3D = get_parent()

var wheel_radius: float
var angular_speed: float

func _ready() -> void:
	
	if flip_mesh:
		$WheelContact/Mesh.scale.x *= -1.0
	
	wheel_radius = $WheelContact/Mesh.position.y

func _process(_delta: float) -> void:
	
	$WheelContact.global_position =\
		$ContactRay.get_collision_point()\
		if $ContactRay.is_colliding()\
		else $ContactRay.to_global($ContactRay.target_position)

func _physics_process(_delta: float) -> void:
	
	if not $ContactRay.is_colliding():
		return
	
	# resist compression
	var compression_fac: float = 1.0 - $ContactRay.global_position.distance_to($ContactRay.get_collision_point()) / $ContactRay.target_position.length()
	
	body.apply_force(global_basis.y * compression_fac * stiffness, global_position)
	
	# resist velocity
	var velocity_at_origin: Vector3 = body.linear_velocity + body.angular_velocity.cross(global_position - body.global_position)
	
	body.apply_force(-velocity_at_origin * dampening, global_position)
	
	# velocity at the point of contact agnostic to the rotation of the wheel
	var body_velocity_at_contact: Vector3 = body.linear_velocity + body.angular_velocity.cross($WheelContact.global_position - body.global_position)
	
	# velocity of the wheel at the point of contact agnostic to the car body
	var wheel_velocity_at_contact: Vector3 = angular_speed * wheel_radius * -$WheelContact.global_basis.z
	
	# apply force to coax wheel into not slipping
	# (when wheel is spinning, this will both account for drive and antislip)
	# (might also want to be able to have velocity_at_contact influence angular_speed, idk)
	
	# when there is no slip, body_velocity_at_contact = -wheel_velocity_at_contact
