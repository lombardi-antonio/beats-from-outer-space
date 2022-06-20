extends MeshInstance

var game_over = false


func _physics_process(_delta):
	if(game_over):
		if(self.mesh.material.uv1_offset.y > 0):
			self.mesh.material.uv1_offset.y -= .02
		return
	self.mesh.material.uv1_offset.y += .02 * Space.time_scale


func _on_vapor_falcon_was_defeated():
	game_over = true
