extends Node3D

@export var stiffness: float = 8000.0
@export var dampening: float = 100.0

func _input(event):
	
	if event.as_text() == "1":
		$Chassis/Camera1.make_current()
	elif event.as_text() == "2":
		$Chassis/Camera2.make_current()

func _physics_process(_delta: float) -> void:
	
	var suspension_dir: Vector3 = $Chassis/FrontSuspension.to_global($Chassis/FrontSuspension.curve.get_point_position(1) - $Chassis/FrontSuspension.curve.get_point_position(0)).normalized()
	
	var suspension_mount: Vector3 = $Chassis/FrontSuspension.to_global($Chassis/FrontSuspension.curve.get_point_position(1))
	
	var compress: Vector3 = $FrontWheel.global_position - $Chassis/FrontSuspension.to_global($Chassis/FrontSuspension.curve.get_point_position(0))
	
	var compress_along_dir := suspension_dir.dot(compress)
	compress -= suspension_dir * compress_along_dir
	compress *= 2.0
	compress += suspension_dir * compress_along_dir
	
	# stiffness (resist compression)
	$Chassis.apply_force(compress * stiffness, suspension_mount - $Chassis.global_position)
	$FrontWheel.apply_force(-compress * stiffness)
	
	# dampening (resist velocity)
	$FrontWheel.apply_force(-($FrontWheel.linear_velocity - $Chassis.linear_velocity) * dampening)
	
	# wheel is a separate physical object from the bike itself
	# normal/frictional forces act on the wheel, which applies normal/spring forces on the bike
	# free body diagram
