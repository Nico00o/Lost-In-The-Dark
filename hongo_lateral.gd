# HongoRobusto.gd
extends Node2D

@export var fuerza_impulso: Vector2 = Vector2(36000, -800)
@export var direccion: String = "derecha" # "derecha" o "izquierda"
@export var tiempo_reset: float = 0.4
@export var suavizado: float = 0.1

# nodos
var anim: AnimatedSprite2D = null
var hitbox: Area2D = null
var timer: Timer = null

# Diccionario para guardar los empujes activos
var empujes: Dictionary = {}

func _ready() -> void:
	# Encontrar AnimatedSprite2D
	anim = get_node_or_null("SpriteHolder/AnimatedSprite2D")
	if not anim:
		anim = get_node_or_null("AnimatedSprite2D")
	if not anim:
		for c in get_children():
			if c is AnimatedSprite2D:
				anim = c
				break

	# Encontrar Area2D 'Hit'
	hitbox = get_node_or_null("Hit")
	if not hitbox:
		for c in get_children():
			if c is Area2D:
				hitbox = c
				break

	# Encontrar Timer o crear uno
	timer = get_node_or_null("Timer")
	if not timer:
		timer = Timer.new()
		add_child(timer)

	timer.one_shot = true
	timer.wait_time = tiempo_reset
	if not timer.is_connected("timeout", Callable(self, "_on_reset")):
		timer.timeout.connect(Callable(self, "_on_reset"))

	# Conectar señal del hitbox
	if hitbox:
		var body_entered_callable := Callable(self, "_on_Hit_body_entered")
		if not hitbox.is_connected("body_entered", body_entered_callable):
			hitbox.body_entered.connect(body_entered_callable)
		print("[Hongo] Hit conectado:", hitbox.name)
	else:
		push_error("[Hongo] NO se encontró Area2D 'Hit' ni Area2D hijo.")

	# Animación inicial
	if anim and anim.sprite_frames.has_animation("reposo"):
		anim.play("reposo")

	print("[Hongo] listo. anim:", anim, " timer:", timer, " fuerza:", fuerza_impulso, " dir:", direccion)

func _body_is_player(body) -> bool:
	for g in body.get_groups():
		if str(g).to_lower() == "player":
			return true
	return false

func _physics_process(delta):
	# Recorre todos los cuerpos que están siendo empujados
	for body in empujes.keys():
		if not is_instance_valid(body):
			empujes.erase(body)
			continue

		var data = empujes[body]
		data.tiempo -= delta

		# Aplica impulso progresivo
		var factor = 2 * delta  # control de suavidad: bajalo = más lento
		body.velocity = body.velocity.lerp(data.objetivo, factor)

		# Para CharacterBody2D se debe mover
		if body.has_method("move_and_slide"):
			body.move_and_slide()

		if data.tiempo <= 0:
			empujes.erase(body)
		else:
			empujes[body] = data

func _on_Hit_body_entered(body):
	if not _body_is_player(body):
		return

	# Calcula impulso según dirección
	var impulso = fuerza_impulso
	impulso.x = -abs(fuerza_impulso.x) if direccion == "izquierda" else abs(fuerza_impulso.x)
	impulso.y = fuerza_impulso.y

	if body is CharacterBody2D:
		# Guardamos para empuje progresivo
		empujes[body] = {
			"objetivo": impulso,
			"tiempo": 0.5  # duración del empuje suave
		}
		print("[Hongo] Empuje activado:", impulso)
	else:
		print("[Hongo] Tipo no compatible:", typeof(body))

	# Animación del hongo
	if anim and anim.sprite_frames.has_animation("salto"):
		anim.play("salto", true)  # reinicia siempre

	if timer:
		timer.stop()
		timer.start()

func _on_reset() -> void:
	if anim and anim.sprite_frames.has_animation("reposo"):
		anim.play("reposo")
	if timer:
		timer.stop()
