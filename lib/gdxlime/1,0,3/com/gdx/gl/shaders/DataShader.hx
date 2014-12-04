package com.gdx.gl.shaders;

/**
 * ...
 * @author djoekr
 */
class DataShader
{

static public var VertexShaderFixed=
"
attribute vec3 inVertexPosition;
attribute vec3 inVertexNormal;
attribute vec2 inTexCoord0;
attribute vec2 inTexCoord1;
attribute vec4 inVertexColor;

uniform mat4 WorldMatrix;
uniform mat4 ViewMatrix;
uniform mat4 ProjectionMatrix;


varying vec2 varTexCoord0;
varying vec2 varTexCoord1;
varying vec4 varVertexColor;



void main(void)
{
	   		
	varTexCoord0 = inTexCoord0;
	varTexCoord1 = inTexCoord1;
	varVertexColor = inVertexColor;
    gl_Position =   ProjectionMatrix * ViewMatrix * WorldMatrix * vec4(inVertexPosition, 1.0);


}
";
//******************

static public var FragmentShaderFixed=

#if !desktop
"precision mediump float;" +
#end
"

/* Definitions */

#define Solid 0
#define Solid2Layer 1
#define LightMap 2
#define DetailMap 3
#define Reflection2Layer 4
#define TransparentAlphaChannel 5
#define TransparentAlphaChannelRef 6
#define TransparentVertexAlpha 7
#define TransparentReflection2Layer 8


uniform int uMaterialType;

uniform bool uTextureUsage0;


uniform sampler2D uTextureUnit0;
uniform sampler2D uTextureUnit1;

uniform vec4  Ambient;		   
uniform vec3  LightPos;

	

varying vec2 varTexCoord0;
varying vec2 varTexCoord1;
varying vec4 varVertexColor;
varying vec3 varVertexNormal;
varying vec4 varWSVertex;

vec4 renderSolid()
{
	vec4 Color = varVertexColor;

	if(uTextureUsage0)		Color *= texture2D(uTextureUnit0, varTexCoord0);
		
	Color.a = 1.0;
		
	return Color;
}

vec4 render2LayerSolid()
{
	float BlendFactor = varVertexColor.a;
	
	vec4 Texel0 = texture2D(uTextureUnit0, varTexCoord0);
	vec4 Texel1 = texture2D(uTextureUnit1, varTexCoord1);
	
	vec4 Color = Texel0 * BlendFactor + Texel1 * (1.0 - BlendFactor);
	vec4 Color = Texel0 * Texel1;
  
	return Color;
}

vec4 renderLightMap()
{
	vec4 Texel0 = texture2D(uTextureUnit0, varTexCoord0);
	vec4 Texel1 = texture2D(uTextureUnit1, varTexCoord1);
	
	vec4 Color = Texel0 * Texel1 * 4.0;
	Color.a = Texel0.a * Texel0.a;
	
	return Color;
}

vec4 renderDetailMap()
{
	vec4 Texel0 = texture2D(uTextureUnit0, varTexCoord0);
	vec4 Texel1 = texture2D(uTextureUnit1, varTexCoord1);
	
	vec4 Color = Texel0;
	Color += Texel1 - 0.5;
	
	return Color;
}

vec4 renderReflection2Layer()
{
	vec4 Color = varVertexColor;
	
	vec4 Texel0 = texture2D(uTextureUnit0, varTexCoord0);
	vec4 Texel1 = texture2D(uTextureUnit1, varTexCoord1);
	
	Color *= Texel0 * Texel1;
	
	return Color;
}

vec4 renderTransparent()
{
	vec4 Color = vec4(1.0, 1.0, 1.0, 1.0);

	if(uTextureUsage0)		Color *= texture2D(uTextureUnit0, varTexCoord0);

	return Color;
}

void main ()
{
	vec4 FinalColor;

    if (uMaterialType == Solid)
		FinalColor = renderSolid();
	else if(uMaterialType == Solid2Layer)
		FinalColor = render2LayerSolid();
	else if(uMaterialType == LightMap)
		FinalColor = renderLightMap();
	else if(uMaterialType == DetailMap)
		FinalColor = renderDetailMap();
	else if(uMaterialType == Reflection2Layer)
		FinalColor = renderReflection2Layer();
	else if(uMaterialType == TransparentAlphaChannel)
		FinalColor = renderTransparent();
	else if(uMaterialType == TransparentAlphaChannelRef)
	{
		vec4 Color = renderTransparent();
		
		if (Color.a < 0.5)
			discard;
		
		FinalColor = Color;
	}
	else if(uMaterialType == TransparentVertexAlpha)
	{
		vec4 Color = renderTransparent();
		Color.a = varVertexColor.a;
		
		FinalColor = Color;
	}
	else if(uMaterialType == TransparentReflection2Layer)
	{
		vec4 Color = renderReflection2Layer();
		Color.a = varVertexColor.a;
		
		FinalColor = Color;
	}
	else
		FinalColor = vec4(1.0, 1.0, 1.0, 1.0);
	    gl_FragColor =FinalColor;

		
	 
}
";	
//**************************************************

static public var VertexShader=
"
attribute vec3 inVertexPosition;
attribute vec3 inVertexNormal;
attribute vec2 inTexCoord0;
attribute vec2 inTexCoord1;
attribute vec4 inVertexColor;

uniform mat4 WorldMatrix;
uniform mat4 ViewMatrix;
uniform mat4 ProjectionMatrix;

uniform vec4 Tint;

varying vec2 varTexCoord0;
varying vec2 varTexCoord1;
varying vec3 varVertexNormal;
varying vec4 varVertexColor;
varying vec4 varWSVertex;


void main(void)
{
	   		
    varWSVertex = vec4(inVertexPosition, 1.0) * WorldMatrix;				
	varTexCoord0 = inTexCoord0;
	varTexCoord1 = inTexCoord1;
	varVertexColor = inVertexColor.bgra * Tint;
	varVertexNormal= inVertexNormal * mat3(WorldMatrix);
    gl_Position =   ProjectionMatrix * ViewMatrix * WorldMatrix * vec4(inVertexPosition, 1.0);


}
";
//******************

static public var FragmentShader=

#if !desktop
"precision mediump float;" +
#end
"
const float LOG2 = 1.442695;
/* Definitions */

#define Solid 0
#define Solid2Layer 1
#define LightMap 2
#define DetailMap 3
#define Reflection2Layer 4
#define TransparentAlphaChannel 5
#define TransparentAlphaChannelRef 6
#define TransparentVertexAlpha 7
#define TransparentReflection2Layer 8


uniform int uMaterialType;

uniform bool uTextureUsage0;


uniform sampler2D uTextureUnit0;
uniform sampler2D uTextureUnit1;

uniform vec4  Ambient;		   
uniform vec3  LightPos;

	

varying vec2 varTexCoord0;
varying vec2 varTexCoord1;
varying vec4 varVertexColor;
varying vec3 varVertexNormal;
varying vec4 varWSVertex;

vec4 renderSolid()
{
	vec4 Color = varVertexColor;

	if(uTextureUsage0)		Color *= texture2D(uTextureUnit0, varTexCoord0);
		
	Color.a = 1.0;
		
	return Color;
}

vec4 render2LayerSolid()
{
	float BlendFactor = varVertexColor.a;
	
	vec4 Texel0 = texture2D(uTextureUnit0, varTexCoord0);
	vec4 Texel1 = texture2D(uTextureUnit1, varTexCoord1);
	
	//vec4 Color = Texel0 * BlendFactor + Texel1 * (1.0 - BlendFactor);
	vec4 Color = Texel0 * Texel1;
  
	return Color;
}

vec4 renderLightMap()
{
	vec4 Texel0 = texture2D(uTextureUnit0, varTexCoord0);
	vec4 Texel1 = texture2D(uTextureUnit1, varTexCoord1);
	
	vec4 Color = Texel0 * Texel1 * 4.0;
	Color.a = Texel0.a * Texel0.a;
	
	return Color;
}

vec4 renderDetailMap()
{
	vec4 Texel0 = texture2D(uTextureUnit0, varTexCoord0);
	vec4 Texel1 = texture2D(uTextureUnit1, varTexCoord1);
	
	vec4 Color = Texel0;
	Color += Texel1 - 0.5;
	
	return Color;
}

vec4 renderReflection2Layer()
{
	vec4 Color = varVertexColor;
	
	vec4 Texel0 = texture2D(uTextureUnit0, varTexCoord0);
	vec4 Texel1 = texture2D(uTextureUnit1, varTexCoord1);
	
	Color *= Texel0 * Texel1;
	
	return Color;
}

vec4 renderTransparent()
{
	vec4 Color = vec4(1.0, 1.0, 1.0, 1.0);

	if(uTextureUsage0)		Color *= texture2D(uTextureUnit0, varTexCoord0);

	return Color;
}

void main ()
{
	vec4 FinalColor;

    if (uMaterialType == Solid)
		FinalColor = renderSolid();
	else if(uMaterialType == Solid2Layer)
		FinalColor = render2LayerSolid();
	else if(uMaterialType == LightMap)
		FinalColor = renderLightMap();
	else if(uMaterialType == DetailMap)
		FinalColor = renderDetailMap();
	else if(uMaterialType == Reflection2Layer)
		FinalColor = renderReflection2Layer();
	else if(uMaterialType == TransparentAlphaChannel)
		FinalColor = renderTransparent();
	else if(uMaterialType == TransparentAlphaChannelRef)
	{
		vec4 Color = renderTransparent();
		
		if (Color.a < 0.5)
			discard;
		
		FinalColor = Color;
	}
	else if(uMaterialType == TransparentVertexAlpha)
	{
		vec4 Color = renderTransparent();
		Color.a = varVertexColor.a;
		
		FinalColor = Color;
	}
	else if(uMaterialType == TransparentReflection2Layer)
	{
		vec4 Color = renderReflection2Layer();
		Color.a = varVertexColor.a;
		
		FinalColor = Color;
	}
	else
		FinalColor = vec4(1.0, 1.0, 1.0, 1.0);
	
		
	
		        vec3 light_dir = normalize(LightPos - varWSVertex.xyz);
				vec3 n = normalize(varVertexNormal);
	            float light_diffuse = clamp(dot(n, light_dir), 0.0, 1.0);
				vec3 lightColor = Ambient.xyz + (varVertexColor.xyz * light_diffuse);
	
	float density = 0.0004;
	float z = gl_FragCoord.z / gl_FragCoord.w;
	float fogFactor = exp2( -density * density * z * z * LOG2);
	fogFactor = clamp(fogFactor, 0.0, 1.0);
	vec4 frag_color =FinalColor * vec4(lightColor, varVertexColor.a);
	vec4 fog_color = vec4(0.4, 0.4,0.4, 0);
	gl_FragColor = mix(fog_color, frag_color, fogFactor);
	
	 
	
		//gl_FragColor = FinalColor * vec4(lightColor, varVertexColor.a);
	 
}
";
///*********************************************

static public var VertexShaderUnlit =
"
attribute vec3 inVertexPosition;
attribute vec3 inVertexNormal;
attribute vec2 inTexCoord0;
attribute vec2 inTexCoord1;
attribute vec4 inVertexColor;

uniform mat4 WorldMatrix;
uniform mat4 ViewMatrix;
uniform mat4 ProjectionMatrix;


varying vec2 varTexCoord0;
varying vec2 varTexCoord1;
varying vec3 varVertexNormal;
varying vec4 varVertexColor;

void main(void)
{
	   		
				
	varTexCoord0 = inTexCoord0;
	varTexCoord1 = inTexCoord1;
	varVertexColor = inVertexColor;
	varVertexNormal= inVertexNormal * mat3(WorldMatrix);
    gl_Position =   ProjectionMatrix * ViewMatrix * WorldMatrix * vec4(inVertexPosition, 1.0);


}
";
//******************

static public var FragmentShaderUnlit=

#if !desktop
"precision mediump float;" +
#end
"

/* Definitions */

#define Solid 0
#define Solid2Layer 1
#define LightMap 2
#define DetailMap 3
#define Reflection2Layer 4
#define TransparentAlphaChannel 5
#define TransparentAlphaChannelRef 6
#define TransparentVertexAlpha 7
#define TransparentReflection2Layer 8


uniform int uMaterialType;

uniform bool uTextureUsage0;


uniform sampler2D uTextureUnit0;
uniform sampler2D uTextureUnit1;

uniform vec4  Ambient;		   
uniform vec3  LightPos;

	

varying vec2 varTexCoord0;
varying vec2 varTexCoord1;
varying vec4 varVertexColor;
varying vec3 varVertexNormal;
varying vec4 varWSVertex;

vec4 renderSolid()
{
	vec4 Color = varVertexColor;

	if(uTextureUsage0)		Color *= texture2D(uTextureUnit0, varTexCoord0);
		
	Color.a = 1.0;
		
	return Color;
}

vec4 render2LayerSolid()
{
	float BlendFactor = varVertexColor.a;
	
	vec4 Texel0 = texture2D(uTextureUnit0, varTexCoord0);
	vec4 Texel1 = texture2D(uTextureUnit1, varTexCoord1);
	
	vec4 Color = Texel0 * BlendFactor + Texel1 * (1.0 - BlendFactor);
	//vec4 Color = Texel0 * Texel1;
  
	return Color;
}

vec4 renderLightMap()
{
	vec4 Texel0 = texture2D(uTextureUnit0, varTexCoord0);
	vec4 Texel1 = texture2D(uTextureUnit1, varTexCoord1);
	
	vec4 Color = Texel0 * Texel1 * 4.0;
	Color.a = Texel0.a * Texel0.a;
	
	return Color;
}

vec4 renderDetailMap()
{
	vec4 Texel0 = texture2D(uTextureUnit0, varTexCoord0);
	vec4 Texel1 = texture2D(uTextureUnit1, varTexCoord1);
	
	vec4 Color = Texel0;
	Color += Texel1 - 0.5;
	
	return Color;
}

vec4 renderReflection2Layer()
{
	vec4 Color = varVertexColor;
	
	vec4 Texel0 = texture2D(uTextureUnit0, varTexCoord0);
	vec4 Texel1 = texture2D(uTextureUnit1, varTexCoord1);
	
	Color *= Texel0 * Texel1;
	
	return Color;
}

vec4 renderTransparent()
{
	vec4 Color = vec4(1.0, 1.0, 1.0, 1.0);

	if(uTextureUsage0)		Color *= texture2D(uTextureUnit0, varTexCoord0);

	return Color;
}

void main ()
{
	vec4 FinalColor;

    if (uMaterialType == Solid)
		FinalColor = renderSolid();
	else if(uMaterialType == Solid2Layer)
		FinalColor = render2LayerSolid();
	else if(uMaterialType == LightMap)
		FinalColor = renderLightMap();
	else if(uMaterialType == DetailMap)
		FinalColor = renderDetailMap();
	else if(uMaterialType == Reflection2Layer)
		FinalColor = renderReflection2Layer();
	else if(uMaterialType == TransparentAlphaChannel)
		FinalColor = renderTransparent();
	else if(uMaterialType == TransparentAlphaChannelRef)
	{
		vec4 Color = renderTransparent();
		
		if (Color.a < 0.5)
			discard;
		
		FinalColor = Color;
	}
	else if(uMaterialType == TransparentVertexAlpha)
	{
		vec4 Color = renderTransparent();
		Color.a = varVertexColor.a;
		
		FinalColor = Color;
	}
	else if(uMaterialType == TransparentReflection2Layer)
	{
		vec4 Color = renderReflection2Layer();
		Color.a = varVertexColor.a;
		
		FinalColor = Color;
	}
	else
		FinalColor = vec4(1.0, 1.0, 1.0, 1.0);
     	gl_FragColor =FinalColor;

		
	 
}
";
//***********************************************
static public var QuadVertexShader=
"
attribute vec3 inVertexPosition;
attribute vec2 inTexCoord;
attribute vec4 inVertexColor;


uniform mat4 WorldMatrix;
uniform mat4 ViewMatrix;
uniform mat4 ProjectionMatrix;


varying vec2 varTexCoord;
varying vec4 varVertexColor;


void main(void)
{

	gl_Position =   ProjectionMatrix * ViewMatrix * WorldMatrix * vec4(inVertexPosition, 1.0);
    //gl_Position = uProjMatrix *  uWorldMatrix * vec4(inVertexPosition, 1.0);
	varTexCoord = inTexCoord;
	varVertexColor = inVertexColor;

}
";

static public var QuadFragmentShader=

#if !desktop
"precision mediump float;" +
#end
"
uniform sampler2D uTextureUnit;
varying vec2 varTexCoord;
varying vec4 varVertexColor;

void main(void)
{
gl_FragColor = texture2D(uTextureUnit, varTexCoord) * varVertexColor;
if(gl_FragColor.a < 0.5)
  discard;
}

	
";
	

static public var CubeVertexShader=
"

//geometry
attribute vec3 inVertexPosition;
attribute vec3 inVertexNormal;
attribute vec2 inVertexTextureCoords;

//matrices
uniform mat4 uProjMatrix;
uniform mat4 uWorldMatrix;
uniform mat4 nNormalMatrix;

//varyings
varying vec2 vTextureCoord;
varying vec3 vVertexNormal;

void main(void) {
	//Final vertex position
	gl_Position = uProjMatrix * uWorldMatrix * vec4(inVertexPosition, 1.0);
	vTextureCoord = inVertexTextureCoords;
	vVertexNormal = (nNormalMatrix * vec4(-inVertexPosition, 1.0)).xyz;
}
";

static public var CubeFragmentShader=

#if !desktop
"precision mediump float;" +
#end
"
//sampler
uniform sampler2D uSampler;
uniform samplerCube uCubeSampler;

//varying
varying vec2 vTextureCoord;
varying vec3 vVertexNormal;

void main(void)
{	
	gl_FragColor = texture2D(uSampler, vTextureCoord) * textureCube(uCubeSampler, vVertexNormal);
}
";

//**************


static public var SkyBoxVertexShader=
"

//geometry
attribute vec3 inVertexPosition;



//matrices
uniform mat4 uProjMatrix;
uniform mat4 uWorldMatrix;


//varyings
varying  vec3 vTextureCoord;


void main(void) {
	
	gl_Position = uProjMatrix * uWorldMatrix * vec4(inVertexPosition, 1.0);
	vTextureCoord.xyz = inVertexPosition.xyz;
	
}
";

static public var SkyBoxFragmentShader=

#if !desktop
"precision mediump float;" +
#end
"
uniform samplerCube uCubeSampler;
varying vec3 vTextureCoord;


void main(void)
{	
    vec3 cube = vec3(textureCube(uCubeSampler, vTextureCoord.xyz));
     gl_FragColor = vec4(cube, 1.0);
}
";
//***********************

static public var FlatShadowVertexShader=
"
attribute vec3 inVertexPosition;


uniform mat4 WorldMatrix;
uniform mat4 ViewMatrix;
uniform mat4 ProjectionMatrix;

varying vec4 varVertexColor;


void main(void)
{
	
	gl_Position =   ProjectionMatrix * ViewMatrix * WorldMatrix * vec4(inVertexPosition, 1.0);


}
";
//******************

static public var FlatShadowFragmentShader=

#if !desktop
"precision mediump float;" +
#end
"
void main ()
{
gl_FragColor = vec4(0.0,0.0,0.0,1);
 
}
";
///*********************************************
///AMBIENT


static public var FragmentShaderAmbient=

#if !desktop
"precision mediump float;" +
#end
"

/* Definitions */

#define Solid 0
#define Solid2Layer 1
#define LightMap 2
#define DetailMap 3
#define Reflection2Layer 4
#define TransparentAlphaChannel 5
#define TransparentAlphaChannelRef 6
#define TransparentVertexAlpha 7
#define TransparentReflection2Layer 8


uniform int uMaterialType;

uniform bool uTextureUsage0;


uniform sampler2D uTextureUnit0;
uniform sampler2D uTextureUnit1;


	

varying vec2 varTexCoord0;
varying vec2 varTexCoord1;
varying vec4 varVertexColor;
varying vec4 varFinalColor;


vec4 renderSolid()
{
	vec4 Color = varVertexColor;

	if(uTextureUsage0)		Color *= texture2D(uTextureUnit0, varTexCoord0);
		
	Color.a = 1.0;
		
	return Color;
}

vec4 render2LayerSolid()
{
	float BlendFactor = varVertexColor.a;
	
	vec4 Texel0 = texture2D(uTextureUnit0, varTexCoord0);
	vec4 Texel1 = texture2D(uTextureUnit1, varTexCoord1);
	
	vec4 Color = Texel0 * BlendFactor + Texel1 * (1.0 - BlendFactor);
	//vec4 Color = Texel0 * Texel1;
  
	return Color;
}

vec4 renderLightMap()
{
	vec4 Texel0 = texture2D(uTextureUnit0, varTexCoord0);
	vec4 Texel1 = texture2D(uTextureUnit1, varTexCoord1);
	
	vec4 Color = Texel0 * Texel1 * 4.0;
	Color.a = Texel0.a * Texel0.a;
	
	return Color;
}

vec4 renderDetailMap()
{
	vec4 Texel0 = texture2D(uTextureUnit0, varTexCoord0);
	vec4 Texel1 = texture2D(uTextureUnit1, varTexCoord1);
	
	vec4 Color = Texel0;
	Color += Texel1 - 0.5;
	
	return Color;
}

vec4 renderReflection2Layer()
{
	vec4 Color = varVertexColor;
	
	vec4 Texel0 = texture2D(uTextureUnit0, varTexCoord0);
	vec4 Texel1 = texture2D(uTextureUnit1, varTexCoord1);
	
	Color *= Texel0 * Texel1;
	
	return Color;
}

vec4 renderTransparent()
{
	vec4 Color = vec4(1.0, 1.0, 1.0, 1.0);

	if(uTextureUsage0)		Color *= texture2D(uTextureUnit0, varTexCoord0);

	return Color;
}

void main ()
{
	vec4 FinalColor;

    if (uMaterialType == Solid)
		FinalColor = renderSolid();
	else if(uMaterialType == Solid2Layer)
		FinalColor = render2LayerSolid();
	else if(uMaterialType == LightMap)
		FinalColor = renderLightMap();
	else if(uMaterialType == DetailMap)
		FinalColor = renderDetailMap();
	else if(uMaterialType == Reflection2Layer)
		FinalColor = renderReflection2Layer();
	else if(uMaterialType == TransparentAlphaChannel)
		FinalColor = renderTransparent();
	else if(uMaterialType == TransparentAlphaChannelRef)
	{
		vec4 Color = renderTransparent();
		
		if (Color.a < 0.5)
			discard;
		
		FinalColor = Color;
	}
	else if(uMaterialType == TransparentVertexAlpha)
	{
		vec4 Color = renderTransparent();
		Color.a = varVertexColor.a;
		
		FinalColor = Color;
	}
	else if(uMaterialType == TransparentReflection2Layer)
	{
		vec4 Color = renderReflection2Layer();
		Color.a = varVertexColor.a;
		
		FinalColor = Color;
	}
	else
		FinalColor = vec4(1.0, 1.0, 1.0, 1.0);
		
		
				
	gl_FragColor = FinalColor * varFinalColor;
			
			//	gl_FragColor =FinalColor;

		
	 
}
";
///*********************************************

static public var VertexShaderAmbient =
"
attribute vec3 inVertexPosition;
attribute vec3 inVertexNormal;
attribute vec2 inTexCoord0;
attribute vec2 inTexCoord1;
attribute vec4 inVertexColor;

//uniform mat4 WorldMatrix;
//uniform mat4 ViewMatrix;
uniform mat4 uMVMatrix;
uniform mat4 ProjectionMatrix;
uniform mat4 NormalMatrix;

uniform float uShininess;		 //shininness
uniform vec3 uLightDirection;	 //light direction

uniform vec4 uLightAmbient;      //light ambient property
uniform vec4 uLightDiffuse;      //light diffuse property 
uniform vec4 uLightSpecular;     //light specular property

uniform vec4 uMaterialAmbient;	 //object ambient property
uniform vec4 uMaterialDiffuse;   //object diffuse property
uniform vec4 uMaterialSpecular;  //object specular property

varying vec2 varTexCoord0;
varying vec2 varTexCoord1;
varying vec4 varVertexColor;
varying vec4 varFinalColor;


void main(void)
{
	   		

	
	
	varTexCoord0 = inTexCoord0;
	varTexCoord1 = inTexCoord1;
	varVertexColor = inVertexColor;
	
	
  //  mat4 NormalMatrix = transpose(inverse(uMVMatrix));

	//Transformed vertex position
	vec4 vertex = uMVMatrix   * vec4(inVertexPosition, 1.0);
	
	//Transformed normal position
    vec3 N = vec3(NormalMatrix * vec4(inVertexNormal, 1.0));
	
	//Invert and normalize light to calculate lambertTerm
    vec3 L = normalize(uLightDirection); 
	
	//Lambert's cosine law
	float lambertTerm = clamp(dot(N,-L),0.0,1.0);
	
	//Ambient Term
    vec4 Ia = uLightAmbient * uMaterialAmbient;
	
	//Diffuse Term
	vec4 Id = vec4(0.0,0.0,0.0,1.0);
	
	//Specular Term
	vec4 Is = vec4(0.0,0.0,0.0,1.0);
    
	
    Id = uLightDiffuse* uMaterialDiffuse * lambertTerm; //add diffuse term
    
    vec3 eyeVec = -vec3(vertex.xyz);
    vec3 E = normalize(eyeVec);
    vec3 R = reflect(L, N);
    float specular = pow(max(dot(R, E), 0.0), uShininess );
    
    Is = uLightSpecular * uMaterialSpecular * specular;	//add specular term

	
	//Final color
	varFinalColor = Ia + Id + Is;
	varFinalColor.a = 1.0;

	//Transformed vertex position
	gl_Position =   ProjectionMatrix  * vertex;


}
";
//******************


static public var VertexShaderTerrain =
"
attribute vec3 position;
attribute vec3 normal;
attribute vec2 texture;
uniform mat4 WorldMatrix;
uniform mat4 ViewMatrix;
uniform mat4 ProjectionMatrix;

uniform sampler2D bumpTexture;
uniform float bumpScale;





uniform float uvAmount0;
uniform float uvAmount1;
uniform float uvAmount2;
uniform float uvAmount3;
uniform float uvAmount4;

varying float vAmount;
varying float vuvAmount0;
varying float vuvAmount1;
varying float vuvAmount2;
varying float vuvAmount3;
varying float vuvAmount4;

varying vec2 vUV;
varying vec3 varVertexNormal;
varying vec4 varWSVertex;

const vec4 WHITE = vec4(1.0, 1.0, 1.0, 1.0);

void main(void)
{
	vUV = texture;
    vec4 bumpData = texture2D( bumpTexture, texture);

    vAmount =  bumpData.r; 
	vuvAmount0 = uvAmount0;
	vuvAmount1 = uvAmount1;
	vuvAmount2 = uvAmount2;
	vuvAmount3 = uvAmount3;
	vuvAmount4 = uvAmount4;

	 vec3 newPosition = position +normal * bumpScale * vAmount;

	
    
  
	
	
  gl_Position = ProjectionMatrix * ViewMatrix * WorldMatrix * vec4(newPosition, 1.0);
}
";

static public var FragmentShaderTerrain=

#if !desktop
"precision mediump float;" +
#end
"


uniform sampler2D layer0;
uniform sampler2D layer1;
uniform sampler2D layer2;
uniform sampler2D layer3;
uniform sampler2D layer4;




varying vec2 vUV;

varying float vAmount;

varying float vuvAmount0;
varying float vuvAmount1;
varying float vuvAmount2;
varying float vuvAmount3;
varying float vuvAmount4;



void main() 
{
 
    vec4 water = (smoothstep(0.01, 0.21, vAmount) - smoothstep(0.24, 0.26, vAmount)) * texture2D( layer0, vUV * vuvAmount0 );
	vec4 sandy = (smoothstep(0.24, 0.27, vAmount) - smoothstep(0.28, 0.31, vAmount)) * texture2D( layer1, vUV * vuvAmount1);
	vec4 grass = (smoothstep(0.28, 0.32, vAmount) - smoothstep(0.35, 0.40, vAmount)) * texture2D( layer2, vUV * vuvAmount2 );
	vec4 rocky = (smoothstep(0.30, 0.50, vAmount) - smoothstep(0.40, 0.70, vAmount)) * texture2D( layer3, vUV * vuvAmount3 );
	vec4 snowy = (smoothstep(0.50, 0.65, vAmount))                                   * texture2D( layer4, vUV * vuvAmount4 );

	

	
	
gl_FragColor =  vec4(0.0, 0.0, 0.0, 1.0) + water + sandy + grass + rocky + snowy ;

	
	
}";

//**************************************************************
//******************


static public var VertexShaderTerrainDetailSplat =
"
attribute vec3 position;
attribute vec3 normal;
attribute vec2 texture;

uniform mat4 WorldMatrix;
uniform mat4 ViewMatrix;
uniform mat4 ProjectionMatrix;




uniform float uvAmount0;
uniform float uvAmount1;
uniform float uvAmount2;
uniform float uvAmount3;

varying float vuvAmount0;
varying float vuvAmount1;
varying float vuvAmount2;
varying float vuvAmount3;

varying vec2 vUV;
varying vec3 varVertexNormal;
varying vec4 varWSVertex;

const vec4 WHITE = vec4(1.0, 1.0, 1.0, 1.0);

void main(void)
{
	vUV = texture;
   	vuvAmount0 = uvAmount0;
	vuvAmount1 = uvAmount1;
	vuvAmount2 = uvAmount2;
	vuvAmount3 = uvAmount3;
	
	 
	 varWSVertex = vec4(position, 1.0) * WorldMatrix;				
	 varVertexNormal = normal * mat3(WorldMatrix);
     gl_Position = ProjectionMatrix * ViewMatrix * WorldMatrix * vec4(position, 1.0);
}
";

static public var FragmentShaderTerrainDetailSplat=

#if !desktop
"precision mediump float;" +
#end
"
const float LOG2 = 1.442695;

uniform sampler2D Alpha;
uniform sampler2D Base;
uniform sampler2D layer0;
uniform sampler2D layer1;
uniform sampler2D layer2;



uniform vec4  Ambient;		   
uniform vec3  LightPos;


varying vec2 vUV;



varying float vuvAmount0;
varying float vuvAmount1;
varying float vuvAmount2;
varying float vuvAmount3;


varying vec4 varWSVertex;
varying vec3 varVertexNormal;


void main() 
{
 
    vec4 alpha   = texture2D( Alpha, vUV.xy );
    vec4 tex0    = texture2D( layer0, vUV.xy * vuvAmount1 ); 
    vec4 tex1    = texture2D( layer1, vUV.xy * vuvAmount2 ); 
    vec4 tex2    = texture2D( layer2, vUV.xy * vuvAmount3 ); 

   tex0 *= alpha.r; // Red channel
   tex1 = mix( tex0, tex1, alpha.g ); // Green channel
   vec4 blend = mix( tex1, tex2, alpha.b ); // Blue channel
   
	
	vec4 detail  = texture2D(Base, vUV.xy * vuvAmount0);//detail
	
	vec4 FinalColor = blend;
	FinalColor += detail - 0.5;

   // vec4 alpha  = texture2D(Alpha, vUV.xy );
   // vec4 color  = texture2D(Base, vUV.xy * vuvAmount0);//detail
   // color = mix(color, texture2D(layer0, vUV.xy * vuvAmount1), alpha[0]);
   // color = mix(color, texture2D(layer1, vUV.xy * vuvAmount2), alpha[1]);
   // color = mix(color, texture2D(layer2, vUV.xy * vuvAmount3), alpha[2]);
   // vec4 FinalColor = color;
	
	
	            vec3 light_dir = normalize(LightPos - varWSVertex.xyz);
				vec3 n = normalize(varVertexNormal);
	            float light_diffuse = clamp(dot(n, light_dir), 0.0, 1.0);
				vec3 lightColor = Ambient.xyz + (vec3(1.0,1.0,1.0) * light_diffuse);
	
	float density = 0.004;
	float z = gl_FragCoord.z / gl_FragCoord.w;
	float fogFactor = exp2( -density * density * z * z * LOG2);
	fogFactor = clamp(fogFactor, 0.0, 1.0);
	vec4 frag_color =FinalColor * vec4(lightColor, 1.0);
	vec4 fog_color = vec4(0.4, 0.4,0.4, 0);
	gl_FragColor = mix(fog_color, frag_color, fogFactor);
	
	//gl_FragColor = vertexColor *  vec4(0.0, 0.0, 0.0, 1.0)+fogVertexColor + water + sandy + grass + rocky + snowy ;

	
	
}";


//**************************************************************
//******************


static public var VertexShaderTerrainSplat =
"
attribute vec3 position;
attribute vec3 normal;
attribute vec2 texture;

uniform mat4 WorldMatrix;
uniform mat4 ViewMatrix;
uniform mat4 ProjectionMatrix;




uniform float uvAmount0;
uniform float uvAmount1;
uniform float uvAmount2;


varying float vuvAmount0;
varying float vuvAmount1;
varying float vuvAmount2;

varying vec2 vUV;
varying vec3 varVertexNormal;
varying vec4 varWSVertex;

const vec4 WHITE = vec4(1.0, 1.0, 1.0, 1.0);

void main(void)
{
	vUV = texture;
   	vuvAmount0 = uvAmount0;
	vuvAmount1 = uvAmount1;
	vuvAmount2 = uvAmount2;
	
	 
	 varWSVertex = vec4(position, 1.0) * WorldMatrix;				
	 varVertexNormal = normal * mat3(WorldMatrix);
     gl_Position = ProjectionMatrix * ViewMatrix * WorldMatrix * vec4(position, 1.0);
}
";

static public var FragmentShaderTerrainSplat=

#if !desktop
"precision mediump float;" +
#end
"
const float LOG2 = 1.442695;

uniform sampler2D Alpha;
uniform sampler2D layer0;
uniform sampler2D layer1;
uniform sampler2D layer2;



uniform vec4  Ambient;		   
uniform vec3  LightPos;


varying vec2 vUV;



varying float vuvAmount0;
varying float vuvAmount1;
varying float vuvAmount2;



varying vec4 varWSVertex;
varying vec3 varVertexNormal;


void main() 
{
 
    vec4 alpha   = texture2D( Alpha, vUV.xy );
    vec4 tex0    = texture2D( layer0, vUV.xy * vuvAmount0 ); 
    vec4 tex1    = texture2D( layer1, vUV.xy * vuvAmount1 ); 
    vec4 tex2    = texture2D( layer2, vUV.xy * vuvAmount2 ); 

   tex0 *= alpha.r; // Red channel
   tex1 = mix( tex0, tex1, alpha.g ); // Green channel
   vec4 FinalColor = mix( tex1, tex2, alpha.b ); // Blue channel
   
	
	          //  vec3 light_dir = normalize(LightPos - varWSVertex.xyz);
				//vec3 n = normalize(varVertexNormal);
	           // float light_diffuse = clamp(dot(n, light_dir), 0.0, 1.0);
				//vec3 lightColor = Ambient.xyz + (vec3(1.0,1.0,1.0) * light_diffuse);
	
	//float density = 0.004;
	//float z = gl_FragCoord.z / gl_FragCoord.w;
	//float fogFactor = exp2( -density * density * z * z * LOG2);
	//fogFactor = clamp(fogFactor, 0.0, 1.0);
	//vec4 frag_color =FinalColor * vec4(lightColor, 1.0);
	//vec4 fog_color = vec4(0.4, 0.4,0.4, 0);
	//gl_FragColor = mix(fog_color, frag_color, fogFactor);
	gl_FragColor = FinalColor;
	

	
	
}";


} 

