#version 400

layout(location=0) in vec3 vs_position_in;

out vec2 uv;
out vec4 shadowCoord;

uniform mat4 m;
uniform mat4 V_light;
uniform mat4 P_light;

mat4 biasMatrix = mat4(
0.5, 0.0, 0.0, 0.0,
0.0, 0.5, 0.0, 0.0,
0.0, 0.0, 0.5, 0.0,
0.5, 0.5, 0.5, 1.0
);

void main()
{
	gl_Position = vec4(vs_position_in,1.0);
	uv = (vs_position_in.xy+vec2(1,1))/2;

	mat4 depthMVP = P_light * V_light * m;
	mat4 biasDepthMVP = biasMatrix * depthMVP;
	shadowCoord = biasDepthMVP * vec4(vs_position_in,1.0);
}