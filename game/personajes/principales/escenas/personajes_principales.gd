extends Node2D

signal personaje_cambiado(show_joseph)

@onready var joseph: CharacterBody2D = $Joseph
@onready var marius: CharacterBody2D = $Marius
@onready var camera: Camera2D = $Camera2D2
@onready var cooldown_label: Label = $CanvasLayer/CooldownLabel


var showing_joseph := false
var deadzone: float = 500
var camera_smooth: float = 0.1
var camera_fixed_y: float = 300
var start_x := 0.0
var switching := false  # evita spamear Tab
var can_switch := true        # controla el cooldown
var switch_cooldown := 15.0  # segundos de espera

@export var camera_offset_x := -650.0

var cooldown_timer: Timer
var cooldown_start_time := 0.0  # nuevo

func _ready():
	# Activar el personaje inicial correctamente
	activate_character(showing_joseph)
	emit_signal("personaje_cambiado", showing_joseph)

	# Crear el Timer para el contador si no existe en la escena
	cooldown_timer = Timer.new()
	cooldown_timer.wait_time = 1.0  # actualizar cada segundo
	cooldown_timer.one_shot = false
	cooldown_timer.autostart = false
	add_child(cooldown_timer)
	cooldown_timer.timeout.connect(_update_cooldown_label)


func _input(event):
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_TAB:
		if not switching and can_switch:
			switching = true
			can_switch = false
			cooldown_start_time = Time.get_ticks_msec() / 1000.0
			cooldown_label.visible = true
			cooldown_timer.start()  # arranca el contador
			await play_switch_fx()
			start_switch_cooldown()
		elif not can_switch:
			show_cooldown_message()

func play_switch_fx() -> void:
	# 🔹 bloquear movimiento
	joseph.can_move = false
	marius.can_move = false

	var current = joseph if showing_joseph else marius
	var fx: AnimatedSprite2D = current.get_node("AnimatedSprite2D/fx")

	# reproducir anim salida
	fx.visible = true
	fx.play("salida")
	await fx.animation_finished
	fx.stop()
	fx.frame = 0
	fx.visible = false

	# cambiar personaje
	showing_joseph = !showing_joseph
	activate_character(showing_joseph)
	emit_signal("personaje_cambiado", showing_joseph)

	# reproducir anim entrada
	var next_char = joseph if showing_joseph else marius
	var next_fx: AnimatedSprite2D = next_char.get_node("AnimatedSprite2D/fx")
	next_fx.visible = true
	next_fx.play("entrada")
	await next_fx.animation_finished
	next_fx.stop()
	next_fx.frame = 0
	next_fx.visible = false

	# 🔹 desbloquear movimiento
	joseph.can_move = true
	marius.can_move = true

	switching = false




func activate_character(show_joseph: bool) -> void:
	var prev: CharacterBody2D
	var next_char: CharacterBody2D

	if show_joseph:
		prev = marius
		next_char = joseph
	else:
		prev = joseph
		next_char = marius

	next_char.visible = true
	_set_collision_enabled(next_char, false)

	next_char.position = prev.position
	next_char.velocity = prev.velocity

	next_char.is_active = true
	prev.is_active = false
	prev.visible = false

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
	var camera_pos = camera.global_position
	var desired_pos = Vector2(target.global_position.x + camera_offset_x, camera_fixed_y)
	camera_pos = camera_pos.lerp(desired_pos, camera_smooth)
	camera.global_position = camera_pos


func start_switch_cooldown() -> void:
	await get_tree().create_timer(switch_cooldown).timeout
	can_switch = true
	cooldown_timer.stop()
	cooldown_label.visible = false


func _update_cooldown_label() -> void:
	var elapsed = (Time.get_ticks_msec() / 1000.0) - cooldown_start_time
	var remaining = max(0, int(ceil(switch_cooldown - elapsed)))  # entero, sin decimales
	if remaining <= 0:
		cooldown_timer.stop()
		cooldown_label.visible = false
	else:
		cooldown_label.text = "Esperá " + str(remaining) + " segundos para cambiar"


func show_cooldown_message():
	# por seguridad, también puede mostrar el tiempo restante si se llama directamente
	_update_cooldown_label()
