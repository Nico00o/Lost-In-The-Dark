extends Node2D

@export var launch_strength := 900.0
@export var cooldown_time := 0.3

var can_bounce := true
@onready var animated_sprite := $Visual/AnimatedSprite2D
@onready var cooldown_timer := $CooldownTimer

func _ready():
	$HitArea.connect("body_entered", Callable(self, "_on_HitArea_body_entered"))
	cooldown_timer.connect("timeout", Callable(self, "_on_CooldownTimer_timeout"))

func _on_HitArea_body_entered(body):
	if not can_bounce:
		return
	
	if body.has_method("set_velocity") and body.velocity.y > 0:
		# Rebote hacia arriba
		body.velocity.y = -launch_strength
		
		# Cambiar animación a "bounce"
		if animated_sprite.animation != "bounce":
			animated_sprite.play("bounce")
		
		# Desactivar rebote momentáneamente
		can_bounce = false
		cooldown_timer.start(cooldown_time)

func _on_CooldownTimer_timeout():
	can_bounce = true
	
	# Volver a animación "idle" solo si no está rebotando
	if animated_sprite.animation == "bounce":
		animated_sprite.play("idle")
