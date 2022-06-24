extends Spatial

onready var camera: Camera = $PlayerCamera
onready var space: Spatial = $"/root/Space"

const MOVE_MARGIN = 15
const RAY_LENGTH = 1000

var _player_dead: bool = false
var _screen_touch: bool = false
var _spawner_defeated: bool = false


func _process(_delta):
	if _spawner_defeated:
		return

	if !_screen_touch && Space.time_scale > .05:
		Space.time_scale -= .05

	elif !_screen_touch && Space.time_scale <= .05:
		Space.time_scale = .005

	elif _player_dead && Space.time_scale <= 2:
		Space.time_scale += .05

	else:
		if Space.time_scale < 1:
			Space.time_scale += .1


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


func _on_vapor_falcon_was_defeated():
	_player_dead = true


func _on_space_spawner_defeated():
	_spawner_defeated = true


func _on_ContinueButton_pressed():
	_spawner_defeated = false
	_screen_touch = false
