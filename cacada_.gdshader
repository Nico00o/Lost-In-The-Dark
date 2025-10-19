shader_type canvas_item;

uniform sampler2D tex : source_color;   // asigná la textura en shader_param
uniform float speed = 0.4;              // velocidad de desplazamiento
uniform float tile_x = 6.0;             // cuántas repeticiones horizontales (ajustar)
uniform float tile_y = 1.0;             // repeticiones verticales si querés
uniform vec2 direction = vec2(1.0, 0.0); // (1,0) derecha, (-1,0) izquierda

void fragment() {
    vec2 uv = UV;
    // Aplicar tiling (multiplica) y desplazar por el tiempo
    vec2 tiled_uv = uv * vec2(tile_x, tile_y) + direction * TIME * speed;
    // Repetir con fract para no depender de Texture Repeat
    tiled_uv = fract(tiled_uv);
    COLOR = texture(tex, tiled_uv);
}
