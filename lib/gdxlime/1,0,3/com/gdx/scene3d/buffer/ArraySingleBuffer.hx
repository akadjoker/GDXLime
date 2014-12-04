package com.gdx.scene3d.buffer ;

import com.gdx.gl.shaders.Shader;
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
class ArraySingleBuffer
{
	public var vertexBuffer:GLBuffer;
	public var buffer:Float32Array;
	
	
	public var useDetail:Bool;
	public var useTexture:Bool;
	public var useColors:Bool;
	public var useNormals:Bool;
	public var vertexStrideSize:Int;
	public var capacity:Int;
	public var pipeline:Shader;
	
	public function new(shader:Shader,texture0:Bool,texture1:Bool,colors:Bool,normals:Bool) 
	{
		this.pipeline = shader;
		this.useTexture = texture0;
		this.useDetail = texture1;
		this.useColors = colors;
		this.useNormals = normals;
		
		var inc:Int = 3;
		
		if (useTexture)
		{
			inc += 2;
			if (useDetail )
			{
			inc += 2;	
			}
		}
		if (useNormals)
		{
			inc += 3;
		}
		if (useColors)
		{
			inc += 4;
			
		}
		
	 //  this.capacity = capacity;
	   vertexStrideSize =  inc *4 ; 
	   vertexBuffer = GL.createBuffer();
	     //   buffer = new Float32Array(capacity * vertexStrideSize);
	    //    GL.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer);
	    //    GL.bufferData(GL.ARRAY_BUFFER, buffer, GL.STATIC_DRAW);
		//	GL.bindBuffer(GL.ARRAY_BUFFER, null);	
		
		
		
	}
	public function uploadDataBuffer(v:Float32Array):Void
    {
		    buffer = v;
	        GL.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer);
	        GL.bufferData(GL.ARRAY_BUFFER, buffer, GL.STATIC_DRAW);
			GL.bindBuffer(GL.ARRAY_BUFFER, null);	
    }	   
	public function uploadData(v:Array<Float>):Void
    {
		    //buffer = new Float32Array(v);
	        GL.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer);
	        GL.bufferData(GL.ARRAY_BUFFER, new Float32Array(cast v), GL.STATIC_DRAW);
			GL.bindBuffer(GL.ARRAY_BUFFER, null);	
    }
	
	
	public function render(primitiveType:Int,Num_Triangles:Int):Void
	{
		var offSet:Int = 0;
		GL.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer);
		GL.vertexAttribPointer(pipeline.vertexAttribute, 3, GL.FLOAT, false, vertexStrideSize, 0); 
    	GL.enableVertexAttribArray (pipeline.vertexAttribute);
		offSet += 3;
		
		if (useNormals)
		{
		GL.vertexAttribPointer(pipeline.normalAttribute, 3, GL.FLOAT, false, vertexStrideSize, offSet*4); 
	    GL.enableVertexAttribArray (pipeline.normalAttribute);
		offSet += 3;
	    }
	
		
		if (useTexture)
		{
   	    GL.vertexAttribPointer(pipeline.texCoord0Attribute, 2, GL.FLOAT, false,  vertexStrideSize, offSet*4);  
		GL.enableVertexAttribArray (pipeline.texCoord0Attribute);
		offSet += 2;
	     	if (useDetail)
		    {
   	        GL.vertexAttribPointer(pipeline.texCoord1Attribute, 2, GL.FLOAT, false,  vertexStrideSize, offSet*4); 
		    GL.enableVertexAttribArray (pipeline.texCoord1Attribute);
			offSet += 2;
		    } else
		    {
		    GL.disableVertexAttribArray (pipeline.texCoord1Attribute);
		    }
			
		} else
		{
			if (pipeline.texCoord0Attribute != -1)
			{
			 GL.disableVertexAttribArray (pipeline.texCoord0Attribute);
			 GL.disableVertexAttribArray (pipeline.texCoord1Attribute);
			}
		}
  
		if (useColors)
		{
   	    GL.vertexAttribPointer(pipeline.colorAttribute, 4, GL.FLOAT, false,  vertexStrideSize, offSet*4);  
	    GL.enableVertexAttribArray (pipeline.colorAttribute);
		offSet += 4;
	
		}
	    
		
        GL.drawArrays(primitiveType, 0, Num_Triangles);
	}
}