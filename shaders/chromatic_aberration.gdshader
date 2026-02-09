shader_type canvas_item;

uniform float intensity : hint_range(0.0, 0.02) = 0.005;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 center = vec2(0.5);
	vec2 dir = uv - center;
	float dist = length(dir);

	float offset = dist * intensity;

	float r = texture(screen_texture, uv + dir * offset).r;
	float g = texture(screen_texture, uv).g;
	float b = texture(screen_texture, uv - dir * offset).b;

	COLOR = vec4(r, g, b, 1.0);
}
