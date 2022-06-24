extends Area

export var speed = 1
export var damage = 10
export var steer_force = 0.2

onready var space = $"/root/Space"
onready var timer = $Timer

var acceleration = Vector3.ZERO
var velocity = Vector3.ZERO
var target = null


func _ready():
	start(Vector3(0, 0, 1), null)
	return connect("body_entered", self, "_on_body_entered")


func start(_transform, _target):
	global_transform.origin = _transform
	velocity = global_transform.origin * speed
	target = _target


func seek():
	var steer = Vector3.ZERO
	if target:
		var desired = (target.global_transform.origin - global_transform.origin).normalized() * speed
		steer = (desired - velocity).normalized() * steer_force
	return steer


func _process(_delta):
	if Space.time_scale < 1:
		if timer: timer.paused = true
	else:
		if timer: timer.paused = false

	if translation.z > 50:
		queue_free()


func _physics_process(delta):
	acceleration += seek()
	velocity += acceleration * delta
	velocity = velocity.normalized() * speed
	translation += velocity * delta * Space.time_scale


func _on_body_entered(body):
	if body.name == "VaporFalcon":
		body.deal_damage(damage)
		queue_free()


func remove_self():
	hide()
	queue_free()


func _on_timer_timeout():
	remove_self()
