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
class FastSpriteBatch
{
private var shaderProgram:GLProgram;
	
 public var vertexAttribute :Int;
 public var positionAttribute :Int;
 public var colorAttribute :Int;
 public var scaleAttribute :Int;
 public var rotationAttribute :Int;
 public var texCoordAttribute :Int;
 public var imageUniform:Dynamic;  
 public var projectionMatrixUniform:Dynamic;
 public var modelViewMatrixUniform:Dynamic;
 
public static var FIX_ARTIFACTS_BY_STRECHING_TEXEL:Bool = true;
	 
	private var capacity:Int;
	private var numVerts:Int;
	private var numIndices:Int; 
	private var vertices:Float32Array;
	private var lastIndexCount:Int;
	private var drawing:Bool;
	private var currentBatchSize:Int;
	private var currentBlendMode:Int;
	private var currentBaseTexture:Texture;
	
	 private var view:Matrix4;
	 private var projs:Matrix4;
	

	
	public var numTex:Int=0;
	public var numBlend:Int=0;
private var vertexBuffer:GLBuffer;
private var indexBuffer:GLBuffer;
private var invTexWidth:Float = 0;
private var invTexHeight:Float = 0;
private var vertexStrideSize:Int;

private var left:Float;
private var right:Float;
private var top:Float;
private var bottom:Float;
  


	public function new(capacity:Int ) 
	{
		
		
var vertexShader = GL.createShader (GL.VERTEX_SHADER);
GL.shaderSource (vertexShader, Filter.textureFastVertexShader);
GL.compileShader (vertexShader);

if (GL.getShaderParameter (vertexShader, GL.COMPILE_STATUS) == 0) 
{

throw (GL.getShaderInfoLog(vertexShader));

}


var fragmentShader = GL.createShader (GL.FRAGMENT_SHADER);
GL.shaderSource (fragmentShader, Filter.texture1ColorFragmentShader);
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
positionAttribute = GL.getAttribLocation (shaderProgram, "aPosition");
texCoordAttribute = GL.getAttribLocation (shaderProgram, "aTexCoord");
colorAttribute = GL.getAttribLocation (shaderProgram, "aColor");
scaleAttribute = GL.getAttribLocation (shaderProgram, "aScale");
rotationAttribute = GL.getAttribLocation (shaderProgram, "aRotation");

projectionMatrixUniform = GL.getUniformLocation (shaderProgram, "uProjectionMatrix");
modelViewMatrixUniform = GL.getUniformLocation (shaderProgram, "uModelViewMatrix");
imageUniform = GL.getUniformLocation (shaderProgram, "uImage0");


	   this.capacity = capacity;
	   vertexStrideSize =  (2+2+2+1+1+2) *4 ; 
       numVerts = capacity * vertexStrideSize ;
       numIndices = capacity * 6;
       vertices = new Float32Array(numVerts);
    

	
        var indices:Array<Int> = [];
        var index = 0;
        for (count in 0...numIndices) {
            indices.push(index);
            indices.push(index + 1);
            indices.push(index + 2);
            indices.push(index);
            indices.push(index + 2);
            indices.push(index + 3);
            index += 4;
        }
		

    drawing = false;
    currentBatchSize = 0;
	currentBlendMode = BlendMode.NORMAL;
	currentBaseTexture = null;




    indexBuffer = GL.createBuffer();
    GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indexBuffer);
    GL.bufferData(GL.ELEMENT_ARRAY_BUFFER,  new Int16Array(indices), GL.STATIC_DRAW);

	//indices = null;
	
    vertices = new Float32Array(numVerts);
	 
	vertexBuffer = GL.createBuffer();
    GL.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer);
    GL.bufferData(GL.ARRAY_BUFFER,  vertices, GL.STATIC_DRAW);
		

	
	left = right = top = bottom = 0;
   }
	
public  inline function Render(texture:Texture,x:Float,y:Float,rotation:Float,scaleX:Float,scaleY:Float,alpha:Float,blendMode:Int)
{

	if(texture!= this.currentBaseTexture || this.currentBatchSize >= this.capacity)
    {
       		switchTexture(texture);
    }


    // check blend mode
    if(blendMode != this.currentBlendMode)
    {
       this.setBlendMode(blendMode);
    }	
	


 var widthTex:Int  = texture.width;
  var heightTex:Int = texture.height;



	    var OriginX:Float =  0.5;
		var OriginY:Float =  0.5;
	//	var fx:Float = -OriginX;
	//	var fy:Float = -OriginY;
	//	var fx2:Float = widthTex - OriginX;
	//	var fy2:Float = heightTex - OriginY;
		
		
 var w0, w1, h0, h1:Float;
		 
		  w0 = (widthTex ) * (1-OriginX);
          w1 = (widthTex ) * -OriginX;
          h0 = heightTex * (1-OriginY);
          h1 = heightTex * -OriginY;

 


   left =0;
   right =  1;
   top = 0;
   bottom = 1;
  			
  
		
		
		
var index:Int = currentBatchSize *  vertexStrideSize;

//xy
vertices[index++] = w0;    vertices[index++] = h0;
vertices[index++] = scaleX; vertices[index++] = scaleY;
vertices[index++] = left;  vertices[index++] = top;
vertices[index++] = rotation;
vertices[index++] = alpha;
vertices[index++] = x;    vertices[index++] = y;

	
vertices[index++] = w0;    vertices[index++] = h1;
vertices[index++] = scaleX; vertices[index++] = scaleY;
vertices[index++] = left;  vertices[index++] = bottom;
vertices[index++] = rotation;
vertices[index++] = alpha;
vertices[index++] = x;    vertices[index++] = y;

vertices[index++] = w1;   vertices[index++] = h1;
vertices[index++] = scaleX; vertices[index++] = scaleY;
vertices[index++] = right; vertices[index++] = bottom;
vertices[index++] = rotation;
vertices[index++] = alpha;
vertices[index++] = x;    vertices[index++] = y;

vertices[index++] = w1; vertices[index++] = h0;
vertices[index++] = scaleX; vertices[index++] = scaleY;
vertices[index++] = right; vertices[index++] = top;
vertices[index++] = rotation;
vertices[index++] = alpha;
vertices[index++] = x;    vertices[index++] = y;

this.currentBatchSize++;
}
   public  function setProjMatrix(proj:Matrix4)
   {
	   this.projs = proj;// new Float32Array(proj);

   }
    public  function setViewMatrix(view:Matrix4)
   {
	   this.view = view;// new Float32Array(view);
	   
   }

	public  function Begin()
	{
		 numTex = 0;
	     numBlend = 0;
		 currentBatchSize = 0;
		 currentBlendMode = -1;
		  
		   GL.useProgram (shaderProgram);
		   GL.uniformMatrix4fv(projectionMatrixUniform, false, projs.m);
		   GL.uniformMatrix4fv(modelViewMatrixUniform, false, view.m);
			
		  
		
		   
        GL.bindBuffer(GL.ARRAY_BUFFER, this.vertexBuffer);
		var offset:Int = 0;
	 	GL.enableVertexAttribArray (vertexAttribute);
		GL.vertexAttribPointer(vertexAttribute, 2, GL.FLOAT, false, vertexStrideSize, offset);

		offset += 2;
		

	    GL.enableVertexAttribArray (scaleAttribute);
		GL.vertexAttribPointer(scaleAttribute, 2, GL.FLOAT, false, vertexStrideSize, offset * 4);
		offset += 2;
		
		
		GL.enableVertexAttribArray (texCoordAttribute);
		GL.vertexAttribPointer(texCoordAttribute  , 2, GL.FLOAT, false, vertexStrideSize, offset * 4);
		offset += 2;

		

		GL.enableVertexAttribArray (rotationAttribute);
		GL.vertexAttribPointer(rotationAttribute, 1, GL.FLOAT, false, vertexStrideSize, offset * 4);
		offset +=1;
	
		
		
		
	
	
		GL.enableVertexAttribArray (colorAttribute);
		GL.vertexAttribPointer(colorAttribute, 1, GL.FLOAT, false, vertexStrideSize, offset * 4);
		offset += 1;

		
	
		GL.enableVertexAttribArray (positionAttribute);
		GL.vertexAttribPointer(positionAttribute, 2, GL.FLOAT, false, vertexStrideSize, offset * 4);
		
		
	 

	}
	public   function End()
	{
	  flush();
	}
	
	
	
private   function flush():Void
{
    if (currentBatchSize == 0) return;
	 
	 currentBaseTexture.Bind();
	 GL.uniform1i (imageUniform, 0); numTex++;
	 
  //   GL.bufferData(GL.ARRAY_BUFFER, vertices, GL.STATIC_DRAW);
	GL.bufferSubData(GL.ARRAY_BUFFER, 0, vertices);
	GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, this.indexBuffer);
    GL.drawElements(GL.TRIANGLES, currentBatchSize * 6, GL.UNSIGNED_SHORT, 0);
    
}
private   function switchTexture (texture:Texture) 
{
this.flush();
this.currentBaseTexture = texture;
invTexWidth  = 1.0 / texture.width;
invTexHeight = 1.0 / texture.height;
}

public   function setBlendMode(blendMode:Int)
{
    flush();
    currentBlendMode = blendMode;
    BlendMode.setBlend(currentBlendMode);
    numBlend++;	
}
  public function dispose():Void 
{
	
	GL.deleteProgram(shaderProgram);
	this.vertices = null;
	GL.deleteBuffer(indexBuffer);
	GL.deleteBuffer(vertexBuffer);

	
}
	
}