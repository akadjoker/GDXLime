package com.gdx.gl.shaders;

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
class PointShader extends Shader
{
 

 
	public function new() 
	{
		super();
		
		 var vertexShader = GL.createShader (GL.VERTEX_SHADER);
        GL.shaderSource (vertexShader, DataShader.ParticlesVertexShader);
        GL.compileShader (vertexShader);
        if (GL.getShaderParameter (vertexShader, GL.COMPILE_STATUS) == 0) 
        {throw ("Load Vert:"+GL.getShaderInfoLog(vertexShader));}
		
       var fragmentShader = GL.createShader (GL.FRAGMENT_SHADER);
       GL.shaderSource (fragmentShader, DataShader.ParticlesFragmentShader);
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
 texture0Uniform = GL.getUniformLocation (shaderProgram, "uTextureUnit");

 
 GL.uniform1i(texture0Uniform, 0);
 vertexAttribute = GL.getAttribLocation (shaderProgram, "inVertexPosition");
 colorAttribute = GL.getAttribLocation (shaderProgram, "inVertexColor");
 texCoord0Attribute = GL.getAttribLocation (shaderProgram, "inTexCoord");
 
}
	
  	
}