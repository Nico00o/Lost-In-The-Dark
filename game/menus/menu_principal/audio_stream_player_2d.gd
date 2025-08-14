extends AudioStreamPlayer

func _ready():
	if get_tree().get_root().has_node("MusicaFondo"):
		queue_free()
		return

	get_tree().get_root().add_child(self)
	self.name = "MusicaFondo"
	self.owner = null
	play()
