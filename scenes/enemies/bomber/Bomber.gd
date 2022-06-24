extends Area

onready var space = $"/root/Space"
onready var mesh = $ShipMesh
onready var collision = $ShipCollision
onready var cooldown = $Cooldown
onready var shot_cooldown = $TripleShotCooldown
onready var animation = $AnimationPlayer
onready var barrel = $Berrel

export var speed = 1
export var health = 10
export var damage = 10
export var hit_damage = 20
export var points = 5
export(PackedScene) var projectile

var dead = false
var can_shoot = true
var shot_count = 0

signal was_defeated()


func _ready():
	connect("body_entered", self, "_on_body_entered")


func _process(_delta):
	# pause cooldown when in slow-mo
	if Space.time_scale < 1:
		cooldown.paused = true
		shot_cooldown.paused = true
	else:
		cooldown.paused = false
		shot_cooldown.paused = false

	if can_shoot:
		_shoot()


func _shoot():
	if dead:
		return

	var new_projectile = projectile.instance()
	get_tree().get_root().add_child(new_projectile)
	new_projectile.translation = barrel.global_transform.origin
	can_shoot = false
	shot_cooldown.start()
	cooldown.start()


func deal_damage(damage):
	animation.play("blowback")
	health -= damage
	if health <= 0:
		dead = true
		if collision: collision.queue_free()
		hide()
		space.points += points
		emit_signal("was_defeated")


func got_parried():
	pass

func shrapnel_damage():
	pass


func _on_body_entered(body):
	if body.name == "VaporFalcon":
		body.deal_damage(hit_damage)
		queue_free()


func _on_TripleShotCooldown_timeout():
	if shot_count >= 3:
		can_shoot = false
	else:
		shot_count += 1
		can_shoot = true


func _on_Cooldown_timeout():
	shot_count = 0
	can_shoot = true
