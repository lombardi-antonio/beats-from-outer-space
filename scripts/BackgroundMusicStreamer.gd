extends AudioStreamPlayer3D

var playing_scale = 1.0

func _ready():
	pass

func _process(_delta):
	if not self.playing:
		self.play()

	if space.time_scale < 1.0:
		if self.pitch_scale > 0.03:
			# make sure the pitch_scale can not dip below 0.01 because this will stop the music
			self.pitch_scale = self.pitch_scale - 0.02
	else:
		if self.pitch_scale < 1:
			self.pitch_scale = self.pitch_scale + 0.02
