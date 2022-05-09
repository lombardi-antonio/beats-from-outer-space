extends "BaseShip.gd"

onready var target = $TargetPosition
onready var spinup = $Spinup
onready var spinup_position = $SpinupPosition

var spinup_ended = false
var spiup_started = false


func _ready():
	if collision:
		collision.disabled = true

	connect("body_entered", self, "_on_body_entered")


func _process(delta):
	if dead:
		return
	if !collision:
		return
	if collision.translation.z >= target.translation.z:
		emit_signal("was_defeated")
		queue_free()
		return

	if space.time_scale < 1:
		spinup.paused = true
	else:
		spinup.paused = false

	if mesh.global_transform.origin.z < -3.3:
		mesh.translation.z += speed * space.time_scale * delta
		collision.translation.z += speed * space.time_scale * delta
	else:
		if not spiup_started:
			spinup.start()
			spiup_started = true

	if spinup_ended:
		mesh.translation.z += speed * space.time_scale * delta
		collision.translation.z += speed * space.time_scale * delta


func _on_Spinup_timeout():
	if dead:
		return
	spinup_ended = true
	if collision:
		collision.disabled = false


func _on_body_entered(body):
	if body.is_in_group("player"):
		body.deal_damage(hit_damage)
		queue_free()