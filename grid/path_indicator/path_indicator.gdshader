shader_type canvas_item;

uniform vec4 color: source_color;

void fragment() {
    vec2 uv = UV + vec2(-1.0, 0.0) * TIME;
    vec4 tex = texture(TEXTURE, uv);

    // Detect "white-ish" pixels
    float threshold = 0.9;
    float is_white = step(threshold, tex.r) * step(threshold, tex.g) * step(threshold, tex.b);

    // Apply energy/color only to white pixels
    vec3 final_rgb = mix(tex.rgb, color.rgb, is_white);

    COLOR = vec4(final_rgb, tex.a * color.a); // preserve alpha
}
//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
