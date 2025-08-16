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
			_on_continuar_pressed()

func _on_continuar_pressed():
	get_tree().paused = false
	visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://game/menus/menu_principal/control.tscn")

func _on_opciones_pressed() -> void:
	pass # Replace with function body.

func _on_historia_pressed() -> void:
	pass # Replace with function body.
