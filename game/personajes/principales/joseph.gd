extends CharacterBody2D 

@export var velocidad_mov : float
@onready var  animate_sprite = $AnimatedSprite2D
var is_facing_right = true 
func update_animations():
	if velocity.x:
		animate_sprite.play("caminar")
	else:
		animate_sprite.play("reposo")

func _physics_process(delta):
	move_x()
	flip()
	update_animations()
	move_and_slide()
func flip():
	if  (is_facing_right and velocity.x < 0) or (not is_facing_right and velocity.x > 0 ):
		scale.x *= -1
		is_facing_right = not is_facing_right
	
func move_x():
	var input_axis = Input .get_axis("derecha","izquerda")
	velocity.x = input_axis * velocidad_mov
