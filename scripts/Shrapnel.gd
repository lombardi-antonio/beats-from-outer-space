extends Area

export var speed = 1
export var damage = 10
export var direction = Vector3(1, 0, 0.3)

onready var space = $"/root/Space"


func _ready():
	randomize()

	connect("body_entered", self, "_on_body_entered")
	connect("area_entered", self, "_on_area_entered")

	rotation_degrees = Vector3(rand_range(0, 360), rand_range(0, 360), rand_range(0, 360))


func _process(delta):
	translation -= direction * speed * space.time_scale * delta
	rotation_degrees += direction * rand_range(500, 1500) * Space.time_scale * delta

	if translation.z < -50:
		queue_free()


func _on_body_entered(body):
	if body.is_in_group("enemies"):
		body.shrapnel_damage()
		queue_free()

func _on_area_entered(area):
	if area.is_in_group("enemies"):
		area.shrapnel_damage()
		queue_free()


func remove_self():
	hide()
	queue_free()
