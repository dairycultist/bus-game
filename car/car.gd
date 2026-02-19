extends RigidBody3D

@export var drive: float = 5000.0
@export var steer: float = 2000.0
@export var grip:  float = 300.0

func _process(_delta: float) -> void:
	
	var input = Input.get_vector("ui_left", "ui_right", "ui_down", "ui_up")
	
	apply_force(-global_basis.z * drive * input.y)
	
	apply_torque(-global_basis.y * steer * input.x)
	
	# oppose motion at the front and back of car
	_oppose_at(Vector3.FORWARD)
	_oppose_at(Vector3.BACK)
	
	# car lean
	var sidevel := global_basis.x.dot(linear_velocity)
	$Mesh.rotation.z = sidevel * abs(sidevel) * 0.001

func _oppose_at(pos: Vector3):
	
	var velocity_at_position := linear_velocity + angular_velocity.cross(global_basis * pos)
	
	var antislip = global_basis.x.dot(velocity_at_position) * grip
	
	apply_force(-global_basis.x * antislip, global_basis * pos)
