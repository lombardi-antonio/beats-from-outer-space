extends Spatial

export var health = 50
export var speed = 3 # pixel per second
export var offset = 0.2 # pixel
export(int, "simple", "double", "tripple", "max") var weapon
export var shooting_delay = 0.2 # seconds
export var projectile : PackedScene
export var pary_area : PackedScene

onready var space = $"/root/space"
onready var background = $"../UniverseMesh"
onready var timer : Timer = $timer
onready var death_time_out : Timer = $DeathTimeOut
onready var simple_weapon : Spatial = $simple_weapon
onready var double_weapon : Spatial = $double_weapon
onready var tripple_weapon : Spatial = $tripple_weapon
onready var max_weapon : Spatial = $max_weapon
onready var weapon_mesh : Spatial = $weapon_mesh
onready var Animation : AnimationPlayer = $AnimationPlayer
onready var explosion : Particles = $Explosion
onready var pary : Particles = $Pary
onready var pary_timer : Timer = $ParyTimer

signal was_defeated()

var state: int
var screen_touch: bool = false
var dead: bool = false
var can_shoot: bool = true
var pary_prerec: bool = false
var is_parying: bool = false
var viewport_rect: Vector2 = Vector2.ZERO
var global_position: Vector2 = Vector2.ZERO
var path: Array = []


enum STATE {
	IDLE,
	MOOVING,
	PARY,
	DEATH
}


func add_to_path(position):
	path.clear()
	path.push_back(position)


func _ready():
	viewport_rect = get_viewport().get_visible_rect().size
	timer.set_wait_time(shooting_delay)
	timer.connect("timeout", self, "on_shoot_delay_timeout")
	state = STATE.MOOVING


func _physics_process(delta):

	# State Maschine
	match state:
		STATE.IDLE:
			pass
		STATE.MOOVING:
			move_to_position(delta)
			if screen_touch and timer.paused:
				timer.paused = false
			if screen_touch and can_shoot:
				shoot()
				can_shoot = false
				timer.start()
			if !screen_touch:
				timer.paused = true
			pass
		STATE.PARY:
			is_parying = true
			Animation.play("pary")
			var new_pary = pary_area.instance()
			get_parent().add_child(new_pary)
			new_pary.translation = global_transform.origin
			pass
		STATE.DEATH:
			pass

	if weapon == 3:
		weapon_mesh.visible = true
	else:
		weapon_mesh.visible = false



func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		screen_touch = event.pressed


func set_state_to_move():
	state = STATE.MOOVING
	is_parying = false


func move_to_position(delta):
	if path.empty():
		rotation.z = 0
		return
	var next_pos = path.front()

	var direction = transform.origin.direction_to(Vector3(next_pos.x, transform.origin.y, next_pos.z - offset))
	var distance = transform.origin.distance_to(Vector3(next_pos.x, transform.origin.y, next_pos.z - offset))
	var reach = speed * space.time_scale * delta

	background.mesh.material.uv1_offset += Vector3(direction.x, -direction.z * .5, direction.y) * distance * space.time_scale * .1

	if distance > reach:
		transform.origin += direction * reach
		if pary_prerec && direction.z > 0.5:
			state = STATE.PARY
			pary.emitting = true
			pary_prerec = false

		elif direction.z < 0:
			pary_prerec = true
			pary_timer.start()


	elif distance < reach:

		while distance < reach:
			transform.origin += direction * distance
			reach -= distance
			path.pop_front()

			if path.empty(): return
			next_pos = path.front()
			direction = transform.origin.direction_to(Vector3(next_pos.x, transform.origin.y, next_pos.y))
			distance = transform.origin.distance_to(Vector3(next_pos.x, transform.origin.y, next_pos.y))

	rotate_with(direction, distance)


func rotate_with(direction, distance):
	rotation.z = -direction.x * distance * 3
	rotation_degrees.z = clamp(rotation_degrees.z, -70, 70)


func on_shoot_delay_timeout():
	if screen_touch:
		shoot()
		timer.start()
	if !screen_touch:
		can_shoot = true


func shoot():
	match weapon:
		0:
			var new_projectile = projectile.instance()
			get_parent().add_child(new_projectile)
			new_projectile.translation = simple_weapon.global_transform.origin

		1:
			for pos_weapon in double_weapon.get_children():
				var new_projectile = projectile.instance()
				get_parent().add_child(new_projectile)
				new_projectile.translation = pos_weapon.global_transform.origin

		2:
			for pos_weapon in tripple_weapon.get_children():
				var new_projectile = projectile.instance()
				get_parent().add_child(new_projectile)
				new_projectile.translation = pos_weapon.global_transform.origin

		3:
			for pos_weapon in max_weapon.get_children():
				var new_projectile = projectile.instance()
				get_parent().add_child(new_projectile)
				new_projectile.translation = pos_weapon.global_transform.origin


func deal_damage(damage):
	if dead:
		return

	Animation.play("blowback")
	health -= damage
	if health <= 0:
		state = STATE.DEATH
		dead = true
		health = 0
		death_time_out.start()
		emit_signal("was_defeated")
		Animation.play("death")
		explosion.emitting = true


func level_cleared():
	if space.time_scale >= .35:
		space.time_scale = .35
	add_to_path(Vector3(0.0, 0.25, -1.5))


func _on_ParyTimer_timeout():
	pary_prerec = false


func _on_DeathTimeOut_timeout():
	space.time_scale = 0.05
	get_tree().reload_current_scene()
