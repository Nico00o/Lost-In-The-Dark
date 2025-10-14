extends CharacterBody2D

@export var velocidad: float = 150.0
@export var gravedad: float = 900.0
@export var step_height: int = 8  # altura máxima que puede subir automáticamente

var objetivo: Node2D = null
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta):
	# Aplicar gravedad
	if not is_on_floor():
		velocity.y += gravedad * delta
	else:
		velocity.y = 0

	# Movimiento horizontal hacia el objetivo
	if objetivo and objetivo.is_inside_tree():
		var direccion = (objetivo.global_position - global_position).normalized()
		velocity.x = direccion.x * velocidad

		animated_sprite.play("correr")
		animated_sprite.flip_h = direccion.x < 0
	else:
		velocity.x = 0
		animated_sprite.play("reposo")

	# Intentar moverse con auto-step
	auto_step_move()


func auto_step_move():
	var original_position = position
	move_and_slide()

	# Si está contra una pared y en el suelo → intentar "subir píxeles"
	if is_on_wall() and is_on_floor():
		for i in range(1, step_height + 1):
			position = original_position + Vector2(0, -i)  # subir i píxeles
			move_and_slide()
			if not is_on_wall():
				break


func _on_areataque_body_entered(body: Node2D) -> void:
	if body.name in ["Joseph", "Marius"]:
		objetivo = body


func _on_areataque_body_exited(body: Node2D) -> void:
	if body == objetivo:
		objetivo = null
