extends Area

onready var space = $"/root/Space"
onready var mesh = $ShipMesh
onready var collision = $ShipCollision
onready var cooldown = $Cooldown
onready var animation = $AnimationPlayer

export var speed = 1.0
export var health = 10
export var damage = 10
export var hit_damage = 20
export var points = 5
export(PackedScene) var projectile

var dead = false
var can_shoot = true

signal was_defeated()


func _ready():
	if projectile == null:
		can_shoot = false
	else:
		cooldown.connect("timeout", self, "_on_cooldown_timeout")

	return connect("body_entered", self, "_on_body_entered")


func _process(_delta):
	# pause cooldown when in slow-mo
	if Space.time_scale < 1:
		cooldown.paused = true
	else:
		cooldown.paused = false

	animation.playback_speed = Space.time_scale

	# if can_shoot:
	# 	_shoot()


func _shoot():
	if dead:
		return

	var new_projectile = projectile.instance()
	get_tree().get_root().add_child(new_projectile)
	new_projectile.translation = global_transform.origin
	can_shoot = false
	cooldown.start()


func deal_damage(_damage):
	animation.play("blowback")
	health -= _damage
	if health <= 0:
		dead = true
		if collision: collision.queue_free()
		hide()
		space.points += points
		emit_signal("was_defeated")


func _on_cooldown_timeout():
	can_shoot = true


func _on_body_entered(body):
	if body.name == "VaperFalcon":
		body.deal_damage(hit_damage)
		queue_free()
