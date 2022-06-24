extends "res://scenes/enemies/BaseProjectile.gd"

var target_ship = null

func _ready():
	target_ship = get_tree().get_nodes_in_group("player")[0]
	start(Vector3(0,0,1), target_ship)


func find_target():
	var units = get_tree().get_nodes_in_group("player")
	var closest = units[0]
	target_ship = closest
