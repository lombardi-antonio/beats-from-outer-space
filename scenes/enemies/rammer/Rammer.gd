extends "res://scenes/enemies/BaseEnemy.gd"

onready var mesh: MeshInstance = $ShipMesh
onready var target: Position3D = $TargetPosition
onready var spinup_position: Position3D = $SpinupPosition
onready var spinup: Timer = $Spinup

var _spinup_ended: bool = false
var _spiup_started: bool = false


func _process(_delta):
	_remove_at_target_pos()


func _remove_at_target_pos():
	if dead:
		return
	if mesh.translation.z >= target.translation.z:
		emit_signal("was_defeated")
		queue_free()
		return


func _process_time_scale():
	if space.time_scale < 1:
		spinup.paused = true
	else:
		spinup.paused = false

	animation.playback_speed = Space.time_scale


func _process_enemy_logic(_delta):
	if mesh.global_transform.origin.z < -3.3:
		mesh.translation.z += speed * Space.time_scale * _delta
		collision.translation.z += speed * Space.time_scale * _delta
	else:
		if not _spiup_started:
			spinup.start()
			_spiup_started = true

	if _spinup_ended:
		mesh.translation.z += speed * Space.time_scale * _delta
		collision.translation.z += speed * Space.time_scale * _delta


func _on_spinup_timeout():
	if dead:
		return
	_spinup_ended = true
	if collision:
		collision.disabled = false


func got_parried():
	pass


func deal_shrapnel_damage():
	deal_damage(health)
