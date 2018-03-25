#version 300 es
precision highp float;

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_frame;
uniform float u_Time;

// Interpolate between regular color and channel-swizzled color
// on right half of screen. Also scale color to range [0, 5].
void main() {
	vec3 color = texture(u_frame, fs_UV).xyz;
	float Exposure = 1.0;
	color *= Exposure; // Hardcode Exposure
	if (color.r > 1.0 || color.g > 1.0 || color.b > 1.0)
		out_Col = vec4(color/16.0, 1.0);
	else
		out_Col = vec4(0.0, 0.0, 0.0, 1.0);
}
