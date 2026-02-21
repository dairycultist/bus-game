extends RigidBody3D

@export_group("Handling")
@export var drive: float = 2000.0
@export var steer: float = 200.0
@export var grip:  float = 500.0

@export_group("VFX")
@export var lean_amount: float  = 0.0005

@export_group("Camera")
@export var follow_speed: float = 10.0

var angle := 0.0

func _process(delta: float) -> void:
	
	# camera
	angle = lerp_angle(angle, global_rotation.y, delta * 4.0)
	
	# ensure camera is always above the car (even if tipped over) and
	# (generally) facing where the car is facing
	$CameraPivot.global_rotation = Vector3(0, angle, 0)
	
	# movement if grounded
	if $GroundingRay.is_colliding():
		
		var input = Input.get_vector("ui_left", "ui_right", "ui_down", "ui_up")
		
		apply_force(-global_basis.z * drive * input.y)
		
		apply_torque(-global_basis.y * steer * input.x * linear_velocity.dot(-global_basis.z))
		
		# oppose motion at the front and back of car
		_oppose_at(Vector3.FORWARD)
		_oppose_at(Vector3.BACK)
		
		# car lean
		var sidevel := global_basis.x.dot(linear_velocity)
		$Mesh.rotation.z = sidevel * abs(sidevel) * lean_amount

func _oppose_at(pos: Vector3):
	
	var velocity_at_position := linear_velocity + angular_velocity.cross(global_basis * pos)
	
	var antislip = global_basis.x.dot(velocity_at_position) * grip
	
	apply_force(-global_basis.x * antislip, global_basis * pos)
