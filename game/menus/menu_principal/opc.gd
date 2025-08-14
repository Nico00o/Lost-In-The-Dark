extends Node2D

@onready var botones_opc: VBoxContainer = $BotonesOpc
@onready var volumen_panel: Panel = $VolumenPanel

func _on_atras_pressed() -> void:
	get_tree().change_scene_to_file("res://game/menus/menu_principal/control.tscn")

func _ready() -> void:
	botones_opc.visible = true
	volumen_panel.visible = false

func _on_volumen_pressed() -> void:
	botones_opc.visible = false
	volumen_panel.visible = true

func _on_at_pressed() -> void:
	botones_opc.visible = true
	volumen_panel.visible = false
