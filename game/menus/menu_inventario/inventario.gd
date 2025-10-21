extends CanvasLayer

@onready var panel: TextureRect = $Panel
@onready var nombre_jugador: AnimatedSprite2D = $Panel/NombreJugador
@onready var btn_cambiar: TextureButton = $Panel/BtnCambiar
@onready var btn_salir: TextureButton = $Panel/BtnSalir
@onready var items_hbox: HBoxContainer = $Panel/ItemsHBox
@onready var equip_slots: HBoxContainer = $Panel/EquipSlots
@onready var info_hover: TextureRect = $Panel/InfoHover
@onready var label_dano: Label = $Panel/LabelDaño
@onready var label_salud: Label = $Panel/LabelSalud
@onready var label_velocidad: Label = $Panel/LabelVelocidad

# 🔹 Personaje que estamos viendo en inventario (solo visual)
var personaje_actual: String = "Joseph"

func _ready():
	visible = false
	set_process_input(true)
	process_mode = Node.PROCESS_MODE_ALWAYS

	btn_cambiar.pressed.connect(_on_btn_cambiar_pressed)
	btn_salir.pressed.connect(_on_btn_salir_pressed)

	# Inicializar inventario global solo si está vacío
	if DatosInventario.inventario_global.size() == 0:
		DatosInventario.agregar_item(DatosInventario.objetos_totales[0])
		DatosInventario.agregar_item(DatosInventario.objetos_totales[1])
		DatosInventario.agregar_item(DatosInventario.objetos_totales[4])
		DatosInventario.agregar_item(DatosInventario.objetos_totales[5])
		DatosInventario.agregar_item(DatosInventario.objetos_totales[2])
		DatosInventario.agregar_item(DatosInventario.objetos_totales[3])
		DatosInventario.agregar_item(DatosInventario.objetos_totales[6])
		DatosInventario.agregar_item(DatosInventario.objetos_totales[7])

	# Conectar botones
	for i in range(items_hbox.get_child_count()):
		var boton = items_hbox.get_child(i)
		if boton is TextureButton:
			boton.pressed.connect(Callable(self, "_on_item_presionado").bind(i))
			boton.mouse_entered.connect(Callable(self, "_on_item_hover").bind(i))
			boton.mouse_exited.connect(Callable(self, "_on_item_unhover"))


	for i in range(equip_slots.get_child_count()):
		var slot = equip_slots.get_child(i)
		if slot is TextureButton:
			slot.pressed.connect(Callable(self, "_on_slot_presionado").bind(i))
			slot.mouse_entered.connect(Callable(self, "_on_slot_hover").bind(i))
			slot.mouse_exited.connect(Callable(self, "_on_slot_unhover"))

	actualizar_personaje()
	actualizar_items()
	actualizar_equip_slots()


# ==========================================================
# Equipar / Desequipar (actualiza personaje visual)
# ==========================================================
func _on_item_presionado(idx: int):
	var items = DatosInventario.obtener_inventario()
	if idx >= items.size():
		return
	var objeto = items[idx]

	# Cambiar temporalmente el personaje que se modifica
	var personaje_modificado = personaje_actual.to_lower()
	var equipados = DatosInventario.amuletos_personaje[personaje_modificado]

	# Evitar duplicado
	for amuleto in equipados:
		if amuleto != null and amuleto.keys()[0] == objeto.keys()[0]:
			print("Ya equipado:", objeto.keys()[0])
			return

	# Máximo 3 slots
	if equipados.count(null) == 0:
		print("No hay espacio para equipar más objetos.")
		return

	# Equipar en el primer slot libre
	var slot_index = equipados.find(null)
	DatosInventario.amuletos_personaje[personaje_modificado][slot_index] = objeto
	DatosInventario.inventario_global.erase(objeto)

	# 🔹 Emitir señal solo si coincide con el personaje activo
	if personaje_modificado == DatosInventario.personaje_activo:
		DatosInventario.emit_signal("amuleto_actualizado", personaje_modificado)

	actualizar_items()
	actualizar_equip_slots()


func _on_slot_presionado(idx: int):
	var personaje_modificado = personaje_actual.to_lower()
	var equipados = DatosInventario.amuletos_personaje[personaje_modificado]

	if idx < equipados.size() and equipados[idx] != null:
		var obj = equipados[idx]
		DatosInventario.amuletos_personaje[personaje_modificado][idx] = null
		DatosInventario.agregar_item(obj)

		# 🔹 Emitir señal solo si coincide con el personaje activo
		if personaje_modificado == DatosInventario.personaje_activo:
			DatosInventario.emit_signal("amuleto_actualizado", personaje_modificado)

	actualizar_items()
	actualizar_equip_slots()


# ==========================================================
# UI e Interfaz
# ==========================================================
func _input(event):
	if event.is_action_pressed("abrir_inventario"):
		if not visible:
			_abrir_inventario()
		else:
			_cerrar_inventario()


func _abrir_inventario():
	get_tree().paused = true
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# 🟢 Sincronizar automáticamente con el personaje activo del juego
	personaje_actual = DatosInventario.personaje_activo.capitalize()
	DatosInventario.cambiar_personaje(personaje_actual)
	
	if DatosInventario.referencia_joseph == null or DatosInventario.referencia_marius == null:
		var personajes = get_tree().get_first_node_in_group("personajes_principales")
		if personajes:
			DatosInventario.referencia_joseph = personajes.joseph
			DatosInventario.referencia_marius = personajes.marius

	actualizar_personaje()
	actualizar_items()
	actualizar_equip_slots()
	actualizar_stats()



func _cerrar_inventario():
	get_tree().paused = false
	visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_btn_cambiar_pressed():
	# Cambiar solo el personaje visual
	personaje_actual = "Marius" if personaje_actual == "Joseph" else "Joseph"
	actualizar_personaje()
	actualizar_items()
	actualizar_equip_slots()
	actualizar_stats()


func _on_btn_salir_pressed():
	_cerrar_inventario()


func actualizar_personaje():
	if personaje_actual == "Joseph":
		nombre_jugador.play("Joseph")
	else:
		nombre_jugador.play("Marius")



func actualizar_items():
	var imagen_vacia = "res://game/menus/menu_inventario/estrella nula.png"
	var items = DatosInventario.obtener_inventario()

	for i in range(items_hbox.get_child_count()):
		var boton = items_hbox.get_child(i)
		if boton is TextureButton:
			if i < items.size():
				var obj = items[i]
				boton.texture_normal = load(obj.icono) if "icono" in obj and ResourceLoader.exists(obj.icono) else load(imagen_vacia)
			else:
				boton.texture_normal = load(imagen_vacia)
			boton.disabled = false


func actualizar_equip_slots():
	var equipados = DatosInventario.amuletos_personaje[personaje_actual.to_lower()]
	var imagen_vacia = "res://game/menus/menu_inventario/estrella nula.png"

	for i in range(equip_slots.get_child_count()):
		var slot = equip_slots.get_child(i)
		if slot is TextureButton:
			var amuleto = equipados[i] if i < equipados.size() else null
			if amuleto != null and "icono" in amuleto and ResourceLoader.exists(amuleto.icono):
				slot.texture_normal = load(amuleto.icono)
			else:
				slot.texture_normal = load(imagen_vacia)

func _on_item_hover(idx: int):
	var items = DatosInventario.obtener_inventario()
	if idx >= items.size():
		return

	var obj = items[idx]

	# Obtener la ruta de la imagen informativa
	var imagen_info := ""
	if "imagen_info" in obj:
		imagen_info = obj.imagen_info
	elif "icono" in obj:
		imagen_info = obj.icono

	if imagen_info != "" and ResourceLoader.exists(imagen_info):
		info_hover.texture = load(imagen_info)
		info_hover.visible = true
		info_hover.modulate.a = 0.0
		_efecto_fade_in(info_hover)


func _on_item_unhover():
	info_hover.visible = false


func _efecto_fade_in(node: CanvasItem):
	var tween = create_tween()
	tween.tween_property(node, "modulate:a", 1.0, 0.7) 

func _efecto_fade_out(node: CanvasItem):
	var tween = create_tween()
	tween.tween_property(node, "modulate:a", 0.0, 1)
	tween.finished.connect(func():
		node.visible = false)


func _on_slot_hover(idx: int):
	var personaje_modificado = personaje_actual.to_lower()
	var equipados = DatosInventario.amuletos_personaje[personaje_modificado]
	if idx >= equipados.size() or equipados[idx] == null:
		return

	var obj = equipados[idx]
	var imagen_info := ""
	if "imagen_info" in obj:
		imagen_info = obj.imagen_info
	elif "icono" in obj:
		imagen_info = obj.icono

	if imagen_info != "" and ResourceLoader.exists(imagen_info):
		info_hover.texture = load(imagen_info)
		info_hover.visible = true
		info_hover.modulate.a = 0.0
		_efecto_fade_in(info_hover)


func _on_slot_unhover():
	if info_hover.visible:
		_efecto_fade_out(info_hover)

	


func actualizar_stats():
	var ref = null

	if personaje_actual == "Joseph" and DatosInventario.referencia_joseph:
		ref = DatosInventario.referencia_joseph
	elif personaje_actual == "Marius" and DatosInventario.referencia_marius:
		ref = DatosInventario.referencia_marius
	
	if ref == null:
		print("⚠️ No se encontró referencia del personaje actual:", personaje_actual)
		return

	print("✅ Stats cargados de:", personaje_actual)
	$Panel/LabelDaño.text = str(ref.dano)
	$Panel/LabelSalud.text = str(ref.health)
	$Panel/LabelVelocidad.text = str(ref.velocidad_mov)
