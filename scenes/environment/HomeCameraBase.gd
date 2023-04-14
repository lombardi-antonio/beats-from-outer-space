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
	_state = STATE.FOCUS
	_target_position = translation


func _process(_delta):

	match _state:
		STATE.PLAYING:
			if _player_dead:
				_state = STATE.DEATH

			if _spawner_defeated:
				_target_position = Vector3(0.0, 0.35, -1.15)
				_state = STATE.MOVING

			if !_screen_touch && Space.time_scale > .05:
				Space.time_scale -= .05

			elif !_screen_touch && Space.time_scale <= .05:
				Space.time_scale = .005

			else:
				if Space.time_scale < 1:
					Space.time_scale += .1

		STATE.MOVING:
			if translation != Vector3(_target_position.x, translation.y, _target_position.z):
				_player_position = _get_player_position()

				if _player_position.z < translation.z:
					look_at(_player_position, Vector3.UP)

				translation = translation.move_toward(_target_position, 2 * _delta)
			else:
				_state = STATE.FOCUS

		STATE.FOCUS:
			_player_position = _get_player_position()
			look_at(_player_position, Vector3.UP)
			if translation.y > 0.25:
				translation.y = translation.y - 2 * _delta
			else:
				_rotate_around_player()

		STATE.DEATH:
			if _player_dead && Space.time_scale <= 2:
				Space.time_scale += .05


func _input(event):
	if _player_dead:
		return

	if _spawner_defeated:
		get_tree().call_group("player", "level_cleared")
		return

	var m_pos = get_viewport().get_mouse_position()
	m_pos.x = clamp(m_pos.x, MOVE_MARGIN, get_viewport().size.x - MOVE_MARGIN)
	m_pos.y = clamp(m_pos.y, MOVE_MARGIN * 3, get_viewport().size.y + MOVE_MARGIN)

	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		_screen_touch = event.pressed

		if _screen_touch:
			_move_spaceship(m_pos)

	elif event is InputEventMouseMotion and _screen_touch:
		_move_spaceship(m_pos)


func _move_spaceship(m_pos):
	var result = _raycast_from_mouse(m_pos, 1)

	if result:
		get_tree().call_group("player", "add_to_path", result.position)


func _raycast_from_mouse(m_pos, collision_mask):
	var ray_start = camera.project_ray_origin(m_pos)
	var ray_end = ray_start + camera.project_ray_normal(m_pos) * RAY_LENGTH
	var space_state = get_world().direct_space_state
	return space_state.intersect_ray(ray_start, ray_end, [], collision_mask)


func _get_player_position():
	return get_node("../VaporFalcon").translation


func _rotate_around_player():
	var angle = 0.01

	translation = Vector3(_player_position.x, 0.0, _player_position.z) + (translation - Vector3(_player_position.x, 0.0, _player_position.z)).rotated(Vector3.UP, angle)
