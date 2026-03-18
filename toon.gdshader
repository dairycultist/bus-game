shader_type spatial;

uniform sampler2D tex : source_color;
uniform vec3 shadow : source_color;

void fragment() {
	ALBEDO = texture(tex, UV).rgb;
}

void light() {
	float fac = step(0.0, dot(NORMAL, LIGHT));
	DIFFUSE_LIGHT += fac * ATTENUATION * LIGHT_COLOR / PI;
	DIFFUSE_LIGHT += shadow * (1.0 - fac) * ATTENUATION * LIGHT_COLOR / PI;
}

