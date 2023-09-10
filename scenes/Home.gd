extends Spatial

onready var animation: AnimationPlayer = $AnimationPlayer
onready var conductor: AudioStreamPlayer3D = $Conductor
onready var user_interface: Control = $UserInterface
onready var transition: ColorRect = $UserInterface/Transition
onready var start_button: Button = $UserInterface/StartButton
onready var label_beats: Label = $UserInterface/BEATS
onready var label_from_outer: Label = $UserInterface/FROMOUTER
onready var label_space: Label = $UserInterface/SPACE
onready var mute_button: Button = $UserInterface/Mute

export(bool) var is_muted = false

var loader: ResourceInteractiveLoader = null
var space_scene = null
var wait_frames = 1
var time_max = 100 # msec
var mute_icon = preload("res://assets/mute.png")
var unmute_icon = preload("res://assets/unmute.png")
var space_save_data = null


func _ready():
	loader = ResourceLoader.load_interactive("res://scenes/space.tscn")

	space_save_data = SaveState.load_game("res://scenes/space.tscn")
	if space_save_data != null:
		print(space_save_data)

		is_muted = space_save_data.stats.is_muted

	if is_muted:
		mute_button.icon = unmute_icon
		conductor.unit_db = -80
	else:
		mute_button.icon = mute_icon
		conductor.unit_db = 0
	if OS.has_feature("web"):
		transition.rect_scale = Vector2(4.0, 14.0)
		var viewport_width = get_viewport().get_visible_rect().size.x
		user_interface.rect_position.x = viewport_width/2 - 95.0
		user_interface.rect_position.y = 0.0

	return get_tree().root.connect("size_changed", self, "_on_viewport_size_changed")


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
			space_scene = loader.get_resource()
			loader = null
			break
		elif err == OK:
			pass
		else: # Error during loading.
			loader = null
			break


func _on_viewport_size_changed():
	var viewport_width = get_viewport().get_visible_rect().size.x
	var viewport_height = get_viewport().get_visible_rect().size.y
	var viewport_position = get_viewport().get_visible_rect().position

	user_interface.rect_size.x = viewport_width
	user_interface.rect_size.y = viewport_height
	user_interface.rect_position.x = viewport_position.x + (viewport_width/2-transition.rect_size.x/2)
	user_interface.rect_position.y = viewport_position.y

	if OS.get_real_window_size().x < OS.get_real_window_size().y * 0.5938:
		user_interface.rect_position = Vector2.ZERO

	if viewport_width > viewport_height * 0.5938:
		transition.rect_size.x = viewport_width * 1.01
		transition.rect_size.y = viewport_width * 1.6842
		transition.rect_position.x = 0.0
		transition.rect_position.y = (viewport_height - transition.rect_size.y)/2
	else:
		transition.rect_size.x = viewport_height * 0.5938
		transition.rect_size.y = viewport_height
		transition.rect_position.x = (viewport_width - transition.rect_size.x)/2
		transition.rect_position.y = 0.0


func _on_StartButton_button_up():
	Space.is_muted = is_muted

	animation.play("StartingAnimation")
	if conductor.get_playback_position() < 36.0:
		conductor.play(36.0)


func start_level():
	if space_scene != null:
		return get_tree().change_scene_to(space_scene)
	else:
		return get_tree().change_scene("res://scenes/space.tscn")


func _on_NewGameButton_button_up():
	SaveState.remove_save_game()
	animation.play("StartingNGAnimation")

	if conductor.get_playback_position() < 36.0:
		conductor.play(36.0)


func _on_Mute_button_up():
	is_muted = !is_muted

	if is_muted:
		mute_button.icon = unmute_icon
		conductor.unit_db = -80
		Space.is_muted = true
	else:
		mute_button.icon = mute_icon
		Space.is_muted = false
		conductor.unit_db = 0

	if space_save_data != null:
		print(space_save_data)
		SaveState.save_game({
			'file_name': get_filename(),
			'stats': {
				'current_level': space_save_data.stats.current_level,
				'current_wave': space_save_data.stats.current_wave,
				'is_muted': is_muted
			}
		})
