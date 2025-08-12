extends Node2D

signal personaje_cambiado(show_joseph)

@onready var joseph = $Joseph
@onready var marius = $Marius

var showing_joseph := true

func _ready():
	activate_character(showing_joseph)

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_TAB:
		showing_joseph = !showing_joseph
		activate_character(showing_joseph)
		emit_signal("personaje_cambiado", showing_joseph)

func activate_character(show_joseph: bool) -> void:
	joseph.is_active = show_joseph
	marius.is_active = not show_joseph
	
	joseph.visible = show_joseph
	marius.visible = not show_joseph
	
	joseph.position = Vector2.ZERO
	marius.position = Vector2.ZERO
