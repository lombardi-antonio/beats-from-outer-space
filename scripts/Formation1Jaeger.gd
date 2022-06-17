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
	target_position = rand_range(target_positon_min, target_positon_max)
	left_bound = translation.x -0.2
	right_bound = translation.x +0.2
	direction = 1 if rand_range(0, 100) > 50 else -1
	enemy_count = get_children().size()


func _process(delta):
	movement(delta)
	translation.x += speed * Space.time_scale * direction * delta
	if translation.x > right_bound:
		direction = -1
	elif translation.x < left_bound:
		direction = 1


func movement(delta):
	if is_in_position:
		return

	translation.z += speed * Space.time_scale * delta
	if translation.z >= target_position:
		translation.z = target_position
		is_in_position = true


func _defeated():
	emit_signal("formation_defeated")
	queue_free()


func _on_any_enemy_defeated():
	enemy_count -= 1
	if enemy_count <= 0:
		_defeated()


func _on_jaeger_was_defeated():
	_on_any_enemy_defeated()


func _on_jaeger2_was_defeated():
	_on_any_enemy_defeated()


func _on_jaeger3_was_defeated():
	_on_any_enemy_defeated()
