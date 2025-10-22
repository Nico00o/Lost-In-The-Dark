extends CharacterBody2D
const Proyectil = preload("res://bala.tscn")
signal vida_cambiada(nombre_personaje: String, vida_actual: int)
signal personaje_muerto(nombre_personaje: String)


@export var velocidad_mov : float = 200.0
@export var gravedad : float = 900.0
@export var fuerza_salto : float = 400.0
@export var step_height : int = 8  # altura máxima que puede subir automáticamente
@export var punto_disparo: Vector2 = Vector2(40, -10) 
@export var cooldown_disparo: float = 0.4

@onready var animate_sprite = $AnimatedSprite2D


var velocidad_original: float = velocidad_mov
var is_invulnerable: bool = false
var is_active = false
var is_alive = true
var health = 160
var dano = 10
const max_health = 160
var is_facing_right = true 
var can_move: bool = true
var puede_disparar: bool = true

func curar_hp(cantidad: int):
	health = min(max_health, health + cantidad)
	emit_signal("vida_cambiada", name, health)
	print(name, "recibió curación de", cantidad, "HP. Vida:", health)


func update_animations():
	if not can_move:
		animate_sprite.play("reposo")
		return
	
	if velocity.x != 0:
		animate_sprite.play("caminar")
	else:
		animate_sprite.play("reposo")


func _physics_process(delta):
	
	if not is_active or not is_alive or not can_move:
		return
	# Aplicar gravedad
	if not is_on_floor():
		velocity.y += gravedad * delta
	else:
		velocity.y = 0

	move_x()
	saltar()
	flip()

	# Intentar moverse con auto-step
	auto_step_move(delta)

	update_animations()

func auto_step_move(_delta):
	var original_position = position
	move_and_slide()

	if is_on_wall() and is_on_floor():
		for i in range(1, step_height + 1):
			position = original_position + Vector2(0, -i)  # Subir i px
			move_and_slide()
			if not is_on_wall():
				break

func flip():
	if (is_facing_right and velocity.x < 0) or (not is_facing_right and velocity.x > 0):
		scale.x *= -1
		is_facing_right = not is_facing_right

func move_x():
	var input_axis = Input.get_axis("izquierda", "derecha")
	velocity.x = input_axis * velocidad_mov

func saltar():
	if Input.is_action_just_pressed("saltar") and is_on_floor():
		velocity.y = -fuerza_salto
# Daño y animación de golpe
func recibir_danio(cant: int):
	if not is_alive or not is_active or is_invulnerable:
		if is_invulnerable:
			print(name, "está protegido por la Máscara del Olvido, no recibe daño")
		return

	health -= cant
	health = clamp(health, 0, max_health)
	print(name, "recibió", cant, "de daño. Vida:", health)
	emit_signal("vida_cambiada", name, health)

	can_move = false
	animate_sprite.play("recibir daño")
	await animate_sprite.animation_finished
	can_move = true

	if health <= 0:
		is_alive = false
		animate_sprite.play("muerto")
		print(name, "ha muerto")
		emit_signal("personaje_muerto", name)



func revivir(valor_hp: int = -1):
	if is_alive:
		return  # Ya está vivo
	
	is_alive = true
	if valor_hp <= 0:
		# Valor por defecto: 50% de HP
		health = int(max_health * 0.5)
	else:
		health = clamp(valor_hp, 0, max_health)

	can_move = true
	animate_sprite.play("reposo")  # Animación de revivir
	print(name, "ha sido revivido con", health, "HP")
	emit_signal("vida_cambiada", name, health)

		# Podés disparar aquí un game over o cambio de personaje
<<<<<<< HEAD
func _disparar():
		if not is_active or not is_alive or not puede_disparar:
			return

		# 1. Iniciar Cooldown
		puede_disparar = false

		# 2. Animación de disparo y bloquear movimiento temporalmente
		can_move = false
		animate_sprite.play("disparo")

		# 3. Instanciar el proyectil
		var proyectil_instance = Proyectil.instantiate()

		# 4. Calcular la posición y dirección (usando scale.x para reflejar la posición si está volteado)
		var offset_x = punto_disparo.x * scale.x 
		var spawn_pos = global_position + Vector2(offset_x, punto_disparo.y)

		proyectil_instance.global_position = spawn_pos
		# La dirección depende de si el sprite está volteado (scale.x > 0) o no
		proyectil_instance.es_derecha = is_facing_right

		# 5. Añadir al árbol de la escena (IMPORTANTE: Se añade al padre de Joseph/Marius, que es PersonajesPrincipales)
		get_parent().add_child(proyectil_instance)

		# 6. Esperar a que termine la animación de disparo
		await animate_sprite.animation_finished

		# 7. Volver al estado normal y desbloquear movimiento
		can_move = true
		update_animations() 

		# 8. Esperar el cooldown del disparo
		await get_tree().create_timer(cooldown_disparo).timeout
		puede_disparar = true
func _process(_delta):
	if not is_active or not is_alive:
		return
		
	# 🔹 Llama a la función de disparo
	if Input.is_action_just_pressed("disparar"):
		_disparar()
=======

func aplicar_impulso(fuerza: Vector2) -> void:
	if not is_alive or not is_active:
		return

	velocity = fuerza
	move_and_slide()
>>>>>>> d0841fa3aa1883a7d2d6b8eeee3ec6506ecb4e9e
