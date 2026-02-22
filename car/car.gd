extends RigidBody3D

@export_group("Handling")
@export var drive: float = 2000.0
@export var steer: float = 200.0
@export var grip:  float = 500.0

@export_group("Camera")
@export var follow_speed: float = 10.0

var angle := 0.0

var _controlled_player: Player = null

func on_interact(player: Player) -> void:
	
	# make the car controlled
	_controlled_player = player
	$CameraPivot/Camera.current = true
	
	# make the player not controlled (also disabling them)
	player.set_controlled(false)
	
	player.global_position.y = 100

func _process(delta: float) -> void:
	
	if _controlled_player:
		
		# camera
		angle = lerp_angle(angle, global_rotation.y, delta * 4.0)
		
		# ensure camera is always above the car (even if tipped over) and
		# (generally) facing where the car is facing
		$CameraPivot.global_rotation = Vector3(0, angle, 0)
	
	# movement if grounded
	if $GroundingRay.is_colliding():
		
		if _controlled_player:
			
			var input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
			
			apply_force(global_basis.z * drive * input.y)
			
			apply_torque(-global_basis.y * steer * input.x * linear_velocity.dot(-global_basis.z))
			
		# oppose motion at the front and back of car (emulates wheels not liking to move sideways)
		_oppose_at(Vector3.FORWARD)
		_oppose_at(Vector3.BACK)
	
		physics_material_override.friction = 0.0
	
	else:
		
		physics_material_override.friction = 1.0

func _oppose_at(pos: Vector3):
	
	var velocity_at_position := linear_velocity + angular_velocity.cross(global_basis * pos)
	
	var antislip = global_basis.x.dot(velocity_at_position) * grip
	
	apply_force(-global_basis.x * antislip, global_basis * pos)

func _input(event):
	
	if _controlled_player and event.is_action_pressed("interact"):
		
		# make the player not controlled (also disabling them)
		_controlled_player.set_controlled(true)
		_controlled_player.global_position = $DropOffPoint.global_position
		
		# make player face in the same direction as the car for convenience
		_controlled_player.rotation.y = angle
		
		# give up control
		_controlled_player = null
		$CameraPivot/Camera.current = false
