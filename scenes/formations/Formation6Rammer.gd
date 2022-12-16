extends Spatial

onready var space = $"/root/Space"

export(float) var speed = 0.5
export(float) var target_positon_min = -1.0
export(float) var target_positon_max = 1.0
export(Array) var upgrade_matrix = [[0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]]

var target_position
var left_bound
var right_bound
var is_in_position = false
var direction = 1
var enemy_count

signal formation_defeated()


func _ready():
	enemy_count = get_children().size()

	if enemy_count >= upgrade_matrix.size():
		_add_upgrade()


func _process(_delta):
	pass


func _add_upgrade():
	for index in get_children().size():
		var enemy = get_children()[index]
		var upgrade_array = upgrade_matrix[index]

		if upgrade_array[0]:
			enemy.holds_upgrade = 1
			enemy.upgrade_level = upgrade_array[1]


func _defeated():
	emit_signal("formation_defeated")
	queue_free()


func _on_any_enemy_defeated():
	enemy_count -= 1
	if enemy_count <= 0:
		_defeated()


func _on_EnemyRammer_was_defeated():
	_on_any_enemy_defeated()


func _on_EnemyRammer2_was_defeated():
	_on_any_enemy_defeated()


func _on_EnemyRammer3_was_defeated():
	_on_any_enemy_defeated()


func _on_EnemyRammer4_was_defeated():
	_on_any_enemy_defeated()


func _on_EnemyRammer5_was_defeated():
	_on_any_enemy_defeated()


func _on_EnemyRammer6_was_defeated():
	_on_any_enemy_defeated()
