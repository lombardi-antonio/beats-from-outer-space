extends Area

onready var animation = $AnimationPlayer
onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

var was_defeated = false
var multiplier = 1


func _ready():
	pass


func _process(delta):
	rotate(Vector3.DOWN, .5 * Space.time_scale * delta * multiplier)

	if was_defeated:
		translate((Vector3.UP * Vector3.LEFT) + Vector3.BACK * 2 * Space.time_scale * delta)

	_process_time_scale()


func _process_time_scale():
	if Space.time_scale < 1.0:
		if audio_player.pitch_scale > 0.03:
			# make sure the pitch_scale can not dip below 0.01 because this will stop the music
			audio_player.pitch_scale = audio_player.pitch_scale - 0.02
	else:
		if audio_player.pitch_scale < 1:
			audio_player.pitch_scale = audio_player.pitch_scale + 0.02

	animation.playback_speed = Space.time_scale


func defeated_movement():
	was_defeated = true


func _on_UfoHead_pepare_for_defeat():
	animation.play("Defeated")
	audio_player.play()


func _on_UfoTurret_was_defeated():
	multiplier += 1
