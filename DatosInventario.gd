extends Node

# =========================================
# 🗃️ SINGLETON: DatosInventario
# =========================================
# Maneja los datos del inventario y amuletos por personaje.
# =========================================

signal amuleto_actualizado(personaje: String)
signal item_recogido(objeto)
signal item_usado(slot_index: int, duracion_estado: float)
signal item_en_cooldown(slot_index: int, duracion_cooldown: float)
signal item_estado_terminado(slot_index: int)

# Equipamiento por personaje
var amuletos_personaje := {
	"joseph": [null, null, null],
	"marius": [null, null, null]
}

var referencia_joseph: Node = null
var referencia_marius: Node = null
var popup_inventario: Node = null

# Inventario compartido
var inventario_global := []

var cooldown_items := {} # clave: slot_index, valor: bool (true = en cooldown)

# Objetos del juego
# Objetos del juego
var objetos_totales := [
	{
		"nombre": "Mascara del olvido",
		"descripcion": "Invulnerable al daño",
		"tipo": "estado",
		"efecto": "invulnerabilidad",
		"valor": 1.0, # no se usa pero mantiene consistencia
		"duracion": 15.0,
		"cooldown": 90.0,
		"icono": "res://game/menus/menu_inventario/objetos/invulnerable al daño.png",
		"imagen_info": "res://game/menus/menu_inventario/hover/mascara del olvido.png",
		"imagen_popup": "res://game/menus/menu_inventario/recogeritem/imagenes/mascara del olvido.png"
	},
	{
		"nombre": "Emblema del velo Alado",
		"descripcion": "Aumenta Velocidad un 10%",
		"tipo": "estado",
		"efecto": "aumento_velocidad",
		"valor": 1.15,
		"duracion": 15.0,
		"cooldown": 20.0,
		"icono": "res://game/menus/menu_inventario/objetos/aumenta la velocidad en 10(1).png",
		"imagen_info": "res://game/menus/menu_inventario/hover/emblema del velo alado.png",
		"imagen_popup": "res://game/menus/menu_inventario/recogeritem/imagenes/emblema del velo alado.png"
	},
	{
		"nombre": "Orbe del Espejo Vivo",
		"descripcion": "Cambia instantáneamente de personaje",
		"tipo": "instantaneo",
		"efecto": "cambiar_personaje",
		"valor": 0,
		"duracion": 0,
		"cooldown": 15.0,
		"icono": "res://game/menus/menu_inventario/objetos/permite cambiar instantaneamente.png",
		"imagen_info": "res://game/menus/menu_inventario/hover/orbe del espejo vivo.png",
		"imagen_popup": "res://game/menus/menu_inventario/recogeritem/imagenes/orbe del espejo vivo.png"
	},
	{
		"nombre": "Semilla del Retorno",
		"descripcion": "Revive a un personaje muerto",
		"tipo": "instantaneo",
		"efecto": "revivir",
		"valor": 1,
		"duracion": 0,
		"cooldown": 100.0,
		"icono": "res://game/menus/menu_inventario/objetos/revive a un personaje(1).png",
		"imagen_info": "res://game/menus/menu_inventario/hover/semilla del retorno.png",
		"imagen_popup": "res://game/menus/menu_inventario/recogeritem/imagenes/semilla del retorno.png"
	},
	{
		"nombre": "Gema del Pulso Carmesí",
		"descripcion": "Recupera 40 de HP",
		"tipo": "instantaneo",
		"efecto": "curar",
		"valor": 40,
		"duracion": 0,
		"cooldown": 20.0,
		"icono": "res://game/menus/menu_inventario/objetos/recupera vida.png",
		"imagen_info": "res://game/menus/menu_inventario/hover/gema del pulso carmesi.png",
		"imagen_popup": "res://game/menus/menu_inventario/recogeritem/imagenes/gema del pulso carmesi.png"
	},
	{
		"nombre": "Rostro del Ritmo Sagrado",
		"descripcion": "Aumenta velocidad de ataque un 10%",
		"tipo": "estado",
		"efecto": "aumento_vel_ataque",
		"valor": 1.1,
		"duracion": 15.0,
		"cooldown": 30.0,
		"icono": "res://game/menus/menu_inventario/objetos/aumenta la barra de vida en 2(1).png",
		"imagen_info": "res://game/menus/menu_inventario/hover/rostro del ritmo sagrado.png",
		"imagen_popup": "res://game/menus/menu_inventario/recogeritem/imagenes/rostro del ritmo sagrado.png"
	},
	{
		"nombre": "Marca del Devoraluz",
		"descripcion": "Aumenta el ataque un 40%",
		"tipo": "estado",
		"efecto": "aumento_fuerza",
		"valor": 1.4,
		"duracion": 15.0,
		"cooldown": 35.0,
		"icono": "res://game/menus/menu_inventario/objetos/aumenta el ataque en 10(1).png",
		"imagen_info": "res://game/menus/menu_inventario/hover/marca del devoraluz.png",
		"imagen_popup": "res://game/menus/menu_inventario/recogeritem/imagenes/marca del devoraluz.png"
	},
	{
		"nombre": "Núcleo del Vínculo Sombrío",
		"descripcion": "Aumenta la resistencia un 20%",
		"tipo": "estado",
		"efecto": "aumento_resistencia",
		"valor": 1.2,
		"duracion": 15.0,
		"cooldown": 30.0,
		"icono": "res://game/menus/menu_inventario/objetos/aumenta la resistencia en 10.png",
		"imagen_info": "res://game/menus/menu_inventario/hover/nucleo del vinculo sombrio.png",
		"imagen_popup": "res://game/menus/menu_inventario/recogeritem/imagenes/nucleo del vinculo sombrio.png"
	}
]

var personaje_activo: String = "joseph"

# -------------------------
# Inventario compartido
# -------------------------
func obtener_inventario() -> Array:
	return inventario_global

func agregar_item(objeto):
	inventario_global.append(objeto)
	emit_signal("item_recogido", objeto)

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

# -------------------------
# Uso de items
# -------------------------
func usar_item(index: int):
	if cooldown_items.has(index) and cooldown_items[index]:
		print("⌛ Item en cooldown, espera antes de usarlo de nuevo")
		return
	# 🛑 Chequear si hay buff o cooldown visual activo en HUD
	var hud = get_tree().get_first_node_in_group("hud_personaje")
	if hud:
		var slot_name = "Slot" + str(index + 1)
		if hud._buff_tiempos.has(slot_name) or hud._cd_tiempos.has(slot_name):
			print("🚫 Ya hay un buff o cooldown activo en", slot_name, "— no se puede volver a usar.")
			return
	var personaje = personaje_activo
	var equipados = amuletos_personaje[personaje]
	if index < 0 or index >= equipados.size():
		return
	var item = equipados[index]
	if item == null:
		print("⚠️ Slot", index, "vacío")
		return

	var nombre = item["nombre"]
	print("🧿 Usando item:", nombre)

	match nombre:
		"Gema del Pulso Carmesí":
			if _hp_actual(personaje) < _hp_max(personaje):
				_restaurar_hp(item["valor"])
				emit_signal("item_usado", index, 0)
				_iniciar_cooldown(index, item["cooldown"])
			else:
				print("💤 Vida ya completa, no se usa Gema del Pulso Carmesi")

		"Emblema del velo Alado":
			_activar_velocidad(index, item["valor"], item["duracion"], item["cooldown"])

		"Mascara del olvido":
			_activar_invulnerabilidad(index, item["duracion"], item["cooldown"])

		"Marca del Devoraluz":
			_activar_estado(index, item["duracion"], item["cooldown"])
			_aplicar_buff_ataque(personaje, item["valor"], item["duracion"])

		"Orbe del Espejo Vivo":
			if _otro_personaje_vivo():
				_cambiar_personaje_instantaneo()
				emit_signal("item_usado", index, 0)
				_iniciar_cooldown(index, item["cooldown"])
			else:
				print("💤 No se puede cambiar de personaje: el otro está muerto")

		"Semilla del Retorno":
			if _otro_personaje_muerto():
				var otro = _obtener_otro_personaje()
				if otro != null and not otro.is_alive:
					otro.revivir()
					print("🌱 Se ha revivido a", otro.name)
					emit_signal("item_usado", index, 0)
					_iniciar_cooldown(index, item["cooldown"])
				else:
					print("⚠️ No se pudo revivir — referencia faltante o ya vivo")
			else:
				print("💤 Ambos personajes vivos, no se activa Semilla del Retorno")

		_:
			print("⚠️ Item no reconocido:", nombre)


func _restaurar_hp(cantidad: int):
	var personaje_ref = referencia_joseph if personaje_activo == "joseph" else referencia_marius
	if personaje_ref == null or not personaje_ref.is_alive:
		print("⚠️ No se puede curar, personaje muerto o sin referencia")
		return

	personaje_ref.curar_hp(cantidad)
	print("💖 Se restauraron", cantidad, "HP a", personaje_activo)

func _iniciar_cooldown(index: int, duracion: float):
	cooldown_items[index] = true
	emit_signal("item_en_cooldown", index, duracion)
	await get_tree().create_timer(duracion).timeout
	cooldown_items[index] = false
	emit_signal("item_estado_terminado", index)


func _activar_estado(index: int, duracion_estado: float, cooldown: float):
	emit_signal("item_usado", index, duracion_estado)
	await get_tree().create_timer(duracion_estado).timeout
	emit_signal("item_en_cooldown", index, cooldown)
	await get_tree().create_timer(cooldown).timeout
	emit_signal("item_estado_terminado", index)

# -------------------------
# Efectos especiales
# -------------------------
func _revive_personaje():
	var objetivo = null
	if personaje_activo == "joseph" and referencia_marius:
		objetivo = referencia_marius
	elif personaje_activo == "marius" and referencia_joseph:
		objetivo = referencia_joseph
	
	if objetivo and objetivo.has_method("revivir"):
		objetivo.revivir()
		print("🌱 Se ha revivido al otro personaje.")
	else:
		print("⚠️ No se pudo revivir — método 'revivir' no encontrado o referencia faltante.")

func _personaje_vivo(nombre: String) -> bool:
	if nombre == "joseph" and referencia_joseph:
		return referencia_joseph.is_alive
	elif nombre == "marius" and referencia_marius:
		return referencia_marius.is_alive
	return false

func _hp_actual(nombre: String) -> int:
	if nombre == "joseph" and referencia_joseph:
		return referencia_joseph.health
	elif nombre == "marius" and referencia_marius:
		return referencia_marius.health
	return 0

func _hp_max(nombre: String) -> int:
	if nombre == "joseph" and referencia_joseph:
		return referencia_joseph.max_health
	elif nombre == "marius" and referencia_marius:
		return referencia_marius.max_health
	return 0

func _otro_personaje_vivo() -> bool:
	if personaje_activo == "joseph":
		return referencia_marius != null and referencia_marius.is_alive
	else:
		return referencia_joseph != null and referencia_joseph.is_alive

func _otro_personaje_muerto() -> bool:
	if personaje_activo == "joseph":
		return referencia_marius != null and not referencia_marius.is_alive
	else:
		return referencia_joseph != null and not referencia_joseph.is_alive

func _cambiar_personaje_instantaneo():
	var personajes_root = get_tree().get_first_node_in_group("personajes_principales")
	if personajes_root == null:
		print("⚠️ No se encontró el nodo personajes_principales")
		return
	# Verificamos que tenga el método de cambio con animación
	if personajes_root.has_method("cambiar_personaje_item"):
		print("✨ Activando cambio con animación (Orbe del Espejo Vivo)")
		await personajes_root.cambiar_personaje_item()
	else:
		print("⚠️ No se encontró 'cambiar_personaje_item' en personajes_principales")


# -------------------------
# Aumentar ataque (buff)
# -------------------------
func _aplicar_buff_ataque(personaje: String, multiplicador: float, duracion: float):
	var ref = referencia_joseph if personaje == "joseph" else referencia_marius
	if ref == null:
		print("⚠️ No se encontró referencia para", personaje)
		return

	var dano_original = ref.dano
	ref.dano = dano_original * multiplicador
	print("💥 Aumento de ataque aplicado a", personaje, ":", dano_original, "→", ref.dano)

	await get_tree().create_timer(duracion).timeout

	ref.dano = dano_original
	print("⏳ Buff de ataque finalizado, daño de", personaje, "vuelve a", dano_original)

func _obtener_otro_personaje() -> CharacterBody2D:
	if personaje_activo == "joseph":
		return referencia_marius
	else:
		return referencia_joseph

func _activar_invulnerabilidad(index: int, duracion: float, cooldown: float):
	var personaje_ref = referencia_joseph if personaje_activo == "joseph" else referencia_marius
	if personaje_ref == null:
		print("⚠️ No se encontró referencia para", personaje_activo)
		return

	emit_signal("item_usado", index, duracion)
	personaje_ref.is_invulnerable = true
	print("🛡️", personaje_activo, "es invulnerable por", duracion, "segundos")

	# Timer para terminar efecto
	await get_tree().create_timer(duracion).timeout
	personaje_ref.is_invulnerable = false
	print("⏳ Invulnerabilidad de", personaje_activo, "terminada")

	# Iniciar cooldown
	emit_signal("item_en_cooldown", index, cooldown)
	await get_tree().create_timer(cooldown).timeout
	emit_signal("item_estado_terminado", index)


func _activar_velocidad(index: int, multiplicador: float, duracion: float, cooldown: float):
	var personaje_ref = referencia_joseph if personaje_activo == "joseph" else referencia_marius
	if personaje_ref == null:
		print("⚠️ No se encontró referencia para", personaje_activo)
		return

	# Guardar la original solo si no existe
	if not personaje_ref.has_meta("velocidad_original"):
		personaje_ref.set_meta("velocidad_original", personaje_ref.velocidad_mov)

	personaje_ref.velocidad_mov = personaje_ref.get_meta("velocidad_original") * multiplicador
	print("💨", personaje_activo, "velocidad aumentada:", personaje_ref.velocidad_mov)

	emit_signal("item_usado", index, duracion)

	await get_tree().create_timer(duracion).timeout

	# Restaurar velocidad original
	personaje_ref.velocidad_mov = personaje_ref.get_meta("velocidad_original")
	print("⏳ Velocidad de", personaje_activo, "restaurada:", personaje_ref.velocidad_mov)

	# Cooldown
	emit_signal("item_en_cooldown", index, cooldown)
	await get_tree().create_timer(cooldown).timeout
	emit_signal("item_estado_terminado", index)
