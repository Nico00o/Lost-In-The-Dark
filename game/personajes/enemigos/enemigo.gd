extends CharacterBody2D

@export var velocidad_caza   := 120.0
@export var distancia_ataque := 40.0
@export var gravedad         := 20.0
@export var cooldown_ataque  := 1.2

@onready var sprite =  $animacion  # << cambialo si tu nodo se llama distinto

var puede_atacar: bool = true

func _physics_process(delta):
	var jugador = get_tree().get_first_node_in_group("Player")
	if not is_instance_valid(jugador):
		return

	# 1) Apuntar al jugador
	var dir_x = sign(jugador.global_position.x - global_position.x)

	# 2) Perseguir
	velocity.x = velocidad_caza * dir_x
	sprite.play("caminar")
	sprite.flip_h = dir_x < 0

	# 3) ¿Está cerca? → atacar
	if global_position.distance_to(jugador.global_position) < distancia_ataque:
		_atacar(jugador)

	# 4) Gravedad
	velocity.y += gravedad
	move_and_slide()
	velocity.y = min(velocity.y, gravedad * 3)

# -------------------------------------------------
func _atacar(jugador: Node2D):
	if not puede_atacar:
		return

	puede_atacar = false
	sprite.play("ataque")

	# Dañamos al personaje
	if jugador.has_method("recibir_danio"):
		jugador.recibir_danio(10)

	# Esperar a que termine la animación
	await sprite.animation_finished
	await get_tree().create_timer(cooldown_ataque).timeout
	puede_atacar = true
