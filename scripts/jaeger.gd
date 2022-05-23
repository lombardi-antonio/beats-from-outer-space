extends Area

onready var space = $"/root/space"
onready var animation = $animation_player
onready var timer = $timer
onready var collision = $collistion
onready var loaded_shot_timer: Timer = $LoadedShotTimer

export var speed = 1
export var health = 30
export var points = 10
export var can_load_attack: bool = false
export(PackedScene) var projectile
export(PackedScene) var shrapnel

var dead = false
var can_shoot = true
var is_loading_shot: bool = false

signal was_defeated()


func _ready():
	if not dead:
		collision.disabled = true

	if can_load_attack:
		timer.wait_time = 1.5
		loaded_shot_timer.start()

	return connect("body_entered", self, "_on_body_entered")


func _process(_delta):
	if space.time_scale < 1:
		timer.paused = true
		loaded_shot_timer.paused = true
	else:
		timer.paused = false
		loaded_shot_timer.paused = false

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


func _on_LoadedShotTimer_timeout():
	can_shoot = false
	_start_loaded_shot()


func _start_loaded_shot():
	# start loading animation
	_shoot_loaded_shot()


func _shoot_loaded_shot():
	if dead:
		return

	var new_projectile = projectile.instance()
	get_tree().get_root().add_child(new_projectile)
	new_projectile.translation = global_transform.origin
	new_projectile.scale *= 2
	new_projectile.damage *= 2
	timer.start()

func remove_self():
	hide()
	queue_free()


func _on_body_entered(body):
	if body.name == "vapor_falcon":
		if not is_loading_shot:
			body.deal_damage(health)
			deal_damage(health)
		else:
			if body.is_parying:
				got_parried()


func got_parried():
	# explode animation
	animation.play("explosion")


func spawn_shrapnel():
	# TODO: spawn 6-8 shrapnel
	pass
