extends Area2D

@onready var exclamation_mark = $ExclamationMark
const CARTEL = preload("res://game/Dialogo/Cartel.dialogue")
var is_player_close = false
var is_dialogue_active = false

func _ready():
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func _process(delta):
	if is_player_close and Input.is_action_just_pressed("interact") and not is_dialogue_active:
		DialogueManager.show_dialogue_balloon(CARTEL, "start")

func _on_area_entered(area):
	exclamation_mark.visible = true
	is_player_close = true

func _on_area_exited(area):
	exclamation_mark.visible = false
	is_player_close = false

func _on_dialogue_started(dialogue):
	is_dialogue_active = true

func _on_dialogue_ended(dialogue):
	is_dialogue_active = false
	await get_tree().create_timer(0.2).timeout
