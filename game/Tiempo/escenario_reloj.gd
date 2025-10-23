extends Node2D

@onready var timer_hud = $TimerHUD/HUDControl
@onready var personajes = $PersonajesPrincipales 
@onready var canvaslayer = $CanvasLayer
@onready var imagen = $CanvasLayer/TextureRect
@onready var fondo = $CanvasLayer.get_node_or_null("Fondo") # opcional

var activo := false
var tween: Tween = null
var imagen_inicial: Texture = preload("res://game/Tiempo/pantallareloj(1).png")

func _ready():
	timer_hud.connect("tiempo_terminado", Callable(self, "_on_tiempo_terminado"))

	# Inicializamos opacidades
	if imagen:
		var c = imagen.modulate
		c.a = 0.0
		imagen.modulate = c
	if fondo:
		var f = fondo.modulate
		f.a = 0.0
		fondo.modulate = f

	canvaslayer.process_mode = Node.PROCESS_MODE_ALWAYS

	# Mostrar popup inicial
	mostrar_popup_inicial()

func mostrar_popup_inicial() -> void:
	imagen.texture = imagen_inicial
	visible_popup(true)

	# Bloquear lógica del jugador y HUD
	personajes.set_process(false)
	timer_hud.set_process(false)

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# Fade in
	if tween:
		tween.kill()
	tween = create_tween()
	if fondo:
		tween.tween_property(fondo, "modulate:a", 0.6, 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(imagen, "modulate:a", 1.0, 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _input(event):
	if not activo:
		return
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		cerrar_popup()

func cerrar_popup() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	if is_instance_valid(imagen):
		tween.tween_property(imagen, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	if is_instance_valid(fondo):
		tween.tween_property(fondo, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.finished.connect(_on_popup_cerrado, CONNECT_ONE_SHOT)

func _on_popup_cerrado() -> void:
	if not is_instance_valid(self):
		return
	visible_popup(false)

	# Reanudar lógica del jugador y HUD
	personajes.set_process(true)
	timer_hud.set_process(true)

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func visible_popup(valor: bool) -> void:
	canvaslayer.visible = valor
	activo = valor

func _on_tiempo_terminado():
	print("Tiempo terminado. Fin del juego.")
	personajes.die()
