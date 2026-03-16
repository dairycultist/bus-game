extends RigidBody3D

var front_wheel_colliding: bool

func _input(event):
	
	if event.as_text() == "1":
		$Camera1.make_current()
	elif event.as_text() == "2":
		$Camera2.make_current()

func _physics_process(delta: float) -> void:
	
	# wheel is a separate physical object from the bike itself
	# normal/frictional forces act on the wheel, which applies normal/spring forces on the bike
	# free body diagram
	
	$FrontWheel.position = $FrontSuspension.curve.sample(0, abs(sin(Time.get_ticks_msec() * 0.001)))
	
	if front_wheel_colliding:
		pass
	else:
		pass

func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	print(local_shape_index)
