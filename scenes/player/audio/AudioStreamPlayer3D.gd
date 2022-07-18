extends AudioStreamPlayer3D


func play( from_position=0.0 ):
	var asp = self.duplicate(DUPLICATE_USE_INSTANCING)
	get_parent().add_child(asp)
	asp.stream = stream
	asp.play(from_position)
	yield(asp, "finished")
	asp.queue_free()