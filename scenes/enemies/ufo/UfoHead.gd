extends Area


export(bool) var open: bool = false
export(int) var health: int = 200

onready var collision: CollisionShape = $CollisionShape
onready var animation: AnimationPlayer = $AnimationPlayer
onready var animation_tree: AnimationTree = $AnimationTree
onready var heart: MeshInstance = $HeartMesh


func _ready():
	collision.disabled = true


func _process(_delta):
	_process_time_scale()
	_reset_animation_parameters()


func _process_time_scale():
	animation_tree["parameters/Blowback/TimeScale/scale"] = Space.time_scale
	animation_tree["parameters/Defeated/TimeScale/scale"] = Space.time_scale
	animation_tree["parameters/Idle/TimeScale/scale"] = Space.time_scale
	animation_tree["parameters/Idle_Close/TimeScale/scale"] = Space.time_scale
	animation_tree["parameters/Idle_Open/TimeScale/scale"] = Space.time_scale


func _reset_animation_parameters():
	animation_tree["parameters/conditions/is_opening"] = 0
	animation_tree["parameters/conditions/is_closing"] = 0
	animation_tree["parameters/conditions/is_hit"] = 0


func open_hatch():
	animation_tree["parameters/conditions/is_opening"] = true


func close_hatch():
	animation_tree["parameters/conditions/is_closing"] = true


func deal_damage(damage):
	animation_tree["parameters/conditions/is_hit"] = true
	health -= damage
	if health <= 0:
		animation_tree["parameters/conditions/is_defeated"] = true


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
