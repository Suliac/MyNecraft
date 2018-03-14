#version 400

uniform mat4 mvp;
uniform mat4 m;
uniform mat4 mv;
uniform mat4 nmat;
uniform float elapsed;
uniform mat4 V_light;
uniform mat4 P_light;

layout(location=0) in vec3 vs_position_in;
layout(location=1) in vec3 vs_normal_in;
layout(location=2) in vec2 vs_uv_in;
layout(location=3) in float vs_type_in;

//Variables en sortie
out vec3 normal;
out vec4 color;
out vec2 uv;
flat out int type;
out vec4 vecIn;
out vec4 shadowCoord;

#define CUBE_HERBE 0.0
#define CUBE_TERRE 1.0
#define CUBE_PIERRE 2.0f
#define CUBE_EAU 3.0
#define CUBE_BRANCHES 4.0f
#define CUBE_TRONC 5.0f
#define CUBE_SABLE 6.0f
#define CUBE_NUAGE 7.0f

mat4 biasMatrix = mat4(
0.5, 0.0, 0.0, 0.0,
0.0, 0.5, 0.0, 0.0,
0.0, 0.0, 0.5, 0.0,
0.5, 0.5, 0.5, 1.0
);

const vec4 CubeColors[8]=vec4[8](
	vec4(0.1,0.7,0.2,1.0), //CUBE_HERBE
	vec4(0.2,0.1,0.0,1.0), //CUBE_TERRE
	vec4(0.7,0.7,0.7,1.0), //CUBE_PIERRE
	vec4(0.0,0.0,1.0,0.8), //CUBE_EAU
	vec4(0.3,0.6,0.3,1.0), //CUBE_BRANCHES
	vec4(0.2,0.1,0.0,1.0), //CUBE_TRONC
	vec4(0.7,0.7,0.0,1.0), //CUBE_SABLE
	vec4(1.0,1.0,1.0,1.0)  //CUBE_NUAGE
);

const int numberwaves = 2;

const float amplitude[numberwaves]=float[numberwaves](
	0.33,
	0.33
);

const vec2 direction[numberwaves]=vec2[numberwaves](
	vec2(1.0, 0.0),
	vec2(0.0, 1.0)
);

const float wavelength[numberwaves]=float[numberwaves](
	2.5,
	3.5
);

const float speedwave[numberwaves]=float[numberwaves](
	1.0,
	1.0
);

void main()
{
	uv = vs_uv_in;
	type = int(vs_type_in);

	vecIn = vec4(vs_position_in,1.0);

	vec4 worldPosition = m * vecIn;

	if(type == 3.0) // Si eau
	{
		for(int i=0;i<numberwaves;i++) // Essai gerstner waves
		{
			float steepness = 1.0 / (wavelength[i]/amplitude[i]);

			vecIn.y += ((steepness * amplitude[i]) * direction[i].y * cos(wavelength[i] * (dot(direction[i], worldPosition.xy)) + speedwave[i] * elapsed));
			vecIn.x += ((steepness * amplitude[i]) * direction[i].x * cos(wavelength[i] * (dot(direction[i], worldPosition.xy)) + speedwave[i] * elapsed));
			vecIn.z += ( amplitude[i] * sin(wavelength[i] * (dot(direction[i], worldPosition.xy)) + speedwave[i] * elapsed))-0.55;
			// vecIn.z += sin((worldPosition.x+worldPosition.y)/3+elapsed)/2 -0.55;
			// vecIn.y += cos(vecIn.z/3+elapsed)/2;
			// vecIn.y += cos(vecIn.x/3+elapsed)/2;
		}
	}

	gl_Position =  mvp * vecIn;

	mat4 depthMVP = P_light * V_light * m;
	mat4 biasDepthMVP = biasMatrix * depthMVP;
	shadowCoord = biasDepthMVP * vec4(vs_position_in,1.0);
			
	normal = (nmat * vec4(vs_normal_in,1.0)).xyz; 

	color = CubeColors[int(vs_type_in)];
}