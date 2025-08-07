extends Node2D


func _on_boton_atras_pressed() -> void:
	get_tree().change_scene_to_file("res://Menu Proyect/control.tscn")
