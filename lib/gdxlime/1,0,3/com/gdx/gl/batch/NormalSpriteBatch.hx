package com.gdx.gl.batch ;


import com.gdx.Clip;
import com.gdx.color.Color4;
import com.gdx.math.Matrix4;
import com.gdx.math.Vector2;
import com.gdx.math.Vector3;

import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLShader;
import lime.graphics.opengl.GLUniformLocation;
import lime.graphics.RenderContext;
import lime.utils.Float32Array;
import lime.utils.Int16Array;




/**
 * ...
 * @author djoker
 */
class NormalSpriteBatch
{
static private var VertexShader=
"
attribute vec2 aVertexPosition;
attribute vec2 aVertexNormal;
attribute vec2 aTexCoord;
attribute vec4 aColor;

varying vec2 vTexCoord;
varying vec4 vColor;
varying vec2 vNormal;

uniform mat4 uModelViewMatrix;
uniform mat4 uProjectionMatrix;

void main(void) 
{
vNormal = aVertexNormal;	
vTexCoord = aTexCoord;
vColor = aColor;
gl_Position = uProjectionMatrix * uModelViewMatrix *  vec4 (aVertexPosition,0.0, 1.0);
}";

static private var FragmentLight=

#if !desktop
"precision mediump float;" +
#end
"
varying vec2 vTexCoord;
varying vec4 vColor;
uniform sampler2D texture;
uniform float cutoff;  
uniform float radius; 
uniform vec3 light;   
uniform vec4 LightColor;


void main(void)
{
	vec3 L = light - gl_FragCoord.xyz;
	float distance = length(L);
	float d = max(distance - radius, 0.0);
	L /= distance;

	float f = d / cutoff;
	d /= 1.0 - f * f;

	f = d / radius + 1.0;
	float attenuation = 1.0 / (f * f);


	gl_FragColor = texture2D(texture, vTexCoord) * vColor * LightColor * max(L.z, 0.0) * attenuation;

}";

static private var FragmentLightNormal=

#if !desktop
"precision mediump float;" +
#end
"
varying vec2 vTexCoord;
varying vec4 vColor;
varying vec2 vNormal;

uniform sampler2D texture;
uniform sampler2D normal;
uniform float cutoff;  
uniform float radius; 
uniform vec3 light;   
uniform vec4 LightColor;

void main(void)
{
	vec3 L = light - gl_FragCoord.xyz;
	float distance = length(L);
	float d = max(distance - radius, 0.0);
	L /= distance;

	float f = d / cutoff;
	d /= 1.0 - f * f;

	f = d / radius + 1.0;
	float attenuation = 1.0 / (f * f);

	gl_FragColor = texture2D(texture, vTexCoord) * vColor
	             * LightColor
	             * max(dot(L, texture2D(normal, vNormal).xyz * 2.0 - 1.0), 0.0)
	             * attenuation;

}";

public static var FIX_ARTIFACTS_BY_STRECHING_TEXEL:Bool = true;

    private var capacity:Int;
	private var numVerts:Int;
	private var numIndices:Int; 
	private var vertices:Float32Array;
	private var normals:Float32Array;

	private var currentBatchSize:Int;
	private var blendMode:Int;
	private var BaseTexture:Texture;
	private var normalTexture:Texture;
	
	 private var view:Matrix4;
	 private var projs:Matrix4;
	
	private var rebuid:Bool;
	private var isBumpmap:Bool;

private var vertexBuffer:GLBuffer;
private var normalBuffer:GLBuffer;
private var indexBuffer:GLBuffer;
private var invTexWidth:Float = 0;
private var invTexHeight:Float = 0;
private var vertexStrideSize:Int;

private var left:Float;
private var right:Float;
private var top:Float;
private var bottom:Float;

private var nleft:Float;
private var nright:Float;
private var ntop:Float;
private var nbottom:Float;


 private var shaderProgram:GLProgram;
 private var projectionMatrixUniform:Dynamic;
 private var modelViewMatrixUniform:Dynamic;
 
 private var imageUniform:Dynamic;
 private var normalUniform:Dynamic;
 private var cutoffUniform:Dynamic;
 private var radiusUniform:Dynamic;
 private var lightUniform:Dynamic;
 private var colorUniform:Dynamic;
 
 private var vertexAttribute:Int ;
 private var normalAttribute:Int ;
 private var texCoordAttribute:Int ;
 private var colorAttribute:Int ;
 
 public var vextexNormal:Vector2;

 public var LightCutoff:Float;
 public var LightRadius:Float;
 public var LightPosition:Vector3;
  private var LightColor:Color4;
 

 public function new(texture:Texture,capacity:Int,normal:Texture=null ) 
	{
			
	var vertexShader = GL.createShader (GL.VERTEX_SHADER);
    GL.shaderSource (vertexShader, VertexShader);
    GL.compileShader (vertexShader);
    if (GL.getShaderParameter (vertexShader, GL.COMPILE_STATUS) == 0) 
    {
    throw (GL.getShaderInfoLog(vertexShader));
     }

var fragmentShader = GL.createShader (GL.FRAGMENT_SHADER);

if(normal != null)
{
	isBumpmap = true;
	normalTexture = normal;
GL.shaderSource (fragmentShader, FragmentLightNormal);
} else

{
	isBumpmap = false;
normalTexture = null;
GL.shaderSource (fragmentShader, FragmentLight);
}
	

GL.compileShader (fragmentShader);

if (GL.getShaderParameter (fragmentShader, GL.COMPILE_STATUS) == 0) {

 throw(GL.getShaderInfoLog(fragmentShader));

}

shaderProgram = GL.createProgram ();
GL.attachShader (shaderProgram, vertexShader);
GL.attachShader (shaderProgram, fragmentShader);
GL.linkProgram (shaderProgram);

if (GL.getProgramParameter (shaderProgram, GL.LINK_STATUS) == 0) {


throw "Unable to initialize the shader program.";
}

vertexAttribute = GL.getAttribLocation (shaderProgram, "aVertexPosition");
GL.bindAttribLocation(shaderProgram, vertexAttribute, "aVertexPosition");

normalAttribute = GL.getAttribLocation (shaderProgram, "aVertexNormal");
GL.bindAttribLocation(shaderProgram, normalAttribute, "aVertexNormal");

texCoordAttribute = GL.getAttribLocation (shaderProgram, "aTexCoord");
GL.bindAttribLocation(shaderProgram, texCoordAttribute, "aTexCoord");

colorAttribute = GL.getAttribLocation (shaderProgram, "aColor");
GL.bindAttribLocation(shaderProgram, colorAttribute, "aColor");

projectionMatrixUniform = GL.getUniformLocation (shaderProgram, "uProjectionMatrix");
modelViewMatrixUniform = GL.getUniformLocation (shaderProgram, "uModelViewMatrix");

imageUniform = GL.getUniformLocation (shaderProgram, "texture");
cutoffUniform = GL.getUniformLocation (shaderProgram, "cutoff");
radiusUniform = GL.getUniformLocation (shaderProgram, "radius");
lightUniform  = GL.getUniformLocation (shaderProgram, "light");
normalUniform = GL.getUniformLocation (shaderProgram, "normal");
colorUniform = GL.getUniformLocation (shaderProgram, "LightColor");


LightColor = new Color4(1, 1, 1,1);

LightCutoff = 10000;
LightRadius = 100;
LightPosition = new  Vector3(Gdx.Instance().width / 2, Gdx.Instance().height / 2, 0.5);
 
 
 

    currentBatchSize = 0;
	blendMode = BlendMode.NORMAL;
    BaseTexture = texture;
    invTexWidth  = 1.0 / BaseTexture.width;
    invTexHeight = 1.0 / BaseTexture.height;

		    
 	
	   this.capacity = capacity;
	   vertexStrideSize =  (2 +2 + 4) *4 ; // 9 floats (x, y, nx,ny,,u,v, r, g, b, a)
       numVerts = capacity * vertexStrideSize ;
       numIndices = capacity * 6;
       vertices = new Float32Array(numVerts);
	   normals = new Float32Array(capacity*((2)*4));
    

	
        var indices:Array<Int> = [];
        var ind = 0;
        for (count in 0...numIndices) {
            indices.push(ind);
            indices.push(ind + 1);
            indices.push(ind + 2);
            indices.push(ind);
            indices.push(ind + 2);
            indices.push(ind + 3);
            ind += 4;
        }
		

 
	nleft= nright= ntop= nbottom = 0;
	left= right= top= bottom=0;




    vertexBuffer = GL.createBuffer();
    indexBuffer = GL.createBuffer();
	normalBuffer = GL.createBuffer();


    //upload the index data
    GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indexBuffer);
    GL.bufferData(GL.ELEMENT_ARRAY_BUFFER,  new Int16Array(indices), GL.STATIC_DRAW);

	indices = null;
	
	GL.bindBuffer(GL.ARRAY_BUFFER, normalBuffer);
    GL.bufferData(GL.ARRAY_BUFFER,  new Float32Array(capacity*((2)*4)), GL.STREAM_DRAW);
	
	
    GL.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer);
    GL.bufferData(GL.ARRAY_BUFFER,  new Float32Array(numVerts), GL.STREAM_DRAW);
	
	
	
	
	
   }
	
	
	

		
	public    function render(
	x:Float, y:Float, 
	width:Float, height:Float,
	scaleX:Float, scaleY:Float,
	angle:Float,
	originX:Float, originY:Float,
	clip:Clip,nclip:Clip,
	flipX:Bool,flipY:Bool,
	r:Float, g:Float, b:Float, a:Float)
	{
		
	







var index:Int = currentBatchSize *  vertexStrideSize;
var nindex:Int = currentBatchSize *  2 * 4 ;


					
		var worldOriginX:Float = x + originX;
		var worldOriginY:Float = y + originY;
		var fx:Float = -originX;
		var fy:Float = -originY;
		var fx2:Float = width - originX;
		var fy2:Float = height - originY;
		
		if (scaleX != 1 || scaleY != 1)
		{
			fx *= scaleX;
			fy *= scaleY;
			fx2 *= scaleX;
			fy2 *= scaleY;
		}
		
		var p1x:Float = fx;
		var p1y:Float = fy;
		var p2x:Float = fx;
		var p2y:Float = fy2;
		var p3x:Float = fx2;
		var p3y:Float = fy2;
		var p4x:Float = fx2;
		var p4y:Float = fy;

		var x1:Float;
		var y1:Float;
		var x2:Float;
		var y2:Float;
		var x3:Float;
		var y3:Float;
		var x4:Float;
		var y4:Float;
		
		
		
			if (angle != 0) 
			{
		
	                var angle:Float = angle * Math.PI / 180;
					var cos:Float = Math.cos(angle);
					var sin:Float = Math.sin(angle);
					
			x1 = cos * p1x - sin * p1y;
			y1 = sin * p1x + cos * p1y;

			x2 = cos * p2x - sin * p2y;
			y2 = sin * p2x + cos * p2y;

			x3 = cos * p3x - sin * p3y;
			y3 = sin * p3x + cos * p3y;

			x4 = x1 + (x3 - x2);
			y4 = y3 - (y2 - y1);
		} else {
			x1 = p1x;
			y1 = p1y;

			x2 = p2x;
			y2 = p2y;

			x3 = p3x;
			y3 = p3y;

			x4 = p4x;
			y4 = p4y;
		}

		x1 += worldOriginX;
		y1 += worldOriginY;
		x2 += worldOriginX;
		y2 += worldOriginY;
		x3 += worldOriginX;
		y3 += worldOriginY;
		x4 += worldOriginX;
		y4 += worldOriginY;
		
				


  var widthTex:Int  = BaseTexture.width;
  var heightTex:Int = BaseTexture.height;


  
  if (FIX_ARTIFACTS_BY_STRECHING_TEXEL)
  {
   left = (2*clip.x+1) / (2*widthTex);
   right =  left +(clip.width*2-2) / (2*widthTex);
   top = (2*clip.y+1) / (2*heightTex);
   bottom = top +(clip.height * 2 - 2) / (2 * heightTex);

   nleft = (2*nclip.x+1) / (2*widthTex);
   nright =  nleft +(nclip.width*2-2) / (2*widthTex);
   ntop = (2*nclip.y+1) / (2*heightTex);
   nbottom = ntop +(nclip.height * 2 - 2) / (2 * heightTex);


}else
  {
   left = clip.x / widthTex;
   right =  (clip.x + clip.width) / widthTex;
   top = clip.y / heightTex;
   bottom = (clip.y + clip.height) / heightTex;

	  
   nleft = nclip.x / widthTex;
   nright =  (nclip.x + nclip.width) / widthTex;
   ntop = nclip.y / heightTex;
   nbottom = (nclip.y + nclip.height) / heightTex;
  }			
  
		

 
  if (flipX) 
 {
			var tmp:Float = left;
			left = right;
			right = tmp;
			
			var ntmp:Float = nleft;
			nleft = nright;
			nright = ntmp;
		}

		if (flipY)
		{
			var tmp:Float = top;
			top = bottom;
			bottom = tmp;
			
			var ntmp:Float = ntop;
			ntop = nbottom;
			nbottom = ntmp;
		}

	
vertices[index++] = x1;vertices[index++] = y1;
vertices[index++] = left;vertices[index++] = top;
vertices[index++] = r;vertices[index++] = g;vertices[index++] = b;vertices[index++] = a;
	
vertices[index++] = x2;vertices[index++] = y2;
vertices[index++] = left;vertices[index++] = bottom;
vertices[index++] = r;vertices[index++] = g;vertices[index++] = b;vertices[index++] = a;

vertices[index++] = x3;vertices[index++] = y3;
vertices[index++] = right;vertices[index++] = bottom;
vertices[index++] = r;vertices[index++] = g;vertices[index++] = b;vertices[index++] = a;

vertices[index++] = x4;vertices[index++] = y4;
vertices[index++] = right;vertices[index++] = top;
vertices[index++] = r;vertices[index++] = g;vertices[index++] = b;vertices[index++] = a;


if(isBumpmap)
{
normals[nindex++] = nleft; normals[nindex++] = ntop;
normals[nindex++] = nleft; normals[nindex++] = nbottom;
normals[nindex++] = nright;normals[nindex++] = nbottom;
normals[nindex++] = nright; normals[nindex++] = ntop;
}

    currentBatchSize++;
	
	}
		
	
	public    function renderEx(
	x:Float, y:Float, 
	width:Float, height:Float,
	scaleX:Float, scaleY:Float,
	angle:Float,
	originX:Float, originY:Float,
	flipX:Bool,flipY:Bool,
	r:Float, g:Float, b:Float, a:Float)
	{
		
	







var index:Int = currentBatchSize *  vertexStrideSize;
var nindex:Int = currentBatchSize *  (2 * 4) ;

					
		var worldOriginX:Float = x + originX;
		var worldOriginY:Float = y + originY;
		var fx:Float = -originX;
		var fy:Float = -originY;
		var fx2:Float = width - originX;
		var fy2:Float = height - originY;
		
		if (scaleX != 1 || scaleY != 1)
		{
			fx *= scaleX;
			fy *= scaleY;
			fx2 *= scaleX;
			fy2 *= scaleY;
		}
		
		var p1x:Float = fx;
		var p1y:Float = fy;
		var p2x:Float = fx;
		var p2y:Float = fy2;
		var p3x:Float = fx2;
		var p3y:Float = fy2;
		var p4x:Float = fx2;
		var p4y:Float = fy;

		var x1:Float;
		var y1:Float;
		var x2:Float;
		var y2:Float;
		var x3:Float;
		var y3:Float;
		var x4:Float;
		var y4:Float;
		
		
		
			if (angle != 0) 
			{
		
	                var angle:Float = angle * Math.PI / 180;
					var cos:Float = Math.cos(angle);
					var sin:Float = Math.sin(angle);
					
			x1 = cos * p1x - sin * p1y;
			y1 = sin * p1x + cos * p1y;

			x2 = cos * p2x - sin * p2y;
			y2 = sin * p2x + cos * p2y;

			x3 = cos * p3x - sin * p3y;
			y3 = sin * p3x + cos * p3y;

			x4 = x1 + (x3 - x2);
			y4 = y3 - (y2 - y1);
		} else {
			x1 = p1x;
			y1 = p1y;

			x2 = p2x;
			y2 = p2y;

			x3 = p3x;
			y3 = p3y;

			x4 = p4x;
			y4 = p4y;
		}

		x1 += worldOriginX;
		y1 += worldOriginY;
		x2 += worldOriginX;
		y2 += worldOriginY;
		x3 += worldOriginX;
		y3 += worldOriginY;
		x4 += worldOriginX;
		y4 += worldOriginY;
		
				


  var widthTex:Int  = BaseTexture.width;
  var heightTex:Int = BaseTexture.height;


  
 var u:Float = 0;
 var v:Float = 0;
 var u2:Float = 1;
 var v2:Float = 1;
 
 left = u;
 right = u2;
 top = v2;
 bottom = v;
 
 nleft = u;
 nright = u2;
 ntop = v2;
 nbottom = v;

		

 
  if (flipX) 
 {
			var tmp:Float = left;
			left = right;
			right = tmp;
			
			var ntmp:Float = nleft;
			nleft = nright;
			nright = ntmp;
		}

		if (flipY)
		{
			var tmp:Float = top;
			top = bottom;
			bottom = tmp;
			
			var ntmp:Float = ntop;
			ntop = nbottom;
			nbottom = ntmp;
		}
 
	//nleft = nright = ntop = nbottom = 0;
	
vertices[index++] = x1;vertices[index++] = y1;
vertices[index++] = left;vertices[index++] = bottom;
vertices[index++] = r;vertices[index++] = g;vertices[index++] = b;vertices[index++] = a;
	
vertices[index++] = x2;vertices[index++] = y2;
vertices[index++] = left;vertices[index++] = top;
vertices[index++] = r;vertices[index++] = g;vertices[index++] = b;vertices[index++] = a;

vertices[index++] = x3;vertices[index++] = y3;
vertices[index++] = right;vertices[index++] = top;
vertices[index++] = r;vertices[index++] = g;vertices[index++] = b;vertices[index++] = a;

vertices[index++] = x4;vertices[index++] = y4;
vertices[index++] = right;vertices[index++] = bottom;
vertices[index++] = r;vertices[index++] = g;vertices[index++] = b;vertices[index++] = a;
if(isBumpmap)
{
normals[nindex++] = nleft; normals[nindex++] = nbottom;
normals[nindex++] = nleft; normals[nindex++] = ntop;
normals[nindex++] = nright;normals[nindex++] = ntop;
normals[nindex++] = nright; normals[nindex++] = nbottom;
}

    currentBatchSize++;
	
	}
		
   public  function setProjMatrix(proj:Matrix4)
   {
	   this.projs = proj;// new Float32Array(proj);

   }
    public  function setViewMatrix(view:Matrix4)
   {
	   this.view = view;// new Float32Array(view);
	   
   }
    public  function setLighCutoff(v:Float)
   {
	  LightCutoff = v;
   }
    public  function setLighRadius(v:Float)
   {
	  LightRadius = v;
   }
   
   
      public  function setLighPosition(x:Float,y:Float,z:Float=0.5)
   {
	   
	    LightPosition.set(x, -y+Gdx.Instance().height, z);
	    GL.useProgram (shaderProgram);
		lightUniform  = GL.getUniformLocation (shaderProgram, "light");
	 	GL.uniform3f(lightUniform, LightPosition.x, LightPosition.y, LightPosition.z);
			 
		
   }
      public  function setAmbientColor(r:Float,g:Float,b:Float,a:Float)
   {
	   
	   LightColor.set(r, g, b,a);
	    GL.useProgram (shaderProgram);
		colorUniform  = GL.getUniformLocation (shaderProgram, "LightColor");
	 	GL.uniform4f(colorUniform, LightColor.r, LightColor.g, LightColor.b, LightColor.a);
			 
		
   }
   


	public  function Begin()
	{
		  currentBatchSize = 0;
 	
	}
	
	public   function End()
	{
	 if (currentBatchSize == 0) return;	
	 
	 
	  
	        BlendMode.setBlend(blendMode);
	  
	        GL.useProgram (shaderProgram);
		   
			GL.uniformMatrix4fv(projectionMatrixUniform, false, projs.m);
			GL.uniformMatrix4fv(modelViewMatrixUniform, false, view.m);
			GL.uniform1f(cutoffUniform, LightCutoff);
			GL.uniform1f(radiusUniform, LightRadius);
			GL.uniform3f(lightUniform, LightPosition.x, LightPosition.y, LightPosition.z);
			GL.uniform4f(colorUniform, LightColor.r, LightColor.g, LightColor.b, LightColor.a);
			 
		
		 if (isBumpmap)
	  {
		  GL.activeTexture(GL.TEXTURE1);
		  normalTexture.Bind(1);
		  GL.uniform1i (normalUniform, 1);
	  }
  
	   GL.activeTexture(GL.TEXTURE0);
       BaseTexture.Bind(0);
	   GL.uniform1i (imageUniform, 0);	
	   
	  if (isBumpmap)
	  {
	    GL.bindBuffer(GL.ARRAY_BUFFER, this.normalBuffer);
		GL.enableVertexAttribArray (normalAttribute);
	    GL.bufferData(GL.ARRAY_BUFFER, normals, GL.STREAM_DRAW);
		GL.vertexAttribPointer(normalAttribute, 2, GL.FLOAT, false, 0 , 0);
	  }
		
	
        GL.bindBuffer(GL.ARRAY_BUFFER, this.vertexBuffer);
		
		var offset:Int = 0;
	 	GL.enableVertexAttribArray (vertexAttribute);
		GL.vertexAttribPointer(vertexAttribute, 2, GL.FLOAT, false, vertexStrideSize, offset);
    	offset += 2;
		
			
		GL.enableVertexAttribArray (texCoordAttribute);
		GL.vertexAttribPointer(texCoordAttribute  , 2, GL.FLOAT, false, vertexStrideSize, 2 * 4);
		offset += 2;
		
		GL.enableVertexAttribArray (colorAttribute);
		GL.vertexAttribPointer(colorAttribute, 4, GL.FLOAT, false, vertexStrideSize,(2+2) * 4);

	
     
	 
    	

		
	
	 

	  
	 
	  

		 
	



	
		

    GL.bufferData(GL.ARRAY_BUFFER, vertices, GL.STREAM_DRAW);
	//GL.bufferSubData(GL.ARRAY_BUFFER, 0, vertices);
	GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, this.indexBuffer);
    GL.drawElements(GL.TRIANGLES, currentBatchSize * 6, GL.UNSIGNED_SHORT, 0);
  //  GL.activeTexture(GL.TEXTURE0);
	}
	
	
	

public   function setTexture (texture:Texture) 
{
this.BaseTexture = texture;
invTexWidth  = 1.0 / BaseTexture.width;
invTexHeight = 1.0 / BaseTexture.height;
}

public   function setBlendMode(blendMode:Int)
{
    this.blendMode = blendMode;

}
  public function dispose():Void 
{
	 GL.deleteProgram(shaderProgram);
	 this.vertices = null;
	 this.normals = null;
     GL.deleteBuffer(indexBuffer);
	 GL.deleteBuffer(vertexBuffer);
	 if(isBumpmap) GL.deleteBuffer(normalBuffer);

	
}



}