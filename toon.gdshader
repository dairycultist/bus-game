shader_type spatial;
render_mode unshaded;

uniform sampler2D tex : source_color;

void fragment() {
	ALBEDO = texture(tex, UV).rgb;
}

