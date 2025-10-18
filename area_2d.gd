extends Area2D

@export var damage: int = 10          # daño por golpe
@export var interval: float = 1.0     # cada cuánto vuelve a dañar (segundos)
@export var single_use: bool = false  # si se destruye después de dañar

var player_in_area: bool = false
var used: bool = false
var target = null

var timer: Timer

func _ready():
	timer = Timer.new()
	timer.wait_time = interval
	timer.one_shot = false
	timer.autostart = false
	add_child(timer)
	timer.connect("timeout", Callable(self, "_on_timeout_damage"))
	
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	if used and single_use:
		return
	
	# Si el cuerpo tiene la función recibir_danio, se guarda y se daña
	if body.has_method("recibir_danio"):
		target = body
		player_in_area = true
		body.recibir_danio(damage)   # daño instantáneo al entrar
		timer.start()                # daño repetido
		print(" daño aplicado a:", body.name)

func _on_body_exited(body):
	if body == target:
		player_in_area = false
		timer.stop()
		target = null

func _on_timeout_damage():
	if not player_in_area or target == null:
		timer.stop()
		return
	
	if target and target.has_method("recibir_danio"):
		target.recibir_danio(damage)
		print(" daño continuo:", damage)
		
		if single_use:
			used = true
			timer.stop()
			queue_free()
