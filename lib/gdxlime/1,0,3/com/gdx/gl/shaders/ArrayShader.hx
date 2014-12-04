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
 * @author djoekr
 */
class ArrayShader
{

	
 private var shaderProgram:GLProgram;
 private var texture0Uniform:Dynamic;
 
 public var vertexAttribute :Int;
 public var texCoord0Attribute :Int;
 
  
 private var MatrixUniform:Dynamic;

	public function new() 
	{
var VertexShader=
"
attribute vec3 inVertexPosition;
attribute vec2 inTexCoord0;
uniform mat4 uMvpMatrix;
varying vec2 vTexCoord0;
void main(void) 
{
vTexCoord0 = inTexCoord0;
gl_Position = uMvpMatrix *   vec4 (inVertexPosition, 1.0);
}";

 var FragmentShader=

#if !desktop
"precision mediump float;" +
#end
"
varying vec2 vTexCoord0;
uniform sampler2D uTextureUnit0;

void main(void)
{
	gl_FragColor = texture2D (uTextureUnit0, vTexCoord0);

}";
			
		 var vertexShader = GL.createShader (GL.VERTEX_SHADER);
        GL.shaderSource (vertexShader, VertexShader);
        GL.compileShader (vertexShader);
        if (GL.getShaderParameter (vertexShader, GL.COMPILE_STATUS) == 0) 
        {throw ("Load Vert:"+GL.getShaderInfoLog(vertexShader));}
		
       var fragmentShader = GL.createShader (GL.FRAGMENT_SHADER);
       GL.shaderSource (fragmentShader, FragmentShader);
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
 
 
MatrixUniform = GL.getUniformLocation (shaderProgram, "uMvpMatrix");

texture0Uniform = GL.getUniformLocation (shaderProgram, "uTextureUnit0");
GL.uniform1i(texture0Uniform, 0);






vertexAttribute = GL.getAttribLocation (shaderProgram, "inVertexPosition");
texCoord0Attribute = GL.getAttribLocation (shaderProgram, "inTexCoord0");
	}



    public function setMatrix(m:Matrix4):Void
	{
 	GL.uniformMatrix4fv(MatrixUniform, false, m.m );
	}

	public function setTexture0(tex:Texture):Void
	{
	 if (tex != null)
		{	
		if(tex != Gdx.Instance().currentBaseTexture0 )
       {
       		Gdx.Instance().currentBaseTexture0 = tex;
			tex.Bind(0);
			GL.uniform1i(texture0Uniform, 0);
			Gdx.Instance().numTextures++;
       }
	 }
	  
	}
		
	public function Bind():Void
	{
		  GL.useProgram (shaderProgram);
	  	  GL.enableVertexAttribArray (vertexAttribute);
		  GL.enableVertexAttribArray (texCoord0Attribute);
	}
	public function unBind():Void
	{
		  GL.useProgram (null);
	}
}