extends Spatial

onready var space = $"/root/Space"

export var speed = 0.5
export var target_positon_min = -1.0
export var target_positon_max = 1.0

var target_position
var left_bound
var right_bound
var is_in_position = false
var direction = 1
var enemy_count

signal formation_defeated()


func _ready():
	enemy_count = get_children().size()


func _process(delta):
	pass


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
