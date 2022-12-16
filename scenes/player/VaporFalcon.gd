extends Spatial

export var speed: float = 3
export var offset: float = 0.2
export var health: int = 50
export var projectile: PackedScene
export var parry_area: PackedScene
export(int, "simple", "double", "tripple", "max") var weapon: int = 0
export(Array, AudioStreamMP3) var notes_in_measure
export(Array, AudioStreamMP3) var player_hit_sounds
export(AudioStreamMP3) var explosion_sound

onready var animation: AnimationPlayer = $AnimationPlayer
onready var background: MeshInstance = $"../UniverseMesh"
onready var space: Spatial = $"/root/Space"
onready var simple_weapon: Spatial = $SimpleWeapon
onready var double_weapon: Spatial = $DoubleWeapon
onready var tripple_weapon: Spatial = $TrippleWeapon
onready var max_weapon: Spatial = $MaxWeapon
onready var weapon_mesh: Spatial = $WeaponMesh
onready var parry_timer: Timer = $ParryTimer
onready var death_time_out: Timer = $DeathTimeOut
onready var parry: Particles = $Parry
onready var explosion: Particles = $Explosion
onready var audio_stream_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

var _path: Array = []
var _dead: bool = false
var _can_shoot: bool = true
var _is_parrying: bool = false
var _parry_prerec: bool = false
var _screen_touch: bool = false
var _state: int
var _viewport_rect: Vector2 = Vector2.ZERO
var _global_position: Vector2 = Vector2.ZERO
var _current_note_index: int = 0

enum STATE {
	IDLE,
	MOOVING,
	PARRY,
	DEATH
}

signal was_defeated()


func add_to_path(position):
	_path.clear()
	_path.push_back(position)


func _ready():
	randomize()
	audio_stream_player.set_stream(notes_in_measure[_current_note_index])

	_viewport_rect = get_viewport().get_visible_rect().size
	_state = STATE.MOOVING


func _physics_process(delta):

	# State Maschine
	match _state:
		STATE.IDLE:
			pass

		STATE.MOOVING:
			move_to_position(delta)
			pass

		STATE.PARRY:
			_is_parrying = true
			animation.play("parry")
			var new_parry = parry_area.instance()
			get_parent().add_child(new_parry)
			new_parry.translation = global_transform.origin
			pass

		STATE.DEATH:
			pass

	if weapon == 3:
		weapon_mesh.visible = true

	else:
		weapon_mesh.visible = false


func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		_screen_touch = event.pressed


func set_state_to_move():
	_state = STATE.MOOVING
	_is_parrying = false


func move_to_position(delta):
	if _path.empty():
		rotation.z = 0
		return
	var next_pos = _path.front()

	var direction = transform.origin.direction_to(Vector3(next_pos.x, transform.origin.y, next_pos.z - offset))
	var distance = transform.origin.distance_to(Vector3(next_pos.x, transform.origin.y, next_pos.z - offset))
	var reach = speed * Space.time_scale * delta

	background.mesh.material.uv1_offset += Vector3(direction.x, -direction.z * .5, direction.y) * distance * Space.time_scale * .1

	if distance > reach:
		transform.origin += direction * reach

		if _parry_prerec && direction.z > 0.5:
			_state = STATE.PARRY
			parry.emitting = true
			_parry_prerec = false

		elif direction.z < 0:
			_parry_prerec = true
			parry_timer.start()

	elif distance < reach:

		while distance < reach:
			transform.origin += direction * distance
			reach -= distance
			_path.pop_front()

			if _path.empty(): return
			next_pos = _path.front()
			direction = transform.origin.direction_to(Vector3(next_pos.x, transform.origin.y, next_pos.y))
			distance = transform.origin.distance_to(Vector3(next_pos.x, transform.origin.y, next_pos.y))

	rotate_with(direction, distance)


func rotate_with(direction, distance):
	rotation.z = -direction.x * distance * 3
	rotation_degrees.z = clamp(rotation_degrees.z, -70, 70)


func shoot():
	match weapon:
		0:
			audio_stream_player.play()
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
	if _dead:
		return

	var sound_index = randi() % (player_hit_sounds.size() - 1)
	animation.play("blowback")
	audio_stream_player.set_stream(player_hit_sounds[sound_index])
	audio_stream_player.play()
	health -= damage

	if health <= 0:
		_state = STATE.DEATH
		_dead = true
		health = 0
		death_time_out.start()
		emit_signal("was_defeated")
		animation.play("death")
		audio_stream_player.set_stream(explosion_sound)
		audio_stream_player.unit_db = 2
		audio_stream_player.play()
		explosion.emitting = true


func update_weapon(level):
	if _dead:
		return

	if level > weapon:
		weapon = level


func level_cleared():
	if Space.time_scale >= .35:
		Space.time_scale = .35
	add_to_path(Vector3(0.0, 0.25, -1.5))


func _on_parry_timer_timeout():
	_parry_prerec = false


func _on_death_timeout_timeout():
	Space.time_scale = 0.05
	var _reload = get_tree().reload_current_scene()


func _on_Conductor_beat(_position):
	pass # called for every beat in song


func _on_Conductor_measure(_position):
	# called for every measure in song (with 4 measure it will repeat after every 4 beats)
	if _screen_touch:
		audio_stream_player.set_stream(notes_in_measure[_position - 1])
		if audio_stream_player.stream:
			shoot()
