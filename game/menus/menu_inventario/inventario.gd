extends CanvasLayer

@onready var panel: TextureRect = $TextureRect

func _ready():
	visible = false  # Inventario cerrado por defecto
	set_process_input(true)       # activa _input
	process_mode = Node.PROCESS_MODE_ALWAYS  # Sigue procesando input aunque el juego esté pausado

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

func _cerrar_inventario():
	get_tree().paused = false
	visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
