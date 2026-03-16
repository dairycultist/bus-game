extends Path3D

@export var powered: bool = true
@export var drive_angular_speed: float = 10.0
@export var stiffness: float = 3000.0
@export var dampening: float = 300.0
@export var grip: float = 300.0
@export var steer_angle: float = 0.0

@onready var body: RigidBody3D = get_parent()

var angular_speed: float = 1.0

func _process(delta: float) -> void:
	
	# visually place wheel
	$Wheel.global_position = to_global(curve.sample(0, abs(sin(Time.get_ticks_msec() * 0.001))))
	
	# visually rotate wheel
	$Wheel/Mesh.rotation.x -= angular_speed * delta
	
	# input
	if powered:
		
		if Input.is_action_pressed("move_up"):
			angular_speed = lerp(angular_speed, drive_angular_speed, delta)
		elif Input.is_action_pressed("move_down"):
			angular_speed = lerp(angular_speed, -drive_angular_speed, delta)
		else:
			angular_speed = lerp(angular_speed, 0.0, delta)

#func _physics_process(delta: float) -> void:
	
	## resist compression
	#var compression_fac: float = 1.0 - $ContactRay.global_position.distance_to($ContactRay.get_collision_point()) / $ContactRay.target_position.length()
	#body.apply_force(global_basis.y * compression_fac * stiffness, global_position - body.global_position)
	#
	## resist vertical velocity
	#var vertical_velocity_at_origin: Vector3 = global_basis.y * global_basis.y.dot(body.linear_velocity + body.angular_velocity.cross(global_position - body.global_position))
	#body.apply_force(-vertical_velocity_at_origin * dampening, global_position - body.global_position)
	#
	## velocity at the point of contact agnostic to the rotation of the wheel
	#var body_velocity_at_contact: Vector3 = body.linear_velocity + body.angular_velocity.cross($WheelContact.global_position - body.global_position)
	#
	## velocity of the wheel at the point of contact agnostic to the car body
	#var wheel_velocity_at_contact: Vector3 = angular_speed * wheel_radius * -$WheelContact.global_basis.z
	#
	## when there is no slip, body_velocity_at_contact = -wheel_velocity_at_contact
	#var slip := body_velocity_at_contact - wheel_velocity_at_contact
	#
	## reduce slip in two ways (accounts for both drive and antislip):
	#
	## slip influences angular_speed (only if in neutral/unpowered -- powered
	## wheels for now brake when not inputing, not neutral)
	#if not powered:
		#
		#var forward_slip := slip.dot(-$WheelContact.global_basis.z)
		#
		#angular_speed += forward_slip / wheel_radius * 6.0 * delta # TODO hardcoding bad
	#
	## slip influences velocity (via frictional force)
	#body.apply_force(-slip * grip, $WheelContact.global_position - body.global_position)
