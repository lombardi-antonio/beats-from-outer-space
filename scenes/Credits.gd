extends Spatial

onready var animation: AnimationPlayer = $AnimationPlayer

var tapped: bool = false


func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		tapped = event.pressed

		if tapped:
			animation.play("StartingAnimation")


func goto_home():
	return get_tree().change_scene("res://scenes/Home.tscn")