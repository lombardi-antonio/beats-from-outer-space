extends "res://scenes/enemies/BaseEnemy.gd"

export(Vector3) var spinup_position = Vector3.BACK * 0.5
export(Vector3) var target = Vector3.BACK * 5
export(bool) var homeing = false

onready var mesh: MeshInstance = $ShipMesh
onready var spinup: Timer = $Spinup

var _spinup_ended: bool = false
var _spiup_started: bool = false


func _ready():
	_is_invincible = true

	if homeing:
		detection_collision.disabled = false


func _process(_delta):
	_remove_at_target_pos()


func _remove_at_target_pos():
	if dead:
		return
	if mesh.global_transform.origin.z >= target.z:
		emit_signal("was_defeated")
		queue_free()
		return


func _process_time_scale():
	if space.time_scale < 1:
		spinup.paused = true
	else:
		spinup.paused = false

	animation.playback_speed = Space.time_scale


func _target_player(_delta):
	if global_transform.origin.z < spinup_position.z:
		global_transform.origin.z += speed * Space.time_scale * _delta
	else:
		if not _spiup_started:
			spinup.start()
			_spiup_started = true

	if _spinup_ended:

		if target_player_node:
			var direction = 1

			if ((global_transform.origin.x - target_player_node.global_transform.origin.x) > 0):
				direction = -1

			global_transform.origin.x += direction * .5 * speed * Space.time_scale * _delta

		global_transform.origin.z += 3 * speed * Space.time_scale * _delta


func _on_spinup_timeout():
	if dead:
		return
	_is_invincible = false
	_spinup_ended = true
	if collision:
		collision.disabled = false


func got_parried():
	pass


func deal_shrapnel_damage():
	deal_damage(health)


func _on_DetectionArea_body_entered(body):
	if target_player_node:
		pass
	if body.name == 'VaporFalcon':
		target_player_node = body
		#speed = 1.0
