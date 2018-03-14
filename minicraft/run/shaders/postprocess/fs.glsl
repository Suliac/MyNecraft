#version 400

in vec2 uv;
in vec4 shadowCoord;

uniform sampler2D TexColor;
uniform sampler2D TexDepth;
uniform sampler2D TexShadow;
uniform float screen_width;
uniform float screen_height;
uniform vec2 near_far;

out vec4 color_out;

float LinearizeDepth(float z)
{
	float n = near_far.x; // camera z near
  	float f = near_far.y; // camera z far
  	return (2.0 * n) / (f + n - z * (f - n));
}

void main (void)
{
	vec4 color = texture2D( TexColor , uv );
	float depth = texture2D( TexDepth , uv ).r;	
	
	//Permet de scaler la profondeur
	depth = LinearizeDepth(depth);

	///////////////////// OUTLINE
	vec2 screenPos = vec2(screen_width*uv.x, screen_height*uv.y);

	vec2 uvTopLeft	= vec2((screenPos.x-1)/screen_width	, (screenPos.y+1)/screen_height);
	vec2 uvTop 		= vec2((screenPos.x)/screen_width	, (screenPos.y+1)/screen_height);
	vec2 uvTopRight = vec2((screenPos.x+1)/screen_width	, (screenPos.y+1)/screen_height);
	vec2 uvMidLeft 	= vec2((screenPos.x-1)/screen_width	, (screenPos.y)/screen_height);
	vec2 uvMidRight = vec2((screenPos.x+1)/screen_width	, (screenPos.y)/screen_height);
	vec2 uvBotLeft	= vec2((screenPos.x-1)/screen_width	, (screenPos.y-1)/screen_height);
	vec2 uvBot 		= vec2((screenPos.x)/screen_width	, (screenPos.y-1)/screen_height);
	vec2 uvBotRight = vec2((screenPos.x+1)/screen_width	, (screenPos.y-1)/screen_height);

	float depthTopLeft = LinearizeDepth(texture2D( TexDepth , uvTopLeft ).r);
	float depthTop = LinearizeDepth(texture2D( TexDepth , uvTop ).r);
	float depthTopRight = LinearizeDepth(texture2D( TexDepth , uvTopRight ).r);
	float depthMidLeft = LinearizeDepth(texture2D( TexDepth , uvMidLeft ).r);
	float depthMidRight = LinearizeDepth(texture2D( TexDepth , uvMidRight ).r);
	float depthBotLeft = LinearizeDepth(texture2D( TexDepth , uvTopLeft ).r);
	float depthBot = LinearizeDepth(texture2D( TexDepth , uvTopLeft ).r);
	float depthBotRight = LinearizeDepth(texture2D( TexDepth , uvTopLeft ).r);

	float dtDepth = abs(depth*8 - (depthTopLeft+depthTop+depthTopRight+depthMidLeft+depthMidRight+depthBotLeft+depthBot+depthBotRight));
	
	color.r = color.r + dtDepth;
	color.g = color.g + dtDepth;
	color.b = color.b + dtDepth;


    //Gamma correction
    color.r = pow(color.r,1.0/2.2);
    color.g = pow(color.g,1.0/2.2);
    color.b = pow(color.b,1.0/2.2);

	color_out = vec4(color.rgb,1.0);
}