extends CharacterBody2D

@export var velocidad = 150.0
var objetivo: Node2D = null
@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(_delta):
	if objetivo and objetivo.is_inside_tree():
		var direccion = (objetivo.global_position - global_position).normalized()
		velocity = direccion * velocidad

		animated_sprite.play("correr")
		animated_sprite.flip_h = direccion.x < 0
	else:
		velocity = Vector2.ZERO
		animated_sprite.play("reposo")
	
	move_and_slide()

func _on_areataque_body_entered(body: Node2D) -> void:
	if body.name in ["Joseph", "Marius"]:
		objetivo = body

func _on_areataque_body_exited(body: Node2D) -> void:
	if body == objetivo:
		objetivo = null
