shader_type canvas_item;

uniform float blur_strength : hint_range(0.0, 0.05) = 0.0;
uniform vec2 blur_direction = vec2(0.0, 0.0);
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

const int SAMPLES = 8;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec4 color = vec4(0.0);
	vec2 step_dir = blur_direction * blur_strength;

	for (int i = 0; i < SAMPLES; i++) {
		float t = float(i) / float(SAMPLES - 1) - 0.5;
		color += texture(screen_texture, uv + step_dir * t);
	}

	COLOR = color / float(SAMPLES);
}
