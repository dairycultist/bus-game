extends CharacterBody3D

# less realistic controls (mario kart) > realistic

@export_category("Handling")
@export var max_speed: float = 40.0
@export var acceleration: float = 20.0
@export var max_turn_speed: float = 1.0
@export var turn_acceleration: float = 5.0

var speed: float
var turn_speed: float

@export_category("VFX")
@export var pitch_intensity: float = 0.07
@export var yaw_intensity: float = 0.3
@export var roll_intensity: float = 0.5
@export var wheel_mesh_radius: float = 1.2

func _input(event):
	
	if event.as_text() == "1":
		$Camera1.make_current()
	elif event.as_text() == "2":
		$Camera2.make_current()

func _process(delta: float) -> void:
	
	var move := -Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if move.y == 0.0:
		move.y = -sign(speed)
	
	if move.x == 0.0:
		move.x = -sign(turn_speed)
	
	# move wheels based on speed
	var angular_speed = velocity.dot(-global_basis.z) / wheel_mesh_radius * delta
	$Mesh/FrontWheelSpring/Mesh.rotate_object_local(Vector3.RIGHT, angular_speed)
	$Mesh/BackWheelSpring/Mesh.rotate_object_local(Vector3.RIGHT, angular_speed)
	
	# accelerate
	var accelerate_y = speed
	
	speed += move.y * acceleration * delta
	speed = clamp(speed, -max_speed, max_speed)
	velocity = -global_basis.z * speed
	
	accelerate_y = -sign(accelerate_y - speed)
	
	# turn
	turn_speed += move.x * turn_acceleration * delta * sign(speed)
	turn_speed = clamp(turn_speed, -max_turn_speed, max_turn_speed)
	global_rotation.y += turn_speed * delta
	
	# lean based on acceleration
	$Mesh.rotation.x = lerp_angle($Mesh.rotation.x, accelerate_y * pitch_intensity, 3.0 * delta)
	$Mesh.rotation.y = lerp_angle($Mesh.rotation.z, turn_speed * sign(speed) * yaw_intensity, 1.5 * delta)
	$Mesh.rotation.z = lerp_angle($Mesh.rotation.z, turn_speed * sign(speed) * roll_intensity, 1.5 * delta)
	
	move_and_slide()
