#version 400

//Variables en entree
in vec3 normal;
in vec4 color;
in vec2 uv;
in vec4 vecIn;
flat in int type;
in vec4 shadowCoord;

out vec4 color_out;

#define CUBE_HERBE 0.0
#define CUBE_TERRE 1.0
#define CUBE_PIERRE 2.0f
#define CUBE_EAU 3.0
#define CUBE_BRANCHES 4.0f
#define CUBE_TRONC 5.0f
#define CUBE_SABLE 6.0f
#define CUBE_NUAGE 7.0f

uniform vec3 lightDir;

uniform sampler2D TexCustom_0;
uniform sampler2D TexCustom_1;
uniform sampler2D TexCustom_2;
uniform sampler2D TexShadow;

// Reflexion
uniform sampler2D water_dudvmap;
uniform sampler2D water_normalmap;
uniform sampler2D TexReflect;

//in vec4 waterTex1; //moving texcoords
//in vec4 waterTex2; //moving texcoords
in vec4 waterTex3; //for projection
in vec4 waterTex4; //viewts

void main()
{
	float y = uv.y/2+0.5;
	float x = (uv.x+type)/32.0;
	
	if(normal.z > 0.1 || normal.z < - 0.1)
		y = uv.y/2;

	vec2 pos = vec2(x,y);
	vec4 newColor = texture2D(TexCustom_0, pos);
	// if(int(vecIn.x)+0.1 < vecIn.x &&int(vecIn.x)-0.1 > vecIn.x && int(vecIn.y)+0.1 < vecIn.y &&int(vecIn.y)-0.1 > vecIn.y)
	// 	newColor = vec4(0.0, 0.0, 0.0, newColor.a);

	float cosTheta = dot(normal, lightDir);
	cosTheta = clamp(cosTheta, 0.0, 1.0);

	float bias = 0.007 * tan(acos(cosTheta));
	bias = clamp(bias, 0.0,0.01);

	float visibility = 1.0;
	if ( texture( TexShadow, shadowCoord.xy ).z  <  shadowCoord.z-bias){
		visibility = 0.5;
	}

	vec3 p_color = newColor.rgb * visibility /**(max(0,normal.z+normal.y/2)+0.2f)*/;

	color_out = vec4(p_color.rgb,newColor.a);

	///////////////////// reflexion
	if(type == CUBE_EAU)
	{	
		newColor = color;	
		vec4 reflexionColor;
		const vec4 two = vec4(2.0, 2.0, 2.0, 1.0);
		const vec4 ofive = vec4(0.5,0.5,0.5,1.0);

		vec4 viewt = normalize(waterTex4);
		// vec4 disdis = texture2D(water_dudvmap, vec2(waterTex2 * tscale));
		// vec4 dist = texture2D(water_dudvmap, vec2(waterTex1 + disdis*sca2));

		// vec4 fdist = dist;
		// fdist = fdist * two + mone;
		// fdist = normalize(fdist);
		// fdist *= sca;

		//load normalmap
		vec4 nmap = (vec4(normal, 1.0)-ofive) * two;
		vec4 vNorm = nmap;
		vNorm = normalize(nmap);

		//get projective texcoords
		vec4 tmp = vec4(1.0 / waterTex3.w);
		vec4 projCoord = waterTex3 * tmp;
		projCoord += vec4(1.0);

		projCoord *= vec4(0.5);
		tmp = projCoord ;/*+ fdist;*/
		tmp = clamp(tmp, 0.001, 0.999);

		//load reflection
		reflexionColor = texture2D(TexReflect, vec2(tmp));

		//Fresnel
		vec4 invfres = vec4( dot(vNorm, viewt) );
		vec4 fres = vec4(1.0) -invfres ;
		fres = clamp(fres, vec4(0.75), vec4(1));
		reflexionColor *= fres;

		color_out = vec4(reflexionColor.rgb,newColor.a);
	}
}