extends Control

onready var kills: Label = $GridContainer/KillNum
onready var points: Label = $GridContainer/PointNum

func _process(_delta):
	kills.text = String(Space.kills)
	points.text = String(Space.points)


func _on_space_spawner_defeated():
	visible = true


func _on_ContinueButton_pressed():
	visible = false
