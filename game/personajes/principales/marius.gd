extends CharacterBody2D

signal vida_cambiada(nombre_personaje: String, vida_actual: int)



@export var velocidad_mov : float = 200.0
@export var gravedad : float = 900.0
@export var fuerza_salto : float = 400.0
@export var step_height : int = 8  # altura máxima que puede subir automáticamente


@onready var animate_sprite = $AnimatedSprite2D


var is_active = false
var is_alive = true
var health = 160
const max_health = 160
var is_facing_right = true 
var can_move: bool = true


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
	if not is_alive or not is_active:
		return

	health -= cant
	health = clamp(health, 0, max_health)

	print(name, " recibió ", cant, " de daño. Vida: ", health)

	# Emitir señal al HUD
	emit_signal("vida_cambiada", "Marius", health)

	# Congelar movimiento y mostrar animación de daño
	can_move = false
	animate_sprite.play("recibir daño")
	await animate_sprite.animation_finished
	can_move = true

	if health <= 0:
		is_alive = false
		animate_sprite.play("muerto")
		print(name, " ha muerto")
		# Podés disparar aquí un game over o cambio de personaje
