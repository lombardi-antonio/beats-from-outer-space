extends KinematicBody

onready var space = $"/root/space"
onready var animation = $animation_player
onready var timer = $timer
onready var collision = $collistion

export var speed = 1
export var health = 30
export var points = 10
export(PackedScene) var projectile

var dead = false
var can_shoot = true

signal was_defeated()


func _ready():
	if not dead:
		collision.disabled = true


func _process(_delta):
	if space.time_scale < 1:
		timer.paused = true
	else:
		timer.paused = false

	if not dead:
		if collision && collision.disabled && collision.global_transform.origin.z >= -3.15:
			collision.disabled = false

		if can_shoot:
			_shoot()

	animation.playback_speed = space.time_scale


func _shoot():
	if dead:
		return

	var new_projectile = projectile.instance()
	get_tree().get_root().add_child(new_projectile)
	new_projectile.translation = global_transform.origin
	can_shoot = false
	timer.start()


func deal_damage(damage):
	animation.play("blowback")
	health -= damage
	if health <= 0:
		dead = true
		if collision: collision.queue_free()
		hide()
		space.points += points
		emit_signal("was_defeated")


func _on_timer_timeout():
	can_shoot = true

func remove_self():
	hide()
	queue_free()
