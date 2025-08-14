extends CanvasLayer

func _ready():
	visible = false

func _input(event):
	if event.is_action_pressed("Pause"):
		if not get_tree().paused:
			get_tree().paused = true
			visible = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			_continuar()

func _continuar():
	get_tree().paused = false
	visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_continuar_pressed():
	_continuar()

func _on_senu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://game/menus/menu_principal/control.tscn")

func _on_salir_pressed():
	get_tree().paused = false
	get_tree().quit()
