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

@export_category("Boobs")
@export var wobble_intensity: float = 1.0
@export var wobble_stiffness: float = 16.0

@onready var skeleton: Skeleton3D = $BikeModel/CharacterModel/Armature/Skeleton3D

@onready var butt_l = skeleton.find_bone("LeftButt")
@onready var butt_r = skeleton.find_bone("RightButt")
@onready var butt_l_baserot = skeleton.get_bone_pose_rotation(butt_l)
@onready var butt_r_baserot = skeleton.get_bone_pose_rotation(butt_r)

@onready var boobs = skeleton.find_bone("Boobs")
@onready var boobs_baserot = skeleton.get_bone_pose_rotation(boobs)
var boobs_rot: Vector2
var boobs_rotvel: Vector2

var pitch_effect: AudioEffectPitchShift

func _ready() -> void:
	
	$BikeModel/AnimationPlayer.play("Lean")
	
	pitch_effect = AudioServer.get_bus_effect(AudioServer.get_bus_index("Engine"), 0)
	$EngineAudio.play()

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
	
		if abs(speed) < max_speed * delta:
			move.x = 0.0 # can't turn if not moving
			speed = 0.0  # prevent weird float stuff
		else:
			move.y = -sign(speed)
	
	if move.x == 0.0:
		
		if abs(turn_speed) < max_turn_speed * delta:
			turn_speed = 0.0 # prevent weird float stuff
		else:
			move.x = -sign(turn_speed)
	
	# accelerate
	var accelerate_y = speed
	
	speed += move.y * acceleration * delta
	speed = clamp(speed, -max_speed, max_speed)
	velocity.x = -global_basis.z.x * speed
	velocity.z = -global_basis.z.z * speed
	
	accelerate_y = -sign(accelerate_y - speed)
	
	# turn
	turn_speed += move.x * turn_acceleration * delta
	turn_speed = clamp(turn_speed, -max_turn_speed, max_turn_speed)
	global_rotation.y += turn_speed * speed / max_speed * delta
	
	# gravity
	velocity += get_gravity() * delta
	
	move_and_slide()
	
	# rotate wheels based on speed
	var angular_speed = clamp(velocity.dot(-global_basis.z) / wheel_mesh_radius * delta, -0.35, 0.35)
	$BikeModel/FrontWheelSpring/Mesh.rotate_object_local(Vector3.RIGHT, angular_speed)
	$BikeModel/BackWheelSpring/Mesh.rotate_object_local(Vector3.RIGHT, angular_speed)
	
	# animate character leaning when going fast
	$BikeModel/AnimationPlayer.seek(clamp(pow(abs(speed / max_speed), 2.0), 0.0, 1.0))
	
	# animate butt bones
	var q := Quaternion.from_euler(Vector3(
		sin(Time.get_ticks_msec() * 0.07) * 0.04 * pow(speed / max_speed, 2.0) + 0.4 * abs(speed) / max_speed,
		0.0,
		0.0
	))
	skeleton.set_bone_pose_rotation(butt_l, butt_l_baserot * q)
	skeleton.set_bone_pose_rotation(butt_r, butt_r_baserot * q)
	
	# animate boobs with spring physics
	boobs_rotvel.x += wobble_intensity * turn_speed * abs(speed) / max_speed * delta
	boobs_rotvel.y -= wobble_intensity * accelerate_y * delta
	
	boobs_rot += boobs_rotvel * delta
	boobs_rotvel -= boobs_rot * wobble_stiffness * delta
	boobs_rotvel *= 0.98
	
	skeleton.set_bone_pose_rotation(
		boobs,
		Quaternion.from_euler(Vector3(boobs_rot.y, 0.0, 0.0)) *
		Quaternion.from_euler(Vector3(0.0, boobs_rot.x, 0.0)) *
		boobs_baserot
	)
	
	# orient bike with ground
	var front_query = PhysicsRayQueryParameters3D.create(
		$BikeModel/FrontWheelSpring.global_position,
		$BikeModel/FrontWheelSpring.global_position + $BikeModel/FrontWheelSpring.global_basis.z * $BikeModel/FrontWheelSpring.spring_length
	)
	front_query.collision_mask = 1
	var front_result = get_world_3d().direct_space_state.intersect_ray(front_query)
	
	var mid_query = PhysicsRayQueryParameters3D.create(
		$BikeModel.global_position + Vector3(0.0,  1.0, 0.0),
		$BikeModel.global_position + Vector3(0.0, -5.0, 0.0)
	)
	mid_query.collision_mask = 1
	var mid_result = get_world_3d().direct_space_state.intersect_ray(mid_query)
	
	var back_query = PhysicsRayQueryParameters3D.create(
		$BikeModel/BackWheelSpring.global_position,
		$BikeModel/BackWheelSpring.global_position + $BikeModel/BackWheelSpring.global_basis.z * $BikeModel/BackWheelSpring.spring_length
	)
	back_query.collision_mask = 1
	var back_result = get_world_3d().direct_space_state.intersect_ray(back_query)
	
	var orient_angle := 0.0
	var div := 0
	
	if front_result.has("normal"):
		orient_angle += front_result.normal.dot(global_basis.z)
		div += 1
	if mid_result.has("normal"):
		orient_angle += mid_result.normal.dot(global_basis.z) * 2
		div += 2
	if back_result.has("normal"):
		orient_angle += back_result.normal.dot(global_basis.z)
		div += 1
	
	if div != 0:
		orient_angle /= div
	
	# lean based on acceleration
	$BikeModel.rotation.x = lerp_angle($BikeModel.rotation.x, orient_angle + accelerate_y * pitch_intensity, 3.0 * delta)
	$BikeModel.rotation.y = lerp_angle($BikeModel.rotation.y, turn_speed * yaw_intensity * speed / max_speed, 1.5 * delta)
	$BikeModel.rotation.z = lerp_angle($BikeModel.rotation.z, turn_speed * roll_intensity * abs(speed) / max_speed, 1.5 * delta)
	
	# engine noise
	$EngineAudio.pitch_scale = 0.99 + pow(abs(speed / max_speed), 2.0)
	pitch_effect.pitch_scale = 1.0 / $EngineAudio.pitch_scale # invert the pitch scale to maintain pitch
