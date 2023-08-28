extends Spatial

export var speed = 0.5
export var target_positon_min = -1.0
export var target_positon_max = 1.0
export(PackedScene) var underling

var _ufo_defeated = false
var _ready_to_respawn = false

var target_position
var left_bound
var right_bound
var is_in_position = false
var direction = 1
var enemy_count

signal formation_defeated()


func _ready():
	enemy_count = get_children().size()
	_spawn_underling()


func _process(_delta):
	pass


func _defeated():
	emit_signal("formation_defeated")
	queue_free()


func _spawn_underling():
	if !is_instance_valid(underling):
		return

	var new_underling = underling.instance()
	get_tree().get_root().add_child(new_underling)
	new_underling.translation = global_transform.origin
	new_underling.can_load_attack = true
	new_underling.loaded_shot_possibility = 2
	new_underling.target_translation = Vector3(
		global_transform.origin.x + rand_range(-.5, .5),
		global_transform.origin.y,
		global_transform.origin.z + 1.2
	)
	new_underling.connect("was_defeated", self, "_on_EnemyJaeger_was_defeated")


func _on_any_enemy_defeated():
	enemy_count -= 1
	if enemy_count <= 0:
		_defeated()


func _on_Ufo_was_defeated():
	_ufo_defeated = true
	_defeated()


func _on_EnemyJaeger_was_defeated():
	_ready_to_respawn = true


func _on_Ufo_has_recovered():
	if _ready_to_respawn:
		_spawn_underling()
		_ready_to_respawn = false
