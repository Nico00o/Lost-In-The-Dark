extends Node2D

func _on_texture_button_3_pressed() -> void:
	get_tree().change_scene_to_file("res://game/menus/menu_principal/control.tscn")

	$VolumenPanel/HSliderMusica.connect("value_changed", Callable(self, "_cambiar_volumen_musica"))
	$VolumenPanel/HSliderEfectos.connect("value_changed", Callable(self, "_cambiar_volumen_musica"))

	# Inicializar los sliders con el volumen actual de los buses de audio
	var idx_musica = AudioServer.get_bus_index("Musica")
	var idx_efectos = AudioServer.get_bus_index("Efectos")

	$VolumenPanel/HSliderMusica.min_value = -80
	$VolumenPanel/HSliderMusica.max_value = 0
	$VolumenPanel/HSliderMusica.value = AudioServer.get_bus_volume_db(idx_musica)

	$VolumenPanel/HSliderEfectos.min_value = -80
	$VolumenPanel/HSliderEfectos.max_value = 0
	$VolumenPanel/HSliderEfectos.value = AudioServer.get_bus_volume_db(idx_efectos)

	# Opcional: Si quieres que el panel esté oculto al iniciar
	$VolumenPanel.visible = false
	$MainMenuContainer.visible = true  # Asegúrate de que el menú principal esté visible

	# Conectar botones para mostrar/ocultar panel volumen (ajusta los nombres si es necesario)
	$MainMenuContainer/TextureButton2.connect("pressed", Callable(self, "_abrir_volumen"))  # Supongo que este botón es "Volumen"
	$VolumenPanel/Volver.connect("pressed", Callable(self, "_cerrar_volumen"))  # Necesitas crear este botón

func _cambiar_volumen_musica(valor):
	var idx = AudioServer.get_bus_index("Musica")
	AudioServer.set_bus_volume_db(idx, valor)

func _cambiar_volumen_efectos(valor):
	var idx = AudioServer.get_bus_index("Efectos")
	AudioServer.set_bus_volume_db(idx, valor)

func _abrir_volumen():
	$MainMenuContainer.visible = false
	$VolumenPanel.visible = true

func _cerrar_volumen():
	$VolumenPanel.visible = false
	$MainMenuContainer.visible = true
