extends Area

onready var space = $"/root/Space"
onready var timer = $Timer


func _ready():
	var _connect_body = connect("body_entered", self, "_on_body_entered")
	var _connect_area = connect("area_entered", self, "_on_area_entered")
	timer.connect("timeout", self, "_on_timeout")


func _process(_delta):
	pass


func _on_body_entered(body):
	if body.is_in_group("enemies"):
		body.got_parried()
		_remove_self()


func _on_area_entered(area):
	if area.is_in_group("enemies"):
		area.got_parried()
		_remove_self()


func _on_timeout():
	_remove_self()


func _remove_self():
	hide()
	queue_free()
