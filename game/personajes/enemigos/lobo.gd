extends CharacterBody2D
# Velocidad de movimiento del lobo. Puedes ajustarla en el Inspector.
@export var velocidad = 150.0
# Gravedad para que el lobo caiga.
@export var gravedad = 800.0
# Distancia a la que el lobo se detendrá para no empujar al personaje.
@export var distancia_de_parada = 50.0

# Esta variable guardará al personaje que el lobo debe perseguir.
var objetivo: Node2D = null

# Referencia a nuestro AnimatedSprite2D.
@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta):
	# --- PRIMERO: Lógica de la gravedad ---
	if not is_on_floor():
		velocity.y += gravedad * delta

	# --- SEGUNDO: Lógica de la persecución ---
	if objetivo != null:
		var direccion = (objetivo.global_position - global_position)
		
		# Solo si la distancia es mayor a la distancia de parada, el lobo se mueve.
		if direccion.length() > distancia_de_parada:
			var direccion_normalizada = direccion.normalized()
			# El movimiento es solo en el eje X para que la gravedad se encargue del Y.
			velocity.x = direccion_normalizada.x * velocidad
			
			# Ponemos la animación de correr.
			animated_sprite.play("correr")
			
			# Volteamos el sprite para que mire al personaje.
			if direccion_normalizada.x > 0:
				animated_sprite.flip_h = false
			elif direccion_normalizada.x < 0:
				animated_sprite.flip_h = true
		else:
			# Si el lobo está cerca del objetivo, se detiene.
			velocity.x = 0
			# Ponemos la animación de estar quieto.
			animated_sprite.play("reposo")
	else:
		# Si no hay objetivo, el lobo se queda quieto.
		velocity.x = 0
		animated_sprite.play("reposo")
		animated_sprite.flip_h = false

	# Aplicamos el movimiento y detectamos colisiones.
	move_and_slide()


# Esta función se activa cuando un objeto entra en el AreaDeAtaque.
func _on_area_de_ataque_body_entered(body: Node2D):
	# Verificamos si el objeto que entró es nuestro personaje.
	if body.name == "PersonajePrincipal":
		objetivo = body


# Esta función se activa cuando un objeto sale del AreaDeAtaque.
func _on_area_de_ataque_body_exited(body: Node2D):
	# ¡Cuidado! Asegúrate de que el nombre esté bien escrito.
	if body.name == "PersonajePrincipal":
		objetivo = null
