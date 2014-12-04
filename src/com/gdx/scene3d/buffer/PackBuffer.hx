package com.gdx.scene3d.buffer;
import com.gdx.color.Color4;
import com.gdx.gl.shaders.Shader;
import com.gdx.math.Vector3;
import com.gdx.math.Vector2;
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
 * @author Luis Santos AKA DJOKER
 */
class PackBuffer
{
	public var vertexBuffer:GLBuffer;
	public var buffer:Float32Array;
	public var vertexStrideSize:Int;
	public var capacity:Int;
	public var pipeline:Shader;
	private var index:Int;
	private var dirt:Bool;
	private var mode:Int;
	private var inc:Int;
	private var numvertex:Int;
	
	
	
	public function new(shader:Shader, capacity:Int,type:Int=0) 
	{
	    pipeline = shader;	
		switch (type)
		{
			case 0:mode = GL.STATIC_DRAW;
			case 1:mode = GL.STREAM_DRAW;
			case 2:mode = GL.DYNAMIC_DRAW;
			default :mode = GL.STATIC_DRAW;
		}
		
			index = 0;
		    dirt = true;
	        numvertex = 0;
			inc = 3;
	        inc += 3;
			inc += 2;
			inc += 2;
			inc += 4;
			
		
	   this.capacity = capacity;
	   vertexStrideSize =  inc *4; 
	   vertexBuffer = GL.createBuffer();
	   buffer = new Float32Array(capacity * vertexStrideSize );
	 //  GL.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer);
     //  GL.bufferData(GL.ARRAY_BUFFER, buffer, mode);
     //  GL.bindBuffer(GL.ARRAY_BUFFER, null);	
	}
	private function updtate():Void
    {
		    dirt = false;
		    GL.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer);
	        GL.bufferData(GL.ARRAY_BUFFER, buffer,mode);
			GL.bindBuffer(GL.ARRAY_BUFFER, null);
    }
	public function getPosition(i:Int):Vector3
	{
	
		
		return new Vector3(
		buffer[i * inc+0],
		buffer[i * inc+1],
		buffer[i * inc+2]);
		
		
	}
		public function setPosition(i:Int,v:Vector3):Void
	{
		buffer[i * inc+0] = v.x;
		buffer[i * inc+1] = v.y;
		buffer[i * inc + 2] = v.z;
	
		dirt = true;
	}
	public function packSize():Int
	{
		return index;
	}
	public function numVertex():Int
	{
		return numvertex;
	}

	public function getNormal(index:Int):Vector3
	{
		return new Vector3(
		buffer[index * inc+3],
		buffer[index * inc+4],
		buffer[index * inc+5]);
		
		
	}
	public function getUv0(index:Int):Vector2
	{
		return new Vector2(
		buffer[index * vertexStrideSize+6],
		buffer[index * vertexStrideSize+7]);
	}
	public function getColor(index:Int):Color4
	{
		return new Color4(
		buffer[index * inc+8],
		buffer[index * inc+9],
		buffer[index * inc+10],
		buffer[index * inc+11]);
	}	
	public function addVertex(v:Vector3,n:Vector3,uv0:Vector2,color:Color4):Void
	{
		buffer[index++] = v.x;
		buffer[index++] = v.y;
		buffer[index++] = v.z;
	
		buffer[index++] = n.x;
		buffer[index++] = n.y;
		buffer[index++] = n.z;
		
		
	    buffer[index++] = uv0.x;
		buffer[index++] = uv0.y;
	
		buffer[index++] = uv0.x;
		buffer[index++] = uv0.y;
	
		buffer[index++] = color.r;
		buffer[index++] = color.g;
		buffer[index++] = color.b;
		buffer[index++] = color.a;
		
		numvertex++;
		
		dirt = true;
	}
	
	
	public function render(primitiveType:Int,Num_Triangles:Int):Void
	{
		if (dirt)
		{
			updtate();
		}
		
		var offSet:Int = 0;
		GL.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer);
	
		
	
		GL.vertexAttribPointer(pipeline.vertexAttribute, 3, GL.FLOAT, false, vertexStrideSize, 0); 
    	GL.enableVertexAttribArray (pipeline.vertexAttribute);
		offSet += 3;
	
		GL.vertexAttribPointer(pipeline.normalAttribute, 3, GL.FLOAT, false, vertexStrideSize, offSet*4); 
	    GL.enableVertexAttribArray (pipeline.normalAttribute);
		offSet += 3;
		
		GL.vertexAttribPointer(pipeline.texCoord0Attribute, 2, GL.FLOAT, false,  vertexStrideSize, offSet*4);  
		GL.enableVertexAttribArray (pipeline.texCoord0Attribute);
		offSet += 2;
		
	    GL.vertexAttribPointer(pipeline.texCoord1Attribute, 2, GL.FLOAT, false,  vertexStrideSize, offSet*4);  
		GL.enableVertexAttribArray (pipeline.texCoord1Attribute);
		offSet += 2;
		
		
		GL.vertexAttribPointer(pipeline.colorAttribute, 4, GL.FLOAT, false,  vertexStrideSize, offSet*4);  
	    GL.enableVertexAttribArray (pipeline.colorAttribute);
		
	    
		
        GL.drawArrays(primitiveType, 0, Num_Triangles);
	}
}