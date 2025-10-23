extends Area2D

@export var velocidad: float = 800.0
@export var dano: int = 20 # Daño que inflige la bala
const VELOCIDAD_ROTACION = 1000 # Para que el sprite gire un poco

var es_derecha: bool = true # Indica la dirección inicial

func _ready():
	# Conectar la señal de colisión (el disparo impacta algo)
	body_entered.connect(_on_body_entered)
	# Voltear si dispara a la izquierda
	if not es_derecha:
		$Sprite2D.scale.x = -1 # Asumiendo que tienes un Sprite2D

func _process(delta):
	# Movimiento constante de la bala
	var direccion = 1 if es_derecha else -1
	position.x += velocidad * direccion * delta
	
	# Rotar el sprite mientras vuela (opcional)
	$Sprite2D.rotation_degrees += VELOCIDAD_ROTACION * delta


func _on_body_entered(body: Node2D):
	# 1. Chequeo de pertenencia a grupo
	if body.is_in_group("Enemies"):
		# 2. Chequeo de método y aplicación de daño
		if body.has_method("recibir_danio"):
			body.recibir_danio(dano)
			
		# 3. Eliminar la bala después del impacto
		queue_free()
