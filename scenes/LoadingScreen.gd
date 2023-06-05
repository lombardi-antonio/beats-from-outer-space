extends Spatial

onready var animation: AnimationPlayer = $AnimationPlayer

var taped: bool = false
var loader: ResourceInteractiveLoader = null
var home_scene = null
var wait_frames = 1
var time_max = 100 # msec


func _ready():
	loader = ResourceLoader.load_interactive("res://scenes/Home.tscn")


func _process(_delta):
	if loader == null:
		# no need to process anymore
		return

	# Wait for frames to let the "loading" animation show up.
	if wait_frames > 0:
		wait_frames -= 1
		return

	var t = OS.get_ticks_msec()
	# Use "time_max" to control for how long we block this thread.
	while OS.get_ticks_msec() < t + time_max:
		# Poll your loader.
		var err = loader.poll()

		if err == ERR_FILE_EOF: # Finished loading.
			home_scene = loader.get_resource()
			loader = null
			animation.play("Rotate")
			break
		elif err == OK:
			pass
		else: # Error during loading.
			loader = null
			break


func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		taped = event.pressed

		if taped:
			animation.play("Transition")


func goto_home():
	if home_scene != null:
		return get_tree().change_scene_to(home_scene)
	else:
		return get_tree().change_scene("res://scenes/Home.tscn")
