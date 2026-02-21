extends CharacterBody3D
class_name Player

@export_group("Camera")
@export var mouse_sensitivity: float = 0.3
var camera_pitch := 0.0

@export var max_camera_distance: float = 3.0

@export_group("Movement")
@export var ground_accel: float = 25
@export var air_accel: float    = 10
@export var max_speed: float    = 5
@export var drag: float         = 8
@export var jump_speed: float   = 8
@export var gravity: float      = 25

var _is_controlled: bool = true

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func set_controlled(value: bool):
	_is_controlled = value
	$CameraPivot/Camera.current = value
	visible = value

func _process(delta: float) -> void:
	
	if not _is_controlled:
		return
	
	# input
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# gravity
	velocity.y -= gravity * delta
	
	# moving
	if direction:
		
		if is_on_floor():
			velocity += direction * ground_accel * delta
		else:
			velocity += direction * air_accel * delta
		
		# limit speed
		var vel2d := Vector2(velocity.x, velocity.z)

		if (vel2d.length() > max_speed):
			
			vel2d = vel2d.normalized() * max_speed
			
			velocity.x = vel2d.x
			velocity.z = vel2d.y
	
	elif is_on_floor():
		
		# drag
		velocity.x = lerp(velocity.x, 0.0, drag * delta)
		velocity.z = lerp(velocity.z, 0.0, drag * delta)
		
	if is_on_floor() and Input.is_action_pressed("jump"):
	
		# jumping
		velocity.y = jump_speed
	
	move_and_slide()
	
	# place camera
	var query = PhysicsRayQueryParameters3D.create($CameraPivot.global_position, $CameraPivot.global_position + max_camera_distance * $CameraPivot.global_transform.basis.z)
	query.exclude = [get_rid()]
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	
	if (result):
		$CameraPivot/Camera.global_position = result.position
	else:
		$CameraPivot/Camera.global_position = $CameraPivot.global_position + max_camera_distance * $CameraPivot.global_transform.basis.z

func _input(event):
	
	if event.is_action_pressed("pause"):
		
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# stuff above can be done even in a car
	elif not _is_controlled:
		return
	
	elif event.is_action_pressed("interact"):
		
		if $CameraPivot/InteractRay.is_colliding():
			if $CameraPivot/InteractRay.get_collider().has_method("on_interact"):
				$CameraPivot/InteractRay.get_collider().on_interact(self)
	
	elif event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		
		var rotation_angle := deg_to_rad(-event.relative.x * mouse_sensitivity)
		
		rotation.y += rotation_angle
		
		camera_pitch = clampf(camera_pitch - event.relative.y * mouse_sensitivity, -90, 90)
		
		$CameraPivot.rotation.x = deg_to_rad(camera_pitch)
