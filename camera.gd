extends Camera3D

@export var target: Node3D
@export var follow_speed: float = 10.0

# TODO camera should always stay above bus looking down, even if it leans or tips over

func _ready() -> void:
	global_position = target.global_position
	global_rotation = target.global_rotation

func _process(delta: float) -> void:
	global_position = lerp(global_position, target.global_position, delta * follow_speed)
	global_basis = Basis(Quaternion(global_basis).slerp(Quaternion(target.global_basis), delta * follow_speed))
