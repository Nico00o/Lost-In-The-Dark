extends CanvasLayer

@onready var imagen: TextureRect = $Imagen
@onready var fondo: ColorRect = get_node_or_null("Fondo") # opcional

var activo: bool = false
var tween: Tween = null


func _ready() -> void:
	# Permite input aun con el árbol pausado
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Estado inicial
	visible = false
	activo = false

	# Aseguramos opacidades iniciales
	if imagen:
		var c = imagen.modulate
		c.a = 0.0
		imagen.modulate = c
	
	if fondo:
		var f = fondo.modulate
		f.a = 0.0
		fondo.modulate = f


func mostrar_item(objeto: Dictionary) -> void:
	# Carga la imagen (puede ser ruta o textura ya precargada)
	if "imagen_popup" in objeto:
		var val = objeto.imagen_popup
		if typeof(val) == TYPE_STRING and ResourceLoader.exists(val):
			imagen.texture = load(val)
		elif typeof(val) != TYPE_STRING:
			imagen.texture = val
		else:
			imagen.texture = null
	
	visible = true
	activo = true
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	print("🔔 Popup mostrado para:", objeto.keys()[0] if objeto.keys().size() > 0 else "item")

	# Fade in: animar la opacidad de Fondo (si existe) y de Imagen
	if tween:
		tween.kill()
	tween = create_tween()
	
	if fondo:
		# Fondo a 0.6 alpha por ejemplo
		tween.tween_property(fondo, "modulate:a", 0.6, 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	if imagen:
		# Imagen a 1.0 alpha
		tween.tween_property(imagen, "modulate:a", 1.0, 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _input(event: InputEvent) -> void:
	if not activo:
		return
	
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		_cerrar_popup()


func _cerrar_popup() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	
	if is_instance_valid(imagen):
		tween.tween_property(imagen, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	if is_instance_valid(fondo):
		tween.tween_property(fondo, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	# Conexión más segura, sin función anónima
	tween.finished.connect(_on_tween_finished, CONNECT_ONE_SHOT)


func _on_tween_finished() -> void:
	if not is_instance_valid(self):
		return
	
	visible = false
	activo = false
	get_tree().paused = false
