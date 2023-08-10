extends Area


func _ready():
	pass


func _process(delta):
	rotate(Vector3.DOWN, .5 * Space.time_scale * delta)
