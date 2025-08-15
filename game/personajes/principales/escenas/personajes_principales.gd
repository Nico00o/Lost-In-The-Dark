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

func _ready():
	activate_character(showing_joseph)
	emit_signal("personaje_cambiado", showing_joseph) # para que el HUD se actualice al inicio

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

func _physics_process(_delta):
	if not camera:
		return

	var target = joseph if showing_joseph else marius

	# Deadzone horizontal con suavizado
	var camera_pos = camera.global_position
	var delta_x = target.global_position.x - camera_pos.x

	if abs(delta_x) > deadzone:
		camera_pos.x += (delta_x - sign(delta_x) * deadzone) * camera_smooth

	# Altura fija
	camera_pos.y = camera_fixed_y

	camera.global_position = camera_pos
