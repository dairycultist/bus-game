extends CharacterBody3D

# visual
@export var pitch_intensity: float = 0.07
@export var roll_intensity: float = 0.5
@export var wheel_mesh_radius: float = 1.2

func _input(event):
	
	if event.as_text() == "1":
		$Camera1.make_current()
	elif event.as_text() == "2":
		$Camera2.make_current()

func _process(delta: float) -> void:
	
	var move := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# move wheels based on speed
	var angular_speed = velocity.dot(-global_basis.z) / wheel_mesh_radius * delta
	$Mesh/FrontWheelSpring/Mesh.rotate_object_local(Vector3.RIGHT, angular_speed)
	$Mesh/BackWheelSpring/Mesh.rotate_object_local(Vector3.RIGHT, angular_speed)
	
	# lean based on acceleration
	$Mesh.rotation.x = lerp_angle($Mesh.rotation.x, -move.y * pitch_intensity, 3.0 * delta)
	$Mesh.rotation.z = lerp_angle($Mesh.rotation.z, -move.x * roll_intensity, 1.5 * delta)
	
	# accelerate
	velocity += global_basis.z * move.y * 10.0 * delta
	
	move_and_slide()
