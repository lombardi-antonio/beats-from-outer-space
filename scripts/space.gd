extends Spatial

export(Array, PackedScene) var spawner_list_level1

var time_scale
var points
var wave = 0
var movement_disabled
var ready_for_next_spawn = false

signal level_cleared()
signal spawner_defeated()


func _ready():
	time_scale = 1
	points = 0
	movement_disabled = false

	_init_next_spawner()


func _init_next_spawner():
	if wave > spawner_list_level1.size() - 1:
		return get_tree().reload_current_scene()
	_spawn(spawner_list_level1[wave])


func _on_spawner_defeated():
	emit_signal("spawner_defeated")
	get_tree().call_group("projectile", "remove_self")
	if wave >= spawner_list_level1.size() - 1:
		emit_signal("level_cleared")
	wave += 1
	ready_for_next_spawn = true


func _spawn(spawner: PackedScene):
	var new_spawn = spawner.instance()
	new_spawn.translation = Vector3(0, 0, -1.7)
	add_child(new_spawn)
	new_spawn.connect("defeated", self, "_on_spawner_defeated")


func _on_ContinueButton_pressed():
	time_scale = .005

	if not ready_for_next_spawn:
		return

	else:
		get_tree().call_group("projectile", "remove_self")
		_init_next_spawner()
		ready_for_next_spawn = false


func _on_vapor_falcon_was_defeated():
	get_tree().call_group("enemies", "remove_self")
	get_tree().call_group("projectile", "remove_self")
