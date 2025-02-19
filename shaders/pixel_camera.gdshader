shader_type canvas_item;
uniform highp vec2 cam_position;
uniform vec2 cam_offset = vec2(0.0, 0.0);

void vertex() {
	highp float roundX = round(cam_position.x);
	highp float roundY = round(cam_position.y);
	highp vec2 subpixel = vec2(roundX-cam_position.x, roundY-cam_position.y);
	//VERTEX += length(subpixel) < 0.001 ? vec2(0) : subpixel;
	VERTEX += cam_offset;
}

//void fragment() {
	//highp float roundX = round(cam_position.x);
	//highp float roundY = round(cam_position.y);
	//highp vec2 subpixel = vec2(roundX-cam_position.x, roundY-cam_position.y);
	////COLOR.rgb = vec3(abs(subpixel - cam_offset), 0.);
//}
