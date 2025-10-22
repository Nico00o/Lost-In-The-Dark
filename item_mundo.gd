extends Area2D

@export var id_objeto: int = 0  # índice dentro de DatosInventario.objetos_totales
@onready var sprite: Sprite2D = $Sprite2D  # ajustá la ruta si tu nodo tiene otro nombre
@export var float_amplitude: float = 5.0
@export var float_speed: float = 1.0

var base_y: float
func _ready():
	# Mostrar el icono correspondiente apenas se crea el item
	base_y = position.y
	_iniciar_flotar_animacion()
	if id_objeto >= 0 and id_objeto < DatosInventario.objetos_totales.size():
		var obj = DatosInventario.objetos_totales[id_objeto]
		if "icono" in obj:
			var val = obj.icono
			if typeof(val) == TYPE_STRING and ResourceLoader.exists(val):
				sprite.texture = load(val)
			elif typeof(val) != TYPE_STRING:
				sprite.texture = val
	else:
		print("⚠️ id_objeto fuera de rango:", id_objeto)

	# Aseguramos conexión al signal
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))

func _iniciar_flotar_animacion():
	var tween = create_tween().set_loops() # se repite infinitamente
	tween.tween_property(self, "position:y", base_y - float_amplitude, float_speed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position:y", base_y + float_amplitude, float_speed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _on_body_entered(body: Node) -> void:
	# Asegurate que tu jugador esté en el grupo EXACTO "Player"
	if not body.is_in_group("Player"):
		return

	if id_objeto >= 0 and id_objeto < DatosInventario.objetos_totales.size():
		var obj = DatosInventario.objetos_totales[id_objeto]
		# Agregamos al inventario
		DatosInventario.agregar_item(obj)
		# Emitir señal para que UI pueda actualizarse si está abierta
		if DatosInventario.has_method("emit_signal"):
			# señal opcional si la definís en DatosInventario (recomendada)
			if "item_recogido" in DatosInventario:
				DatosInventario.emit_signal("item_recogido", obj)

		# Mostrar popup si está referenciado
		if DatosInventario.popup_inventario != null:
			DatosInventario.popup_inventario.mostrar_item(obj)
		else:
			print("⚠️ popup_inventario es null — no se mostró popup")

		# Borrar el item del mapa
		queue_free()
