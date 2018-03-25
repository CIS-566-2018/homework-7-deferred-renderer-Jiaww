#version 300 es
precision highp float;

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_frame;
uniform sampler2D u_frame2; // gb0: xyz:normal, w: depth
uniform float u_Time;

uniform mat4 u_View;
uniform mat4 u_Proj;
uniform vec4 u_CamPos;   

uniform vec2 u_Resolution;

const float focalLength = 25.0;

float normpdf(in float x, in float sigma)
{
	return 0.39894*exp(-0.5*x*x/(sigma*sigma))/sigma;
}

// Interpolation between color and greyscale over time on left half of screen
void main() {
	vec3 color = texture(u_frame, fs_UV).xyz;
	float depth = texture(u_frame2, fs_UV).w;
	float focalDepth = focalLength/100.0;

	vec2 pos_NDC = vec2(fs_UV.x*2.0-1.0, fs_UV.y*2.0-1.0);
	vec4 pos_WS = inverse(u_Proj*u_View) * vec4(pos_NDC, depth, 1.0);
	pos_WS /= pos_WS.w;

	float distanceLevel = length(pos_WS.xyz - u_CamPos.xyz)/100.0;
	//declare stuff
	const int mSize = 15;
	const int kSize = (mSize-1)/2;
	float kernel[mSize];
	vec3 final_color = vec3(0.0);
	
	//create the 1-D kernel
	float sigma = abs(distanceLevel - focalDepth) * 20.0;
	float Z = 0.0;
	for (int j = 0; j <= kSize; ++j)
	{
		kernel[kSize+j] = kernel[kSize-j] = normpdf(float(j), sigma);
	}
	
	//get the normalization factor (as the gaussian has been clamped)
	for (int j = 0; j < mSize; ++j)
	{
		Z += kernel[j];
	}
	
	//read out the texels
	for (int i=-kSize; i <= kSize; ++i)
	{
		for (int j=-kSize; j <= kSize; ++j)
		{
			final_color += kernel[kSize+j]*kernel[kSize+i]*texture(u_frame, fs_UV+(vec2(float(i),float(j))) / u_Resolution.xy).rgb;

		}
	}
	
	out_Col = vec4(final_color/(Z*Z), 1.0);
	//out_Col = vec4(vec3(distanceLevel), 1.0);
}
