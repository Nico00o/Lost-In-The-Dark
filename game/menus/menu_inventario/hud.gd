extends CanvasLayer

# 🔹 Identificador del personaje de este HUD
@export var personaje_hud: String = "joseph"

# 🔹 Slots del HUD
@onready var slots = [
	$Triangulo/Slot1,
	$Triangulo/Slot2,
	$Triangulo/Slot3
]

# 🔹 Diccionarios de control
var _buff_tiempos := {}   # nombre_slot -> tiempo restante de buff
var _cd_tiempos := {}     # nombre_slot -> tiempo restante de cooldown

# ======================================================
# 🔸 Inicio
# ======================================================
func _ready():
	actualizar_slots(DatosInventario.personaje_activo)
	add_to_group("hud_personaje")
	var pp = get_node_or_null("../PersonajesPrincipales")
	if pp:
		var callable = Callable(self, "_on_personaje_cambiado")
		if not pp.is_connected("personaje_cambiado", callable):
			pp.connect("personaje_cambiado", callable)

	var s = DatosInventario
	var callable2 = Callable(self, "_on_amuleto_actualizado")
	if not s.is_connected("amuleto_actualizado", callable2):
		s.connect("amuleto_actualizado", callable2)

	_on_amuleto_actualizado(DatosInventario.personaje_activo)

	s.connect("item_usado", Callable(self, "_on_item_usado"))
	s.connect("item_en_cooldown", Callable(self, "_on_item_en_cooldown"))
	s.connect("item_estado_terminado", Callable(self, "_on_item_estado_terminado"))

	print("✅ HUD de amuletos listo para recibir señales.")

# ======================================================
# 🔹 Actualiza los slots del HUD
# ======================================================
func actualizar_slots(personaje: String):
	print("🔄 Actualizando slots HUD para:", personaje)
	var equipados = DatosInventario.amuletos_personaje[personaje.to_lower()]

	for i in range(3):
		var slot = slots[i]
		var fondo = slot.get_node("FondoVacio") as CanvasItem
		var amuleto = slot.get_node("Amuleto") as TextureRect
		var decoracion = slot.get_node("Decoracion") as CanvasItem

		if i < equipados.size() and equipados[i] != null:
			var item_dict = equipados[i]
			if "icono" in item_dict and ResourceLoader.exists(item_dict.icono):
				amuleto.texture = load(item_dict.icono)
			else:
				amuleto.texture = null
			fondo.visible = false
			print("🧿 Slot", i, ":", item_dict.nombre)
		else:
			amuleto.texture = null
			fondo.visible = true

		decoracion.visible = true

# ======================================================
# 🔸 Cambio de personaje
# ======================================================
func _on_personaje_cambiado(show_joseph: bool) -> void:
	limpiar_overlays()
	var nuevo_personaje = "joseph" if show_joseph else "marius"
	print("🔁 Cambiando personaje activo a:", nuevo_personaje)
	DatosInventario.cambiar_personaje(nuevo_personaje)
	actualizar_slots(DatosInventario.personaje_activo)

# ======================================================
# 🔸 Limpieza visual al cambiar
# ======================================================
func limpiar_overlays():
	for slot in slots:
		for child in slot.get_children():
			if child.name.begins_with("Overlay_"):
				child.queue_free()
		var buff_label = slot.get_node_or_null("BuffLabel")
		var cd_label = slot.get_node_or_null("CooldownLabel")
		if buff_label: buff_label.visible = false
		if cd_label: cd_label.visible = false
		slot.get_node("Amuleto").modulate = Color(1,1,1,1)
	_buff_tiempos.clear()
	_cd_tiempos.clear()

# ======================================================
# 🔸 Actualización de amuleto
# ======================================================
func _on_amuleto_actualizado(personaje: String) -> void:
	if personaje == DatosInventario.personaje_activo:
		actualizar_slots(personaje)

# ======================================================
# 🔸 Item usado
# ======================================================
func _on_item_usado(slot_index: int, duracion_estado: float):

	if slot_index >= slots.size(): return

	var slot = slots[slot_index]
	var key = slot.name

	# Evitar duplicar si ya está activo
	if _buff_tiempos.has(key) or _cd_tiempos.has(key):
		print("⚠️ Ya hay un efecto activo o cooldown en", key)
		return

	var amuleto = slot.get_node("Amuleto") as TextureRect
	amuleto.modulate = Color(1,1,1,1)

	if duracion_estado > 0:
	# Obtener el item del slot activo
		var item_dict = DatosInventario.amuletos_personaje[DatosInventario.personaje_activo][slot_index]
		if item_dict:
			_crear_overlay(slot, duracion_estado, Color(0,1,0), "duracion", item_dict.get("cooldown", 35))

	else:
		print("ℹ️ Item sin duración, pasando directo a cooldown.")
		var item_dict = DatosInventario.amuletos_personaje[DatosInventario.personaje_activo][slot_index]
		if item_dict:
			_iniciar_cooldown(slot, item_dict.get("cooldown", 1))  # usar el cooldown real del item


# ======================================================
# 🔸 Item en cooldown
# ======================================================
func _on_item_en_cooldown(slot_index: int, duracion: float):

	if slot_index >= slots.size(): return
	var slot = slots[slot_index]
	var amuleto = slot.get_node("Amuleto") as TextureRect
	amuleto.modulate = Color(0.5,0.5,0.5,1)
	_crear_overlay(slot, duracion, Color(1,0,0), "cooldown", 0)

# ======================================================
# 🔸 Terminar cooldown o estado
# ======================================================
func _on_item_estado_terminado(slot_index: int):

	if slot_index >= slots.size(): return
	var slot = slots[slot_index]
	var amuleto = slot.get_node("Amuleto") as TextureRect
	amuleto.modulate = Color(1,1,1,1)

	for child in slot.get_children():
		if child.name.begins_with("Overlay_"):
			child.queue_free()

# # ======================================================
# 🔸 Crear overlay con contadores
# ======================================================
func _crear_overlay(slot: Node, duracion: float, _color: Color, tipo: String, cooldown: float):
	var key = slot.name

	# ⚠️ No crear otro overlay si ya hay uno activo
	if _buff_tiempos.has(key) or _cd_tiempos.has(key):
		print("⚠️ Ya existe overlay activo en", key)
		return

	var buff_label = slot.get_node_or_null("BuffLabel") as Label
	var cd_label = slot.get_node_or_null("CooldownLabel") as Label

	if tipo == "duracion":
		if buff_label:
			buff_label.visible = true
			buff_label.text = str(int(duracion))
		if cd_label:
			cd_label.visible = false
		
		_buff_tiempos[key] = duracion

		# ✅ Timer seguro
		var timer = Timer.new()
		timer.name = "BuffTimer_" + key
		timer.wait_time = 1
		timer.one_shot = false
		timer.autostart = true
		slot.add_child(timer)
		timer.timeout.connect(func():
			_actualizar_tiempo_buff(slot, timer, cooldown)
		)
	
	elif tipo == "cooldown":
		_iniciar_cooldown(slot, duracion)


# # ======================================================
# 🔸 Actualizar buff activo
# ======================================================
func _actualizar_tiempo_buff(slot: Node, timer: Timer, cooldown : float):

	var buff_label = slot.get_node_or_null("BuffLabel") as Label
	if not buff_label: return
	var key = slot.name
	if not _buff_tiempos.has(key): return

	_buff_tiempos[key] -= 1
	var tiempo = _buff_tiempos[key]

	if tiempo <= 0:
		timer.queue_free()
		buff_label.visible = false
		_buff_tiempos.erase(key)
		_iniciar_cooldown(slot, cooldown)
	else:
		buff_label.text = str(int(tiempo))



# ======================================================
# 🔸 Iniciar cooldown
# ======================================================
func _iniciar_cooldown(slot: Node, duracion : float):
	var key = slot.name

	# ⚠️ No iniciar si ya hay cooldown
	if _cd_tiempos.has(key):
		print("⚠️ Cooldown ya en curso para", key)
		return

	var amuleto = slot.get_node("Amuleto") as TextureRect
	var cd_label = slot.get_node_or_null("CooldownLabel") as Label
	var buff_label = slot.get_node_or_null("BuffLabel") as Label

	amuleto.modulate = Color(0.5,0.5,0.5,1)
	if cd_label:
		cd_label.visible = true
		cd_label.text = str(int(duracion))
	if buff_label:
		buff_label.visible = false
	
	_cd_tiempos[key] = duracion

	var timer = Timer.new()
	timer.name = "CooldownTimer_" + key
	timer.wait_time = 1
	timer.one_shot = false
	timer.autostart = true
	slot.add_child(timer)
	timer.timeout.connect(func():
		_actualizar_tiempo_cooldown(slot, timer)
	)

# ======================================================
# 🔸 Actualizar cooldown
# ======================================================
func _actualizar_tiempo_cooldown(slot: Node, timer: Timer):
	var cd_label = slot.get_node_or_null("CooldownLabel") as Label
	var amuleto = slot.get_node("Amuleto") as TextureRect
	if not cd_label: return
	var key = slot.name
	if not _cd_tiempos.has(key): return

	_cd_tiempos[key] -= 1
	var tiempo = _cd_tiempos[key]
	if tiempo <= 0:
		timer.queue_free()
		_cd_tiempos.erase(key)
		cd_label.visible = false
		amuleto.modulate = Color(1,1,1,1)
	else:
		cd_label.text = str(int(tiempo))

# ======================================================
# 🔸 Detectar teclas de uso
# ======================================================

func _unhandled_input(event):
	if get_tree().paused: return
	if event.is_action_pressed("usar_slot1"):
		DatosInventario.usar_item(0)
	elif event.is_action_pressed("usar_slot2"):
		DatosInventario.usar_item(1)
	elif event.is_action_pressed("usar_slot3"):
		DatosInventario.usar_item(2)
