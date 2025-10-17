extends CanvasLayer

# 🔹 Slots del HUD
@onready var slots = [
	$Triangulo/Slot1,
	$Triangulo/Slot2,
	$Triangulo/Slot3
]

func _ready():
	# 🔹 Equipar objetos distintos para probar (solo si no están equipados ya)
	if DatosInventario.obtener_equipados()[1] == null:
		DatosInventario.cambiar_personaje("marius")
		DatosInventario.equipar_objeto(1, {"icono": preload("res://game/menus/menu_inventario/objetos/recupera vida.png")})

		DatosInventario.cambiar_personaje("joseph")
		DatosInventario.equipar_objeto(1, {"icono": preload("res://game/menus/menu_inventario/objetos/aumenta la velocidad en 10(1).png")})

	# 🔹 Inicializar HUD con el personaje que está activo en escena
	var pp = get_node("../PersonajesPrincipales")  # Ajustá según tu jerarquía
	if pp:
		if pp.showing_joseph:
			DatosInventario.cambiar_personaje("joseph")
		else:
			DatosInventario.cambiar_personaje("marius")
	else:
		# Si no encontramos el nodo, dejamos Marius por defecto
		DatosInventario.cambiar_personaje("marius")

	actualizar_slots()

	# 🔹 Conectar señal de cambio de personaje desde PersonajesPrincipales
	if pp:
		var callable = Callable(self, "_on_personaje_cambiado")
		if not pp.is_connected("personaje_cambiado", callable):
			pp.connect("personaje_cambiado", callable)
	else:
		print("⚠️ No se encontró el nodo PersonajesPrincipales para conectar la señal.")


# ===========================================================
# 🔹 Actualiza los slots del HUD según el personaje activo
# ===========================================================
func actualizar_slots():
	var equipados = DatosInventario.obtener_equipados()

	for i in range(3):
		var slot = slots[i]
		var fondo = slot.get_node("FondoVacio")
		var amuleto = slot.get_node("Amuleto")
		var decoracion = slot.get_node("Decoracion")

		if i < equipados.size() and equipados[i] != null:
			amuleto.texture = equipados[i].icono
			fondo.visible = false
		else:
			amuleto.texture = null
			fondo.visible = true

		decoracion.visible = true  # Siempre visible


# ===========================================================
# 🔁 Reacción al cambio de personaje
# ===========================================================
func _on_personaje_cambiado(show_joseph: bool) -> void:
	if show_joseph:
		DatosInventario.cambiar_personaje("joseph")
	else:
		DatosInventario.cambiar_personaje("marius")

	actualizar_slots()
