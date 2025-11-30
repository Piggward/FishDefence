shader_type canvas_item;

uniform vec4 color : source_color;
uniform sampler2D noise: repeat_enable;
uniform sampler2D screen_content: hint_screen_texture;

uniform vec2 speed = vec2(0.03, 0.07);

uniform float wave_strength = 2.0;
uniform vec2 wave_scale = vec2(1.0, 2.0);
void fragment() {
	vec2 uv = UV + speed * TIME;
    uv.x += sin(uv.y * wave_scale.y + TIME) * 0.01;
    uv.y += cos(uv.x * wave_scale.x + TIME) * 0.01;
	vec2 noise_2 = texture (noise, uv).rg;

	COLOR *= vec4(color.r, color.g, color.b, 1) + vec4(noise_2.x, noise_2.y, 1, 1);
	COLOR.a *= 0.25;
	//COLOR *= texture(screen_content, SCREEN_UV + noise_2 * (wave_strength / 100.0));
}