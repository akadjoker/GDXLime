package com.gdx.gl.shaders;

import com.gdx.gl.Texture;
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
class CubeShader extends Shader
{
 public var textureCubeUniform:Dynamic;

 
	public function new() 
	{
		super();
		
		 var vertexShader = GL.createShader (GL.VERTEX_SHADER);
        GL.shaderSource (vertexShader, DataShader.CubeVertexShader);
        GL.compileShader (vertexShader);
        if (GL.getShaderParameter (vertexShader, GL.COMPILE_STATUS) == 0) 
        {throw ("Load Vert:"+GL.getShaderInfoLog(vertexShader));}
		
       var fragmentShader = GL.createShader (GL.FRAGMENT_SHADER);
       GL.shaderSource (fragmentShader, DataShader.CubeFragmentShader);
       GL.compileShader (fragmentShader);
       if (GL.getShaderParameter (fragmentShader, GL.COMPILE_STATUS) == 0) 
	   { throw("Load Frag:"+GL.getShaderInfoLog(fragmentShader));}

shaderProgram = GL.createProgram ();
GL.attachShader (shaderProgram, vertexShader);
GL.attachShader (shaderProgram, fragmentShader);
GL.linkProgram (shaderProgram);

if (GL.getProgramParameter (shaderProgram, GL.LINK_STATUS) == 0) 
{throw "Unable to initialize the shader program.";}


 GL.useProgram (shaderProgram);
 projMatrixUniform= GL.getUniformLocation (shaderProgram, "uProjMatrix");
 worldMatrixUniform = GL.getUniformLocation (shaderProgram, "uWorldMatrix");
 
 texture0Uniform = GL.getUniformLocation (shaderProgram, "uSampler");
 textureCubeUniform = GL.getUniformLocation (shaderProgram, "uCubeSampler");
 
 vertexAttribute = GL.getAttribLocation (shaderProgram, "inVertexPosition");

 texCoord0Attribute = GL.getAttribLocation (shaderProgram, "inVertexTextureCoords");
 
}
	
  public function setCubeMap(tex:Texture):Void
	{
	   if (tex != null)
		{	
		if(tex != Gdx.Instance().currentBaseTexture1 )
       {
       		Gdx.Instance().currentBaseTexture1 = tex;
			tex.Bind(1);
			GL.uniform1i(textureCubeUniform, 1);
			Gdx.Instance().numTextures+=1;
       }
	 }
	 }

  	
}