extends Area

export var speed = 1
export var hit_damage = 30
export var health = 30

onready var space = $"/root/space"
onready var collision = $collistion

var dead = false

signal was_defeated()


func _ready():
	return connect("body_entered", self, "_on_body_entered")


func _process(delta):
	translation.z += speed * space.time_scale * delta

	if translation.z > 50:
		queue_free()


func _on_body_entered(body):
	if body.name == "vapor_falcon":
		body.deal_damage(hit_damage)
		queue_free()


func deal_damage(damage):
	health -= damage
	if health <= 0:
		dead = true
		collision.queue_free()
		hide()
		emit_signal("was_defeated")
