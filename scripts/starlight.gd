extends Spatial

onready var spotlight = $spotlight
onready var position = $position
onready var space = $"/root/space"

export var speed = 1
var start_pos
var end_pos
var rng = RandomNumberGenerator.new()


func _ready():
	spotlight.translation.x = 1
	spotlight.translation.y = 1
	start_pos = spotlight.translation.z
	end_pos = position.translation.z


func _process(delta):
	spotlight.translation.z += speed * space.time_scale * delta

	if spotlight.translation.z > end_pos:
		randomize_star_pos()
		adjust_rotation()
		spotlight.translation.z = start_pos


func randomize_star_pos():
	rng.randomize()
	var random_negation = (randi() & 2) - 1
	var random_x = rng.randf_range(0.7, 2.0)

	rng.randomize()
	var random_y = rng.randf_range(-2.0, 2.0)

	spotlight.translation.x = random_negation * random_x
	spotlight.translation.y = random_y


func adjust_rotation():
	spotlight.rotation_degrees.z = abs(spotlight.translation.x) - 0.7 * 32 + spotlight.translation.y * 22.5
	if spotlight.translation.x < 0:
		spotlight.rotation_degrees.z += 180
