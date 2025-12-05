extends Node3D

# the wheel node indicates the positions at zero compression (aka the lowest point)
# it should be the child of a rigidbody representing the car's chassis

# default values work good enough for a 100kg car

# https://sketchfab.com/3d-models/cartoon-car-09431a8df4344a84aa83a4095bef10fc

@export_category("Suspension")
@export var max_compression_distance: float = 1.0 # ensure this point is located within the parent car's collider to prevent the tire "falling through" level collision
@export var stiffness: float = 1500.0
@export var dampening: float = 150.0

@export_category("Handling")

## Decreases drift and allows for sharper turns, but increases likelihood of rollover.
@export var antislip: float = 100.0
@export var steered: SteerType = SteerType.NotSteered
@export_range(0.0, 90.0) var max_turn_angle: float = 30.0

@export_category("Drive")
@export var powered: bool = true
@export var drive_force: float = 50.0

enum SteerType {
	NotSteered,
	RightTurnsRight,
	RightTurnsLeft
}

func _process(_delta: float) -> void:
	
	var chassis                        := get_parent_node_3d()
	var chassis_up                     :=  chassis.global_transform.basis.y
	var chassis_forward                := -chassis.global_transform.basis.z # -z direction is forward
	var chassis_to_suspension_position := global_position + chassis_up * max_compression_distance - chassis.global_position
	
	# turn wheel in direction of inputed steer
	var steer_rotation := 0.0
	
	if (steered == SteerType.RightTurnsRight):
		
		if (Input.is_action_pressed("ui_left")):
			steer_rotation += deg_to_rad(max_turn_angle)
		
		if (Input.is_action_pressed("ui_right")):
			steer_rotation -= deg_to_rad(max_turn_angle)
	
	elif (steered == SteerType.RightTurnsLeft):
		
		if (Input.is_action_pressed("ui_left")):
			steer_rotation -= deg_to_rad(max_turn_angle)
		
		if (Input.is_action_pressed("ui_right")):
			steer_rotation += deg_to_rad(max_turn_angle)
	
	rotation.y = steer_rotation
	
	# raycast from the point of max_compression_distance down,
	# ignoring the car's collider
	var max_compression_position = global_position + chassis_up * max_compression_distance
	
	var query = PhysicsRayQueryParameters3D.create(
		max_compression_position,
		global_position
	)
	query.exclude = [get_parent_node_3d()]
	
	var ray_result = get_world_3d().direct_space_state.intersect_ray(query)
	
	# if the ray hits something before the point of zero compression, it means
	# the suspension is compressed, the wheel is grounded, and we should apply a
	# relevant forces to the chassis
	var compression_distance := 0.0
	
	if (ray_result):
		
		compression_distance   = max_compression_distance - (max_compression_position - ray_result.position).length()
		var compression_amount = compression_distance / max_compression_distance
		
		# apply spring force at the chassis_to_suspension_position based on compression_amount
		chassis.apply_force(compression_amount * chassis_up * stiffness, chassis_to_suspension_position)
		
		# apply dampening force at the chassis_to_suspension_position opposite
		# to the vertical velocity at the chassis_to_suspension_position
		var velocity_at_position = chassis.linear_velocity + chassis.angular_velocity.cross(chassis_to_suspension_position)
		var vertical_velocity_at_position = velocity_at_position.dot(chassis_up)
		
		chassis.apply_force(vertical_velocity_at_position * -chassis_up * dampening, chassis_to_suspension_position)
		
		# get relative wheel contact position for applying forces to the chassis
		var chassis_to_wheel_contact_position = global_position + compression_distance * chassis_up - chassis.global_position
		
		# apply force opposite to side-to-side wheel slip at chassis_to_wheel_contact_position
		# (angle of wheel is already accounted for in its transform)
		var sidetoside_velocity_at_position = velocity_at_position.dot(global_transform.basis.x)
		
		chassis.apply_force(sidetoside_velocity_at_position * -global_transform.basis.x * antislip, chassis_to_wheel_contact_position)
		
		# apply drive_force at the chassis_to_wheel_contact_position proportional
		# to compression distance (a barely grounded tire barely applies force! prevents bouncing)
		# TODO should take into account current speed (for applying force AND mesh rotation around x)
		if (powered):
			
			if (Input.is_action_pressed("ui_up")):
				chassis.apply_force(-self.global_transform.basis.z * drive_force * compression_distance / max_compression_distance, chassis_to_wheel_contact_position)
			
			if (Input.is_action_pressed("ui_down")):
				chassis.apply_force(self.global_transform.basis.z * drive_force * compression_distance / max_compression_distance, chassis_to_wheel_contact_position)
	
	# visibly push our mesh up during compression
	$Mesh.position.y = compression_distance + 0.2
