extends Node

# =========================================
# 🗃️ SINGLETON: DatosInventario
# =========================================
# Maneja los datos del inventario y amuletos por personaje.
# =========================================

# Estructura:
# - Cada personaje tiene su propio array de amuletos equipados (3 slots)
var amuletos_personaje := {
	"joseph": [null, null, null],
	"marius": [null, null, null]
}

# Personaje activo actual
var personaje_activo: String = "marius"

# -----------------------------------------
# Cambiar personaje activo
# -----------------------------------------
func cambiar_personaje(nombre: String):
	if amuletos_personaje.has(nombre):
		personaje_activo = nombre


# -----------------------------------------
# Obtener los amuletos del personaje activo
# -----------------------------------------
func obtener_equipados() -> Array:
	return amuletos_personaje[personaje_activo]


# -----------------------------------------
# Equipar objeto en un slot del personaje activo
# -----------------------------------------
func equipar_objeto(slot_index: int, objeto):
	if slot_index < amuletos_personaje[personaje_activo].size():
		amuletos_personaje[personaje_activo][slot_index] = objeto


# -----------------------------------------
# Desequipar objeto de un slot
# -----------------------------------------
func desequipar_objeto(slot_index: int):
	if slot_index < amuletos_personaje[personaje_activo].size():
		amuletos_personaje[personaje_activo][slot_index] = null
