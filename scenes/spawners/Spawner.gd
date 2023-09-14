extends Spatial

export(Array, PackedScene) var formation_list

var offset = 0.8
var wave = 0
var withdraw = false

signal defeated()

func _ready():
	_init_enemies()


func _process(delta):
	if withdraw:
		translation.z -= Space.time_scale * delta


func _spawn(formation):
	var new_formation = formation.instance()
	new_formation.translation = Vector3(translation.x, 0, translation.z)
	add_child(new_formation)
	new_formation.connect("formation_defeated", self, "_on_formation_defeated")


func _init_enemies():
	if wave > formation_list.size() - 1:
		return
	_spawn(formation_list[wave])


func _on_formation_defeated():
	if wave >= formation_list.size() - 1:
		emit_signal("defeated")
	wave += 1
	_init_enemies()


func _on_vapor_falcon_was_defeated():
	withdraw = true

func _on_ContinueButton_pressed():
	wave = 0
