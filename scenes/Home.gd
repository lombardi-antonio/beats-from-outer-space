extends Spatial


func _ready():
	pass # Replace with function body.


func _on_StartButton_button_up():
	get_tree().change_scene("res://scenes/space.tscn")
