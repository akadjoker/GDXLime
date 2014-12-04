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
class Flat extends Shader
{
	
 
 

    
		
 
 private var MaterialUniform:Dynamic;
 

  
 private var TintUniform:Dynamic;
 private var AmbientUniform:Dynamic;
 private var lightPosUniform:Dynamic;
 
 
 private var materialType:Int;
 private var lastmaterialType:Int;

	public function new() 
	{
		super();
		 materialType =0 ;
		 lastmaterialType = -1;
			
		 var vertexShader = GL.createShader (GL.VERTEX_SHADER);
        GL.shaderSource (vertexShader, DataShader.VertexShader);
        GL.compileShader (vertexShader);
        if (GL.getShaderParameter (vertexShader, GL.COMPILE_STATUS) == 0) 
        {throw ("Load Vert:"+GL.getShaderInfoLog(vertexShader));}
		
       var fragmentShader = GL.createShader (GL.FRAGMENT_SHADER);
       GL.shaderSource (fragmentShader, DataShader.FragmentShader);
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
 

texture0Uniform = GL.getUniformLocation (shaderProgram, "uTextureUnit0");
texture1Uniform = GL.getUniformLocation (shaderProgram, "uTextureUnit1");
GL.uniform1i(texture0Uniform, 0);
GL.uniform1i(texture1Uniform, 1);

MaterialUniform = GL.getUniformLocation (shaderProgram, "uMaterialType");
GL.uniform1i(MaterialUniform, 0);



textureUsageUniform = GL.getUniformLocation (shaderProgram, "uTextureUsage0");
GL.uniform1i(textureUsageUniform, 0);

TintUniform = GL.getUniformLocation (shaderProgram, "Tint");
AmbientUniform = GL.getUniformLocation (shaderProgram, "Ambient");
lightPosUniform= GL.getUniformLocation (shaderProgram, "LightPos");
GL.uniform4f(TintUniform, 1, 1, 1, 1);
GL.uniform4f(AmbientUniform, 0.8,0.8,0.8, 1);
GL.uniform3f(lightPosUniform, 100,100,-100);


//trace(projMatrixUniform+","+worldMatrixUniform+","+viewMatrixUniform+","+TintUniform+","+AmbientUniform );

//trace(projMatrixUniform + "," + worldMatrixUniform + "," + viewMatrixUniform);
 

vertexAttribute = GL.getAttribLocation (shaderProgram, "inVertexPosition");
texCoord0Attribute = GL.getAttribLocation (shaderProgram, "inTexCoord0");
texCoord1Attribute = GL.getAttribLocation (shaderProgram, "inTexCoord1");
colorAttribute = GL.getAttribLocation (shaderProgram, "inVertexColor");
normalAttribute = GL.getAttribLocation (shaderProgram, "inVertexNormal");

#if debug trace(vertexAttribute+"," + normalAttribute+"," + texCoord0Attribute+"," + texCoord1Attribute+"," + colorAttribute ); #end


 GL.useProgram (null); 


       
		


	}
	
	
	public function setMaterialType(type:Int):Void
	{
		if (lastmaterialType != type)
		{
	     materialType = type;
		 lastmaterialType = type;
 	     MaterialUniform = GL.getUniformLocation (shaderProgram, "uMaterialType");
         GL.uniform1i(MaterialUniform, materialType);
		}
	}
	
public function setAmbient(r:Float,g:Float,b:Float,a:Float):Void
	{
     AmbientUniform = GL.getUniformLocation (shaderProgram, "Ambient");
     GL.uniform4f(AmbientUniform, r,g,b,a);
	}
public function setLightPosition(x:Float,y:Float, z:Float):Void
	{
     lightPosUniform = GL.getUniformLocation (shaderProgram, "LightPos");
     GL.uniform3f(lightPosUniform, x,y,z);
	}	
public function setColor(r:Float,g:Float,b:Float,a:Float):Void
	{
     TintUniform = GL.getUniformLocation (shaderProgram, "Tint");
     GL.uniform4f(TintUniform, r,g,b,a);
	}
	

	 
	

		
		
			 
		
	
}