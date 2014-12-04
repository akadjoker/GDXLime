package com.gdx.gl.shaders;
import com.gdx.gl.Texture;
import com.gdx.math.Matrix4;
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
class Shader
{
	
 public var textureUsageUniform:Dynamic;
 public var texture0Uniform:Dynamic;
 public var texture1Uniform:Dynamic;
 
 
 public var shaderProgram:GLProgram;
 
 public var projMatrixUniform:Dynamic;
 public var worldMatrixUniform:Dynamic;
 public var viewMatrixUniform:Dynamic;
 
 public var vertexAttribute :Int;
 public var normalAttribute :Int;
 public var colorAttribute :Int;
 public var texCoord0Attribute :Int;
 public var texCoord1Attribute :Int;

 
 
	public function new() 
	{
		vertexAttribute = -1;
		normalAttribute = -1;
		colorAttribute = -1;
		texCoord0Attribute = -1;
		texCoord1Attribute = -1;
		
	}
	public function setProjMatrix(m:Matrix4):Void
	{
    GL.uniformMatrix4fv(projMatrixUniform, false, m.m );
	}
	public function setViewMatrix(m:Matrix4):Void
	{
 	GL.uniformMatrix4fv(viewMatrixUniform, false, m.m );
	}
	public function setWorldMatrix(m:Matrix4):Void
	{
 	GL.uniformMatrix4fv(worldMatrixUniform, false, m.m );
	}
	public function setTexture0(tex:Texture):Void
	{
		if (texCoord0Attribute == -1) return;
	 if (tex != null)
		{	
		if(tex != Gdx.Instance().currentBaseTexture0 )
       {
       		Gdx.Instance().currentBaseTexture0 = tex;
			tex.Bind(0);
			GL.uniform1i(texture0Uniform, 0);
			Gdx.Instance().numTextures+=1;
       }
	 }
	  
	}

    public function setTexture1(tex:Texture):Void
	{
		if (texCoord1Attribute == -1) return;
	   if (tex != null)
		{	
		if(tex != Gdx.Instance().currentBaseTexture1 )
       {
       		Gdx.Instance().currentBaseTexture1 = tex;
			tex.Bind(1);
			GL.uniform1i(texture1Uniform, 1);
			Gdx.Instance().numTextures+=1;
       }
	 }
	 }

	public function enableTexture(b:Bool):Void
	{
		 GL.useProgram (shaderProgram);
	 	 var i:Int = b? 1 :0;
	     GL.uniform1i(textureUsageUniform, i);
	}
	public function Bind():Void
	{
		  GL.useProgram (shaderProgram);
		/*
	      GL.enableVertexAttribArray (vertexAttribute);
		  GL.enableVertexAttribArray (normalAttribute);
		  GL.enableVertexAttribArray (colorAttribute);
		  GL.enableVertexAttribArray (texCoord0Attribute);
		  GL.enableVertexAttribArray (texCoord1Attribute);
		*/
	
		
	  	
	}
	public function unBind():Void
	{
		  GL.useProgram (null);
		  	  
		if (vertexAttribute != -1)
		{
		 GL.disableVertexAttribArray (vertexAttribute);
		}
		
			if (normalAttribute != -1)
			{
		     GL.disableVertexAttribArray (normalAttribute);
			}
	      
		
		     if (texCoord0Attribute != -1)
			{
	 	      GL.disableVertexAttribArray (texCoord0Attribute);
		    } 
		      
			if (texCoord1Attribute != -1)
				{
	                 GL.disableVertexAttribArray (texCoord1Attribute);
				}	
		
  
		
			if (colorAttribute != -1)
			{
	        GL.disableVertexAttribArray (colorAttribute);
			}
	
	}
}