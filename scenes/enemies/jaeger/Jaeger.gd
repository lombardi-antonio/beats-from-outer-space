extends "res://scenes/enemies/BaseEnemy.gd"

export(bool) var can_load_attack: bool = false
export(float) var cooldown_time: float = 0.8

onready var loaded_shot_timer: Timer = $LoadedCooldown
onready var loading_particles: CPUParticles = $LoadingParticles

var is_load_shooting: bool = false


func _ready():
	# IMPORTANT: Does not overwrite parent _ready function!
	# Both will be called. Same for _process and _physical_process.
	# Only non Godot reserved functions will be overwritten (actual inheritance)

	# Parent will be called first!
	_init_timers()


func _process_time_scale():
	if Space.time_scale < 1:
		cooldown.paused = true
		loaded_shot_timer.paused = true

	else:
		cooldown.paused = false
		loaded_shot_timer.paused = false

	animation.playback_speed = Space.time_scale
	loading_particles.speed_scale = Space.time_scale


func _process_enemy_logic(_delta):
	if not dead:
		_invincibility_at_entry(-3.4)
		_handle_shooting()


func _init_timers():
	if can_load_attack && cooldown_time > 0:
		cooldown.wait_time = cooldown_time


func _on_cooldown_timeout():
	if can_load_attack && randi() % 10 == 0:
		is_load_shooting = true
		loaded_shot_timer.start()
		loading_particles.emitting = true
		can_shoot = false
		_is_invincible = true
	else:
		can_shoot = true


func _on_loaded_cooldown_timeout():
	can_shoot = false
	_start_loaded_shot()
	is_load_shooting = false
	_is_invincible = false


func _start_loaded_shot():
	# start loading animation
	_shoot_loaded_shot()


func _shoot_loaded_shot():
	if dead:
		return

	loading_particles.emitting = false
	var new_projectile = projectile.instance()
	get_tree().get_root().add_child(new_projectile)
	new_projectile.translation = global_transform.origin
	new_projectile.scale *= 2
	new_projectile.damage *= 2
	cooldown.start()


func _handle_shooting():
	if behaviour != STATE.FOLLOW || !target_player_node:
		if can_shoot: _shoot()

	elif global_transform.origin.x >= target_player_node.global_transform.origin.x -0.01 && global_transform.origin.x <= target_player_node.global_transform.origin.x +0.01:
		if can_shoot: _shoot()


func _on_body_entered(body):
	if is_load_shooting || body.name != 'VaporFalcon': return

	body.deal_damage(collision_damage)
	deal_damage(health)


func got_parried():
	if not is_load_shooting: return

	is_load_shooting = false
	animation.play("explosion")


func deal_shrapnel_damage():
	_is_invincible = true
	animation.play("explosion")


func _on_DetectionArea_body_entered(body):
	if body.name == 'VaporFalcon':
		target_player_node = body
		speed = 1.0
