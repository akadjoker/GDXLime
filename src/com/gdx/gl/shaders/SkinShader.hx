package com.gdx.gl.shaders;



import com.gdx.color.Color3;
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
class SkinShader extends Shader
{

public var bonesAttribute :Int;
public var wighsAttribute :Int;
public var boneMatrixUniform:Array<Dynamic>;

 

	public function new() 
	{
		super();

			
		 var vertexShader = GL.createShader (GL.VERTEX_SHADER);
        GL.shaderSource (vertexShader, DataShader.VertexShaderSkin);
        GL.compileShader (vertexShader);
        if (GL.getShaderParameter (vertexShader, GL.COMPILE_STATUS) == 0) 
        {throw ("Load Vert:"+GL.getShaderInfoLog(vertexShader));}
		
       var fragmentShader = GL.createShader (GL.FRAGMENT_SHADER);
       GL.shaderSource (fragmentShader, DataShader.FragmentShaderSkin);
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
 



 projMatrixUniform= GL.getUniformLocation (shaderProgram, "ProjectionMatrix");
 worldMatrixUniform = GL.getUniformLocation (shaderProgram, "WorldMatrix");
 viewMatrixUniform = GL.getUniformLocation (shaderProgram, "ViewMatrix");
 boneMatrixUniform = [];
 
 for (i in 0...50)
{
var name:String = "gBones[" + i + "]";
boneMatrixUniform[i] = GL.getUniformLocation (shaderProgram,name);

}

texture0Uniform = GL.getUniformLocation (shaderProgram, "uTextureUnit0");
GL.uniform1i(texture0Uniform, 0);





trace(projMatrixUniform + "," + worldMatrixUniform + "," + viewMatrixUniform);
 

vertexAttribute = GL.getAttribLocation (shaderProgram, "inVertexPosition");
texCoord0Attribute = GL.getAttribLocation (shaderProgram, "inTexCoord0");
texCoord1Attribute = GL.getAttribLocation (shaderProgram, "inTexCoord1");

trace(vertexAttribute+","+texCoord0Attribute+","+texCoord1Attribute );



bonesAttribute = GL.getAttribLocation (shaderProgram, "BoneIDs");



wighsAttribute = GL.getAttribLocation (shaderProgram, "Weights");

trace(bonesAttribute+","+wighsAttribute);


 GL.useProgram (null); 


       
		


	}
	
	public function setBoneMatrix(index:Int,m:Matrix4):Void
	{
 	GL.uniformMatrix4fv(boneMatrixUniform[index], false, m.m );
	}
	
}