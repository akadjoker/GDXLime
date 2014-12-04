package com.gdx.gl.shaders;

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
class SplatTerrainShader extends Shader
{

 public var texture2Uniform:Dynamic;

 
 public var alphaUniform:Dynamic;
 
 
 public var uvScale0Uniform:Dynamic;
 public var uvScale1Uniform:Dynamic;
 public var uvScale2Uniform:Dynamic;
 
 

 public var ambientColorUniform:Dynamic;
 public var lightPositionUniform:Dynamic;

 



 
	public function new() 
	{
    super();
		
		 var vertexShader = GL.createShader (GL.VERTEX_SHADER);
        GL.shaderSource (vertexShader, DataShader.VertexShaderTerrainSplat);
        GL.compileShader (vertexShader);
        if (GL.getShaderParameter (vertexShader, GL.COMPILE_STATUS) == 0) 
        {throw ("Load Vert:"+GL.getShaderInfoLog(vertexShader));}
		
       var fragmentShader = GL.createShader (GL.FRAGMENT_SHADER);
       GL.shaderSource (fragmentShader, DataShader.FragmentShaderTerrainSplat);
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

 alphaUniform = GL.getUniformLocation (shaderProgram, "Alpha");
 texture0Uniform = GL.getUniformLocation (shaderProgram, "layer0");
 texture1Uniform = GL.getUniformLocation (shaderProgram, "layer1");
 texture2Uniform = GL.getUniformLocation (shaderProgram, "layer2");
 


 
uvScale0Uniform = GL.getUniformLocation (shaderProgram, "uvAmount0");
uvScale1Uniform = GL.getUniformLocation (shaderProgram, "uvAmount1");
uvScale2Uniform = GL.getUniformLocation (shaderProgram, "uvAmount2");

GL.uniform1f(uvScale0Uniform, 4.0);
GL.uniform1f(uvScale1Uniform, 4.0);
GL.uniform1f(uvScale2Uniform, 4.0);

 


 projMatrixUniform= GL.getUniformLocation (shaderProgram, "ProjectionMatrix");
 worldMatrixUniform = GL.getUniformLocation (shaderProgram, "WorldMatrix");
 viewMatrixUniform = GL.getUniformLocation (shaderProgram, "ViewMatrix");
 

 
 ambientColorUniform= GL.getUniformLocation (shaderProgram, "Ambient");
 lightPositionUniform= GL.getUniformLocation (shaderProgram, "LightPos");



 

 vertexAttribute = GL.getAttribLocation (shaderProgram, "position");
 normalAttribute = GL.getAttribLocation (shaderProgram, "normal");
 texCoord0Attribute = GL.getAttribLocation (shaderProgram, "texture");

 
 GL.useProgram (null); 
}
public function setLayerScale(value:Float,layer:Int):Void
	{
     GL.useProgram (shaderProgram); 
     switch (layer)
	 {
		 case 0:GL.uniform1f(uvScale0Uniform, value);
		 case 1:GL.uniform1f(uvScale1Uniform, value);
		 case 2:GL.uniform1f(uvScale2Uniform, value);
	 }
	}

public function setAmbient(r:Float,g:Float,b:Float,a:Float):Void
	{
     ambientColorUniform = GL.getUniformLocation (shaderProgram, "Ambient");
     GL.uniform4f(ambientColorUniform, r,g,b,a);
	}
public function setLightPosition(x:Float,y:Float, z:Float):Void
	{
     lightPositionUniform = GL.getUniformLocation (shaderProgram, "LightPos");
     GL.uniform3f(lightPositionUniform, x,y,z);
	}
	



	public function setTexture(tex:Texture,layer:Int):Void
	{
		if (tex == null) return;
		
		tex.Bind(layer);
		switch (layer)
		{
			case 0:
				{
					GL.uniform1i(alphaUniform, layer);
				}
	
		case 1:
			{
			GL.uniform1i(texture0Uniform, layer);
		     }
	case 2:
			{
			GL.uniform1i(texture1Uniform, layer);
		     }

    	case 3:
			{
			GL.uniform1i(texture2Uniform, layer);
		     }

	}
    
     
	  
	}

  	
}