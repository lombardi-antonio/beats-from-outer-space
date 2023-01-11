extends Area

export var speed = 1
export var level = 1
export var steer_force = 0.2

onready var space = $"/root/Space"
onready var timer = $Timer
onready var animation: AnimationPlayer = $AnimationPlayer
onready var textMesh: TextMesh = $TextMesh.mesh
onready var background: MeshInstance = $Background

var acceleration = Vector3.ZERO
var velocity = Vector3.ZERO
var target = null
var hsl = [.0, .66, .77]
var step = .01


func _ready():
	textMesh.text = String(level) + "UP"
	start(Vector3(0, 0, 1), null)
	var _connect_body = connect("body_entered", self, "_on_body_entered")
	animation.play("Rotate")


func start(_transform, _target):
	var material = SpatialMaterial.new()
	match level:
		1:
			material.set("albedo_color", Color8(225, 150, 80))
			material.set("emission", Color8(190, 80, 20))
		2:
			material.set("albedo_color", Color8(80, 80, 225))
			material.set("emission", Color8(130, 20, 210))
		3:
			material.set("albedo_color", Color8(255, 255, 255))
			material.set("emission", Color8(255, 255, 255))

	material.set("emission_enabled", true)
	material.set("emission_energy", 1)
	background.set_surface_material(0, material)

	global_transform.origin = _transform
	velocity = global_transform.origin * speed
	target = _target


func seek():
	var steer = Vector3.ZERO
	if target:
		var desired = (target.global_transform.origin - global_transform.origin).normalized() * speed
		steer = (desired - velocity).normalized() * steer_force
	return steer


func _process(_delta):
	if Space.time_scale < 1:
		if timer: timer.paused = true
	else:
		if timer: timer.paused = false

	if translation.z > 50:
		queue_free()

	animation.playback_speed = Space.time_scale

	if level == 3:
		_create_rainbow_effect(background.get_surface_material(0))


func _physics_process(delta):
	acceleration += seek()
	velocity += acceleration * delta
	velocity = velocity.normalized() * speed
	translation += velocity * delta * Space.time_scale


func _on_body_entered(body):
	if body.name == "VaporFalcon":
		body.update_weapon(level)
		queue_free()


func _create_rainbow_effect(material: SpatialMaterial):
	if hsl[0] >= 1.0: hsl[0] = 0.0
	else: hsl[0] += step

	var color = Color.from_hsv(hsl[0], hsl[1], hsl[2])
	material.set("albedo_color", color)
	material.set("emission", color)


func remove_self():
	hide()
	queue_free()


func _on_timer_timeout():
	remove_self()
