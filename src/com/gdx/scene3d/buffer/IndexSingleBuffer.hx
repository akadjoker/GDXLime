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
class IndexSingleBuffer
{
	public var vertexBuffer:GLBuffer;
	public var  indexBuffer:GLBuffer;

	
	public var useDetail:Bool;
	public var useTexture:Bool;
	public var useColors:Bool;
	public var useNormals:Bool;
	public var vertexStrideSize:Int;

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
	
	   vertexStrideSize =  inc *4 ; 
	   vertexBuffer = GL.createBuffer();
	   indexBuffer = GL.createBuffer();
	
		
	}
	public function uploadIndices(v:Array<Int>):Void
    {

	       GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indexBuffer);
           GL.bufferData(GL.ELEMENT_ARRAY_BUFFER,  new Int16Array(v), GL.STATIC_DRAW);
		   GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, null);
		   
   }

   
	public function uploadData(v:Array<Float>):Void
    {
	        GL.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer);
	        GL.bufferData(GL.ARRAY_BUFFER,  new Float32Array ( v), GL.STATIC_DRAW);
			GL.bindBuffer(GL.ARRAY_BUFFER, null);	
    }
	public function uploadDataBuffer(v:Float32Array):Void
    {
	        GL.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer);
	        GL.bufferData(GL.ARRAY_BUFFER,  v, GL.STATIC_DRAW);
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
	    } else
		{
			if(pipeline.normalAttribute!=-1) GL.disableVertexAttribArray(pipeline.normalAttribute);
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
		    if (pipeline.texCoord1Attribute != -1)GL.disableVertexAttribArray (pipeline.texCoord1Attribute);
		    }
			
		} else
		{
			if (pipeline.texCoord0Attribute != -1) GL.disableVertexAttribArray (pipeline.texCoord0Attribute);
			if (pipeline.texCoord1Attribute != -1)GL.disableVertexAttribArray (pipeline.texCoord1Attribute);
			
			 
		}
	
			
		
  
		if (useColors)
		{
   	    GL.vertexAttribPointer(pipeline.colorAttribute, 4, GL.FLOAT, false,  vertexStrideSize, offSet*4);  
	    GL.enableVertexAttribArray (pipeline.colorAttribute);
		offSet += 4;
		} else
		{
			if (pipeline.colorAttribute != -1)GL.disableVertexAttribArray (pipeline.colorAttribute);
		}
		

				
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indexBuffer);
        GL.drawElements(primitiveType, Num_Triangles, GL.UNSIGNED_SHORT, 0);
	}
	public function dispose()
	{
		GL.deleteBuffer(vertexBuffer);
		GL.deleteBuffer(indexBuffer );
	}
}