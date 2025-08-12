extends Node2D

# Export para asignar las escenas de personajes en el editor
@export var joseph_scene: PackedScene
@export var marius_scene: PackedScene

var current_character: Node = null
var showing_joseph := true

@onready var spawn_point = $Marker2D

func _ready():
	# Cargar a Joseph al inicio
	spawn_character(joseph_scene)

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_TAB:
		switch_character()

func spawn_character(scene: PackedScene):
	# Eliminar personaje actual
	if current_character:
		current_character.queue_free()
	
	# Instanciar nuevo
	current_character = scene.instantiate()
	add_child(current_character)
	current_character.global_position = spawn_point.global_position

func switch_character():
	showing_joseph = !showing_joseph
	if showing_joseph:
		spawn_character(joseph_scene)
	else:
		spawn_character(marius_scene)
