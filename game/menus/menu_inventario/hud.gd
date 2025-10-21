extends CanvasLayer

# 🔹 Slots del HUD
@onready var slots = [
	$Triangulo/Slot1,
	$Triangulo/Slot2,
	$Triangulo/Slot3
]

func _ready():
	# Inicializar HUD con el personaje activo real
	actualizar_slots(DatosInventario.personaje_activo)

	# Conectar señal de cambio de personaje desde PersonajesPrincipales
	var pp = get_node_or_null("../PersonajesPrincipales")
	if pp:
		var callable = Callable(self, "_on_personaje_cambiado")
		if not pp.is_connected("personaje_cambiado", callable):
			pp.connect("personaje_cambiado", callable)
	else:
		print("⚠️ No se encontró el nodo PersonajesPrincipales para conectar la señal.")

	# Conectar señal del singleton para actualizar cuando se equipa/desequipa
	var s = DatosInventario
	var callable2 = Callable(self, "_on_amuleto_actualizado")
	if not s.is_connected("amuleto_actualizado", callable2):
		s.connect("amuleto_actualizado", callable2)

	# 🔹 Forzar actualización inicial del HUD con los equipados del personaje activo
	_on_amuleto_actualizado(DatosInventario.personaje_activo)


# 🔹 Actualiza los slots del HUD según el personaje activo real
func actualizar_slots(personaje: String):
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
		else:
			amuleto.texture = null
			fondo.visible = true

		decoracion.visible = true


# 🔸 Reacción al cambio de personaje en el juego (TAB)
func _on_personaje_cambiado(show_joseph: bool) -> void:
	var nuevo_personaje = "joseph" if show_joseph else "marius"
	DatosInventario.cambiar_personaje(nuevo_personaje)
	actualizar_slots(DatosInventario.personaje_activo)


# 🔸 Reacción cuando se equipa o desequipa un amuleto
func _on_amuleto_actualizado(personaje: String) -> void:
	# Solo actualiza el HUD si el personaje del evento es el activo
	if personaje == DatosInventario.personaje_activo:
		actualizar_slots(personaje)
