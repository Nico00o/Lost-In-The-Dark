extends Node

@export var current_character: CharacterBody2D
@export var joseph: CharacterBody2D
@export var marius: CharacterBody2D
@export var camera: Camera2D

func _ready():
    # Inicialmente, solo un personaje está activo.
    joseph.is_active = true
    marius.is_active = false
    
    current_character = joseph
    
    # Conectamos la cámara al personaje activo
    if camera and current_character:
        camera.reparent(current_character)
        camera.position = Vector2(0, 0) # Centra la cámara en el personaje
        camera.position_smoothing_enabled = true
        
    # Conecta la señal de "muerte" de cada personaje.
    if joseph and not joseph.is_connected("died", Callable(self, "_on_joseph_died")):
        joseph.connect("died", Callable(self, "_on_joseph_died"))
    if marius and not marius.is_connected("died", Callable(self, "_on_marius_died")):
        marius.connect("died", Callable(self, "_on_marius_died"))

func _process(delta):
    # Si el jugador presiona un botón para cambiar de personaje.
    if Input.is_action_just_pressed("cambiar_personaje"):
        switch_character()

func switch_character():
    # Si ambos están muertos, no hagas nada
    if not joseph.is_alive and not marius.is_alive:
        return
        
    # Desactiva el personaje actual.
    if current_character:
        current_character.is_active = false
    
    # Cambia al otro personaje, si está vivo.
    if current_character == joseph and marius.is_alive:
        current_character = marius
    elif current_character == marius and joseph.is_alive:
        current_character = joseph
    
    # Activa el nuevo personaje.
    if current_character:
        current_character.is_active = true
        # Actualiza la cámara para que siga al nuevo personaje.
        if camera:
            camera.reparent(current_character)
            camera.position = Vector2(0, 0)
    
func _on_joseph_died():
    if marius.is_alive:
        print("Joseph died, switching to Marius.")
        switch_character()
    else:
        print("Game Over. Both characters are dead.")

func _on_marius_died():
    if joseph.is_alive:
        print("Marius died, switching to Joseph.")
        switch_character()
    else:
        print("Game Over. Both characters are dead.")
