#version 300 es
precision highp float;

// Reference: https://www.shadertoy.com/view/MdX3Dr


in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_frame;
uniform float u_Time;
uniform vec2 u_Resolution;
uniform float u_ColorHatch;

// The brightnesses at which different hatch lines appear
float hatch_1 = 0.8;
float hatch_2 = 0.6;
float hatch_3 = 0.3;
float hatch_4 = 0.15;
float hatch_5 = 0.001;

// How close together hatch lines should be placed
float density = 10.0;

// How wide hatch lines are drawn.
float width = 1.5;

// enable GREY_HATCHES for greyscale hatch lines
#define GREY_HATCHES

// enable COLOUR_HATCHES for coloured hatch lines
#define COLOUR_HATCHES

float hatch_1_brightness = 0.8;
float hatch_2_brightness = 0.6;
float hatch_3_brightness = 0.3;
float hatch_4_brightness = 0.0;

float d = 1.0; // kernel offset

float lookup(vec2 p, float dx, float dy)
{
    vec2 uv = (p.xy + vec2(dx * d, dy * d)) / u_Resolution.xy;
    vec4 c = texture(u_frame, uv.xy);
	
	// return as luma
    return 0.2126*c.r + 0.7152*c.g + 0.0722*c.b;
}

// Interpolation between color and greyscale over time on left half of screen
void main() {
	vec3 color = texture(u_frame, fs_UV).xyz;
	//
	// Inspired by the technique illustrated at
	// http://www.geeks3d.com/20110219/shader-library-crosshatching-glsl-filter/
	//
	float ratio = u_Resolution.y / u_Resolution.x;
	float coordX = fs_UV.x;
	float coordY = fs_UV.y;
	vec2 dstCoord = vec2(coordX, coordY);
	vec2 srcCoord = vec2(coordX, coordY / ratio);	
	vec2 uv = srcCoord.xy;

	vec3 res = vec3(1.0, 1.0, 1.0);
    float brightness = (0.2126*color.x) + (0.7152*color.y) + (0.0722*color.z);
	if(u_ColorHatch == 1.0){
	// check whether we have enough of a hue to warrant coloring our
	// hatch strokes.  If not, just use greyscale for our hatch color.
	float dimmestChannel = min( min( color.r, color.g ), color.b );
	float brightestChannel = max( max( color.r, color.g ), color.b );
	float delta = brightestChannel - dimmestChannel;
	if ( delta > 0.1 )
		color = color * ( 1.0 / brightestChannel );
	else
		color.rgb = vec3(1.0,1.0,1.0);
	}
  
    if (brightness < hatch_1) 
    {
		if (mod(gl_FragCoord.x + gl_FragCoord.y, density) <= width)
		{
			if(u_ColorHatch == 1.0)
				res = vec3(color.rgb * hatch_1_brightness);
			else
				res = vec3(hatch_1_brightness);
		}
    }
  
    if (brightness < hatch_2) 
    {
		if (mod(gl_FragCoord.x - gl_FragCoord.y, density) <= width)
		{
			if(u_ColorHatch == 1.0)
				res = vec3(color.rgb * hatch_2_brightness);
			else
				res = vec3(hatch_2_brightness);
		}
    }
  
    if (brightness < hatch_3) 
    {
		if (mod(gl_FragCoord.x + gl_FragCoord.y - (density*0.5), density) <= width)
		{
			if(u_ColorHatch == 1.0)
				res = vec3(color.rgb * hatch_3_brightness);
			else
				res = vec3(hatch_3_brightness);
		}
    }
  
    if (brightness < hatch_4) 
    {
		if (mod(gl_FragCoord.x - gl_FragCoord.y - (density*0.5), density) <= width)
		{
			if(u_ColorHatch == 1.0)
				res = vec3(color.rgb * hatch_4_brightness);
			else
				res = vec3(hatch_4_brightness);
		}
    }
	
	if (brightness < hatch_5) 
    {
		res = vec3(1.0);
    }

	vec2 p = gl_FragCoord.xy;
    
	// simple sobel edge detection,
	// borrowed and tweaked from jmk's "edge glow" filter, here:
	// https://www.shadertoy.com/view/Mdf3zr
    float gx = 0.0;
    gx += -1.0 * lookup(p, -1.0, -1.0);
    gx += -2.0 * lookup(p, -1.0,  0.0);
    gx += -1.0 * lookup(p, -1.0,  1.0);
    gx +=  1.0 * lookup(p,  1.0, -1.0);
    gx +=  2.0 * lookup(p,  1.0,  0.0);
    gx +=  1.0 * lookup(p,  1.0,  1.0);
    
    float gy = 0.0;
    gy += -1.0 * lookup(p, -1.0, -1.0);
    gy += -2.0 * lookup(p,  0.0, -1.0);
    gy += -1.0 * lookup(p,  1.0, -1.0);
    gy +=  1.0 * lookup(p, -1.0,  1.0);
    gy +=  2.0 * lookup(p,  0.0,  1.0);
    gy +=  1.0 * lookup(p,  1.0,  1.0);
    
	// hack: use g^2 to conceal noise in the video
    float g = gx*gx + gy*gy;
	res *= (1.0-g);
	
	out_Col = vec4(res, 1.0);
}
