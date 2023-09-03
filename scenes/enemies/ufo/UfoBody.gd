extends Area

onready var animation = $AnimationPlayer

var was_defeated = false
var multiplier = 1


func _ready():
	pass


func _process(delta):
	rotate(Vector3.DOWN, .5 * Space.time_scale * delta * multiplier)

	if was_defeated:
		translate((Vector3.UP * Vector3.LEFT) + Vector3.BACK * 2 * Space.time_scale * delta)


func defeated_movement():
	was_defeated = true


func _on_UfoHead_pepare_for_defeat():
	animation.play("Defeated")


func _on_UfoTurret_was_defeated():
	multiplier += 1
