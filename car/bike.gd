extends Node3D

@export var stiffness: float = 3000.0

func _input(event):
	
	if event.as_text() == "1":
		$Chassis/Camera1.make_current()
	elif event.as_text() == "2":
		$Chassis/Camera2.make_current()

func _physics_process(_delta: float) -> void:
	
	# wheel is a separate physical object from the bike itself
	# normal/frictional forces act on the wheel, which applies normal/spring forces on the bike
	# free body diagram
	$FrontWheel.global_position = $Chassis/FrontSuspension.to_global(
		$Chassis/FrontSuspension.curve.get_closest_point(
			$Chassis/FrontSuspension.to_local($FrontWheel.global_position)
		)
	)
	
	var compression_dist: float = ($FrontWheel.global_position - $Chassis/FrontSuspension.to_global($Chassis/FrontSuspension.curve.get_point_position(0))).length()
	
	var suspension_dir: Vector3 = $Chassis/FrontSuspension.to_global($Chassis/FrontSuspension.curve.get_point_position(1) - $Chassis/FrontSuspension.curve.get_point_position(0)).normalized()
	var suspension_mount: Vector3 = $Chassis/FrontSuspension.to_global($Chassis/FrontSuspension.curve.get_point_position(1))
	
	$Chassis.apply_force(suspension_dir * compression_dist * stiffness, suspension_mount - $Chassis.global_position)
