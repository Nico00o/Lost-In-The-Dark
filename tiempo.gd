extends Control

signal tiempo_terminado  # 🔔 señal personalizada

@onready var tiempo_label = $TiempoLabel
@export var tiempo_total: float = 10.0  # tiempo en segundos
var tiempo_restante: float
var terminado: bool = false

func _ready():
	tiempo_restante = tiempo_total
	# conectamos la señal a una función interna para probar
	self.connect("tiempo_terminado", Callable(self, "_on_tiempo_terminado"))

func _process(delta):
	if terminado:
		return  # si ya terminó, no seguimos
	if tiempo_restante > 0:
		tiempo_restante -= delta
	if tiempo_restante <= 0:
		tiempo_restante = 0
		terminado = true
		tiempo_label.text = "⏰ Tiempo agotado"
		emit_signal("tiempo_terminado")  # 📢 avisamos que el tiempo terminó
	else:
		tiempo_label.text = "Tiempo: " + str(int(tiempo_restante))

func _on_tiempo_terminado():
	print("💀 La señal funcionó: ¡el tiempo se acabó!")
