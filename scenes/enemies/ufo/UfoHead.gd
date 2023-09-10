extends Area


export(int) var health: int = 30

onready var collision: CollisionShape = $CollisionShape
onready var animation: AnimationPlayer = $AnimationPlayer
onready var animation_tree: AnimationTree = $AnimationTree
onready var heart: MeshInstance = $HeartMesh
onready var recoveryTimer: Timer = $RecoveryTimer
onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

var _is_open: bool = false

signal has_recovered()
signal was_opend()
signal was_defeated()
signal call_backup()
signal pepare_for_defeat()


func _ready():
	collision.disabled = false
	animation_tree.active = true


func _process(_delta):
	_process_time_scale()


func _process_time_scale():
	animation_tree["parameters/Idle/TimeScale/scale"] = Space.time_scale
	animation_tree["parameters/Idle_Open/TimeScale/scale"] = Space.time_scale
	animation_tree["parameters/Idle_Close/TimeScale/scale"] = Space.time_scale
	animation_tree["parameters/Blowback/TimeScale/scale"] = Space.time_scale
	animation_tree["parameters/Blowback_Close/TimeScale/scale"] = Space.time_scale
	animation_tree["parameters/Defeated/TimeScale/scale"] = Space.time_scale

	if Space.time_scale < 1.0:
		if audio_player.pitch_scale > 0.03:
			# make sure the pitch_scale can not dip below 0.01 because this will stop the music
			audio_player.pitch_scale = audio_player.pitch_scale - 0.02
	else:
		if audio_player.pitch_scale < 1:
			audio_player.pitch_scale = audio_player.pitch_scale + 0.02


func deal_damage(damage):
	if not _is_open: return

	health -= damage
	animation_tree["parameters/conditions/is_hit"] = true

	if health <= 0:
		animation_tree["parameters/conditions/is_defeated"] = true
		emit_signal("pepare_for_defeat")
		return
	else:
		animation_tree["parameters/conditions/is_closing"] = true

	recoveryTimer.start()


func set_is_open(is_open: bool):
	_is_open = is_open


func reset_animation_parameters(with_closing: bool = true):
	animation_tree["parameters/conditions/is_opening"] = false
	animation_tree["parameters/conditions/is_hit"] = false
	if with_closing:
		animation_tree["parameters/conditions/is_closing"] = false


func deal_shrapnel_damage():
	emit_signal("was_opend")
	animation_tree["parameters/conditions/is_opening"] = true


func call_for_backup():
	emit_signal("call_backup")


func _boss_defeated():
	hide()
	Space.kills += 1
	Space.points += 1000
	emit_signal("was_defeated")


func _on_UfoHead_body_entered(body):
	if body.name != 'VaporFalcon': return

	body.deal_damage(1000)


func _on_RecoveryTimer_timeout():
	emit_signal("has_recovered")
