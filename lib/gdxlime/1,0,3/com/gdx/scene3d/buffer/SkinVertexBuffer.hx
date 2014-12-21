package com.gdx.scene3d.buffer ;

import com.gdx.gl.shaders.Shader;
import com.gdx.gl.shaders.SkinShader;
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
 * @author djoekr
 */
class SkinVertexBuffer
{
  	
	public var coordBuffer:GLBuffer;
	public var bonesBuffer:GLBuffer;
	public var wighsBuffer:GLBuffer;
	public var tex0Buffer:GLBuffer;
	public var  indexBuffer:GLBuffer;
	private var indicescount:Int;
	public var useDetail:Bool;
	public var useTexture:Bool;

	
	public var pipeline:SkinShader;
	
	public function new(shader:SkinShader) 
	{
		this.pipeline = shader;
		

	
			useTexture = true;
			
		
		
		
		coordBuffer = GL.createBuffer();
		
		tex0Buffer = GL.createBuffer();
		
	
bonesBuffer=GL.createBuffer();
wighsBuffer=GL.createBuffer();
	
		
		indexBuffer = GL.createBuffer();
		
		
	}
	public function uploadIndices(v:Array<Int>):Void
    {
	       GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indexBuffer);
           GL.bufferData(GL.ELEMENT_ARRAY_BUFFER,  new Int16Array(v), GL.STATIC_DRAW);
		   GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, null);
		   indicescount = v.length;
		   
   }
   public function uploadBones(v:Array<Float>):Void
    {
	       GL.bindBuffer(GL.ARRAY_BUFFER, bonesBuffer);
           GL.bufferData(GL.ARRAY_BUFFER,  new Float32Array(v), GL.STATIC_DRAW);
		   GL.bindBuffer(GL.ARRAY_BUFFER, null);
   }
	 public function uploadHeigs(v:Array<Float>):Void
    {
		    GL.bindBuffer(GL.ARRAY_BUFFER, wighsBuffer);
	        GL.bufferData(GL.ARRAY_BUFFER,  new Float32Array( v), GL.STATIC_DRAW);
			GL.bindBuffer(GL.ARRAY_BUFFER, null);
    }  
	public function uploadVertex(v:Array<Float>):Void
    {
		    GL.bindBuffer(GL.ARRAY_BUFFER, coordBuffer);
	        GL.bufferData(GL.ARRAY_BUFFER,  new Float32Array( v), GL.STATIC_DRAW);
			GL.bindBuffer(GL.ARRAY_BUFFER, null);
    }

	public function uploadUVCoord0(v:Array<Float>):Void
    {
		   if (!useTexture) return;
		    GL.bindBuffer(GL.ARRAY_BUFFER, tex0Buffer);
	        GL.bufferData(GL.ARRAY_BUFFER,  new Float32Array( v), GL.STATIC_DRAW);
			GL.bindBuffer(GL.ARRAY_BUFFER, null);
    }
	
			public function setUVCoord0(v:Float32Array):Void
    {
		   if (!useTexture) return;
		    GL.bindBuffer(GL.ARRAY_BUFFER, tex0Buffer);
	        GL.bufferData(GL.ARRAY_BUFFER, v , GL.STATIC_DRAW);
	 }

		public function setVertex(v:Float32Array):Void
    {
		    GL.bindBuffer(GL.ARRAY_BUFFER, coordBuffer);
	        GL.bufferData(GL.ARRAY_BUFFER,  v, GL.STATIC_DRAW);
	  }	 
	
	public function render(primitiveType:Int,Num_Triangles:Int):Void
	{
	
		GL.bindBuffer(GL.ARRAY_BUFFER, coordBuffer);
		GL.vertexAttribPointer(pipeline.vertexAttribute, 3, GL.FLOAT, false, 0, 0); 
    	GL.enableVertexAttribArray (pipeline.vertexAttribute);
		

		
		if (useTexture)
		{
			if (pipeline.texCoord0Attribute != -1)
			{
	         GL.bindBuffer(GL.ARRAY_BUFFER, tex0Buffer);
   	         GL.vertexAttribPointer(pipeline.texCoord0Attribute, 2, GL.FLOAT, false, 0, 0);  
		     GL.enableVertexAttribArray (pipeline.texCoord0Attribute);
			}
	     	
			
		} else
		{
			if(pipeline.texCoord0Attribute>=0) GL.disableVertexAttribArray (pipeline.texCoord0Attribute);
		}
  

		    if (pipeline.bonesAttribute != -1)
			{
	         GL.bindBuffer(GL.ARRAY_BUFFER, bonesBuffer);
   	         GL.vertexAttribPointer(pipeline.bonesAttribute, 4, GL.FLOAT, false, 0, 0);  
		     GL.enableVertexAttribArray (pipeline.bonesAttribute);
			}
			
			 if (pipeline.wighsAttribute != -1)
			{
	         GL.bindBuffer(GL.ARRAY_BUFFER, wighsBuffer);
   	         GL.vertexAttribPointer(pipeline.wighsAttribute, 4, GL.FLOAT, false, 0, 0);  
		     GL.enableVertexAttribArray (pipeline.wighsAttribute);
			}
			

		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indexBuffer);
        GL.drawElements(primitiveType, Num_Triangles, GL.UNSIGNED_SHORT, 0);
		
		
		 
	}
	public function dispose()
	{
		GL.deleteBuffer(coordBuffer);
		GL.deleteBuffer(tex0Buffer);
		GL.deleteBuffer(indexBuffer );
	}
}