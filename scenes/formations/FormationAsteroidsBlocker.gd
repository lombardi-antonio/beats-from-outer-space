extends Spatial

onready var space = $"/root/Space"
onready var timer = $Timer

export var speed = 0.5
export var target_positon_min = -1.0
export var target_positon_max = 1.0
export var enemy_count = 0

var target_position
var left_bound
var right_bound
var is_in_position = false
var direction = 1

signal formation_defeated()


func _ready():
	target_position = rand_range(target_positon_min, target_positon_max)
	left_bound = translation.x -0.2
	right_bound = translation.x +0.2
	direction = 1 if rand_range(0, 100) > 50 else -1
	if enemy_count == 0:
		for child in get_children():
			if child.is_in_group("obstacle") || child.is_in_group("enemies"):
				enemy_count += 1


func _process(_delta):
	pass


func movement(_delta):
	pass


func _defeated():
	emit_signal("formation_defeated")
	queue_free()


func _on_any_enemy_defeated():
	enemy_count -= 1
	if enemy_count <= 0:
		timer.start()


func _on_Timer_timeout():
	get_tree().call_group("projectile", "remove_self")

	_defeated()


func _spawn_another_jaeger():
	pass


func _on_EnemyJaeger_was_defeated():
	_spawn_another_jaeger()


func _on_Asteroid_was_defeated():
	_on_any_enemy_defeated()
