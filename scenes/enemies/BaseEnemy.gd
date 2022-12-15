extends Area

export(float) var speed: float = 1
export(float) var shrapnel_angle: float = 0.0
export(int) var health: int = 30
export(int) var collision_damage: int = 30
export(int) var points: int = 10
export(PackedScene) var projectile
export(PackedScene) var shrapnel

onready var space: Spatial = $"/root/Space"
onready var animation: AnimationPlayer = $AnimationPlayer
onready var collision: CollisionShape = $ShipCollision
onready var cooldown: Timer = $Cooldown

var dead: bool = false
var can_shoot: bool = true
var _is_invincible = false

signal was_defeated()


func _ready():
	_init_collision()
	_connect_signals()


func _process(_delta):
	_process_time_scale()

	if !dead:
		_process_enemy_logic(_delta)


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


func deal_damage(damage):
	if _is_invincible: return

	health -= damage
	if health > 0:
		animation.play("blowback")
	else:
		dead = true
		if collision: collision.queue_free()
		hide()
		space.points += points
		emit_signal("was_defeated")


func deal_shrapnel_damage():
	_is_invincible = true
	animation.play("explosion")


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


func _spawn_sharpnel_pieces(direction: Vector3):
	var new_shrapnel = shrapnel.instance()
	get_tree().get_root().add_child(new_shrapnel)
	new_shrapnel.translation = global_transform.origin
	new_shrapnel.direction = direction
	new_shrapnel.speed = rand_range(0.4, 1.0)
