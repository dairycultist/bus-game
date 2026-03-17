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
	elif event.as_text() == "3":
		$BikeModel/Camera3.make_current()

func _process(delta: float) -> void:
	
	var move := -Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if move.y == 0.0:
		
		move.y = -sign(speed)
	
		if abs(speed) < 0.5:
			move.x = 0.0 # can't turn if not moving
			speed = 0.0  # prevent weird float stuff
	
	if move.x == 0.0:
		
		move.x = -sign(turn_speed)
		
		if abs(turn_speed) < 0.5:
			turn_speed = 0.0 # prevent weird float stuff
	
	# move wheels based on speed
	var angular_speed = velocity.dot(-global_basis.z) / wheel_mesh_radius * delta
	$BikeModel/FrontWheelSpring/Mesh.rotate_object_local(Vector3.RIGHT, angular_speed)
	$BikeModel/BackWheelSpring/Mesh.rotate_object_local(Vector3.RIGHT, angular_speed)
	
	# accelerate
	var accelerate_y = speed
	
	speed += move.y * acceleration * delta
	speed = clamp(speed, -max_speed, max_speed)
	velocity = -global_basis.z * speed
	
	accelerate_y = -sign(accelerate_y - speed)
	
	# turn
	turn_speed += move.x * turn_acceleration * delta
	turn_speed = clamp(turn_speed, -max_turn_speed, max_turn_speed)
	global_rotation.y += turn_speed * (speed / max_speed) * delta
	
	# lean based on acceleration
	$BikeModel.rotation.x = lerp_angle($BikeModel.rotation.x, accelerate_y * pitch_intensity, 3.0 * delta)
	$BikeModel.rotation.y = lerp_angle($BikeModel.rotation.z, turn_speed * yaw_intensity * abs(speed) / max_speed, 1.5 * delta)
	$BikeModel.rotation.z = lerp_angle($BikeModel.rotation.z, turn_speed * roll_intensity * abs(speed) / max_speed, 1.5 * delta)
	
	move_and_slide()
	
	## TODO animate butt bone
	##mixamorig_LeftUpLeg.001
	#$BikeModel/CharacterModel/Armature/Skeleton3D.find_bone("mixamorig_RightUpLeg.001")
