extends Camera2D

var velocidad = 40

func _process(delta):
	if Input.is_action_pressed("ui_right"):
		position.x += velocidad * delta
	if Input.is_action_pressed("ui_left"):
		position.x -= velocidad * delta
