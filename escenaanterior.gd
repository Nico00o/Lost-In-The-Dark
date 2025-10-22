extends Node

var ultima_escena_path: String = ""

func cambiar_escena(path: String):
#Guardamos la escena actual por su path
	if get_tree().current_scene:
		ultima_escena_path = get_tree().current_scene.filename
		get_tree().change_scene_to_file(path)

func volver_escena():
	if ultima_escena_path != "":
		get_tree().change_scene_to_file(ultima_escena_path)
