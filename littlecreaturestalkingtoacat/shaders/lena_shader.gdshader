shader_type spatial;

uniform sampler2D color;
uniform sampler2D face;
uniform sampler2D curve;

void vertex() {
}

void fragment() {
	vec3 base_color = texture(color, UV).xyz * 0.999;
	vec3 new_color = vec3(
		texture(curve, vec2(base_color.x, 0.0)).x,
		texture(curve, vec2(base_color.y, 0.0)).y,
		texture(curve, vec2(base_color.z, 0.0)).z
	);	
	
	//LIGHT_VERTEX = vec3(0.0);
	
	ALBEDO = new_color;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
