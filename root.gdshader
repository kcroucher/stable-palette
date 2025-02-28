shader_type canvas_item;

uniform sampler2D lut;
uniform float sub_table_size;
uniform float brightness_levels;
uniform vec2 mouse;
uniform int mode;

// + inside, - outside
float sdCircle( vec2 p, float r ) {
    return r - length(p);
}

void fragment() {
	// Center uv on origin
	vec2 uv = FRAGCOORD.xy * SCREEN_PIXEL_SIZE.y - 0.5;
	float lut_width = sub_table_size * sub_table_size;
	float lut_height = sub_table_size * brightness_levels;

	// Diagonal bar representing the light source + direction
	float theta = -TAU/16.0;
	mat2 rot = mat2(
		vec2(cos(theta), sin(theta)),
		vec2(-sin(theta), cos(theta))
	);
	vec2 uvrot = rot * uv + .52;
	float threshold =
		// Cut the bar along the diagonal
		step(0.3, uvrot.y) * step(uvrot.y, 0.7) *
		// Cut the bar along the axis
		step(uv.y, 0.164) * step(uv.x, 0.1);

	// Light properties
	float light_intensity_base = 0.15;
	float light_intensity_change = (sin(TIME) + 1.) / 30.;
	float light_intensity = light_intensity_base + light_intensity_change;
	vec3 light_color = vec3(1.0, 1.0, 1.0);
	vec4 light_base = vec4(light_color, light_intensity);

	// Mix light with the base texture
	vec4 light = mix(vec4(0.0), light_base, threshold);
	float light_falloff = 1.0 - smoothstep(0.2, 0.4, length(uv));
	if (mode != 0) {
		COLOR = mix(COLOR, light, light.a * light_falloff);
	}

	// Mouse
	vec2 mouse_uv = mouse * SCREEN_PIXEL_SIZE.y - 0.5;
	float radius = 0.4;
	float circle = sdCircle(mouse_uv - uv, radius);
	circle *= 1.0 / radius;
	circle *= 1.6;

	float brightness = 1.0;
	if (mode == 2) {
		brightness = clamp(circle, 0.4, 1.0);
	}

	// Snap the color to the palette
	float sub_table_size_minus = sub_table_size - 1.;
	float brightness_levels_minus = brightness_levels - 1.;
	vec2 lutUv = vec2(
		(COLOR.r * (sub_table_size_minus / lut_width))
		+ floor(COLOR.b * sub_table_size_minus) / sub_table_size,
		(COLOR.g * (sub_table_size_minus / lut_height))
		+ floor(brightness * brightness_levels_minus) / brightness_levels
	);
	COLOR = texture(lut, lutUv);
}
