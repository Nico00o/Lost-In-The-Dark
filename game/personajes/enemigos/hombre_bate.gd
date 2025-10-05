extends CharacterBody2D


var VELOCIDAD = 70
var forgod = true
var GRAVITY = 20

func _physics_process(_delta) -> void:
	
	if is_on_wall():
		forgod = not forgod
		
		
	if forgod == true:
		velocity.x = VELOCIDAD
		$animacion.play("caminar")
		$animacion.flip_h = false
		
	else:
		velocity.x = VELOCIDAD 
		$animacion.play("caminar")
		$animacion.flip_h = true
		
	velocity.y += GRAVITY
	
	move_and_slide()
	
	velocity.x = lerp(velocity.x,0, 0.2)
