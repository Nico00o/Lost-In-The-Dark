extends CanvasLayer


@onready var barra_marius = $TextureRectMarius
@onready var barra_joseph = $TextureRectJoseph


# Cargar las imágenes de las barras (podés cambiarlas por tus rutas)
@onready var imagenes_marius: Array = [
	preload("res://game/accesorios/barra de vida/barra de vida marius/vida_160.png"),
	preload("res://game/accesorios/barra de vida/barra de vida marius/vida_140.png"),
	preload("res://game/accesorios/barra de vida/barra de vida marius/vida_120.png"),
	preload("res://game/accesorios/barra de vida/barra de vida marius/vida_100.png"),
	preload("res://game/accesorios/barra de vida/barra de vida marius/vida_80.png"),
	preload("res://game/accesorios/barra de vida/barra de vida marius/vida_60.png"),
	preload("res://game/accesorios/barra de vida/barra de vida marius/vida_40.png"),
	preload("res://game/accesorios/barra de vida/barra de vida marius/vida_20.png"),
	preload("res://game/accesorios/barra de vida/barra de vida marius/vida_0.png")
]

@onready var imagenes_joseph: Array = [
	preload("res://game/accesorios/barra de vida/barra de vida joseph/vida_120.png"),
	preload("res://game/accesorios/barra de vida/barra de vida joseph/vida_100.png"),
	preload("res://game/accesorios/barra de vida/barra de vida joseph/vida_80.png"),
	preload("res://game/accesorios/barra de vida/barra de vida joseph/vida_60.png"),
	preload("res://game/accesorios/barra de vida/barra de vida joseph/vida_40.png"),
	preload("res://game/accesorios/barra de vida/barra de vida joseph/vida_20.png"),
	preload("res://game/accesorios/barra de vida/barra de vida joseph/vida_0.png"),
]

func _ready():
	# Empieza mostrando las barras completas
	barra_marius.texture = imagenes_marius[0]
	barra_joseph.texture = imagenes_joseph[0]
	
	
	# 🔹 Mostrar solo la barra del personaje inicial
	barra_marius.visible = false
	barra_joseph.visible = true


# 🔹 Se llama desde los personajes cuando cambia la vida
func actualizar_barra(nombre_personaje: String, vida_actual: int):
	if nombre_personaje == "Marius":
		actualizar_barra_marius(vida_actual)
	elif nombre_personaje == "Joseph":
		actualizar_barra_joseph(vida_actual)

func actualizar_barra_marius(vida_actual: int):
	if vida_actual > 120:
		barra_marius.texture = imagenes_marius[0]
	elif vida_actual > 80:
		barra_marius.texture = imagenes_marius[1]
	elif vida_actual > 40:
		barra_marius.texture = imagenes_marius[2]
	elif vida_actual > 0:
		barra_marius.texture = imagenes_marius[3]
	else:
		barra_marius.texture = imagenes_marius[4]

func actualizar_barra_joseph(vida_actual: int):
	if vida_actual > 80:
		barra_joseph.texture = imagenes_joseph[0]
	elif vida_actual > 40:
		barra_joseph.texture = imagenes_joseph[1]
	elif vida_actual > 20:
		barra_joseph.texture = imagenes_joseph[2]
	else:
		barra_joseph.texture = imagenes_joseph[3]
