extends Area

export var speed = 1
export var damage = 10

onready var timer = $Timer


func _ready():
	var _conect_body = connect("body_entered", self, "_on_body_entered")
	var _conect_area = connect("area_entered", self, "_on_area_entered")


func _process(delta):
	translation.z -= speed * Space.time_scale * delta

	if translation.z < -50:
		queue_free()

	if Space.time_scale < 1:
		timer.paused = true
	else:
		timer.paused = false


func _on_body_entered(body):
	if body.is_in_group("enemies"):
		body.deal_damage(damage)
		queue_free()

func _on_area_entered(area):
	if area.is_in_group("enemies"):
		area.deal_damage(damage)
		queue_free()


func remove_self():
	hide()
	queue_free()


func _on_Timer_timeout():
	remove_self()
