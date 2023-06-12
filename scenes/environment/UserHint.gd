extends Control


onready var animation: AnimationPlayer = $AnimationPlayer
onready var hint_timer: Timer = $HintTimer


func _ready():
	visible = false


func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if visible: visible = false

		hint_timer.paused = true


func _on_HintTimer_timeout():
	visible = true
	animation.play("ShowHint")
