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
class AmbientLight extends Shader
{
	
 
 


 
    
		
 
 private var MaterialUniform:Dynamic;
 private var normalMatrixUniform:Dynamic;
 private var MVMatrixUniform:Dynamic;
 
 
 private var uAmbientColor:Dynamic;
 private var uDirectionalColor:Dynamic;
 
  private var useLight:Dynamic;
 

 
  
 private var uMaterialAmbient:Dynamic;
 private var uMaterialDiffuse:Dynamic;
 private var uMaterialSpecular:Dynamic;
 
 private var uShininess:Dynamic;
 private var uLightAmbient:Dynamic;
 private var uLightDiffuse:Dynamic;
 private var uLightSpecular:Dynamic;
 
 private var uLightDirection:Dynamic;
 
 
 private var materialType:Int;
 private var lastmaterialType:Int;

	public function new() 
	{
		super();
		 materialType =0 ;
		 lastmaterialType = -1;
			
		 var vertexShader = GL.createShader (GL.VERTEX_SHADER);
        GL.shaderSource (vertexShader, DataShader.VertexShaderAmbient);
        GL.compileShader (vertexShader);
        if (GL.getShaderParameter (vertexShader, GL.COMPILE_STATUS) == 0) 
        {throw ("Load Vert:"+GL.getShaderInfoLog(vertexShader));}
		
       var fragmentShader = GL.createShader (GL.FRAGMENT_SHADER);
       GL.shaderSource (fragmentShader, DataShader.FragmentShaderAmbient);
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
 //worldMatrixUniform = GL.getUniformLocation (shaderProgram, "WorldMatrix");
 //viewMatrixUniform = GL.getUniformLocation (shaderProgram, "ViewMatrix");
 MVMatrixUniform= GL.getUniformLocation (shaderProgram, "uMVMatrix");
 normalMatrixUniform = GL.getUniformLocation (shaderProgram, "NormalMatrix");


texture0Uniform = GL.getUniformLocation (shaderProgram, "uTextureUnit0");
texture1Uniform = GL.getUniformLocation (shaderProgram, "uTextureUnit1");
GL.uniform1i(texture0Uniform, 0);
GL.uniform1i(texture1Uniform, 1);

MaterialUniform = GL.getUniformLocation (shaderProgram, "uMaterialType");
GL.uniform1i(MaterialUniform, 0);

textureUsageUniform = GL.getUniformLocation (shaderProgram, "uTextureUsage0");
GL.uniform1i(textureUsageUniform, 0);


    uAmbientColor	= GL.getUniformLocation (shaderProgram, "uAmbientColor");	
	uDirectionalColor     	= GL.getUniformLocation (shaderProgram, "uDirectionalColor");
	uLightDirection    	= GL.getUniformLocation (shaderProgram, "uLightDirection");
	useLight = GL.getUniformLocation (shaderProgram, "uUseLighting");
	 
	
	GL.uniform3f(uLightDirection,-0.25, -0.25, -1.0);
	GL.uniform3f(uDirectionalColor,0.8,0.0,0.0);
	GL.uniform3f(uAmbientColor, 0.8, 0.8, 0.8);	

     GL.uniform1i(useLight, 1);
	
/*
    uMaterialAmbient	=GL.getUniformLocation (shaderProgram, "uMaterialAmbient");	
	uMaterialDiffuse    = GL.getUniformLocation (shaderProgram, "uMaterialDiffuse");
	uMaterialSpecular	= GL.getUniformLocation (shaderProgram, "uMaterialSpecular");
	
	uShininess         	=GL.getUniformLocation (shaderProgram,"uShininess");
	
	uLightAmbient     	= GL.getUniformLocation (shaderProgram, "uLightAmbient");
	uLightDiffuse       = GL.getUniformLocation (shaderProgram, "uLightDiffuse");
	uLightSpecular		=GL.getUniformLocation (shaderProgram, "uLightSpecular");
	
	uLightDirection    	= GL.getUniformLocation (shaderProgram, "uLightDirection");


    GL.uniform3f(uLightDirection,-0.25, -0.25, -0.25);
	GL.uniform4f(uLightAmbient,0.5,0.5,0.5,1.0);
	GL.uniform4f(uLightDiffuse, 1.0,1.0,1.0,1.0);	
	GL.uniform4f(uLightSpecular, 1.0,1.0,1.0,1.0);
    
	GL.uniform4f(uMaterialAmbient, 1.0,1.0,1.0,1.0);
	GL.uniform4f(uMaterialDiffuse, 1.0,1.0,1.0,1.0);
	GL.uniform4f(uMaterialSpecular, 1.0,1.0,1.0,1.0);
    GL.uniform1f(uShininess, 10.0);
	*/
//trace(projMatrixUniform + "," + worldMatrixUniform + "," + viewMatrixUniform);
 

vertexAttribute = GL.getAttribLocation (shaderProgram, "inVertexPosition");
texCoord0Attribute = GL.getAttribLocation (shaderProgram, "inTexCoord0");
texCoord1Attribute = GL.getAttribLocation (shaderProgram, "inTexCoord1");
colorAttribute = GL.getAttribLocation (shaderProgram, "inVertexColor");
normalAttribute = GL.getAttribLocation (shaderProgram, "inVertexNormal");

trace(vertexAttribute+","+normalAttribute+","+texCoord0Attribute+","+texCoord1Attribute+","+colorAttribute );

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
	

	
	
     public function setLightShininess(v:Float):Void
	{
     uShininess = GL.getUniformLocation (shaderProgram, "uShininess");
     GL.uniform1f(uShininess, v);
	}	
	
	
     public function setLightDirection(x:Float,y:Float, z:Float):Void
	{
       GL.uniform3f(uLightDirection, x,y,z);
	}	
	
	
	
    public function setDiffuse(r:Float,g:Float,b:Float,a:Float):Void
	{
     uLightDiffuse = GL.getUniformLocation (shaderProgram, "uLightDiffuse");
     GL.uniform4f(uLightDiffuse, r,g,b,a);
	}
	public function setAmbient(r:Float,g:Float,b:Float,a:Float):Void
	{
     uLightAmbient = GL.getUniformLocation (shaderProgram, "uLightAmbient");
     GL.uniform4f(uLightAmbient, r,g,b,a);
	}
	public function setSpecular(r:Float,g:Float,b:Float,a:Float):Void
	{
     uLightSpecular = GL.getUniformLocation (shaderProgram, "uLightSpecular");
     GL.uniform4f(uLightSpecular, r,g,b,a);
	}
	
	
	public function setMaterialDiffuse(r:Float,g:Float,b:Float,a:Float):Void
	{
     uMaterialAmbient = GL.getUniformLocation (shaderProgram, "uMaterialAmbient");
     GL.uniform4f(uMaterialAmbient, r,g,b,a);
	}
	public function setMaterialAmbient(r:Float,g:Float,b:Float,a:Float):Void
	{
     uMaterialDiffuse = GL.getUniformLocation (shaderProgram, "uMaterialDiffuse");
     GL.uniform4f(uMaterialDiffuse, r,g,b,a);
	}
	public function setMaterialSpecular(r:Float,g:Float,b:Float,a:Float):Void
	{
     uMaterialSpecular = GL.getUniformLocation (shaderProgram, "uMaterialSpecular");
     GL.uniform4f(uMaterialSpecular, r,g,b,a);
	}

	public function setAmbientColor(r:Float,g:Float,b:Float):Void
	{
     GL.uniform3f(uAmbientColor, r,g,b);
	}
	public function setLightColor(r:Float,g:Float,b:Float):Void
	{
     GL.uniform3f(uDirectionalColor, r,g,b);
	}
	
	
	
 public function setNormalMatrix(m:Matrix4):Void
	{
 	GL.uniformMatrix4fv(normalMatrixUniform, false, m.m );
	}
 public function setMVMatrix(m:Matrix4):Void
	{
 	GL.uniformMatrix4fv(MVMatrixUniform, false, m.m );
	}	
	 
	

		
		
			 
		
	
}