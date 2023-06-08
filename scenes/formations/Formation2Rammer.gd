extends Spatial

onready var space = $"/root/Space"
onready var spinup = $Spinup
onready var target = $Target

export(float) var speed = 1.0
export(float) var target_positon_min = -1.0
export(float) var target_positon_max = 1.0
export(int) var upgrade_level = 0 # if zero no upgrade will be placed

var is_in_position = false
var direction = 1
var enemies: Array
var enemy_count
var enemy_missed: bool = false

signal formation_defeated()


func _ready():
	for child in get_children():
		if child is Area:
			enemies.append(child)
			child.spinup_position.z = spinup.global_transform.origin.z
			child.target.z = target.global_transform.origin.z

	enemy_count = enemies.size()


func _process(_delta):
	pass


func _add_upgrade():
	if enemy_missed:
		return

	for index in enemies.size():
		var enemy = enemies[index]

		if is_instance_valid(enemy):
			enemy.holds_upgrade = 1
			enemy.upgrade_level = upgrade_level


func _defeated():
	emit_signal("formation_defeated")
	queue_free()


func _on_any_enemy_defeated():
	enemy_count -= 1

	if enemy_count == 1:
		if upgrade_level > 0:
			_add_upgrade()
		else:
			pass

	elif enemy_count <= 0:
		_defeated()


func _on_EnemyRammer_was_defeated():
	_on_any_enemy_defeated()


func _on_EnemyRammer2_was_defeated():
	_on_any_enemy_defeated()


func _on_EnemyRammer_passed():
	enemy_missed = true
	_on_any_enemy_defeated()


func _on_EnemyRammer2_passed():
	enemy_missed = true
	_on_any_enemy_defeated()
