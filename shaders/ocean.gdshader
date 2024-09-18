shader_type spatial;
uniform vec4 ocean_base_color = vec4(0.0, 0.5, 1.0, 1.0);  // Azul océano
uniform float wave_amplitude : hint_range(0.2, 1.5) = 0.5;   // Altura máxima de la ola
uniform float wave_speed : hint_range(0.2, 2.5) = 0.8;       // Velocidad de las olas
uniform float beer_factor : hint_range(0.0, 0.5) = 0.02;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;

float generateOffset(float x, float z, float val1, float val2, float time){
	float radiansX = ((mod(x + z * x * val1, wave_amplitude) / wave_amplitude) + (time * wave_speed) * mod(x * 0.8 +z, 1.5)) * 2.0 * 3.14;
	float radiansZ = ((mod(val2 * (z * x + z * x), wave_amplitude) / wave_amplitude) + (time * wave_speed) * 2.0 * mod(x,2.0)) * 2.0 * 3.14;
	return wave_amplitude * 0.5 * (sin(radiansZ) + cos(radiansX));	
}

vec3 applyDistorsion(vec3 vertex, float time){
	float xd = generateOffset(vertex.x, vertex.z, 0.2, 0.1, time);
	float yd = generateOffset(vertex.x, vertex.z, 0.1, 0.3, time);
	float zd = generateOffset(vertex.x, vertex.z, 0.15, 0.2, time);
	return vertex + vec3(xd, yd, zd);
}

void vertex() {
	VERTEX = applyDistorsion(VERTEX, TIME * 0.1);
}

void fragment() {
	NORMAL = normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));
	METALLIC = 0.6;
	SPECULAR = 0.5;
	ROUGHNESS = 0.2;
    ALBEDO = ocean_base_color.rgb;
	// Coordenadas de textura del fragmento (UV)
    vec2 uv = UV;
    // Leer la profundidad desde la textura
    float depth = texture(DEPTH_TEXTURE, uv).r;
    // Aplicar el factor de Beer
    float transparency = exp(-beer_factor * depth);
    // Ajustar el color y la transparencia
    vec3 color = ocean_base_color.rgb;
    ALBEDO = color;
    ALPHA = transparency;
}
