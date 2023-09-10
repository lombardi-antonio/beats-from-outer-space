extends Area

signal has_recovered()
signal was_defeated()
signal was_opend()
signal send_back_up()

onready var target_position: Position3D = $TargetPosition
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

var target: Vector3 = Vector3.ZERO

var _active_turrets: int = 4


func _ready():
	target = target_position.global_transform.origin


func _process(delta):
	if global_transform.origin.distance_to(target) < 0.1:
		return

	global_transform.origin = global_transform.origin.move_toward(target, delta * Space.time_scale)

	_process_time_scale()


func _process_time_scale():
	if Space.time_scale < 1.0:
		if audio_player.pitch_scale > 0.03:
			# make sure the pitch_scale can not dip below 0.01 because this will stop the music
			audio_player.pitch_scale = audio_player.pitch_scale - 0.02
	else:
		if audio_player.pitch_scale < 1:
			audio_player.pitch_scale = audio_player.pitch_scale + 0.02

	animation_player.playback_speed = Space.time_scale



func _on_UfoHead_was_defeated():
	emit_signal("was_defeated")


func _on_UfoHead_has_recovered():
	emit_signal("has_recovered")


func _on_UfoTurret_was_defeated():
	if _active_turrets <= 1:
		emit_signal("send_back_up")
		return

	_active_turrets -= 1


func _on_UfoHead_was_opend():
	emit_signal("was_opend")


func _on_UfoHead_call_backup():
	emit_signal("send_back_up")
