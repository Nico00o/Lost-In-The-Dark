extends Area2D
@export var dialogo : DialogueResource
var esta_cerca := false

func _on_body_entered(body):
	if body.is_in_group("Player"):
		esta_cerca = true

func _on_body_exited(body):
	if body.is_in_group("Player"):
		esta_cerca = false

func _process(delta):
	if esta_cerca and Input.is_action_just_pressed("interact"):
		DialogueManager.show_example(dialogo, "Cartel")
