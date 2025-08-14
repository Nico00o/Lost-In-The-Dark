extends Node2D

@onready var v_box_container_2: VBoxContainer = $VBoxContainer2
@onready var volumen_panel: Panel = $VolumenPanel

func _ready():
	v_box_container_2.visible = true
	volumen_panel.visible = false  

func _on_texture_button_pressed() -> void:
	print("Settings Pressed")
	v_box_container_2.visible = false  
	volumen_panel.visible = true

func _on_texture_button_3_pressed() -> void:
	get_tree().change_scene_to_file("res://game/menus/menu_principal/control.tscn")

func _on_texture_button_2_pressed() -> void:
	pass # Replace with function body.
