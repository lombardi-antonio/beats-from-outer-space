extends Area


export(bool) var open: bool = false
export(int) var health: int = 200

onready var collision: CollisionShape = $CollisionShape
onready var animation: AnimationPlayer = $AnimationPlayer
onready var animation_tree: AnimationTree = $AnimationTree
onready var heart: MeshInstance = $HeartMesh
onready var recoveryTimer: Timer = $RecoveryTimer

var _is_open: bool = false

signal has_recovered()
signal was_defeated()


func _ready():
	collision.disabled = false
	animation_tree.active = true


func _process(_delta):
	_process_time_scale()
	_reset_animation_parameters()


func _process_time_scale():
	animation_tree["parameters/Blowback/TimeScale/scale"] = Space.time_scale
	animation_tree["parameters/Defeated/TimeScale/scale"] = Space.time_scale
	animation_tree["parameters/Idle/TimeScale/scale"] = Space.time_scale
	animation_tree["parameters/Idle_Close/TimeScale/scale"] = Space.time_scale
	animation_tree["parameters/Idle_Open/TimeScale/scale"] = Space.time_scale

	if Space.time_scale < 1 && not recoveryTimer.is_paused():
		recoveryTimer.set_paused(true)
	else:
		if _is_open:
			recoveryTimer.set_paused(false)


func _reset_animation_parameters():
	animation_tree["parameters/conditions/is_opening"] = 0
	animation_tree["parameters/conditions/is_closing"] = 0
	animation_tree["parameters/conditions/is_hit"] = 0


func open_hatch():
	_is_open = true
	animation_tree["parameters/conditions/is_open"] = true
	animation_tree["parameters/conditions/is_opening"] = true
	recoveryTimer.set_wait_time(3)
	recoveryTimer.start()


func close_hatch():
	_is_open = false
	animation_tree["parameters/conditions/is_open"] = false
	animation_tree["parameters/conditions/is_closing"] = true


func deal_damage(damage):
	if not _is_open: return

	animation_tree["parameters/conditions/is_hit"] = true
	health -= damage
	if health <= 0:
		animation_tree["parameters/conditions/is_defeated"] = true


func deal_shrapnel_damage():
	open_hatch()


func _boss_defeated():
	hide()
	Space.kills += 1
	Space.points += 1000
	emit_signal("was_defeated")


func _on_UfoHead_body_entered(body):
	if body.name != 'VaporFalcon': return

	body.deal_damage(1000)


func _update_animation_parameters():
	animation_tree["parameters/conditions/is_idle"] = true


func _on_RecoveryTimer_timeout():
	close_hatch()
	emit_signal("has_recovered")
