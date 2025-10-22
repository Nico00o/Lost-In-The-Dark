extends Node2D

@onready var timer_hud = $TimerHUD/HUDControl
@onready var personajes = $PersonajesPrincipales  # o como se llame tu nodo de personajes

func _ready():
	timer_hud.connect("tiempo_terminado", Callable(self, "_on_tiempo_terminado"))

func _on_tiempo_terminado():
	print(" Tiempo terminado. Fin del juego.")
	personajes.die()  # o personajes.die() si hiciste una función así
