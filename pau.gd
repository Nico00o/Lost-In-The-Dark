extends Control

@onready var pau: Control = $"."

func _input(_event):
	if Input.is_action_just_pressed("Pause") and get_tree().paused == false:
		get_tree().paused = true
		$".".visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_continuar_pressed():
	get_tree().paused = false
	$".".visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_senu_pressed():
	get_tree().change_scene("res://game/menus/menu_principal/control.tscn")
	get_tree().paused = false

func _on_salir_pressed():
	get_tree().quit()
	get_tree().paused = false
