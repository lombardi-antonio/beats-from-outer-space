extends "res://scenes/enemies/BaseEnemy.gd"

onready var shot_cooldown = $TripleShotCooldown
onready var barrel = $Berrel

export var damage = 10
export var hit_damage = 20

var shot_count = 0


func _ready():
	pass


func _process(_delta):
	# pause cooldown when in slow-mo
	if Space.time_scale < 1:
		cooldown.paused = true
		shot_cooldown.paused = true
	else:
		cooldown.paused = false
		shot_cooldown.paused = false

	if can_shoot:
		_shoot()


func _shoot():
	if dead:
		return

	var new_projectile = projectile.instance()
	get_tree().get_root().add_child(new_projectile)
	new_projectile.translation = barrel.global_transform.origin
	can_shoot = false
	shot_cooldown.start()
	cooldown.start()


func got_parried():
	pass


func shrapnel_damage():
	pass


func _on_TripleShotCooldown_timeout():
	if shot_count >= 3:
		can_shoot = false
	else:
		shot_count += 1
		can_shoot = true


func _on_Cooldown_timeout():
	shot_count = 0
	can_shoot = true
