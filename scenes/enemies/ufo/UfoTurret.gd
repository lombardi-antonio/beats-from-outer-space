extends Area

export(PackedScene) var projectile
export(int) var health: int = 50

onready var collision: CollisionShape = $CollisionShape
onready var animation_tree: AnimationTree = $AnimationTree
onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

var in_position: bool = false

signal was_defeated()


func _ready():
	in_position = true
	animation_tree.active = true


func _process(_delta):
	if Space.is_muted:
		audio_player.unit_db = -80
	else:
		audio_player.unit_db = 0

	_process_time_scale()
	_reset_animation_parameters()

	if in_position:
		animation_tree["parameters/conditions/is_shooting"] = 1


func deal_damage(damage):
	health -= damage
	if health > 0:
		animation_tree["parameters/conditions/is_hit"] = 1
	else:
		animation_tree["parameters/conditions/is_defeated"] = 1
		audio_player.play()
		if is_instance_valid(collision):
			collision.queue_free()
		Space.kills += 1
		Space.points += 10
		emit_signal("was_defeated")


func deal_shrapnel_damage():
	deal_damage(100)


func _process_time_scale():
	animation_tree["parameters/Idle/TimeScale/scale"] = Space.time_scale
	animation_tree["parameters/Shooting/TimeScale/scale"] = Space.time_scale
	animation_tree["parameters/Blowback/TimeScale/scale"] = Space.time_scale

	if Space.time_scale < 1.0:
		if audio_player.pitch_scale > 0.03:
			# make sure the pitch_scale can not dip below 0.01 because this will stop the music
			audio_player.pitch_scale = audio_player.pitch_scale - 0.02
	else:
		if audio_player.pitch_scale < 1:
			audio_player.pitch_scale = audio_player.pitch_scale + 0.02


func _reset_animation_parameters():
	animation_tree["parameters/conditions/is_shooting"] = 0
	animation_tree["parameters/conditions/stoped_shooting"] = 0
	animation_tree["parameters/conditions/is_hit"] = 0


func _shoot():
	if !is_instance_valid(projectile):
		return

	var new_projectile = projectile.instance()
	get_tree().get_root().add_child(new_projectile)
	new_projectile.translation = global_transform.origin + Vector3.UP * 0.3


func _remove_self():
	hide()
	queue_free()


func _on_UfoTurret_body_entered(body:Node):
	if body.name != 'VaporFalcon': return

	body.deal_damage(20)
	deal_damage(50)


func set_collision_disabled(val:bool):
	if is_instance_valid(collision):
		collision.disabled = val
