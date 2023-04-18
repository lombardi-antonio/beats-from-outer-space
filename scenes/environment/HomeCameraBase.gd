extends Spatial

onready var camera: Camera = $PlayerCamera
onready var space: Spatial = $"/root/Space"

const MOVE_MARGIN = 15
const RAY_LENGTH = 1000

var _player_dead: bool = false
var _player_position: Vector3 = Vector3.ZERO
var _target_position: Vector3
var _screen_touch: bool = false
var _spawner_defeated: bool = false
var _state: int

enum STATE {
	PLAYING,
	MOVING,
	FOCUS,
	DEATH
}


func _ready():
	_target_position = translation


func _process(_delta):
	_player_position = _get_player_position()
	look_at(_player_position, Vector3.UP)
	if translation.y > 0.25:
		translation.y = translation.y - 2 * _delta
	else:
		_rotate_around_player()


func _get_player_position():
	return get_node("../VaporFalcon").translation


func _rotate_around_player():
	var angle = 0.01

	translation = Vector3(_player_position.x, 0.0, _player_position.z) + (translation - Vector3(_player_position.x, 0.0, _player_position.z)).rotated(Vector3.UP, angle)
