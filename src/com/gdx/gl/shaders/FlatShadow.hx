package com.gdx.gl.shaders;



import com.gdx.color.Color3;
import com.gdx.gl.Texture;
import com.gdx.math.Matrix4;
import com.gdx.scene3d.Light;
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
class FlatShadow extends Shader
{

 private var MaterialUniform:Dynamic;
 
 private var materialType:Int;
 private var lastmaterialType:Int;

	public function new() 
	{
		super();
		 materialType =0 ;
		 lastmaterialType = -1;
			
		 var vertexShader = GL.createShader (GL.VERTEX_SHADER);
        GL.shaderSource (vertexShader, DataShader.FlatShadowVertexShader);
        GL.compileShader (vertexShader);
        if (GL.getShaderParameter (vertexShader, GL.COMPILE_STATUS) == 0) 
        {throw ("Load Vert:"+GL.getShaderInfoLog(vertexShader));}
		
       var fragmentShader = GL.createShader (GL.FRAGMENT_SHADER);
       GL.shaderSource (fragmentShader, DataShader.FlatShadowFragmentShader);
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
 


trace(projMatrixUniform + "," + worldMatrixUniform + "," + viewMatrixUniform);
 

vertexAttribute = GL.getAttribLocation (shaderProgram, "inVertexPosition");
colorAttribute = GL.getAttribLocation (shaderProgram, "inVertexColor");


 GL.useProgram (null); 


       
		


	}
	

	
	

	 
	

		
		
			 
		
	
}