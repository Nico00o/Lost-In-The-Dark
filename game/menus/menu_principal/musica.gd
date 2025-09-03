extends HSlider

@export var audio_bus_name: String

var audio_bus_id

func _ready():
	audio_bus_id = AudioServer.get_bus_index(audio_bus_name)

func _on_value_changed(nuevo_valor: float) -> void:
	var db = linear_to_db(nuevo_valor)
	AudioServer.set_bus_volume_db(audio_bus_id, db)
