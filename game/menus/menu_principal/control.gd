extends Control

@onready var volumen_panel: Panel = $VolumenPanel
@onready var botones: VBoxContainer = $Botones
@onready var botones_opc: VBoxContainer = $BotonesOpc

func _ready():
	$Botones.visible = true
	$BotonesOpc.visible = false
	$VolumenPanel.visible = false

func _on_texture_button_pressed():
	get_tree().change_scene_to_file("res://game/escenarios/escenario_1/escenario1.tscn")

func _on_texture_button_2_pressed():
	$Botones.visible = false
	$BotonesOpc.visible = true

func _on_texture_button_3_pressed():
	get_tree().quit()

func _on_atras_pressed() -> void:
	$Botones.visible = true
	$BotonesOpc.visible = false

func _on_volumen_pressed() -> void:
	$BotonesOpc.visible = false
	$VolumenPanel.visible = true

func _on_at_pressed() -> void:
	$BotonesOpc.visible = true
	$VolumenPanel.visible = false
