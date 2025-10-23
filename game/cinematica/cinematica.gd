extends CanvasLayer

@onready var video = $VideoStreamPlayer

func _ready():
	video.play()
	video.finished.connect(_on_video_finished)

func _on_video_finished():
	# Cuando termina el video, cargar el mundo o menú
	get_tree().change_scene_to_file("res://game/Tiempo/EscenarioReloj.tscn")
