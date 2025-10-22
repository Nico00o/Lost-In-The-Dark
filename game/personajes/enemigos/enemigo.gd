extends CharacterBody2D

# --- parámetros exportables (ajustalos en el Inspector) ---
@export var velocidad_caza: float = 120.0
@export var dano: int = 20
@export var gravedad: float = 900.0
@export var cooldown_ataque: float = 1.2
@export var vida_maxima: int = 100

# --- nodos ---$animacion
@onready var sprite: AnimatedSprite2D = $animacion
@onready var detector: Area2D = $Detector
@onready var attack_area: Area2D = $AttackArea
@onready var health_bar: ProgressBar = $HealthBar

# estado
var vida_actual: int 
var is_alive: bool = true
var objetivo: CharacterBody2D = null
var puede_atacar: bool = true
var persiguiendo: bool = false

func _ready():
	# conectar señales del detector y del attack_area
	detector.body_entered.connect(_on_detector_entered)
	detector.body_exited.connect(_on_detector_exited)
	attack_area.body_entered.connect(_on_attack_area_entered)
	attack_area.body_exited.connect(_on_attack_area_exited)
	vida_actual = vida_maxima
	_actualizar_barra_vida() # Inicializa la barra (generalmente oculta)
	# ...
	

func _physics_process(delta):
	# gravedad
	if not is_on_floor():
		velocity.y += gravedad * delta
	else:
		velocity.y = 0

	# si no hay objetivo o el objetivo no está válido, no hacemos nada
	if not objetivo or not is_instance_valid(objetivo) or not objetivo.is_alive:
		if not persiguiendo:
			sprite.play("reposo")
			velocity.x = 0
		move_and_slide()
		return

	# si estamos en el area de ataque, dejamos movimiento a 0 (ataque manejado por señal)
	if _is_in_attack_area():
		velocity.x = 0
		move_and_slide()
		return

	# perseguir objetivo
	var dir = sign(objetivo.global_position.x - global_position.x)
	velocity.x = dir * velocidad_caza
	sprite.flip_h = dir < 0
	sprite.play("caminar")

	move_and_slide()

# ---- DETECCIÓN por Area2D ----
func _on_detector_entered(body):
	# consideramos objetivo sólo a personajes (y activos)
	if body.is_in_group("Player") and body.has_method("recibir_danio") and body.is_active and body.is_alive:
		objetivo = body
		persiguiendo = true
		# debug
		# print("Enemigo: objetivo adquirido -> ", body.name)

func _on_detector_exited(body):
	if body == objetivo:
		# si sale del detector, dejamos de perseguirlo
		objetivo = null
		persiguiendo = false
		sprite.play("reposo")

# ---- ATAQUE por Area2D (contacto cercano) ----
func _on_attack_area_entered(body):
	# ataca sólo al personaje activo
	if not body.is_in_group("Player"):
		return
	if not body.has_method("recibir_danio") or not ("is_active" in body and body.is_active):
		return
	if not body.is_alive:
		return

	# Parar y atacar
	velocity.x = 0
	_atacar(body)

func _on_attack_area_exited(body):
	if body.is_in_group("Player"):
		puede_atacar = true
		sprite.play("reposo")

# ---- lógica de ataque ----
func _atacar(jugador):
	if not puede_atacar:
		return

	puede_atacar = false
	sprite.play("ataque")

	# Esperar hasta el frame del golpe (ajustá si tu animación tarda más o menos)
	# 🔹 Podés usar la duración de la animación para más precisión:
	# var tiempo_golpe = sprite.get_animation_length("ataque") * 0.3 # ej. al 30% del ataque
	await get_tree().create_timer(0.4).timeout

	# 🔹 Aplicar daño: Chequea si el jugador sigue activo y en el área
	if jugador and is_instance_valid(jugador) and jugador.is_alive and jugador.is_active:
		var cuerpos = attack_area.get_overlapping_bodies()
		if cuerpos.has(jugador):
			if jugador.has_method("recibir_danio"):
				# Usamos la variable 'dano' exportada del enemigo
				jugador.recibir_danio(dano) 

	# 🔹 Esperar a que termine la animación
	await sprite.animation_finished

	# 🔹 Cooldown entre ataques
	await get_tree().create_timer(cooldown_ataque).timeout

	# 🔹 Una vez que termina el cooldown, se vuelve a habilitar el ataque.
	# Esto no significa que atacará inmediatamente, sino que está listo para atacar.
	puede_atacar = true
	
	# 🔹 Nuevo: Si el jugador sigue dentro del área después del cooldown, intenta atacar de nuevo
	if attack_area.get_overlapping_bodies().has(jugador):
		_atacar(jugador)
	else:
		# Si ya no está en el área, vuelve a reposo
		sprite.play("reposo")

# helper: chequea si el objetivo actual está dentro del area de ataque
func _is_in_attack_area() -> bool:
	for b in attack_area.get_overlapping_bodies():
		if b == objetivo:
			return true
	return false
func recibir_danio(cant: int):
	if not is_alive:
		return

	vida_actual -= cant
	vida_actual = clamp(vida_actual, 0, vida_maxima)

	print(name, " recibió ", cant, " de daño. Vida: ", vida_actual)

	_actualizar_barra_vida()

	if vida_actual <= 0:
		_morir()

func _actualizar_barra_vida():
	if health_bar:
	# 1. Calcula el porcentaje (de 0 a 1)
		var porcentaje = float(vida_actual) / float(vida_maxima)
		health_bar.value = porcentaje

	# 2. Muestra la barra si la vida no está completa, o si ya no está muerto
	health_bar.visible = vida_actual < vida_maxima and is_alive


func _morir():
	is_alive = false
	velocity.x = 0
	puede_atacar = false 

	# 1. Asegurarse de que la barra se muestre vacía (o se oculte)
	_actualizar_barra_vida() 
	health_bar.visible = false

	# 2. Animación de muerte 
	sprite.play("muerto")

	# 3. Desactivar colisiones (para que el jugador no choque con el cadáver)
	set_collision_mask_value(1, false) 
	# Desactivar detector y ataque
	detector.monitoring = false
	attack_area.monitoring = false
	await sprite.animation_finished

# 4. Esperar a que termine la animación

	
	queue_free()
