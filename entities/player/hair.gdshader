shader_type canvas_item;

uniform vec2 size;
//group_uniforms Points;
uniform float pointRadius;
uniform int numPoints;
uniform vec2[100] points;
uniform vec4 color : source_color;

void vertex() {

	// Called for every vertex the material is visible on.
}

uniform int scale = 100;

vec2 transformPoint(vec2 TL, vec2 point) {
	float tX = (point.x - TL.x)/size.x;
	float tY = 1.-(point.y - TL.y)/size.y;
	return vec2(tX, tY);
}

// first point is always at the center
void fragment() {
	vec2 tl = vec2(points[1].x - size.x/2., points[1].y - size.y/2.);
	//vec2 br = vec2(test[0].x + size.x/2., test[0].y + size.y/2.);
	bool found = false;
	float fRadius = pointRadius/size.x;
	vec2[100] directions;
	float[100] dist;
	float test = 999.;
	int numDirections = 0;
	float finalDistance = 0.;
	vec2 finalDirection;

	for(int i = 1; i < numPoints; i++){
		float mult = float(scale);
		vec2 reduced = vec2(round(UV.x*mult)/mult, round(UV.y*mult)/mult);
		vec2 transformed = transformPoint(tl, points[i]);
		finalDistance = distance(reduced, transformed);
		if(finalDistance < (fRadius)){
			//COLOR = vec4(UV.xy, 1.0, 1.0);
			found = true;
			directions[numDirections++] = (UV-transformed)/fRadius;
			//dist[numDirections-1] = finalDistance/fRadius;
			if (test > finalDistance/fRadius){
				test = finalDistance/fRadius;
				finalDirection = (UV-transformed)/fRadius;
				//directions[numDirections++] = (UV-transformed)/fRadius;
			}
		}
	}
	if (found){
		vec2 sum = vec2(0);
		//float distSum = 0.;
		for(int i = 0; i < numDirections; i++){
			sum += directions[i];
			//distSum += dist[i];
		}
		sum /= float(numDirections);
		//sum = finalDirection;
		//distSum /= float(numDirections);
		float z = sqrt(2. - (pow(sum.x, 2.0) + pow(sum.y, 2.0)));
		vec3 pos = vec3(sum.x, sum.y, z);
		NORMAL_MAP = normalize(pos) * 0.5 + 0.5;
		COLOR = color;
		//COLOR = vec4(test, test, test, 1.0);
		//COLOR = vec4(0.5, 0.5, 0.5, 1.0);
	} else {
		COLOR = vec4(0.0);
	}
		//COLOR = vec4(UV, 0.0, 1.0);
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
