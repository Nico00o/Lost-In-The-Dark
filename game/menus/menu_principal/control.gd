extends Control

func _on_texture_button_pressed():
	get_tree().change_scene_to_file("res://Menu Proyect/star.tscn")

func _on_texture_button_2_pressed():
	get_tree().change_scene_to_file("res://Menu Proyect/opciones.tscn")

func _on_texture_button_3_pressed():
	get_tree().quit()
