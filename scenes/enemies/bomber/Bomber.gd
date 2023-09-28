extends "res://scenes/enemies/BaseEnemy.gd"

onready var shot_cooldown = $TripleShotCooldown
onready var barrel = $Berrel
onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

export var damage: int = 10
export var hit_damage: int = 20
export var bullet_number: int = 3

var shot_count: int = 0


func _ready():
	pass


func _process(_delta):
	_process_time_scale()

	if can_shoot:
		_shoot()


func _process_time_scale():

	if Space.is_muted:
		audio_player.unit_db = -80
	else:
		audio_player.unit_db = 0

	if Space.time_scale < 1.0:
		cooldown.paused = true
		shot_cooldown.paused = true
		if audio_player.pitch_scale > 0.03:
			# make sure the pitch_scale can not dip below 0.01 because this will stop the music
			audio_player.pitch_scale = audio_player.pitch_scale - 0.02
	else:
		cooldown.paused = false
		shot_cooldown.paused = false
		if audio_player.pitch_scale < 1:
			audio_player.pitch_scale = audio_player.pitch_scale + 0.02


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


func deal_damage(recieved_damage):
	if dead:
		return

	if _is_invincible: return

	health -= recieved_damage
	if health > 0:
		animation.play("Blowback")
	else:
		dead = true
		release_upgrade()
		space.kills += 1
		space.points += points
		animation.play("Defeated")
		emit_signal("was_defeated")


func deal_shrapnel_damage():
	deal_damage(20)


func _on_TripleShotCooldown_timeout():
	if shot_count >= bullet_number:
		can_shoot = false
	else:
		shot_count += 1
		can_shoot = true


func _on_Cooldown_timeout():
	shot_count = 0
	can_shoot = true


func _on_DetectionArea_body_entered(body:Node):
	if target_player_node:
		pass
	if body.name == 'VaporFalcon':
		target_player_node = body
		speed = 1.0
