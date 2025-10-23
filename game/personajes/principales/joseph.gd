extends CharacterBody2D

signal vida_cambiada(nombre_personaje: String, vida_actual: int)
signal personaje_muerto(nombre_personaje: String)


@export var velocidad_mov : float = 230.0
@export var gravedad : float = 900.0
@export var fuerza_salto : float = 400.0
@export var step_height : int = 8  # altura máxima que puede subir automáticamente

@onready var animate_sprite = $AnimatedSprite2D


var velocidad_original: float = velocidad_mov
var is_invulnerable: bool = false
var is_active = false
var is_alive = true
var health = 120
var dano = 12
const max_health = 120
var is_facing_right = true 
var can_move: bool = true

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

	# 🔹 TESTEO: para probar daño manual (presionar G)
	if Input.is_action_just_pressed("golpe_test"):
		recibir_danio(20)

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

# ----------------------------
# Daño y animación de golpe
# ----------------------------
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

func aplicar_impulso(fuerza: Vector2) -> void:
	if not is_alive or not is_active:
		return

	velocity = fuerza
	move_and_slide()


# ======================================================
# 🧱 CAÍDA Y RESPAWN EN ÚLTIMO PASTO
# ======================================================

@onready var ray_suelo = $RaySuelo
@export var limite_caida_y: float = 2000.0  # altura a la que se considera que cayó
@export var dano_caida: int = 20
var ultimo_tile_pasto: Vector2 = Vector2.ZERO

func _process(delta):
	# 🔹 Detectar el último tile de pasto tocado
	if ray_suelo.is_colliding():
		var collider = ray_suelo.get_collider()
		if collider and collider is TileMap and collider.name == "Grass":
			var tilemap: TileMap = collider
			var cell = tilemap.local_to_map(ray_suelo.get_collision_point())
			var layer = 0  # Si solo hay 1 layer, lo dejamos en 0
			var tile_id = tilemap.get_cell(layer, cell)
			if tile_id != -1:  # Tile válido
				var tile_data = tilemap.tile_get_data(tile_id)
				if tile_data and tile_data.get_custom_data("tipo") == "pasto":
					var tile_center = tilemap.map_to_world(cell) + tilemap.cell_size / 2
					ultimo_tile_pasto = tilemap.to_global(tile_center)

	# 🔹 Detectar si se cayó del mapa
	if global_position.y > limite_caida_y and is_alive:
		_on_caida_fuera_del_mapa()


func _on_caida_fuera_del_mapa():
	print("☠️", name, "se cayó del escenario.")
	recibir_danio(dano_caida)

	if ultimo_tile_pasto != Vector2.ZERO:
		print("🌿 Teletransportando a último pasto:", ultimo_tile_pasto)
		global_position = ultimo_tile_pasto
	else:
		print("⚠️ No se detectó último pasto, respawn por defecto.")
		global_position = Vector2(100, 100)
