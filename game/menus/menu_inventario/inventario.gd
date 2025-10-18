extends CanvasLayer

@onready var panel: TextureRect = $Panel
@onready var nombre_jugador: AnimatedSprite2D = $Panel/NombreJugador
@onready var btn_cambiar: TextureButton = $Panel/BtnCambiar
@onready var btn_salir: TextureButton = $Panel/BtnSalir
@onready var stats_vbox: VBoxContainer = $Panel/StatsVBox
@onready var items_hbox: HBoxContainer = $Panel/ItemsHBox
@onready var equip_slots: HBoxContainer = $Panel/EquipSlots

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

	# Conectar botones
	for i in range(items_hbox.get_child_count()):
		var boton = items_hbox.get_child(i)
		if boton is TextureButton:
			boton.pressed.connect(Callable(self, "_on_item_presionado").bind(i))

	for i in range(equip_slots.get_child_count()):
		var slot = equip_slots.get_child(i)
		if slot is TextureButton:
			slot.pressed.connect(Callable(self, "_on_slot_presionado").bind(i))

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

	# 🔹 Forzar que el singleton coincida con la pestaña del inventario
	DatosInventario.cambiar_personaje(personaje_actual)

	actualizar_personaje()
	actualizar_items()
	actualizar_equip_slots()



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
