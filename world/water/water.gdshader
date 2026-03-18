shader_type spatial;

render_mode unshaded;

uniform float slide_speed = 0.05;
uniform float wobble_speed = 0.5;
uniform float wobble_intensity = 0.05;
uniform float shuffle_intensity = 1.0;
uniform sampler2D water : repeat_enable;

void vertex() {

	VERTEX.y += sin(TIME * wobble_speed) * 0.5 + 0.5;
}

void fragment() {
	
	vec3 pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz * 0.1;

	ALBEDO = texture(
		water,
		vec2(
			(pos.x + sin(TIME * wobble_speed + pos.x * shuffle_intensity) * wobble_intensity + TIME * slide_speed),
			(pos.z + cos(TIME * wobble_speed * 0.5) * wobble_intensity) * 2.0
		)
	).xyz;
	ALPHA = 0.7;
}