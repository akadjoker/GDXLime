package com.gdx.gl ;



/**
 * 
 * 
 * ...
 * @author djoker
 */
class Filter
{

	
static public var colorVertexShader=
"
attribute vec3 aVertexPosition;
attribute vec4 aColor;


varying vec4 vColor;

uniform mat4 uModelViewMatrix;
uniform mat4 uProjectionMatrix;


void main(void) 
{
vColor = aColor;
gl_Position = uProjectionMatrix * uModelViewMatrix * vec4 (aVertexPosition, 1.0);

}";


static public var colorFragmentShader=

#if !desktop
"precision mediump float;" +
#end
"

varying vec4 vColor;
void main(void)
{
	gl_FragColor =  vColor;
}";

static public var textureMatrixVertexShader=
"
attribute vec2 aVertexPosition;
attribute vec2 aTexCoord;
attribute float aColor;

attribute vec2 aCos;
attribute vec2 aSin;
attribute vec2 aPosition;


varying vec2 vTexCoord;
varying float vColor;


uniform mat4 uModelViewMatrix;
uniform mat4 uProjectionMatrix;


 


void main(void) 
{
vTexCoord = aTexCoord;
vColor = aColor;



vec2 vCoord;

float x = aVertexPosition.x;
float y = aVertexPosition.y;

vCoord.x = aCos.x * x + aCos.y * y + aPosition.x;
vCoord.y = aSin.y * y + aSin.x * x + aPosition.y;


gl_Position = uProjectionMatrix * uModelViewMatrix *  vec4(vCoord,0.0,1.0);
}";



static public var textureFastVertexShader=
"
attribute vec2 aVertexPosition;
attribute vec2 aPosition;
attribute vec2 aTexCoord;
attribute vec2 aScale;
attribute float aRotation;
attribute float aColor;

varying vec2 vTexCoord;
varying float vColor;


uniform mat4 uModelViewMatrix;
uniform mat4 uProjectionMatrix;

mat4 translate(float x, float y)
{
    return mat4(
        vec4(1.0, 0.0, 0.0, 0.0),
        vec4(0.0, 1.0, 0.0, 0.0),
        vec4(0.0, 0.0, 1.0, 0.0),
        vec4(x, y, 0.0, 1.0)
    );
}
 


void main(void) 
{
vTexCoord = aTexCoord;
vColor = aColor;
        
           vec2 v;
           vec2 sv = aVertexPosition * aScale;
           v.x = (sv.x) * cos(aRotation) - (sv.y) * sin(aRotation);
           v.y = (sv.x) * sin(aRotation) + (sv.y) * cos(aRotation);
		
           gl_Position = uProjectionMatrix * (uModelViewMatrix*translate(aPosition.x,aPosition.y))  *  vec4 (v, 0.0, 1.0);
		//   gl_Position = uProjectionMatrix * uModelViewMatrix *     vec4 (v, 0.0, 1.0);
		   

}";

static public var textureVertexShader=
"
attribute vec3 aVertexPosition;
attribute vec2 aTexCoord;
attribute vec4 aColor;

varying vec2 vTexCoord;
varying vec4 vColor;

uniform mat4 uModelViewMatrix;
uniform mat4 uProjectionMatrix;

void main(void) 
{
vTexCoord = aTexCoord;
vColor = aColor;
gl_Position = uProjectionMatrix * uModelViewMatrix *  vec4 (aVertexPosition, 1.0);


}";


static public var texture1ColorFragmentShader=

#if !desktop
"precision mediump float;" +
#end
"
varying vec2 vTexCoord;
varying float vColor;
uniform sampler2D uImage0;

void main(void)
{
	gl_FragColor = texture2D (uImage0, vTexCoord) * vColor;

}";

static public var textureFragmentShader=

#if !desktop
"precision mediump float;" +
#end
"
varying vec2 vTexCoord;
varying vec4 vColor;
uniform sampler2D uImage0;

void main(void)
{
	gl_FragColor = texture2D (uImage0, vTexCoord) * vColor;

}";

static public var textureDiscardFragmentShader=

#if !desktop
"precision mediump float;" +
#end
"
varying vec2 vTexCoord;
varying vec4 vColor;
uniform sampler2D uImage0;

void main(void)
{
	vec4 color  = texture2D (uImage0, vTexCoord) * vColor;
 if (color.rgb == vec3(1.0,0.0,0.0))
      discard;    
   gl_FragColor = color;
   
}";

static public var normalFilter = 
			
			#if !desktop
			"precision mediump float;" +
			#end
			"varying vec2 vTexCoord;
			uniform sampler2D uImage0;
			void main(void)
			{
			gl_FragColor = texture2D (uImage0, vTexCoord);
			}";
			
static public var grayFilter =
 #if !desktop
"precision mediump float;" +
#end
" 
        varying vec2 vTexCoord;
        varying vec4 vColor;
        uniform sampler2D uImage0;
        uniform float gray;

        void main(void)
		{
           gl_FragColor = texture2D(uImage0, vTexCoord);
           gl_FragColor.rgb = mix(gl_FragColor.rgb, vec3(0.2126*gl_FragColor.r + 0.7152*gl_FragColor.g + 0.0722*gl_FragColor.b), gray);
        }";
		   
		
static public var colorStepFilter =
 #if !desktop
"precision mediump float;" +
#end
"       varying vec2 vTexCoord;
        varying vec4 vColor;
        uniform sampler2D uImage0;
        uniform float step;

        void main(void) 
		{
           vec4 color = texture2D(uImage0, vTexCoord);
           color = floor(color * step) / step;
           gl_FragColor = color;
        };";
		
		
static public var invertFilter =
 #if !desktop
"precision mediump float;" +
#end
 "       varying vec2 vTexCoord;
        varying vec4 vColor;
        uniform float invert;
        uniform sampler2D uImage0;

        void main(void) {
           gl_FragColor = texture2D(uImage0, vTexCoord);
           gl_FragColor.rgb = mix( (vec3(1)-gl_FragColor.rgb) * gl_FragColor.a, gl_FragColor.rgb, 1.0 - invert);
         }";
		
static public var blurYFilter =
 #if !desktop
"precision mediump float;" +
#end
  "     varying vec2 vTexCoord;
        varying vec4 vColor;
        uniform float blur;
        uniform sampler2D uImage0;

        void main(void) {
           vec4 sum = vec4(0.0);

           sum += texture2D(uImage0, vec2(vTexCoord.x, vTexCoord.y - 4.0*blur)) * 0.05;
           sum += texture2D(uImage0, vec2(vTexCoord.x, vTexCoord.y - 3.0*blur)) * 0.09;
           sum += texture2D(uImage0, vec2(vTexCoord.x, vTexCoord.y - 2.0*blur)) * 0.12;
           sum += texture2D(uImage0, vec2(vTexCoord.x, vTexCoord.y - blur)) * 0.15;
           sum += texture2D(uImage0, vec2(vTexCoord.x, vTexCoord.y)) * 0.16;
           sum += texture2D(uImage0, vec2(vTexCoord.x, vTexCoord.y + blur)) * 0.15;
           sum += texture2D(uImage0, vec2(vTexCoord.x, vTexCoord.y + 2.0*blur)) * 0.12;
           sum += texture2D(uImage0, vec2(vTexCoord.x, vTexCoord.y + 3.0*blur)) * 0.09;
           sum += texture2D(uImage0, vec2(vTexCoord.x, vTexCoord.y + 4.0*blur)) * 0.05;

           gl_FragColor = sum;
        }";

		
	
static public var blurXFilter =
 #if !desktop
"precision mediump float;" +
#end
  "     varying vec2 vTexCoord;
        varying vec4 vColor;
        uniform float blur;
        uniform sampler2D uImage0;

        void main(void) {
           vec4 sum = vec4(0.0);

           sum += texture2D(uImage0, vec2(vTexCoord.x - 4.0*blur, vTexCoord.y)) * 0.05;
           sum += texture2D(uImage0, vec2(vTexCoord.x - 3.0*blur, vTexCoord.y)) * 0.09;
           sum += texture2D(uImage0, vec2(vTexCoord.x - 2.0*blur, vTexCoord.y)) * 0.12;
           sum += texture2D(uImage0, vec2(vTexCoord.x - blur, vTexCoord.y)) * 0.15;
           sum += texture2D(uImage0, vec2(vTexCoord.x, vTexCoord.y)) * 0.16;
           sum += texture2D(uImage0, vec2(vTexCoord.x + blur, vTexCoord.y)) * 0.15;
           sum += texture2D(uImage0, vec2(vTexCoord.x + 2.0*blur, vTexCoord.y)) * 0.12;
           sum += texture2D(uImage0, vec2(vTexCoord.x + 3.0*blur, vTexCoord.y)) * 0.09;
           sum += texture2D(uImage0, vec2(vTexCoord.x + 4.0*blur, vTexCoord.y)) * 0.05;

           gl_FragColor = sum;
        }";
static public var twistFilter =
 #if !desktop
"precision mediump float;" +
#end
  " 
        varying vec2 vTexCoord;
        varying vec4 vColor;
        uniform vec4 dimensions;
        uniform sampler2D uImage0;

        uniform float radius;
        uniform float angle;
        uniform vec2 offset;

        void main(void) {
           vec2 coord = vTexCoord - offset;
           float distance = length(coord);

           if (distance < radius) {
               float ratio = (radius - distance) / radius;
               float angleMod = ratio * ratio * angle;
               float s = sin(angleMod);
               float c = cos(angleMod);
               coord = vec2(coord.x * c - coord.y * s, coord.x * s + coord.y * c);
           }

           gl_FragColor = texture2D(uImage0, coord+offset);
        }";		
		

static public var sepiaFilter =
 #if !desktop
"precision mediump float;" +
#end
  " 
        varying vec2 vTexCoord;
        varying vec4 vColor;
        uniform float sepia;
        uniform sampler2D uImage0;

        const mat3 sepiaMatrix = mat3(0.3588, 0.7044, 0.1368, 0.2990, 0.5870, 0.1140, 0.2392, 0.4696, 0.0912);

        void main(void) {
           gl_FragColor = texture2D(uImage0, vTexCoord);
           gl_FragColor.rgb = mix( gl_FragColor.rgb, gl_FragColor.rgb * sepiaMatrix, sepia);
        }";
		
		
static public var blurFilter =
 #if !desktop
"precision mediump float;" +
#end
  " 
        precision mediump float;
        varying vec2 vTexCoord;
        uniform sampler2D uImage0;
        //'uniform vec2 delta;',
        const vec2 delta = vec2(1.0/10.0, 0.0);
        //'uniform float darkness;',

        float random(vec3 scale, float seed) {
           return fract(sin(dot(gl_FragCoord.xyz + seed, scale)) * 43758.5453 + seed);
        }


        void main(void) {
           vec4 color = vec4(0.0);
           float total = 0.0;

           float offset = random(vec3(12.9898, 78.233, 151.7182), 0.0);

           for (float t = -30.0; t <= 30.0; t++) 
		   {
               float percent = (t + offset - 0.5) / 30.0;
               float weight = 1.0 - abs(percent);
               vec4 sample = texture2D(uImage0, vTexCoord + delta * percent);
               sample.rgb *= sample.a;
               color += sample * weight;
               total += weight;
           }

           gl_FragColor = color / total;
           gl_FragColor.rgb /= gl_FragColor.a + 0.00001;
        //'   gl_FragColor.rgb *= darkness;',
        }";		
		
		
static public var pixelateFilter =
 #if !desktop
"precision mediump float;" +
#end
  " 
        varying vec2 vTexCoord;
        varying vec4 vColor;
        uniform vec2 pixelSize;
        uniform sampler2D uImage0;

        void main(void) 
		{
           vec4 dimensions = vec4(10000, 100, 10, 10);
		   vec2 size = dimensions.xy/pixelSize;
           vec2 color = floor( ( vTexCoord * size ) ) / size + pixelSize/dimensions.xy * 0.5;
           gl_FragColor = texture2D(uImage0, color);
       }";
	   
static public var dotscreenFilter =
 #if !desktop
"precision mediump float;" +
#end
  " 
        varying vec2 vTexCoord;
        varying vec4 vColor;
        uniform sampler2D uImage0;
        uniform float angle;
        uniform float scale;
		

        float pattern() 
		{
		   vec4 dimensions = vec4(0,0,0,0);
           float s = sin(angle), c = cos(angle);
           vec2 tex = vTexCoord * dimensions.xy;
           vec2 point = vec2(
               c * tex.x - s * tex.y,
               s * tex.x + c * tex.y
           ) * scale;
           return (sin(point.x) * sin(point.y)) * 4.0;
        }

        void main() {
           vec4 color = texture2D(uImage0, vTexCoord);
           float average = (color.r + color.g + color.b) / 3.0;
           gl_FragColor = vec4(vec3(average * 10.0 - 5.0 + pattern()), color.a);
        }";
		

static public var rgbsplitFilter =
 #if !desktop
"precision mediump float;" +
#end
  " 
        varying vec2 vTexCoord;
        varying vec4 vColor;
		uniform float distance;
        uniform vec2 red;
        uniform vec2 green;
        uniform vec2 blue;
        uniform vec4 dimensions;
        uniform sampler2D uImage0;

        void main(void) 
		{
           gl_FragColor.r = texture2D(uImage0, vTexCoord + red/distance).r;
           gl_FragColor.g = texture2D(uImage0, vTexCoord + green/distance).g;
           gl_FragColor.b = texture2D(uImage0, vTexCoord + blue/distance).b;
           gl_FragColor.a = texture2D(uImage0, vTexCoord).a;
        }";
		
static public var croshatchFilter =
 #if !desktop
"precision mediump float;" +
#end
  " 		
        varying vec2 vTexCoord;
        varying vec4 vColor;
        uniform float blur;
        uniform sampler2D uImage0;

        void main(void) {
            float lum = length(texture2D(uImage0, vTexCoord.xy).rgb);

            gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);

            if (lum < 1.00) {
                if (mod(gl_FragCoord.x + gl_FragCoord.y, 10.0) == 0.0) {
                    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
                }
            }

            if (lum < 0.75) {
                if (mod(gl_FragCoord.x - gl_FragCoord.y, 10.0) == 0.0) {
                    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
                }
            }
            if (lum < 0.50) {
                if (mod(gl_FragCoord.x + gl_FragCoord.y - 5.0, 10.0) == 0.0) {
                    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
                }
           }

            if (lum < 0.3) {
                if (mod(gl_FragCoord.x - gl_FragCoord.y - 5.0, 10.0) == 0.0) {
                    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
                }
            }
        }";
		
static public var colormatrixFilter =
 #if !desktop
"precision mediump float;" +
#end
  " 
        varying vec2 vTexCoord;
        varying vec4 vColor;
        uniform mat4 matrix;
        uniform sampler2D uImage0;

        void main(void) {
           gl_FragColor = texture2D(uImage0, vTexCoord) * matrix;
        }";
    		
}