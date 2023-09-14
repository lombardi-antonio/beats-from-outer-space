extends Spatial

export(Array, Array, PackedScene) var levels
export(Array, AudioStreamMP3) var music_list
export(Array, int) var music_list_bpm
export(bool) var is_muted = false

var time_scale: float
var kills: int
var points: int

var current_level: int = 0
var current_wave: int = 0
var _movement_disabled: bool
var _ready_for_next_spawn: bool = false
var _level_cleared: bool = false
var _current_spawner: Node = null

signal level_cleared()
signal spawner_defeated()


func _ready():
	SaveState.load_game()
	is_muted = Space.is_muted

	time_scale = 1
	points = 0
	_movement_disabled = false
	_init_next_spawner()


func get_save_stats():
	print("current_wave: ", current_wave)
	print("current_level: ", current_level)
	print("is_muted: ", is_muted)
	return {
		'file_name': get_filename(),
		'stats': {
			'current_level': current_level,
			'current_wave': current_wave,
			'is_muted': is_muted
		}
	}


func load_save_stats(saved_data):
	current_level = saved_data.stats.current_level
	current_wave = saved_data.stats.current_wave
	is_muted = saved_data.stats.is_muted
	print("Loaded Save Data: " + str(saved_data.stats))


func _init_next_spawner():
	if !levels:
		return

	if current_level > levels.size():
		goto_credits()

	_spawn(levels[current_level][current_wave])


func _spawn(spawner: PackedScene):
	_current_spawner = spawner.instance()
	_current_spawner.translation = Vector3(0, 0, -1.7)
	add_child(_current_spawner)
	return _current_spawner.connect("defeated", self, "_on_spawner_defeated")


func _on_spawner_defeated():
	if is_instance_valid(_current_spawner):
		_current_spawner.queue_free()

	emit_signal("spawner_defeated")
	get_tree().call_group("projectile", "remove_self")

	if current_wave >= levels[current_level].size() - 1:
		emit_signal("level_cleared")
		_level_cleared = true
		current_level += 1
		current_wave = 0
	else:
		current_wave += 1

	if current_level >= levels.size():
		goto_credits()

	_ready_for_next_spawn = true


func _on_vapor_falcon_was_defeated():

	get_tree().call_group("enemies", "remove_self")
	get_tree().call_group("projectile", "remove_self")

	kills = 0
	points = 0
	current_wave = 0

	SaveState.save_game()


func _on_CameraBase_ready_for_next_spawn():
	time_scale = .005

	if not _ready_for_next_spawn:
		return

	else:
		get_tree().call_group("projectile", "remove_self")
		_init_next_spawner()
		_ready_for_next_spawn = false


func goto_credits():
	return get_tree().change_scene("res://scenes/Credits.tscn")


func _on_DeathTimeOut_timeout():
	get_tree().call_group("projectile", "remove_self")
	get_tree().call_group("enemies", "remove_self")
	get_tree().call_group("obstacles", "remove_self")

	current_wave = 0
	time_scale = .005

	if not _ready_for_next_spawn:
		return

	else:
		get_tree().call_group("projectile", "remove_self")
		_init_next_spawner()
		_ready_for_next_spawn = false


func _on_MuteButton_button_down():
	is_muted = !is_muted
	Space.is_muted = is_muted
