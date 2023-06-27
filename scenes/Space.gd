extends Spatial

export(Array, Array, PackedScene) var levels
export(Array, AudioStreamMP3) var music_list
export(Array, int) var music_list_bpm

var time_scale: float
var kills: int
var points: int

var _current_level: int = 0
var _current_wave: int = 0
var _movement_disabled: bool
var _ready_for_next_spawn: bool = false
var _level_cleared: bool = false
var _current_spawner: Node = null

onready var conductor: AudioStreamPlayer3D = $Conductor
onready var animation: AnimationPlayer = $AnimationPlayer
onready var universe_mesh: MeshInstance = $UniverseMesh
onready var death_timer: Timer = $DeathTimeOut
onready var player: KinematicBody = $VaporFalcon

signal level_cleared()
signal spawner_defeated()


func _ready():
	SaveState.load_game()

	time_scale = 1
	points = 0
	_movement_disabled = false
	_init_next_spawner()

	if is_instance_valid(conductor):

		_change_music_track(_current_level)


func get_save_stats():
	return {
		'file_name': get_filename(),
		'stats': {
			'current_level': _current_level,
			'current_wave': _current_wave
		}
	}


func load_save_stats(saved_data):
	_current_level = saved_data.stats.current_level
	_current_wave = saved_data.stats.current_wave


func _init_next_spawner():
	if !levels:
		return

	if _current_level > levels.size():
		goto_credits()

	_spawn(levels[_current_level][_current_wave])


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

	if _current_wave >= levels[_current_level].size() - 1:
		emit_signal("level_cleared")
		_level_cleared = true
		_current_level += 1
		_current_wave = 0
		_transition_to_next_level()
		_change_music_track(_current_level % music_list.size())
	else:
		_current_wave += 1

	if _current_level >= levels.size():
		goto_credits()

	_ready_for_next_spawn = true


func _on_vapor_falcon_was_defeated():
	death_timer.start()

	get_tree().call_group("enemies", "remove_self")
	get_tree().call_group("projectile", "remove_self")

	kills = 0
	points = 0
	_current_wave = 0

	SaveState.save_game()


func _change_music_track(track_number: int):
	if conductor.playing:
		conductor.stop()

	conductor.stream = music_list[track_number]
	conductor.bpm = music_list_bpm[track_number]
	conductor.recalculate_sec_per_beat()
	conductor.play()


func _on_CameraBase_ready_for_next_spawn():
	time_scale = .005

	if not _ready_for_next_spawn:
		return

	else:
		get_tree().call_group("projectile", "remove_self")
		_init_next_spawner()
		_ready_for_next_spawn = false


func _load_universe_image():
	if is_instance_valid(universe_mesh):
		universe_mesh.mesh.material.albedo_texture.image = load("res://sprites/Space_Stars" + String(_current_level + 1) +".png")


func _transition_to_next_level():
	animation.play("Transition")


func goto_next_level():
	# TODO: Create Array of Levels
	pass


func goto_credits():
	return get_tree().change_scene("res://scenes/Credits.tscn")


func _on_DeathTimeOut_timeout():
	get_tree().call_group("projectile", "remove_self")
	get_tree().call_group("enemies", "remove_self")
	get_tree().call_group("obstacles", "remove_self")

	player.respawn()

	_current_wave = 0
	time_scale = .005

	if not _ready_for_next_spawn:
		return

	else:
		get_tree().call_group("projectile", "remove_self")
		_init_next_spawner()
		_ready_for_next_spawn = false
