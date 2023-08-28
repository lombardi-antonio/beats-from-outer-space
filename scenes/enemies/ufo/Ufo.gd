extends Area

signal has_recovered()
signal was_defeated()

onready var target_position: Position3D = $TargetPosition
onready var animation_player: AnimationPlayer = $AnimationPlayer

var target: Vector3 = Vector3.ZERO


func _ready():
	target = target_position.global_transform.origin


func _process(delta):
	if global_transform.origin.distance_to(target) < 0.1:
		return

	global_transform.origin = global_transform.origin.move_toward(target, delta * Space.time_scale)

	animation_player.playback_speed = Space.time_scale


func _on_UfoHead_was_defeated():
	emit_signal("was_defeated")


func _on_UfoHead_has_recovered():
	emit_signal("has_recovered")
