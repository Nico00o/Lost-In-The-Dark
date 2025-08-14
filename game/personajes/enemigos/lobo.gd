extends CharacterBody2D
# Velocidad de movimiento del lobo. Puedes ajustarla en el Inspector.
@export var velocidad = 150.0

# Esta variable guardará al personaje que el lobo debe perseguir.
var objetivo: Node2D = null

# Referencia a nuestro AnimatedSprite2D.
@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta):
	# Si tenemos un objetivo (el personaje), nos movemos hacia él.
	if objetivo != null:
		# Calculamos la dirección del personaje.
		var direccion = (objetivo.global_position - global_position).normalized()
		# Asignamos la velocidad en esa dirección.
		velocity = direccion * velocidad
		
		# Ponemos la animación de correr.
		animated_sprite.play("correr")
		
		# Volteamos el sprite para que mire al personaje.
		if direccion.x > 0:
			animated_sprite.flip_h = false
		elif direccion.x < 0:
			animated_sprite.flip_h = true
	else:
		# Si no hay objetivo, el lobo se queda quieto.
		velocity = Vector2.ZERO
		# Ponemos la animación de estar quieto.
		animated_sprite.play("reposo")
		animated_sprite.flip_h = false # Opcional: no voltearlo cuando está quieto.

	# Aplicamos el movimiento y detectamos colisiones.
	move_and_slide()


# Esta función se activa cuando un objeto entra en el AreaDeAtaque.
func _on_area_de_ataque_body_entered(body: Node2D):
	# Verificamos si el objeto que entró es nuestro personaje.
	# Asegúrate de que "PersonajePrincipal" es el nombre exacto de tu nodo de personaje.
	if body.name == "joseph":
		# Si es el personaje, lo guardamos como nuestro objetivo.
		objetivo = body


# Esta función se activa cuando un objeto sale del AreaDeAtaque.
func _on_area_de_ataque_body_exited(body: Node2D):
	# Si el personaje se fue, dejamos de perseguirlo.
	if body.name == "joseph":
		objetivo = null


func _on_areataque_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_areataque_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
