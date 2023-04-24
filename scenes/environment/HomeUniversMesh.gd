extends MeshInstance

func _physics_process(_delta):
	self.mesh.material.uv1_offset.y += .02 * 0.01
