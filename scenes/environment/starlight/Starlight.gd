extends Spatial


onready var spotlight: Spatial = $Spotlight
onready var position: Position3D = $Position
onready var space: Spatial = $"/root/Space"

export var speed: float = 1.0

var _start_pos: float
var _end_pos: float
var _rng: RandomNumberGenerator  = RandomNumberGenerator.new()


func _ready():
	spotlight.translation.x = 1.0
	spotlight.translation.y = 1.0
	_start_pos = spotlight.translation.z
	_end_pos = position.translation.z


func _process(delta):
	spotlight.translation.z += speed * Space.time_scale * delta

	if spotlight.translation.z > _end_pos:
		_randomize_star_pos()
		_adjust_rotation()
		spotlight.translation.z = _start_pos


func _randomize_star_pos():
	_rng.randomize()
	var random_negation = (randi() & 2) - 1
	var random_x = _rng.randf_range(0.7, 2.0)

	_rng.randomize()
	var random_y = _rng.randf_range(-2.0, 2.0)

	spotlight.translation.x = random_negation * random_x
	spotlight.translation.y = random_y


func _adjust_rotation():
	spotlight.rotation_degrees.z = abs(spotlight.translation.x) - 0.7 * 32 + spotlight.translation.y * 22.5
	if spotlight.translation.x < 0:
		spotlight.rotation_degrees.z += 180
