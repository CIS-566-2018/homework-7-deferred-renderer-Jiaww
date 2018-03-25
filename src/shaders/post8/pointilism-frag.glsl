#version 300 es
precision highp float;

// Reference: https://www.shadertoy.com/view/MdX3Dr


in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_frame;
uniform float u_Time;
uniform vec2 u_Resolution;

float r(float n)
{
 	return fract(cos(n*89.42)*343.42);
}

float rand2(vec2 n)
{
 	return (r(n.x*23.62-300.0+n.y*34.35)+r(n.x*45.13+256.0+n.y*38.89))/2.0; 
}

// Interpolation between color and greyscale over time on left half of screen
void main() {
	vec3 color = texture(u_frame, fs_UV).xyz;

	vec3 res = vec3(1.0, 1.0, 1.0);

    float brightness = (0.2126*color.x) + (0.7152*color.y) + (0.0722*color.z);
	
	if (rand2(fs_UV) > brightness)
		res = vec3(0.2,0.2,0.2) * brightness;
	out_Col = vec4(res, 1.0);
}
