extends Area

export(int, "block", "flythrough") var behaviour: int = 0
export(PackedScene) var shrapnel
export(float) var shrapnel_angle: float = 0.0
export(float) var speed: float = 1
export(Vector3) var target_position = Vector3.FORWARD * 3

onready var animation: AnimationPlayer = $AnimationPlayer
onready var collision: CollisionShape = $ObstacleCollision

var rand_rotation: Vector2


enum STATE {
	BLOCK,
	FLYTHROUGH
}

signal was_defeated()


func get_children_of_type(child_type):
	var list = []
	for i in range(get_child_count()):
		var child = get_child(i)
		if child is child_type:
			list.append(child)
	return list


func _ready():
	collision.disabled = false

	randomize()
	rand_rotation = Vector2(rand_range(-16, 16), rand_range(-16, 16))
	var rand_mesh_number = randi() % 5
	var iterator = 0

	for mesh in get_children_of_type(MeshInstance):
		mesh.visible = iterator == rand_mesh_number
		iterator += 1


func _process(delta):
	if global_transform.origin.z < target_position.z:
		print(global_transform.origin.z)
		global_transform.origin.z += speed * Space.time_scale * delta

	rotation_degrees.x += rand_rotation.x * delta * Space.time_scale
	rotation_degrees.y += rand_rotation.y * delta * Space.time_scale

	match behaviour:
		STATE.BLOCK:
			_block_player(delta)

		STATE.FLYTHROUGH:
			_fly_through(delta)


func _block_player(_delta):
	pass


func _fly_through(_delta):
	pass


func deal_shrapnel_damage():
	animation.play("Explosion")


func send_defeated():
	emit_signal("was_defeated")

	remove_self()


func spawn_shrapnel():
	if !is_instance_valid(shrapnel): return

	# spawn 6-8 shrapnel
	for i in range(12):
		_spawn_sharpnel_pieces(Vector3(1, 0, i + (-1 + shrapnel_angle)))
		_spawn_sharpnel_pieces(Vector3(-1, 0, i + (-1 + shrapnel_angle)))

	_spawn_sharpnel_pieces(Vector3(0, 0, -1))
	_spawn_sharpnel_pieces(Vector3(0, 0, 1))


func _spawn_sharpnel_pieces(spawn_direction: Vector3):
	var new_shrapnel = shrapnel.instance()
	get_tree().get_root().add_child(new_shrapnel)
	randomize()
	new_shrapnel.translation = global_transform.origin + Vector3(rand_range(-0.1, 0.1), rand_range(-0.1, 0.1), 0.0)
	new_shrapnel.direction = spawn_direction
	new_shrapnel.speed = rand_range(0.4, 1.0)


func remove_self():
	hide()
	queue_free()


func _on_Asteroid_body_entered(body):
	if body.name != 'VaporFalcon': return

	body.deal_damage(10000)
