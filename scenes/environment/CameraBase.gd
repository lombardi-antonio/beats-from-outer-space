extends Spatial

const MOVE_MARGIN = 15
const ray_length = 1000

onready var camera = $PlayerCamera
onready var space = $"/root/Space"

var screen_touch = false
var player_dead = false
var spawner_defeated = false
var v_size
var norm_position


func _process(_delta):
	if spawner_defeated:
		return
	if !screen_touch && Space.time_scale > .05:
		Space.time_scale -= .05
	elif !screen_touch && Space.time_scale <= .05:
		Space.time_scale = .005
	elif player_dead && Space.time_scale <= 2:
		Space.time_scale += .05
	else:
		if Space.time_scale < 1:
			Space.time_scale += .1



func _input(event):
	if player_dead:
		return

	if spawner_defeated:
		get_tree().call_group("player", "level_cleared")
		return

	var m_pos = get_viewport().get_mouse_position()
	m_pos.x = clamp(m_pos.x, MOVE_MARGIN, get_viewport().size.x - MOVE_MARGIN)
	m_pos.y = clamp(m_pos.y, MOVE_MARGIN * 3, get_viewport().size.y + MOVE_MARGIN)

	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		screen_touch = event.pressed
		if screen_touch:
			move_spaceship(m_pos)
	elif event is InputEventMouseMotion and screen_touch:
		move_spaceship(m_pos)


func move_spaceship(m_pos):
	var result = raycast_from_mouse(m_pos, 1)
	if result:
		get_tree().call_group("player", "add_to_path", result.position)


func raycast_from_mouse(m_pos, collision_mask):
	var ray_start = camera.project_ray_origin(m_pos)
	var ray_end = ray_start + camera.project_ray_normal(m_pos) * ray_length
	var space_state = get_world().direct_space_state
	return space_state.intersect_ray(ray_start, ray_end, [], collision_mask)


func _on_vapor_falcon_was_defeated():
	player_dead = true


func _on_space_spawner_defeated():
	spawner_defeated = true


func _on_ContinueButton_pressed():
	spawner_defeated = false
	screen_touch = false
