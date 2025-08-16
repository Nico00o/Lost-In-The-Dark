extends Node2D

signal personaje_cambiado(show_joseph)

@onready var joseph: CharacterBody2D = $Joseph
@onready var marius: CharacterBody2D = $Marius
@onready var camera: Camera2D = $Camera2D2

# Arranca con Marius en lugar de Joseph
var showing_joseph := false
var deadzone: float = 500
var camera_smooth: float = 0.1
var camera_fixed_y: float = 300

var used_deadzone := false
var start_x := 0.0

func _ready():
	# Activar el personaje inicial
	activate_character(showing_joseph)
	emit_signal("personaje_cambiado", showing_joseph) # para que el HUD se actualice al inicio
	
	# Guardar la posición inicial del jugador para la deadzone
	var target = joseph if showing_joseph else marius
	start_x = target.global_position.x


func _input(event):
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_TAB:
		showing_joseph = !showing_joseph
		activate_character(showing_joseph)
		emit_signal("personaje_cambiado", showing_joseph)


func activate_character(show_joseph: bool) -> void:
	var prev: CharacterBody2D
	var next_char: CharacterBody2D

	if show_joseph:
		prev = marius
		next_char = joseph
	else:
		prev = joseph
		next_char = marius

	# 1. Desactivar colisiones y visibilidad del nuevo personaje temporalmente
	next_char.visible = true
	_set_collision_enabled(next_char, false)

	# 2. Copiar posición exacta y velocidad
	next_char.position = prev.position
	next_char.velocity = prev.velocity

	# 3. Activar/desactivar personajes
	next_char.is_active = true
	prev.is_active = false
	prev.visible = false

	# 4. Activar colisiones recién después
	_set_collision_enabled(next_char, true)
	_set_collision_enabled(prev, false)


func _set_collision_enabled(character: CharacterBody2D, enabled: bool) -> void:
	for shape in character.get_children():
		if shape is CollisionShape2D:
			shape.disabled = not enabled



@export var camera_offset_x := -650.0  # negativo = personaje un poco hacia atrás

func _physics_process(_delta):
	if not camera:
		return

	var target = joseph if showing_joseph else marius
	var camera_pos = camera.global_position

	# Posición deseada: personaje + offset
	var desired_pos = Vector2(target.global_position.x + camera_offset_x, camera_fixed_y)

	# Suavizado con lerp de Godot 4
	camera_pos = camera_pos.lerp(desired_pos, camera_smooth)

	camera.global_position = camera_pos
