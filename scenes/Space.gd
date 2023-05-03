extends Spatial

export(Array, PackedScene) var spawner_list_level1

var time_scale: float
var points: int

var _wave: int = 0
var _movement_disabled: bool
var _ready_for_next_spawn: bool = false

signal level_cleared()
signal spawner_defeated()


func _ready():
	time_scale = 1
	points = 0
	_movement_disabled = false
	_init_next_spawner()


func _init_next_spawner():
	if _wave > spawner_list_level1.size() - 1:
		return get_tree().reload_current_scene()
	_spawn(spawner_list_level1[_wave])


func _spawn(spawner: PackedScene):
	var new_spawn = spawner.instance()
	new_spawn.translation = Vector3(0, 0, -1.7)
	add_child(new_spawn)
	new_spawn.connect("defeated", self, "_on_spawner_defeated")


func _on_spawner_defeated():
	emit_signal("spawner_defeated")
	get_tree().call_group("projectile", "remove_self")

	if _wave >= spawner_list_level1.size() - 1:
		emit_signal("level_cleared")

	_wave += 1
	_ready_for_next_spawn = true


func _on_vapor_falcon_was_defeated():
	get_tree().call_group("enemies", "remove_self")
	get_tree().call_group("projectile", "remove_self")


func _on_CameraBase_ready_for_next_spawn():
	time_scale = .005

	if not _ready_for_next_spawn:
		return

	else:
		get_tree().call_group("projectile", "remove_self")
		_init_next_spawner()
		_ready_for_next_spawn = false
