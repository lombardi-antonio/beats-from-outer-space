extends Area

export var speed = 1

onready var space = $"/root/space"


func _ready():
	connect("body_entered", self, "_on_body_entered")
	connect("area_entered", self, "_on_area_entered")


func _process(_delta):
	pass


func _on_body_entered(body):
	if body.is_in_group("enemies"):
		body.got_parried()
		queue_free()

func _on_area_entered(area):
	if area.is_in_group("enemies"):
		area.got_parried()
		queue_free()


func remove_self():
	hide()
	queue_free()
