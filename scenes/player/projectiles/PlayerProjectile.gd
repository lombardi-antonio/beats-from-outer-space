extends Area

export var speed = 1
export var damage = 10

onready var space = $"/root/Space"


func _ready():
	connect("body_entered", self, "_on_body_entered")
	connect("area_entered", self, "_on_area_entered")


func _process(delta):
	translation.z -= speed * Space.time_scale * delta

	if translation.z < -50:
		queue_free()


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
