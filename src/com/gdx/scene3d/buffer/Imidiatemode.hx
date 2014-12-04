package com.gdx.scene3d.buffer ;




import com.gdx.math.Matrix4;
import com.gdx.math.Vector2;
import com.gdx.math.Vector3;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLShader;
import lime.graphics.opengl.GLUniformLocation;
import lime.graphics.opengl.GLTexture;
import lime.graphics.RenderContext;
import lime.utils.Float32Array;
import lime.utils.Int16Array;







/**
 * ...
 * @author djoker
 */
class Imidiatemode

{
	public var colorBuffer:GLBuffer;
	public var colorIndex:Int;
	public var colors:Float32Array;
	public var vertexBuffer:GLBuffer;
	public var vertices:Float32Array;

	public var fcolorBuffer:GLBuffer;
	public var fcolorIndex:Int;
	public var fcolors:Float32Array;
	public var fvertexBuffer:GLBuffer;
	public var fvertices:Float32Array;
	
    private var capacity:Int;


	private var alpha:Float = 1;
	public var _red:Float=1;
	public var _green:Float=1;
	public var _blue:Float=1;
	   
	private var cp:Vector2 = new Vector2(0, 0);

	private var currentBlendMode:Int;


	private var idxCols:Int;
	private var idxPos:Int;

	
    private var fidxCols:Int;
	private var fidxPos:Int;

   
 private var shaderProgram:GLProgram;
	
 public var vertexAttribute :Int;
 public var colorAttribute :Int;
 public var vpwMatrixUniform:Dynamic;
 
 private  var transform:Matrix4;

  




	
	public function new(capacity:Int) 
	{
		
		
 var colorVertexShader=
"
attribute vec3 aVertexPosition;
attribute vec4 aColor;
varying vec4 vColor;
uniform mat4 vpwMatrix;



void main(void) 
{
vColor = aColor;
gl_Position = vpwMatrix * vec4 (aVertexPosition, 1.0);

}";


 var colorFragmentShader=

#if !desktop
"precision mediump float;" +
#end
"
varying vec4 vColor;
void main(void)
{
	gl_FragColor =  vColor;
}";
		
var vertexShader = GL.createShader (GL.VERTEX_SHADER);
GL.shaderSource (vertexShader, colorVertexShader);
GL.compileShader (vertexShader);

if (GL.getShaderParameter (vertexShader, GL.COMPILE_STATUS) == 0) 
{

throw (GL.getShaderInfoLog(vertexShader));

}


var fragmentShader = GL.createShader (GL.FRAGMENT_SHADER);
GL.shaderSource (fragmentShader, colorFragmentShader);
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
colorAttribute = GL.getAttribLocation (shaderProgram, "aColor");
vpwMatrixUniform = GL.getUniformLocation (shaderProgram, "vpwMatrix");






transform = Matrix4.Identity();

	
	this.vertexBuffer =  GL.createBuffer();
	this.colorBuffer =  GL.createBuffer();
	this.fvertexBuffer =  GL.createBuffer();
	this.fcolorBuffer =  GL.createBuffer();
	this.capacity = capacity;

    idxPos=0;
	idxCols = 0;


	fidxPos=0;
	fidxCols = 0;

    vertices = new Float32Array(capacity * 3 *4*4);
	GL.bindBuffer(GL.ARRAY_BUFFER, this.vertexBuffer);
	GL.bufferData(GL.ARRAY_BUFFER,this.vertices , GL.DYNAMIC_DRAW);
	colors = new Float32Array(capacity * 4 * 4*4);
	GL.bindBuffer(GL.ARRAY_BUFFER, this.colorBuffer);
	GL.bufferData(GL.ARRAY_BUFFER, this.colors , GL.DYNAMIC_DRAW);
    
	fvertices = new Float32Array(capacity * 3 *4*4);
	GL.bindBuffer(GL.ARRAY_BUFFER, this.fvertexBuffer);
	GL.bufferData(GL.ARRAY_BUFFER,this.fvertices , GL.DYNAMIC_DRAW);
	fcolors = new Float32Array(capacity * 4 * 4*4);
	GL.bindBuffer(GL.ARRAY_BUFFER, this.fcolorBuffer);
	GL.bufferData(GL.ARRAY_BUFFER, this.fcolors , GL.DYNAMIC_DRAW);

	}
	
	
public function fvertex(x:Float, y:Float, ?z:Float = 0.0)
{
		fvertices[fidxPos++] = x;
        fvertices[fidxPos++] = y;
        fvertices[fidxPos++] = z;
	
}
public function fcolor(r:Float, g:Float,b:Float, ?a:Float =0.0)
	{
	fcolors[fidxCols++] = r;
	fcolors[fidxCols++] = g;
	fcolors[fidxCols++] = b;
	fcolors[fidxCols++] = a;	
	}
	
	
public function vertex(x:Float, y:Float, ?z:Float = 0.0)
{
		vertices[idxPos++] = x;
        vertices[idxPos++] = y;
        vertices[idxPos++] = z;
	
}
public function color(r:Float, g:Float,b:Float, ?a:Float =0.0)
	{
	colors[idxCols++] = r;
	colors[idxCols++] = g;
	colors[idxCols++] = b;
	colors[idxCols++] = a;	
	}


	public function reset()
	{
	 idxPos=0;
	 idxCols = 0;
	 fidxPos=0;
	 fidxCols = 0;
	}
	
    public function render(camera:Camera)
	{
//	  if (idxPos<=0 || fidxPos <=0) return;

		Gdx.Instance().setCullFace(false);
		Gdx.Instance().setBlend(false);
	//	Gdx.Instance().setDepthMask(false);
	//	Gdx.Instance().setDepthTest(false);

  if (idxPos >= capacity) idxPos = capacity;
  if (fidxPos >= capacity) fidxPos = capacity;

		
	 var WorldMat:Matrix4 = Matrix4.Identity();
     transform.multiplyToRef( camera.getProjViewMatrix(), WorldMat);
	 
	 
	 GL.useProgram (shaderProgram);
     GL.uniformMatrix4fv(vpwMatrixUniform, false, new Float32Array(WorldMat.m) );
	 
	  GL.enableVertexAttribArray (vertexAttribute);
	  GL.enableVertexAttribArray (colorAttribute);
		 
	
if(fidxPos >= 1)
{
	 GL.bindBuffer(GL.ARRAY_BUFFER, this.fvertexBuffer);	
     GL.bufferSubData(GL.ARRAY_BUFFER, 0, this.fvertices);
     GL.vertexAttribPointer(vertexAttribute, 3, GL.FLOAT, false, 0, 0);
	 GL.bindBuffer(GL.ARRAY_BUFFER, this.fcolorBuffer);
	 GL.bufferSubData(GL.ARRAY_BUFFER, 0, this.fcolors);
     GL.vertexAttribPointer(colorAttribute, 4, GL.FLOAT, false, 0, 0);
 	 GL.drawArrays( GL.TRIANGLES, 0, Std.int(fidxPos / 3));
}
	
	 
	 
	
if(idxPos >= 1)
{
	 GL.bindBuffer(GL.ARRAY_BUFFER, this.vertexBuffer);	
     GL.bufferData(GL.ARRAY_BUFFER, this.vertices , GL.STATIC_DRAW);
	 GL.vertexAttribPointer(vertexAttribute, 3, GL.FLOAT, false, 0, 0);
	 
	 GL.bindBuffer(GL.ARRAY_BUFFER, this.colorBuffer);
	 GL.bufferData(GL.ARRAY_BUFFER, this.colors , GL.STATIC_DRAW);
	 GL.vertexAttribPointer(colorAttribute, 4, GL.FLOAT, false, 0, 0);

	 
	 GL.drawArrays(GL.LINES, 0, Std.int(idxPos / 3));
	   
}
	 
	 
	 
	 

  
	 
	}


	
	//**********
	public function circle (x:Float, y:Float, radius:Float , segments:Int,r:Float,g:Float,b:Float,?a:Float=1 ) 
	{
	
		var angle:Float = 2 * 3.1415926 / segments;
		var cos:Float = Math.cos(angle);
		var sin:Float = Math.sin(angle);
		var cx:Float = radius;
		var cy:Float = 0;
		for ( i  in 0...segments)
		 {
	
				vertex(x + cx, y + cy, 0);color(r, g, b, a);
				var temp = cx;
				cx = cos * cx - sin * cy;
				cy = sin * temp + cos * cy;
				
				vertex(x + cx, y + cy, 0);color(r, g, b, a);
			}
			
			vertex(x + cx, y + cy, 0);color(r, g, b, a);
			
			vertex(x, y, 0);color(r, g, b, a);
			
			vertex(x + cx, y + cy, 0);color(r, g, b, a);
		

		var temp:Float = cx;
		cx = radius;
		cy = 0;
		
		vertex(x + cx, y + cy, 0);color(r, g, b, a);
	}


	public function ellipse ( x:Float, y:Float, width:Float, height:Float, segments:Int,r:Float,g:Float,b:Float,?a:Float=1 ) 
	{
	
		var  angle:Float = 2 * 3.1415926/ segments;

		var cx:Float = x + width / 2; 
		var cy:Float = y + height / 2;
		

			for (i in 0... segments)
			{
	
				vertex(cx + (width * 0.5 * Math.cos(i * angle)), cy + (height * 0.5 * Math.sin(i * angle)), 0);
				color(r, g, b, a);

		
				vertex(cx + (width * 0.5 * Math.cos((i + 1) * angle)),cy + (height * 0.5 * Math.sin((i + 1) * angle)), 0);
				color(r, g, b, a);
			}
		
	}

public function line(x1:Float,y1:Float,x2:Float,y2:Float,r:Float,g:Float,b:Float,?a:Float=1)
{

vertex(x1, y1);
color(r, g, b, a);
vertex(x2, y2);
color(r, g, b, a);
}
public function lineVector(va:Vector3,vb:Vector3,r:Float,g:Float,b:Float,?a:Float=1)
{

vertex(va.x,va.y,va.z);
color(r, g, b, a);
vertex(vb.x,vb.y,vb.z);
color(r, g, b, a);
}

public function drawFullTriangle(va:Vector3,vb:Vector3,vc:Vector3,r:Float,g:Float,b:Float,?a:Float=1)
{

fvertex(va.x,va.y,va.z);
fcolor(r, g, b, a);
fvertex(vb.x,vb.y,vb.z);
fcolor(r, g, b, a);
fvertex(vc.x,vc.y,vc.z);
fcolor(r, g, b, a);
Gdx.Instance().numVertex += 6;
Gdx.Instance().numTris += 1;

}

public function drawTriangle(va:Vector3,vb:Vector3,vc:Vector3,r:Float,g:Float,b:Float,?a:Float=1)
{

vertex(va.x,va.y,va.z);
color(r, g, b, a);
vertex(vb.x,vb.y,vb.z);
color(r, g, b, a);
vertex(vc.x,vc.y,vc.z);
color(r, g, b, a);

Gdx.Instance().numVertex += 6;
Gdx.Instance().numTris += 1;

}
public function line3D(x1:Float,y1:Float,z1:Float,x2:Float,y2:Float,z2:Float,r:Float=1,g:Float=1,b:Float=1,?a:Float=1)
{

vertex(x1, y1,z1);
color(r, g, b, a);
vertex(x2, y2,z2);
color(r, g, b, a);
}
public function rect(x:Float,y:Float,width:Float,height:Float,r:Float,g:Float,b:Float,?a:Float=1)
{
			vertex(x, y, 0);color(r, g, b, a);
			vertex(x + width, y, 0);color(r, g, b, a);
			vertex(x + width, y, 0);color(r, g, b, a);
			vertex(x + width, y + height, 0);color(r, g, b, a);
			vertex(x + width, y + height, 0);color(r, g, b, a);
			vertex(x, y + height, 0);color(r, g, b, a);
			vertex(x, y + height, 0);color(r, g, b, a);
			vertex(x, y, 0);color(r, g, b, a);
}


public function setColor(color:Int = 0, alpha:Float = 1.0):Void
{
	    this.alpha = alpha;
      	color &= 0xFFFFFF;
	    _red = Util.getRed(color) / 255;
		_green = Util.getGreen(color) / 255;
		_blue = Util.getBlue(color) / 255;
}


public function drawRect(x:Float, y:Float, width:Float, height:Float):Void
{
rect(x, y, width, height, _red, _green, _blue, alpha);
}



 public function dispose():Void 
{
	    GL.deleteProgram(shaderProgram);
		this.vertices = null;
		this.colors = null;
    	GL.deleteBuffer(vertexBuffer);
		GL.deleteBuffer(colorBuffer);
	
		
}


}