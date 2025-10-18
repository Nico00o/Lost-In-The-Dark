extends Control

@onready var tiempo_label = $TiempoLabel
@onready var temporizador = $Temporizador

signal tiempo_terminado

var tiempo_restante = 180  # segundos, ejemplo 1:30

func _ready():
	_actualizar_label()  # mostrar al inicio en formato MM:SS
	temporizador.wait_time = 1
	temporizador.start()
	temporizador.timeout.connect(_on_temporizador_timeout)

func _on_temporizador_timeout():
	tiempo_restante -= 1  # restar 1 segundo
	_actualizar_label()
	print("[DEBUG] Tiempo restante:", tiempo_restante)

	if tiempo_restante <= 0:
		temporizador.stop()
		print("[DEBUG] TimerHUD: tiempo_terminado emitido")
		emit_signal("tiempo_terminado")

# 🔹 Función para actualizar el label en formato MM:SS
func _actualizar_label():
	var minutos = int(tiempo_restante / 60)
	var segundos = tiempo_restante % 60
	tiempo_label.text = str(minutos) + ":" + str(segundos).pad_zeros(2)

	if tiempo_restante <= 0:
		temporizador.stop()
		print("[DEBUG] TimerHUD: tiempo_terminado emitido")
		emit_signal("tiempo_terminado")
