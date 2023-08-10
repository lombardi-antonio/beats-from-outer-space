extends Area


export(bool) var open: bool = false

onready var animation: AnimationPlayer = $AnimationPlayer


func _ready():
	pass


func _process(_delta):
	_process_time_scale()


func _process_time_scale():
	animation.playback_speed = Space.time_scale


func open_hatch():
	animation.play("Open")


func close_hatch():
	animation.play("Closed")