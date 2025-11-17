shader_type canvas_item; // for 2D — use 'spatial' for 3D materials

uniform float wave_speed : hint_range(0.0, 10.0) = 1.0;
uniform float wave_strength : hint_range(0.0, 0.1) = 0.02;
uniform vec2 speed = vec2(0.02, 0.07);
uniform vec2 wave_scale = vec2(4.0, 4.0);
uniform sampler2D noise_tex : source_color; // optional noise texture
uniform sampler2D screen_content: hint_screen_texture;
uniform vec4 color : source_color;
void fragment() {
    // Time-based offset
    float t = TIME * wave_speed;

    // Create simple sine-based wave distortion
    vec2 uv = UV + speed * TIME;
    uv.x += sin(uv.y * wave_scale.y + t) * wave_strength;
    uv.y += cos(uv.x * wave_scale.x + t) * wave_strength;

    // Optional noise for extra subtle motion
    if (textureSize(noise_tex, 0).x > 0) {
        vec2 noise = texture(noise_tex, UV * wave_scale * 0.2 + vec2(t * 0.05)).rg - 0.5;
        uv += noise * wave_strength;
    }
    // Clamp to valid range to avoid wrapping artifacts
    uv = clamp(uv, vec2(0.0), vec2(1.0));

    // Sample distorted screen content
    vec4 screen_col = texture(screen_content, uv);

    // Tint or adjust final color
    COLOR = screen_col * color;
}