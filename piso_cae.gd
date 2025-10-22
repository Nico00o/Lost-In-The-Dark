extends Node2D

@export var tiempo_antes_caer: float = 1.0
@export var velocidad_caida: float = 400.0
@export var tiempo_en_el_suelo: float = 3.0
@export var reutilizable: bool = true

var timer_activado := false
var cayendo := false
var posicion_inicial: Vector2
var piso: CharacterBody2D
var colision_piso: CollisionShape2D

func _ready():
	piso = $Piso
	colision_piso = piso.get_node("CollisionShape2D")
	posicion_inicial = piso.position
	
	$Timer.one_shot = true
	$Timer.wait_time = tiempo_antes_caer
	$Timer.timeout.connect(_empezar_caida)
	$Area2D.body_entered.connect(_on_Area2D_body_entered)

func _on_Area2D_body_entered(body):
	if body.is_in_group("Player") and not timer_activado:
		print("Jugador detectado, iniciando temporizador...")
		$Timer.start()
		timer_activado = true

func _empezar_caida():
	print("¡Cayendo!")
	cayendo = true
	colision_piso.disabled = true  # 🔴 Desactiva la colisión
	await get_tree().create_timer(tiempo_en_el_suelo).timeout
	_reiniciar_plataforma()

func _physics_process(delta):
	if cayendo:
		piso.position.y += velocidad_caida * delta

func _reiniciar_plataforma():
	print("Plataforma reiniciada.")
	cayendo = false
	piso.position = posicion_inicial
	colision_piso.disabled = false  #  Reactiva la colisión
	timer_activado = false
