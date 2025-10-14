extends CanvasLayer

@onready var btn_continuar = $TextureButtonContinuar
@onready var btn_salir = $TextureButtonSalir

func _ready():
	btn_continuar.pressed.connect(_on_continuar_pressed)
	btn_salir.pressed.connect(_on_salir_pressed)

func _on_continuar_pressed():
	print("Reiniciar juego...")
	get_tree().change_scene_to_file("res://game/escenarios/escenario_1/escenario1.tscn")  # o tu escena principal

func _on_salir_pressed():
	print("Salir al menú...")
	get_tree().change_scene_to_file("res://game/menus/menu_principal/control.tscn")  # o salir al menú principal
