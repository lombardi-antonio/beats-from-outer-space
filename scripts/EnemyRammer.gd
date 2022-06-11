extends Area

onready var space = $"/root/space"
onready var mesh = $ShipMesh
onready var collision = $ShipCollision
onready var cooldown = $Cooldown
onready var animation = $AnimationPlayer

export var speed = 1.0
export var health = 10
export var damage = 10
export var hit_damage = 20
export var points = 5

var dead = false
var can_shoot = true

signal was_defeated()

onready var target = $TargetPosition
onready var spinup = $Spinup
onready var spinup_position = $SpinupPosition

var spinup_ended = false
var spiup_started = false


func _ready():
	if collision:
		collision.disabled = true

	return connect("body_entered", self, "_on_body_entered")


func _process(delta):
	if dead:
		return
	if !collision:
		return
	if collision.translation.z >= target.translation.z:
		emit_signal("was_defeated")
		queue_free()
		return

	if space.time_scale < 1:
		spinup.paused = true
	else:
		spinup.paused = false

	if mesh.global_transform.origin.z < -3.3:
		mesh.translation.z += speed * space.time_scale * delta
		collision.translation.z += speed * space.time_scale * delta
	else:
		if not spiup_started:
			spinup.start()
			spiup_started = true

	if spinup_ended:
		mesh.translation.z += speed * space.time_scale * delta
		collision.translation.z += speed * space.time_scale * delta


func _on_Spinup_timeout():
	if dead:
		return
	spinup_ended = true
	if collision:
		collision.disabled = false


func deal_damage(_damage):
	animation.play("blowback")
	health -= _damage
	if health <= 0:
		dead = true
		if collision: collision.queue_free()
		hide()
		space.points += points
		emit_signal("was_defeated")


func got_parried():
	pass


func _on_body_entered(body):
	if body.name == "vapor_falcon":
		body.deal_damage(hit_damage)
		deal_damage(health)
