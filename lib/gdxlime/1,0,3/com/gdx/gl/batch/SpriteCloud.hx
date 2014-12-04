package com.gdx.gl.batch ;



import com.gdx.math.Matrix4;
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
class SpriteCloud
{
public static var FIX_ARTIFACTS_BY_STRECHING_TEXEL:Bool = true;

    private var capacity:Int;
	private var numVerts:Int;
	private var numIndices:Int; 
	private var vertices:Float32Array;

	private var currentBatchSize:Int;
	private var currentBlendMode:Int;
	private var currentBaseTexture:Texture;
	
	 private var view:Matrix4;
	 private var projs:Matrix4;
	
	private var rebuid:Bool;
	
private var index:Int;
private var vertexBuffer:GLBuffer;
private var indexBuffer:GLBuffer;
private var invTexWidth:Float = 0;
private var invTexHeight:Float = 0;
private var vertexStrideSize:Int;

private var left:Float;
private var right:Float;
private var top:Float;
private var bottom:Float;

 private var shaderProgram:GLProgram;
 private var projectionMatrixUniform:Dynamic;
 private var modelViewMatrixUniform:Dynamic;
 private var imageUniform:Dynamic;
 private var invertUniform:Dynamic;
 private var vertexAttribute :Int=0;
 private var texCoordAttribute :Int=1;
 private var colorAttribute :Int = 2;	 
		

	public function new(texture:Texture,capacity:Int ) 
	{
			
		 var vertexShader = GL.createShader (GL.VERTEX_SHADER);
    GL.shaderSource (vertexShader, Filter.textureVertexShader);
    GL.compileShader (vertexShader);
    if (GL.getShaderParameter (vertexShader, GL.COMPILE_STATUS) == 0) 
    {
    throw (GL.getShaderInfoLog(vertexShader));
     }
var fragmentShader = GL.createShader (GL.FRAGMENT_SHADER);
GL.shaderSource (fragmentShader, Filter.textureFragmentShader);
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
GL.bindAttribLocation(shaderProgram,vertexAttribute,"aVertexPosition");
texCoordAttribute = GL.getAttribLocation (shaderProgram, "aTexCoord");
GL.bindAttribLocation(shaderProgram,texCoordAttribute,"aTexCoord");
colorAttribute = GL.getAttribLocation (shaderProgram, "aColor");
GL.bindAttribLocation(shaderProgram,colorAttribute,"aColor");
projectionMatrixUniform = GL.getUniformLocation (shaderProgram, "uProjectionMatrix");
modelViewMatrixUniform = GL.getUniformLocation (shaderProgram, "uModelViewMatrix");
imageUniform = GL.getUniformLocation (shaderProgram, "uImage0");

    currentBatchSize = 0;
	currentBlendMode = BlendMode.NORMAL;
    this.currentBaseTexture = texture;
    invTexWidth  = 1.0 / texture.width;
    invTexHeight = 1.0 / texture.height;

		    
 	
	   this.capacity = capacity;
	   vertexStrideSize =  (3+2+4) *4 ; // 9 floats (x, y, z,u,v, r, g, b, a)
       numVerts = capacity * vertexStrideSize ;
       numIndices = capacity * 6;
       vertices = new Float32Array(numVerts);
    

	
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
		

 



    
    index = 0;


    indexBuffer = GL.createBuffer();
    GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indexBuffer);
    GL.bufferData(GL.ELEMENT_ARRAY_BUFFER,  new Int16Array(indices), GL.STATIC_DRAW);

	//indices = null;
	
    
	 
	vertexBuffer = GL.createBuffer();
	vertices = new Float32Array(numVerts);
    GL.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer);
    GL.bufferData(GL.ARRAY_BUFFER,  vertices, GL.STATIC_DRAW);
    rebuid = false;
	

	
	}
	
   public  function setProjMatrix(proj:Matrix4)
   {
	   this.projs = proj;// new Float32Array(proj);

   }
    public  function setViewMatrix(view:Matrix4)
   {
	   this.view = view;// new Float32Array(view);
	   
   }
	
 public function dispose():Void 
{
	
	 GL.deleteProgram(shaderProgram);
	GL.useProgram (null);
	this.vertices = null;
	GL.deleteBuffer(indexBuffer);
	GL.deleteBuffer(vertexBuffer);
}
	

	
public function addImage(	x:Float, y:Float, 
	width:Float, height:Float,
	scaleX:Float, scaleY:Float,
	angle:Float,
	originX:Float, originY:Float,
	clip:Clip,
	flipX:Bool,flipY:Bool,
	r:Float, g:Float, b:Float, a:Float)
{





					
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
					var sin:Float =  Math.sin(angle);
					
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
		
				


  var widthTex:Int  =currentBaseTexture.width;
  var heightTex:Int = currentBaseTexture.height;


  
  if (FIX_ARTIFACTS_BY_STRECHING_TEXEL)
  {
   left = (2*clip.x+1) / (2*widthTex);
   right =  left +(clip.width*2-2) / (2*widthTex);
   top = (2*clip.y+1) / (2*heightTex);
   bottom = top +(clip.height * 2 - 2) / (2 * heightTex);



}else
  {
   left = clip.x / widthTex;
   right =  (clip.x + clip.width) / widthTex;
   top = clip.y / heightTex;
   bottom = (clip.y + clip.height) / heightTex;
  }			
  
		

 
  if (flipX) 
 {
			var tmp:Float = left;
			left = right;
			right = tmp;
		}

		if (flipY)
		{
			var tmp:Float = top;
			top = bottom;
			bottom = tmp;
		}
 
vertices[index++] = x1;
vertices[index++] = y1;
vertices[index++] = 0;
vertices[index++] = left;vertices[index++] = top;
vertices[index++] = r;vertices[index++] = g;vertices[index++] = b;vertices[index++] = a;
	
vertices[index++] = x2;
vertices[index++] = y2;
vertices[index++] = 0;
vertices[index++] = left;vertices[index++] = bottom;
vertices[index++] = r;vertices[index++] = g;vertices[index++] = b;vertices[index++] = a;

vertices[index++] = x3;
vertices[index++] = y3;
vertices[index++] = 0;
vertices[index++] = right;vertices[index++] = bottom;
vertices[index++] = r;vertices[index++] = g;vertices[index++] = b;vertices[index++] = a;

vertices[index++] = x4;
vertices[index++] = y4;
vertices[index++] = 0;
vertices[index++] = right;vertices[index++] = top;
vertices[index++] = r;vertices[index++] = g;vertices[index++] = b;vertices[index++] = a;


    currentBatchSize++;
	
	}
	

public function addTile(x:Float,y:Float,width:Float,height:Float,clip:Clip,flipx:Bool,flipy:Bool,?alpha:Float=1)
{
var r, g, b, a:Float;
r = 1;
g = 1;
b = 1;
a = alpha;



		var fx2:Float = x+width;
		var fy2:Float = y+height;
		

		
		
		
		


  var widthTex:Int  = currentBaseTexture.width;
  var heightTex:Int = currentBaseTexture.height;


  
  if (FIX_ARTIFACTS_BY_STRECHING_TEXEL)
  {

   left = (2*clip.x+1) / (2*widthTex);
   right =  left +(clip.width*2-2) / (2*widthTex);
   top = (2*clip.y+1) / (2*heightTex);
   bottom = top +(clip.height * 2 - 2) / (2 * heightTex);



}else
  {
   left = clip.x / widthTex;
   right =  (clip.x + clip.width) / widthTex;
   top = clip.y / heightTex;
   bottom = (clip.y + clip.height) / heightTex;
  }			
  
				

 if (flipx) 
 {
			var tmp:Float = left;
			left = right;
			right = tmp;
		}

		if (flipy)
		{
			var tmp:Float = top;
			top = bottom;
			bottom = tmp;
		}
		
		
	

vertices[index++] = x;
vertices[index++] = y;
vertices[index++] = 0;
vertices[index++] = left; vertices[index++] = top;
vertices[index++] = 1;vertices[index++] = 1;vertices[index++] = 1;vertices[index++] = 1;
	
vertices[index++] = x;
vertices[index++] = fy2;
vertices[index++] = 0;
vertices[index++] = left;vertices[index++] = bottom;
vertices[index++] = 1; vertices[index++] = 1; vertices[index++] = 1; vertices[index++] = 1;

vertices[index++] = fx2;
vertices[index++] = fy2;
vertices[index++] = 0;
vertices[index++] =right;vertices[index++] = bottom;
vertices[index++] = 1; vertices[index++] = 1; vertices[index++] = 1; vertices[index++] = 1;

vertices[index++] = fx2;
vertices[index++] = y;
vertices[index++] = 0;
vertices[index++] = right; vertices[index++] = top;
vertices[index++] = 1; vertices[index++] = 1; vertices[index++] = 1; vertices[index++] = 1;

		    
						
				
			
						
    currentBatchSize++;
	
	}
	

   

   public function build()
	{
		  GL.bindBuffer(GL.ARRAY_BUFFER, this.vertexBuffer);
		  GL.bufferData(GL.ARRAY_BUFFER, vertices, GL.STATIC_DRAW);
		  vertices = null;
	
	}
   
	public  function render()
	{

		if (!rebuid)
		{
			build();
			rebuid = true;
			return;
		}
	 if (currentBatchSize == 0) return;
	 
   
	
	        GL.useProgram (shaderProgram);
		    GL.uniformMatrix4fv(projectionMatrixUniform, false, projs.m);
			GL.uniformMatrix4fv(modelViewMatrixUniform, false, view.m);
			 
		  
	
        GL.bindBuffer(GL.ARRAY_BUFFER, this.vertexBuffer);
		GL.enableVertexAttribArray (vertexAttribute);
		GL.vertexAttribPointer(vertexAttribute, 3, GL.FLOAT, false, vertexStrideSize, 0);
		GL.enableVertexAttribArray (texCoordAttribute);
		GL.vertexAttribPointer(texCoordAttribute  , 2, GL.FLOAT, false, vertexStrideSize,3*4);
		GL.enableVertexAttribArray (colorAttribute);
		GL.vertexAttribPointer(colorAttribute, 4, GL.FLOAT, false, vertexStrideSize,(3+2)*4);

	 

	  currentBaseTexture.Bind();
	  GL.uniform1i (imageUniform, 0);
	  BlendMode.setBlend(currentBlendMode);
	  
	 GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, this.indexBuffer); 
	 GL.drawElements(GL.TRIANGLES, currentBatchSize * 6, GL.UNSIGNED_SHORT, 0);
	 

	 
	
    }

}