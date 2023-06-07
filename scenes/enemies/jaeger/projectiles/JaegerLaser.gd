extends Area


export var damage = 50

onready var timer: Timer = $Timer
onready var animation: AnimationPlayer = $AnimationPlayer


func _ready():
	return connect("body_entered", self, "_on_body_entered")


func _process(_delta):
	if Space.time_scale < 1:
		timer.paused = true

	else:
		timer.paused = false

	animation.playback_speed = Space.time_scale


func _on_body_entered(body):
	if body.name == "VaporFalcon":
		body.deal_damage(damage)


func remove_self():
	hide()
	queue_free()


func _on_Timer_timeout():
	queue_free()


func _on_AnimationPlayer_animation_finished(anim_name:String):
	if anim_name == "Loading":
		animation.play("Shoot")
	else:
		queue_free()
