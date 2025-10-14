extends CanvasLayer

@onready var barra_marius = $TextureRectMarius
@onready var barra_joseph = $TextureRectJoseph

# 🔹 Imágenes de las barras
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
	preload("res://game/accesorios/barra de vida/barra de vida joseph/vida_0.png")
]

# 🔹 Máxima vida de cada personaje
const MAX_HEALTH_MARIUS = 160
const MAX_HEALTH_JOSEPH = 120

func _ready():
	# Mostrar barras completas y escala
	barra_marius.texture = imagenes_marius[0]
	barra_joseph.texture = imagenes_joseph[0]
	barra_marius.scale = Vector2(0.27, 0.27)
	barra_joseph.scale = Vector2(0.27, 0.27)
	
	# Mostrar solo la barra inicial
	barra_marius.visible = false
	barra_joseph.visible = true

# 🔹 Actualizar barra desde los personajes
func actualizar_barra(nombre_personaje: String, vida_actual: int):
	if nombre_personaje == "Marius":
		_actualizar_barra_porcentaje(barra_marius, imagenes_marius, vida_actual, MAX_HEALTH_MARIUS)
		barra_marius.visible = true
		barra_joseph.visible = false
	elif nombre_personaje == "Joseph":
		_actualizar_barra_porcentaje(barra_joseph, imagenes_joseph, vida_actual, MAX_HEALTH_JOSEPH)
		barra_joseph.visible = true
		barra_marius.visible = false


# 🔹 Función interna que calcula la textura por porcentaje de vida
func _actualizar_barra_porcentaje(barra: TextureRect, imagenes: Array, vida_actual: int, vida_max: int):
	var porcentaje = float(vida_actual) / float(vida_max)
	var index = int(round((1.0 - porcentaje) * (imagenes.size() - 1)))
	index = clamp(index, 0, imagenes.size() - 1)
	barra.texture = imagenes[index]
