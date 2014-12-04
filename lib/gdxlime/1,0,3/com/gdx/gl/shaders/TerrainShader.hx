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
class TerrainShader extends Shader
{

 public var texture2Uniform:Dynamic;
 public var texture3Uniform:Dynamic;
 public var texture4Uniform:Dynamic;
 public var bumpUniform:Dynamic;
 public var uvScale0Uniform:Dynamic;
 public var uvScale1Uniform:Dynamic;
 public var uvScale2Uniform:Dynamic;
 public var uvScale3Uniform:Dynamic;
 public var uvScale4Uniform:Dynamic;
 public var bumpScaleUniform:Dynamic;
 

 public var ambientColorUniform:Dynamic;
 public var lightPositionUniform:Dynamic;

 



 
	public function new() 
	{
    super();
		
		 var vertexShader = GL.createShader (GL.VERTEX_SHADER);
        GL.shaderSource (vertexShader, DataShader.VertexShaderTerrain);
        GL.compileShader (vertexShader);
        if (GL.getShaderParameter (vertexShader, GL.COMPILE_STATUS) == 0) 
        {throw ("Load Vert:"+GL.getShaderInfoLog(vertexShader));}
		
       var fragmentShader = GL.createShader (GL.FRAGMENT_SHADER);
       GL.shaderSource (fragmentShader, DataShader.FragmentShaderTerrain);
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

  bumpUniform=GL.getUniformLocation (shaderProgram, "bumpTexture");
 texture0Uniform = GL.getUniformLocation (shaderProgram, "layer0");
 texture1Uniform = GL.getUniformLocation (shaderProgram, "layer1");
 texture2Uniform = GL.getUniformLocation (shaderProgram, "layer2");
 texture3Uniform = GL.getUniformLocation (shaderProgram, "layer3");
 texture4Uniform = GL.getUniformLocation (shaderProgram, "layer4");
 
trace(texture0Uniform);
trace(texture1Uniform);
trace(texture2Uniform);
trace(texture3Uniform);
trace(texture4Uniform);
trace(bumpUniform);



 
 
uvScale0Uniform = GL.getUniformLocation (shaderProgram, "uvAmount0");
uvScale1Uniform = GL.getUniformLocation (shaderProgram, "uvAmount1");
uvScale2Uniform = GL.getUniformLocation (shaderProgram, "uvAmount2");
uvScale3Uniform = GL.getUniformLocation (shaderProgram, "uvAmount3");
uvScale4Uniform = GL.getUniformLocation (shaderProgram, "uvAmount4");
GL.uniform1f(uvScale0Uniform, 14.0);
GL.uniform1f(uvScale1Uniform, 10.0);
GL.uniform1f(uvScale2Uniform, 20.0);
GL.uniform1f(uvScale3Uniform, 20.0);
GL.uniform1f(uvScale4Uniform, 4.0);

 
 bumpScaleUniform = GL.getUniformLocation (shaderProgram, "bumpScale");
 

 
 

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
		 case 3:GL.uniform1f(uvScale3Uniform, value);
		 case 4:GL.uniform1f(uvScale3Uniform, value); 
	 }
	}
public function setBumpScale(v:Float):Void
	{
     GL.useProgram (shaderProgram); 
     GL.uniform1f(bumpScaleUniform, v);
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
					GL.uniform1i(bumpUniform, layer);
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

    	case 4:
			{
			GL.uniform1i(texture3Uniform, layer);
		     }
			 case 5:
			{
			GL.uniform1i(texture4Uniform, layer);
		     }
	}
    
     
	  
	}

  	
}