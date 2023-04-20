extends Area

export(int, "hold_position", "follow", "keep_distance", "target_hit") var behaviour: int = 0
export(bool) var holds_upgrade: bool = false
export(float) var speed: float = 1
export(float) var shrapnel_angle: float = 0.0
export(int) var health: int = 30
export(int) var collision_damage: int = 30
export(int) var points: int = 10
export(int) var upgrade_level: int = 1
export(PackedScene) var projectile
export(PackedScene) var shrapnel
export(PackedScene) var upgrade

onready var space: Spatial = $"/root/Space"
onready var animation: AnimationPlayer = $AnimationPlayer
onready var collision: CollisionShape = $ShipCollision
onready var cooldown: Timer = $Cooldown
onready var target_position: Position3D = $TargetPosition
onready var detection_collision: CollisionShape = $DetectionArea/CollisionShape

var dead: bool = false
var can_shoot: bool = true
var target_translation: Vector3 = Vector3.ZERO
var _is_invincible = false
var left_bound: float
var right_bound: float
var direction: int
var target_player_node: KinematicBody = null


enum STATE {
	HOLD_POSITION,
	FOLLOW,
	KEEP_DISTANCE,
	TARGET_HIT
}

signal was_defeated()


func _ready():
	_init_collision()
	_connect_signals()
	if is_instance_valid(target_position): target_translation = target_position.global_transform.origin

	if behaviour == STATE.FOLLOW:
		detection_collision.disabled = false

	left_bound = target_translation.x -0.25
	right_bound = target_translation.x +0.25
	direction = 1 if rand_range(0, 100) > 50 else -1



func _process(_delta):
	_process_time_scale()

	if !dead:
		_process_enemy_logic(_delta)

		match behaviour:
			STATE.HOLD_POSITION:
				_hold_position_logic(_delta)

			STATE.FOLLOW:
				_follow_player_logic(_delta)
				_hold_position_logic(_delta)

			STATE.KEEP_DISTANCE:
				_keep_distance_logic(_delta)

			STATE.TARGET_HIT:
				_target_player(_delta)


func _init_collision():
	if not dead && collision:
		collision.disabled = true


func _connect_signals():
	return connect("body_entered", self, "_on_body_entered")


func _process_time_scale():
	if Space.time_scale < 1:
		cooldown.paused = true

	else:
		cooldown.paused = false

	animation.playback_speed = Space.time_scale


# Overwrite this function for enemy behavior
func _process_enemy_logic(_delta):
	_invincibility_at_entry()
	_handle_shooting()


func _invincibility_at_entry(_till_z_value: float = -3.5):
	if collision && collision.disabled && collision.global_transform.origin.z >= _till_z_value:
		collision.disabled = false


func _handle_shooting():
	if can_shoot: _shoot()


func _shoot():
	if !is_instance_valid(projectile):
		return

	var new_projectile = projectile.instance()
	get_tree().get_root().add_child(new_projectile)
	new_projectile.translation = global_transform.origin
	can_shoot = false
	cooldown.start()


func _hold_position_logic(_delta):
	if global_transform.origin != target_translation:
		global_transform.origin = global_transform.origin.move_toward(target_translation, speed * Space.time_scale * _delta)
	else:
		if global_transform.origin.x > right_bound:
			direction = -1

		if global_transform.origin.x < left_bound:
			direction = 1

		target_translation = target_translation + Vector3(0.05 * direction * Space.time_scale , 0.0, 0.0)

		var direction_to_player = global_transform.origin.direction_to(Vector3(target_translation.x, global_transform.origin.y, target_translation.y + 0.5))
		var distance_to_player = global_transform.origin.distance_to(Vector3(target_translation.x, global_transform.origin.y, target_translation.y + 0.5))

		rotate_with(direction_to_player, distance_to_player)


func _follow_player_logic(_delta):
	if target_player_node:
		target_translation.x = target_player_node.global_transform.origin.x
		target_translation.z = target_player_node.global_transform.origin.z - 0.5

		if global_transform.origin != target_translation:
			left_bound = target_translation.x -0.5
			right_bound = target_translation.x +0.5

			if global_transform.origin.x > right_bound:
				direction = -1

			if global_transform.origin.x < left_bound:
				direction = 1

			target_translation = target_translation + Vector3(direction * Space.time_scale , 0.0, 0.0)

			var direction_to_player = global_transform.origin.direction_to(Vector3(target_player_node.global_transform.origin.x, global_transform.origin.y, target_player_node.global_transform.origin.y))
			var distance_to_player = global_transform.origin.distance_to(Vector3(target_player_node.global_transform.origin.x, global_transform.origin.y, target_player_node.global_transform.origin.y))

			rotate_with(direction_to_player, distance_to_player)


func _keep_distance_logic(_delta):
	pass


func _target_player(_delta):
	pass


func rotate_with(ship_direction, ship_distance):
	rotation.z = ship_direction.x * ship_distance * 5
	rotation_degrees.z = clamp(rotation_degrees.z, -50, 50)


func release_upgrade():
	if !holds_upgrade:
		return

	if !is_instance_valid(upgrade):
		return

	var new_upgrade = upgrade.instance()
	if upgrade_level > 1:
		new_upgrade.level = upgrade_level

	get_tree().get_root().add_child(new_upgrade)
	new_upgrade.translation = get_children()[0].global_transform.origin

	holds_upgrade = false


func deal_damage(damage):
	if dead:
		return

	if _is_invincible: return

	health -= damage
	if health > 0:
		animation.play("blowback")
	else:
		dead = true
		release_upgrade()
		if collision:
			collision.queue_free()
		hide()
		space.points += points
		emit_signal("was_defeated")


func deal_shrapnel_damage():
	pass


func _on_cooldown_timeout():
	can_shoot = true


func remove_self():
	hide()
	queue_free()


func _on_body_entered(body):
	if body.name != 'VaporFalcon': return

	body.deal_damage(collision_damage)
	deal_damage(health)


func got_parried():
	animation.play("explosion")


func spawn_shrapnel():
	if !is_instance_valid(shrapnel): return

	_is_invincible = false
	# spawn 6-8 shrapnel
	for i in range(3):
		_spawn_sharpnel_pieces(Vector3(1, 0, i + (-1 + shrapnel_angle)))
		_spawn_sharpnel_pieces(Vector3(-1, 0, i + (-1 + shrapnel_angle)))

	_spawn_sharpnel_pieces(Vector3(0, 0, -1))
	_spawn_sharpnel_pieces(Vector3(0, 0, 1))

	deal_damage(health)


func _spawn_sharpnel_pieces(spawn_direction: Vector3):
	var new_shrapnel = shrapnel.instance()
	get_tree().get_root().add_child(new_shrapnel)
	new_shrapnel.translation = global_transform.origin
	new_shrapnel.direction = spawn_direction
	new_shrapnel.speed = rand_range(0.4, 1.0)


func _try_setting_colision_disabled(state: bool):
	if is_instance_valid(collision):
		collision.disabled = state
