extends MeshInstance


func _physics_process(_delta):
	self.mesh.material.uv1_offset.y += 0.008 * space.time_scale
