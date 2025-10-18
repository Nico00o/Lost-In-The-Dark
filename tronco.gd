extends Node2D
@onready var area_activacion = $Area
@onready var tronco = $RigidBody2D
@onready var sonido = $AudioStreamPlayer2D
@export var damage := 30
@export var delay_caida := 0.5  # segundos antes de caer

var activado := false

func _ready():
	tronco.freeze = true  # el tronco empieza congelado
	area_activacion.connect("body_entered", Callable(self, "_on_body_entered"))
	tronco.connect("body_entered", Callable(self, "_on_tronco_golpea"))

func _on_body_entered(body):
	if body.is_in_group("jugador") and not activado:
		activado = true
		await get_tree().create_timer(delay_caida).timeout
		tronco.freeze = false  # el tronco cae

func _on_tronco_golpea(body):
	if body.is_in_group("jugador"):
		if body.has_method("recibir_daño"):
			body.recibir_daño(damage)
		if sonido:
			sonido.play()
