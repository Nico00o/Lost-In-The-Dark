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
var switching := false
var can_switch := true
var switch_cooldown := 15.0

@export var camera_offset_x := -650.0

var cooldown_timer: Timer
var elapsed_cooldown := 0.0

func _ready():
	activate_character(showing_joseph)
	emit_signal("personaje_cambiado", showing_joseph)
	
	if DatosInventario.popup_inventario == null:
		var escena = get_tree().get_root().get_node_or_null("Escenario1/PopupRecogerItem")
		if escena:
			DatosInventario.popup_inventario = escena
		else:
			print("⚠️ No se encontró PopupRecogerItem en Escenario1")

	# 🔹 Crear el timer que se pausa junto al juego
	cooldown_timer = Timer.new()
	cooldown_timer.wait_time = 1.0
	cooldown_timer.one_shot = false
	cooldown_timer.autostart = false
	cooldown_timer.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(cooldown_timer)
	cooldown_timer.timeout.connect(_update_cooldown_label)

	# 🔹 Conexiones de vida y muerte
	marius.connect("vida_cambiada", Callable(self, "_on_vida_cambiada"))
	joseph.connect("vida_cambiada", Callable(self, "_on_vida_cambiada"))
	marius.connect("personaje_muerto", Callable(self, "_on_personaje_muerto"))
	joseph.connect("personaje_muerto", Callable(self, "_on_personaje_muerto"))

	# 🔹 HUD
	var hud_node = get_node_or_null("../HUD")
	if hud_node:
		connect("personaje_cambiado", Callable(hud_node, "_on_personaje_cambiado"))
	else:
		print("⚠️ No se encontró el HUD para conectar la señal.")

	# 🔹 Guardar referencias en el autoload
	if DatosInventario.referencia_joseph == null or DatosInventario.referencia_marius == null:
		var personajes_root = get_tree().get_first_node_in_group("personajes_principales")
		if personajes_root:
			DatosInventario.referencia_joseph = personajes_root.get_node_or_null("Joseph")
			DatosInventario.referencia_marius = personajes_root.get_node_or_null("Marius")


func _input(event):
	if event.is_action_pressed("golpe_test"):
		var personaje = joseph if showing_joseph else marius
		personaje.recibir_danio(20)

	# =========================
	# 🔹 CAMBIO CON TAB
	# =========================
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_TAB:
		if showing_joseph and not marius.is_alive:
			print("❌ No podés cambiar: Marius está muerto.")
			return
		elif not showing_joseph and not joseph.is_alive:
			print("❌ No podés cambiar: Joseph está muerto.")
			return

		# Solo aplica cooldown al cambio manual
		if not switching and can_switch:
			switching = true
			can_switch = false
			elapsed_cooldown = 0.0
			cooldown_label.visible = true
			cooldown_timer.start()
			await play_switch_fx()
			start_switch_cooldown()
		elif not can_switch:
			show_cooldown_message()


# 🔹 Método público para cambiar personaje desde cualquier parte (input o item)
# 🔹 Cambio desde item (respetando cooldown si está libre)
func cambiar_personaje_item():
	if switching:
		return

	# 🔹 Si el cooldown está activo, fuerza el cambio sin tocar el HUD ni timers
	if not can_switch:
		print("🧿 Cooldown activo, pero el item puede forzar el cambio.")
		await cambiar_personaje_item_forzado()
		return

	# 🔹 Cambio con item sin activar cooldown
	switching = true
	print("✨ Cambio por item sin cooldown")
	await play_switch_fx(false)  # no afecta el HUD (ni círculo gris)
	switching = false


# 🔹 Cambio forzado ignorando cooldown — usado por el Orbe del Espejo Vivo
# 🔹 Cambio forzado (ignora cooldown)
func cambiar_personaje_item_forzado():
	if switching:
		return
	switching = true
	print("⚡ Cambio instantáneo por item (ignora cooldown)")
	await play_switch_fx(false)  # <-- parámetro que evita afectar HUD
	switching = false



# 🔹 Efectos visuales compartidos
#   change_fx_affects_ui = true si el cambio fue por Tab (default)
func play_switch_fx(change_fx_affects_ui: bool = true) -> void:
	joseph.can_move = false
	marius.can_move = false

	if showing_joseph:
		if change_fx_affects_ui:
			circulo_cambio.play("cambio1")
	else:
		if change_fx_affects_ui:
			circulo_cambio.play("cambio2")

	var current = joseph if showing_joseph else marius
	var fx: AnimatedSprite2D = current.get_node("AnimatedSprite2D/fx")

	fx.visible = true
	fx.play("salida")
	await fx.animation_finished
	fx.stop()
	fx.frame = 0
	fx.visible = false

	showing_joseph = !showing_joseph
	activate_character(showing_joseph)
	emit_signal("personaje_cambiado", showing_joseph)

	var next_char = joseph if showing_joseph else marius
	var next_fx: AnimatedSprite2D = next_char.get_node("AnimatedSprite2D/fx")
	next_fx.visible = true
	next_fx.play("entrada")
	await next_fx.animation_finished
	next_fx.stop()
	next_fx.frame = 0
	next_fx.visible = false

	if change_fx_affects_ui:
		if showing_joseph:
			circulo_cambio.play("defecto1")
		else:
			circulo_cambio.play("defecto2")

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
	if target == null:
		return
	var camera_pos = camera.global_position
	var desired_pos = Vector2(target.global_position.x + camera_offset_x, camera_fixed_y)
	camera_pos = camera_pos.lerp(desired_pos, camera_smooth)
	camera.global_position = camera_pos


# ======================================================
# COOLDOWN
# ======================================================
func start_switch_cooldown() -> void:
	if showing_joseph:
		circulo_cambio.play("desactivado1")
	else:
		circulo_cambio.play("desactivado2")

	var local_timer := Timer.new()
	local_timer.one_shot = true
	local_timer.wait_time = switch_cooldown
	local_timer.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(local_timer)
	local_timer.start()
	await local_timer.timeout
	local_timer.queue_free()

	if joseph.is_alive and marius.is_alive:
		if showing_joseph:
			circulo_cambio.play("defecto1")
		else:
			circulo_cambio.play("defecto2")

	can_switch = true
	cooldown_timer.stop()
	cooldown_label.visible = false


func _update_cooldown_label() -> void:
	elapsed_cooldown += 1.0
	var remaining = max(0, int(ceil(switch_cooldown - elapsed_cooldown)))
	if remaining <= 0:
		cooldown_timer.stop()
		cooldown_label.visible = false
	else:
		cooldown_label.text = str(remaining)


func show_cooldown_message():
	_update_cooldown_label()


# ======================================================
# GAME OVER Y VIDA
# ======================================================
func _on_vida_cambiada(nombre_personaje: String, vida_actual: int):
	barra_vida.actualizar_barra(nombre_personaje, vida_actual)


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


func die():
	print("💀 El tiempo se acabó. Los personajes mueren.")
	joseph.can_move = false
	marius.can_move = false
	joseph.is_alive = false
	marius.is_alive = false
	_game_over()
