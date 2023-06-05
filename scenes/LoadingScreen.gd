extends Spatial

onready var animation: AnimationPlayer = $AnimationPlayer

var taped: bool = false
var home_scene = null


func _ready():
	home_scene = load("res://scenes/Home.tscn")


func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		taped = event.pressed

		if taped:
			animation.play("Transition")


func goto_home():
	if home_scene:
		return get_tree().change_scene_to(home_scene)
	else:
		return get_tree().change_scene("res://scenes/Home.tscn")
