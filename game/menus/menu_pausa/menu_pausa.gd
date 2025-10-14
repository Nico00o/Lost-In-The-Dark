extends CanvasLayer

@onready var botones: VBoxContainer = $Botones
@onready var botones_opc: VBoxContainer = $BotonesOpc
@onready var inventario: CanvasLayer = $"../Inventario"# 

func _ready():
	visible = false
	$Botones.visible = true
	$BotonesOpc.visible = false

func _input(event):
	if event.is_action_pressed("Pause"):
		# 🔹 No pausar si el inventario está visible
		if inventario.visible:
			return

		if not get_tree().paused:
			get_tree().paused = true
			visible = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			_on_continuar_pressed()

func _on_continuar_pressed():
	get_tree().paused = false
	visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://game/menus/menu_principal/control.tscn")

func _on_opciones_pressed() -> void:
	$Botones.visible = false
	$BotonesOpc.visible = true

func _on_reiniciar_pressed() -> void:
	get_tree().reload_current_scene()

func _on_atras_pressed() -> void:
	$Botones.visible = true
	$BotonesOpc.visible = false
