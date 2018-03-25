#version 300 es
precision highp float;

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_frame;
uniform float u_Time;


//Linear
vec3 linearToneMapping(vec3 color){
	color *= 1.25;
	vec3 retColor = pow(color,vec3(1.0/2.0));
   	return retColor;
}

vec3 ReinhardToneMapping(vec3 color){
   	color *= 1.25;  // Hardcoded Exposure Adjustment
   	color = color/(vec3(1.0)+color);
   	vec3 retColor = pow(color,vec3(1.0/2.2));
   	return retColor;
}

vec3 Uncharted2Tonemap(vec3 color)
{
	color *= 16.0;
	float A = 0.15;
	float B = 0.50;
	float C = 0.10;
	float D = 0.20;
	float E = 0.02;
	float F = 0.30;
	float W = 11.2;
   	return ((color*(A*color+vec3(C*B))+vec3(D*E))/(color*(A*color+vec3(B))+vec3(D*F)))-vec3(E/F);
}

void main() {
	// TODO: proper tonemapping
	// This shader just clamps the input color to the range [0, 1]
	// and performs basic gamma correction.
	// It does not properly handle HDR values; you must implement that.

	vec3 texColor = texture(u_frame, fs_UV).xyz;
   	vec3 color = Uncharted2Tonemap(texColor);

	out_Col = vec4(color, 1.0);
}
