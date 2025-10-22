extends Area2D

# --- Propiedades exportables (ajustables en el Inspector) ---
@export var velocidad: float = 1200.0 # Velocidad del proyectil (ajusta para tu escopeta)
@export var dano: int = 50           # Daño que causa al enemigo (ajusta a gusto)
@export var vida_util: float = 3.0   # Segundos antes de que la bala se autodestruya
@export var es_derecha: bool = true  # Dirección: true = derecha, false = izquierda

var velocidad_movimiento: Vector2 = Vector2.ZERO
@onready var sprite = $Sprite2D  # Asume que el nodo de sprite se llama Sprite2D

func _ready():
	# 1. Conectar la señal: Detectar cuando un cuerpo (como un enemigo) entra en el área.
	body_entered.connect(_on_body_entered)
	
	# 2. Autodestruir después de 3 segundos para limpiar la escena.
	get_tree().create_timer(vida_util).timeout.connect(queue_free)
	
	# 3. Establecer la dirección de movimiento
	velocidad_movimiento.x = velocidad * (1.0 if es_derecha else -1.0)
	
	# 4. Voltear el sprite según la dirección
	if sprite:
		# Voltea si mira a la izquierda (asume que el sprite por defecto mira a la derecha)
		sprite.flip_h = !es_derecha 

func _process(delta):
	# Mover el proyectil
	global_position += velocidad_movimiento * delta

# Función que se llama al colisionar con otro cuerpo
func _on_body_entered(body):
	# 1. Identificar si es un enemigo (asegúrate de que tus enemigos estén en el grupo "Enemies")
	if body.is_in_group("Enemies") and body.has_method("recibir_danio"):
		# 2. Aplicar daño al enemigo
		body.recibir_danio(dano) 
		# 3. La bala se autodestruye al golpear
		queue_free()
	
	# Opcional: Destruir si golpea cualquier objeto estático (paredes, suelo)
	# if body is StaticBody2D or body is TileMap:
	#     queue_free()
