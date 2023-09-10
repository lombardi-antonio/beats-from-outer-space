extends Control

onready var mute_button = $MuteButton

var mute_icon = load("res://assets/mute.png")
var unmute_icon = load("res://assets/unmute.png")


func _ready():
	if Space.is_muted:
		mute_button.icon = unmute_icon
	else:
		mute_button.icon = mute_icon


func _process(_delta):

	if Space.time_scale < 1.0:
		mute_button.disabled = false
		mute_button.visible = true
	else:
		mute_button.disabled = true
		mute_button.visible = false

	if Space.is_muted:
		mute_button.icon = unmute_icon
	else:
		mute_button.icon = mute_icon