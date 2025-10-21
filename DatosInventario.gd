extends Node

# =========================================
# 🗃️ SINGLETON: DatosInventario
# =========================================
# Maneja los datos del inventario y amuletos por personaje.
# =========================================

# Señal que se emite cuando un amuleto se equipa o se desequipa
signal amuleto_actualizado(personaje: String)

# Equipamiento por personaje
var amuletos_personaje := {
	"joseph": [null, null, null],
	"marius": [null, null, null]
}

var referencia_joseph: Node = null
var referencia_marius: Node = null


# Inventario compartido
var inventario_global := []

# Objetos del juego
var objetos_totales := [
	{"Mascara del olvido":"Invulnerable al daño",
	"icono":"res://game/menus/menu_inventario/objetos/invulnerable al daño.png",
	"imagen_info":"res://game/menus/menu_inventario/hover/mascara del olvido.png"},
	
	{"Emblema del velo Alado":"Aumenta Velocidad un 10%",
	 "icono":"res://game/menus/menu_inventario/objetos/aumenta la velocidad en 10(1).png",
	"imagen_info":"res://game/menus/menu_inventario/hover/emblema del velo alado.png"},
	
	{"orbe":"Cambia Instantaneamente",
	 "icono":"res://game/menus/menu_inventario/objetos/permite cambiar instantaneamente.png",
	"imagen_info":"res://game/menus/menu_inventario/hover/orbe del espejo vivo.png"},
	
	{"Semilla del retorno":"Revive a un personaje muerto",
	 "icono":"res://game/menus/menu_inventario/objetos/revive a un personaje(1).png",
	"imagen_info":"res://game/menus/menu_inventario/hover/semilla del retorno.png"},
	
	{"Gema del Pulso Carmesi":"Recupera 40 de hp",
	"icono":"res://game/menus/menu_inventario/objetos/recupera vida.png",
	"imagen_info":"res://game/menus/menu_inventario/hover/gema del pulso carmesi.png"},
	
	{"Rostro del Ritmo Sagrado":"Aumenta velocidad de ataque un 10%",
	 "icono":"res://game/menus/menu_inventario/objetos/aumenta la barra de vida en 2(1).png",
	"imagen_info":"res://game/menus/menu_inventario/hover/rostro del ritmo sagrado.png"},
	
	{"Marca del Devoraluz":"Aumenta el ataque un 40%", 
	"icono":"res://game/menus/menu_inventario/objetos/aumenta el ataque en 10(1).png",
	"imagen_info":"res://game/menus/menu_inventario/hover/marca del devoraluz.png"},
	
	{"Nucleo del vinculo Sombrio":"Aumenta la resistencia un 30%", 
	"icono":"res://game/menus/menu_inventario/objetos/aumenta la resistencia en 10.png", 
	"imagen_info":"res://game/menus/menu_inventario/hover/nucleo del vinculo sombrio.png"},
]

# Personaje activo actual
var personaje_activo: String = "joseph"

# -------------------------
# Inventario compartido
# -------------------------
func obtener_inventario() -> Array:
	return inventario_global

func agregar_item(objeto):
	inventario_global.append(objeto)

# -------------------------
# Equipamiento por personaje
# -------------------------
func obtener_equipados() -> Array:
	return amuletos_personaje[personaje_activo]

func equipar_objeto(slot_index: int, objeto):
	if slot_index < amuletos_personaje[personaje_activo].size():
		amuletos_personaje[personaje_activo][slot_index] = objeto
		emit_signal("amuleto_actualizado", personaje_activo)

func desequipar_objeto(personaje: String, slot_index: int):
	var nombre = personaje.to_lower()
	if amuletos_personaje.has(nombre) and slot_index < amuletos_personaje[nombre].size():
		amuletos_personaje[nombre][slot_index] = null
		emit_signal("amuleto_actualizado", nombre)

func cambiar_personaje(nombre: String):
	nombre = nombre.to_lower()
	if amuletos_personaje.has(nombre):
		personaje_activo = nombre
