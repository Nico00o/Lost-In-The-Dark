extends Area2D

<<<<<<< HEAD

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
=======
@export var damage: int = 10          # daño por golpe
@export var interval: float = 1.0     # cada cuánto vuelve a dañar (segundos)
@export var single_use: bool = false  # si se destruye después de dañar

var player_in_area: bool = false
var used: bool = false
var target = null

var timer: Timer

func _ready():
	timer = Timer.new()
	timer.wait_time = interval
	timer.one_shot = false
	timer.autostart = false
	add_child(timer)
	timer.connect("timeout", Callable(self, "_on_timeout_damage"))
	
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	if used and single_use:
		return
	
	# Si el cuerpo tiene la función recibir_danio, se guarda y se daña
	if body.has_method("recibir_danio"):
		target = body
		player_in_area = true
		body.recibir_danio(damage)   # daño instantáneo al entrar
		timer.start()                # daño repetido
		print(" daño aplicado a:", body.name)

func _on_body_exited(body):
	if body == target:
		player_in_area = false
		timer.stop()
		target = null

func _on_timeout_damage():
	if not player_in_area or target == null:
		timer.stop()
		return
	
	if target and target.has_method("recibir_danio"):
		target.recibir_danio(damage)
		print(" daño continuo:", damage)
		
		if single_use:
			used = true
			timer.stop()
			queue_free()
>>>>>>> afd510cf09bec5630f4ccaddd089e7db161252ca
