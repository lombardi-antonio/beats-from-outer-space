extends Spatial

export var move_speed = 1
export var offset = 6.0

onready var front = $front
onready var back = $back
onready var space = $"/root/space"

var front_position
var back_position
var rewinding = false


func _ready():
	front_position = front.translation.z
	back_position = back.translation.z


func _process(delta):
	if rewinding:
		rewind(delta)
		return
	endless_scroll(delta)


func endless_scroll(delta):
	front.translation.z += move_speed * space.time_scale * delta
	back.translation.z += move_speed * space.time_scale * delta

	if front.translation.z >= back_position + offset:
		front.translation.z = front_position
	elif back.translation.z >= back_position + offset:
		back.translation.z = front_position


func rewind(delta):
	front.translation.z -= move_speed * space.time_scale * delta
	back.translation.z -= move_speed * space.time_scale * delta

	if front.translation.z < front_position:
		front.translation.z = back_position
	elif back.translation.z < front_position:
		back.translation.z = back_position


func _on_vapor_falcon_was_defeated():
	rewinding = false
