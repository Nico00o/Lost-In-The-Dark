extends Control

func _on_texture_button_pressed():
	get_tree().change_scene_to_file("res://game/escenarios/escenario_1/escenario1.tscn")

func _on_texture_button_2_pressed():
	get_tree().change_scene_to_file("res://game/menus/menu_principal/opc.tscn")

func _on_texture_button_3_pressed():
	get_tree().quit()
