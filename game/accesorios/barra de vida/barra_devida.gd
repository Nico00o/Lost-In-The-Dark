extends CanvasLayer

var personaje_activo = "Joseph"  # o el que empiece

@onready var barra_joseph = $JosephBarraDeVida
@onready var barra_marius = $MariusBarraDeVida

func _ready():
	_actualizar_barras()

func _input(event):
	if event.is_action_pressed("cambio"):  # Tab en Input Map
		if personaje_activo == "Joseph":
			personaje_activo = "Marius"
		else:
			personaje_activo = "Joseph"
		_actualizar_barras()

func _actualizar_barras():
	barra_joseph.visible = personaje_activo == "Joseph"
	barra_marius.visible = personaje_activo == "Marius"
