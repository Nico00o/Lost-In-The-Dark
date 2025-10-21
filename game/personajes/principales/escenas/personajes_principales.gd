extends Node2D

signal personaje_cambiado(show_joseph)

@onready var joseph: CharacterBody2D = $Joseph
@onready var marius: CharacterBody2D = $Marius
@onready var camera: Camera2D = $Camera2D2
@onready var cooldown_label: Label = $CanvasLayer/CooldownLabel
@onready var barra_vida = $"../barradevida"
@onready var fade_rect: ColorRect = $CanvasLayer/Fade
@onready var circulo_cambio: AnimatedSprite2D = $"../barradevida/AnimatedSprite2D"

var showing_joseph := true
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
	
	# Conectar barra de vida
	marius.connect("vida_cambiada", Callable(self, "_on_vida_cambiada"))
	joseph.connect("vida_cambiada", Callable(self, "_on_vida_cambiada"))
	marius.connect("personaje_muerto", Callable(self, "_on_personaje_muerto"))
	joseph.connect("personaje_muerto", Callable(self, "_on_personaje_muerto"))
	
	# 🔹 Conectar HUD al cambio de personaje
	var hud_node = get_node_or_null("../HUD")  # Ajustar según la jerarquía
	if hud_node:
		connect("personaje_cambiado", Callable(hud_node, "_on_personaje_cambiado"))
	else:
		print("⚠️ No se encontró el HUD para conectar la señal.")


func _on_vida_cambiada(nombre_personaje: String, vida_actual: int):
	barra_vida.actualizar_barra(nombre_personaje, vida_actual)


func _input(event):
	if event.is_action_pressed("golpe_test"):
		var personaje = joseph if showing_joseph else marius
		personaje.recibir_danio(20)
		
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_TAB:
		# Evitar cambiar si uno está muerto
		if showing_joseph and not marius.is_alive:
			print("❌ No podés cambiar: Marius está muerto.")
			return
		elif not showing_joseph and not joseph.is_alive:
			print("❌ No podés cambiar: Joseph está muerto.")
			return

		# Evitar cambiar durante el cooldown o animación
		if not switching and can_switch:
			switching = true
			can_switch = false
			cooldown_start_time = Time.get_ticks_msec() / 1000.0
			cooldown_label.visible = true
			cooldown_timer.start()
			await play_switch_fx()
			start_switch_cooldown()
		elif not can_switch:
			show_cooldown_message()


func play_switch_fx() -> void:
	# Bloquear movimiento
	joseph.can_move = false
	marius.can_move = false

	# Animación del círculo
	if showing_joseph:
		circulo_cambio.play("cambio1")
	else:
		circulo_cambio.play("cambio2")

	var current = joseph if showing_joseph else marius
	var fx: AnimatedSprite2D = current.get_node("AnimatedSprite2D/fx")

	# Animación de salida
	fx.visible = true
	fx.play("salida")
	await fx.animation_finished
	fx.stop()
	fx.frame = 0
	fx.visible = false

	# Cambiar personaje
	showing_joseph = !showing_joseph
	activate_character(showing_joseph)
	emit_signal("personaje_cambiado", showing_joseph)

	# Animación de entrada
	var next_char = joseph if showing_joseph else marius
	var next_fx: AnimatedSprite2D = next_char.get_node("AnimatedSprite2D/fx")
	next_fx.visible = true
	next_fx.play("entrada")
	await next_fx.animation_finished
	next_fx.stop()
	next_fx.frame = 0
	next_fx.visible = false

	# Círculo vuelve al estado defecto
	if showing_joseph:
		circulo_cambio.play("defecto1")
	else:
		circulo_cambio.play("defecto2")

	# Desbloquear movimiento
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

	# Cambiar la barra de vida
	if barra_vida:
		barra_vida.barra_joseph.visible = show_joseph
		barra_vida.barra_marius.visible = not show_joseph


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
	if showing_joseph:
		circulo_cambio.play("desactivado1")
	else:
		circulo_cambio.play("desactivado2")

	await get_tree().create_timer(switch_cooldown).timeout

	if joseph.is_alive and marius.is_alive:
		if showing_joseph:
			circulo_cambio.play("defecto1")
		else:
			circulo_cambio.play("defecto2")

	can_switch = true
	cooldown_timer.stop()
	cooldown_label.visible = false


func _update_cooldown_label() -> void:
	var elapsed = (Time.get_ticks_msec() / 1000.0) - cooldown_start_time
	var remaining = max(0, int(ceil(switch_cooldown - elapsed)))
	if remaining <= 0:
		cooldown_timer.stop()
		cooldown_label.visible = false
	else:
		cooldown_label.text = str(remaining)


func show_cooldown_message():
	_update_cooldown_label()


func _game_over():
	print("💀 Ambos personajes han muerto. Iniciando Game Over...")

	joseph.can_move = false
	marius.can_move = false

	var tree := get_tree()

	var tween = create_tween()
	fade_rect.color.a = 0
	tween.tween_property(fade_rect, "color:a", 1.0, 2.0)
	await tween.finished

	await tree.create_timer(0.5).timeout

	tree.change_scene_to_file("res://game/menus/menu_gameover/gameover.tscn")


func _on_vida_joseph(vida_actual: int):
	barra_vida._actualizar_barra(barra_vida.barra_joseph, vida_actual, "Joseph")

func _on_vida_marius(vida_actual: int):
	barra_vida._actualizar_barra(barra_vida.barra_marius, vida_actual, "Marius")
	
func _on_personaje_muerto(nombre_personaje: String):
	print("⚰️", nombre_personaje, "ha muerto")

	if not joseph.is_alive and not marius.is_alive:
		_game_over()
		return

	if nombre_personaje == "Joseph" and marius.is_alive and showing_joseph:
		showing_joseph = false
		activate_character(showing_joseph)
		emit_signal("personaje_cambiado", showing_joseph)
		print("Cambio automático a Marius")
	elif nombre_personaje == "Marius" and joseph.is_alive and not showing_joseph:
		showing_joseph = true
		activate_character(showing_joseph)
		emit_signal("personaje_cambiado", showing_joseph)
		print("Cambio automático a Joseph")

	if not joseph.is_alive or not marius.is_alive:
		if showing_joseph:
			circulo_cambio.play("desactivado1")
		else:
			circulo_cambio.play("desactivado2")

func die():
	print("💀 El tiempo se acabó. Los personajes mueren.")

	# Desactivar movimiento
	joseph.can_move = false
	marius.can_move = false

	# Marcar ambos como muertos
	joseph.is_alive = false
	marius.is_alive = false

	# Llamar al game over
	_game_over()
