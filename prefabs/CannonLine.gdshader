shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 moving_uv = vec2(UV.x-TIME, UV.y);
	// Called for every pixel the material is visible on.
	vec4 in_texture = texture(TEXTURE,moving_uv);
	COLOR = in_texture * COLOR;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
