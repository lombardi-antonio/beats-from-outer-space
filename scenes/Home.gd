extends Spatial

onready var animation: AnimationPlayer = $AnimationPlayer
onready var conductor: AudioStreamPlayer3D = $Conductor


func _ready():
	pass


func _on_StartButton_button_up():
	animation.play("StartingAnimation")
	if conductor.get_playback_position() < 36.0:
		conductor.play(36.0)


func start_level():
	get_tree().change_scene("res://scenes/space.tscn")
