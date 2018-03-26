#version 300 es
precision highp float;

#define EPS 0.0001
#define PI 3.1415962

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_gb0;
uniform sampler2D u_gb1;
uniform sampler2D u_gb2;

uniform float u_Time;

uniform mat4 u_View;
uniform mat4 u_Proj;
uniform vec4 u_CamPos;   

// world space light direction
const vec3 lightDir = vec3(1, 1, 1);

void main() { 
	// read from GBuffers
	vec4 gb0 = texture(u_gb0, fs_UV);
	vec4 gb1 = texture(u_gb1, fs_UV);
	vec4 gb2 = texture(u_gb2, fs_UV);

	vec3 nor_WS = gb0.xyz;
	float depth = gb0.w;
	vec2 pos_NDC = vec2(fs_UV.x*2.0-1.0, fs_UV.y*2.0-1.0);

	vec4 pos_WS = inverse(u_Proj*u_View) * vec4(pos_NDC, depth, 1.0);
	pos_WS /= pos_WS.w;

	if(depth < 1.0){

		vec3 diffuseCol = gb2.xyz;
		vec3 specularCol = gb1.xyz;

		float lambertian = max(dot(lightDir, nor_WS), 0.0);
		float specular = 0.0;
		float ambient = 0.05;

		if(lambertian > 0.0){
			vec3 viewDir = normalize(u_CamPos.xyz - pos_WS.xyz);

			vec3 halfDir = normalize(lightDir + viewDir);
			float specAngle = max(dot(halfDir, nor_WS), 0.0);
	   		specular = pow(specAngle, 64.0*gb1.w);
		}

		vec3 col = diffuseCol * (lambertian + ambient) + specularCol * specular;

		out_Col = vec4(col, 1.0);
	}
	else{
		out_Col = vec4(0.0);
	}
	
}