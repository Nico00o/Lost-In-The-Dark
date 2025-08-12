extends Node2D

@onready var joseph = $Joseph
@onready var marius = $Marius

var showing_joseph := true

func _ready():
	print("Escena personajes_principales lista")
	joseph.visible = true
	marius.visible = false

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_TAB:
		print("Tab presionado, cambiando personaje")
		toggle_character()

func toggle_character():
	showing_joseph = !showing_joseph
	joseph.visible = showing_joseph
	marius.visible = not showing_joseph
	print("Mostrando Joseph?", showing_joseph)
