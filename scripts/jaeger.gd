extends Area

onready var space = $"/root/space"
onready var animation = $animation_player
onready var timer = $timer
onready var collision = $Collision
onready var loaded_shot_timer: Timer = $LoadedShotTimer
onready var loading_particles: Particles = $LoadingParticles

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
		timer.wait_time = 3.0

	connect("body_entered", self, "_on_body_entered")
	connect("area_entered", self, "_on_area_entered")


func _process(_delta):
	if space.time_scale < 1:
		timer.paused = true
		loaded_shot_timer.paused = true
		loading_particles.speed_scale = space.time_scale
	else:
		timer.paused = false
		loaded_shot_timer.paused = false
		loading_particles.speed_scale = 1.0

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
	if is_loading_shot: return

	animation.play("blowback")
	health -= damage
	if health <= 0:
		dead = true
		if collision: collision.queue_free()
		hide()
		space.points += points
		emit_signal("was_defeated")


func shrapnel_damage():
	animation.play("explosion")


func _on_timer_timeout():
	if can_load_attack && randi() % 3 == 0:
		is_loading_shot = true
		loaded_shot_timer.start()
		loading_particles.emitting = true
	else:
		can_shoot = true


func _on_LoadedShotTimer_timeout():
	can_shoot = false
	_start_loaded_shot()
	is_loading_shot = false


func _start_loaded_shot():
	# start loading animation
	_shoot_loaded_shot()


func _shoot_loaded_shot():
	if dead:
		return

	loading_particles.emitting = false
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
	if is_loading_shot || body.name != 'vapor_falcon': return

	body.deal_damage(health)
	deal_damage(health)


func got_parried():
	if not is_loading_shot: return

	animation.play("explosion")


func _spawn_sharpnel_pieces(direction: Vector3):
	var new_shrapnel = shrapnel.instance()
	get_tree().get_root().add_child(new_shrapnel)
	new_shrapnel.translation = global_transform.origin
	new_shrapnel.direction = direction
	new_shrapnel.speed = rand_range(0.4, 1.0)


func spawn_shrapnel():
	# spawn 6-8 shrapnel
	for i in range(3):
		_spawn_sharpnel_pieces(Vector3(1, 0, i + -1.3))
		_spawn_sharpnel_pieces(Vector3(-1, 0, i + -1.3))

	_spawn_sharpnel_pieces(Vector3(0, 0, -1))
	_spawn_sharpnel_pieces(Vector3(0, 0, 1))

	is_loading_shot = false
	deal_damage(health)
