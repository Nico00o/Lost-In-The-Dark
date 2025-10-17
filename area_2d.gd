extends Area2D


@export var damage := 20
@export var tiempo_activado := 2.0
@export var tiempo_desactivado := 2.0

@onready var anim = $"../AnimationPlayer"
@onready var colision = $CollisionShape2D

var activa := false

func _ready():
	colision.disabled = true
	anim.play("desactivar")
	_loop_trampa()
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if activa and body.is_in_group("jugador"):
		if body.has_method("recibir_daño"):
			body.recibir_daño(damage)

func _loop_trampa():
	await get_tree().create_timer(tiempo_desactivado).timeout
	anim.play("activar")
	colision.disabled = false
	activa = true

	await get_tree().create_timer(tiempo_activado).timeout
	anim.play("desactivar")
	colision.disabled = true
	activa = false

	_loop_trampa() # se repite indefinidamente
