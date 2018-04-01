#version 400

uniform mat4 m;
uniform mat4 mv;
uniform mat4 mvp;
uniform mat4 nmat;
uniform float elapsed;
uniform float water_height;
uniform mat4 V_light;
uniform mat4 P_light;
uniform vec3 camPos;

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

// reflexion
out vec4 waterTex1;
out vec4 waterTex2;
out vec4 waterTex3;
out vec4 waterTex4;

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
	0.1,
	0.15
);

const vec2 direction[numberwaves]=vec2[numberwaves](
	vec2(1.0, 0.0),
	vec2(0.71, 0.71)
);

const float wavelength[numberwaves]=float[numberwaves](
	2.5,
	3.5
);

const float speedwave[numberwaves]=float[numberwaves](
	1.0,
	2.5
);

void main()
{
	uv = vs_uv_in;
	type = int(vs_type_in);

	vecIn = vec4(vs_position_in,1.0);
	vec4 normIn = vec4(vs_normal_in, 1.0);

	vec4 worldPosition = m * vecIn;

 	//////////////// Essai gerstner waves
	if(type == 3.0) // Si eau
	{
		vecIn.z = water_height;
		normIn.z = 1.0;
		for(int i=0;i<numberwaves;i++)
		{
			float steepness = 1.0 / (wavelength[i]/amplitude[i]);

			vecIn.x += ((steepness * amplitude[i]) * direction[i].x * cos(wavelength[i] * (dot(direction[i], worldPosition.xy)) + speedwave[i] * elapsed));
			vecIn.y += ((steepness * amplitude[i]) * direction[i].y * cos(wavelength[i] * (dot(direction[i], worldPosition.xy)) + speedwave[i] * elapsed));
			vecIn.z += ( amplitude[i] * sin(wavelength[i] * (dot(direction[i], worldPosition.xy)) + speedwave[i] * elapsed));

			normIn.x -= (direction[i].x * (wavelength[i] * amplitude[i]) * (cos(wavelength[i] * (dot(direction[i], vecIn.xy)) + speedwave[i] * elapsed)));
			normIn.y -= (direction[i].y * (wavelength[i] * amplitude[i]) * (cos(wavelength[i] * (dot(direction[i], vecIn.xy)) + speedwave[i] * elapsed)));
			normIn.z -= steepness * wavelength[i] * amplitude[i] * sin(wavelength[i] * (dot(direction[i], vecIn.xy)) + speedwave[i] * elapsed);
		}
	}

	///////////////////////////////////////////////
	// Round world
	vec4 worldSpacePos = m * vecIn;
	worldSpacePos.xyz -= camPos.xyz; 
	// worldSpacePos = vec4( 0.0, 0.0, ((worldSpacePos.x * worldSpacePos.x) + (worldSpacePos.y * worldSpacePos.y))* - 0.001, 0.0);

	// vecIn +=  worldSpacePos;

	////////////////////////////////////////////////
	// Calcul shadow coord
	mat4 depthMVP = P_light * V_light * m;
	mat4 biasDepthMVP = biasMatrix * depthMVP;
	shadowCoord = biasDepthMVP * (vec4(vs_position_in,1.0));
			
	normal = (nmat * normIn).xyz; 

	color = CubeColors[int(vs_type_in)];

	////////////////////////////////////////////////
	// Reflexion
	gl_ClipDistance[0] = -dot(m * vecIn, vec4(0, 0, -1, water_height));
	
	vec4 tangent = vec4(1.0, 0.0, 0.0, 0.0);
    vec4 norm = vec4(0.0, 1.0, 0.0, 0.0);
    vec4 binormal = vec4(0.0, 0.0, 1.0, 0.0);

	vec4 temp = m *vec4(camPos, 1.0) - m *vecIn;
    waterTex4.x = dot(temp, tangent);
    waterTex4.y = dot(temp, binormal);
    waterTex4.z = dot(temp, norm);
    waterTex4.w = 0.0;

	waterTex3 = mvp * vecIn *vec4(1.0, -1.0, 1.0, 1.0);

	// vec4 t1 = vec4(0.0, -time, 0.0,0.0);
    // vec4 t2 = vec4(0.0, -time2, 0.0,0.0);    

    // waterTex1 = gl_MultiTexCoord0 + t1;
    // waterTex2 = gl_MultiTexCoord0 + t2;
  
    // waterTex3 = mpos;
	////////////////////////////////////////////////
	gl_Position =  mvp * vecIn;
}