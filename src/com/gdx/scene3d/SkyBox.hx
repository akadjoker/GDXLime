package com.gdx.scene3d;

import com.gdx.gl.shaders.Brush;
import com.gdx.gl.shaders.SkyBoxShader;
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
class SkyBox
{
   public var shader:SkyBoxShader;
   public var texture:Texture;
   public var brush:Brush;
    public var coordBuffer:GLBuffer;
	public var  indexBuffer:GLBuffer;
	
	
	public function new(size:Float,cubemap:Texture) 
	{
		texture = cubemap;
		shader = new SkyBoxShader();
		brush = new Brush(0);
		brush.BlendFace = false;
		brush.DepthMask = false;
		brush.DepthTest = false;
		
		
		var vertices = [
    -size, -size,  size,
    size, -size,  size,
    -size,  size,  size,
    size,  size,  size,
    -size, -size, -size,
    size, -size, -size,
    -size,  size, -size,
    size,  size, -size,
	];

var indices = [ 0, 1, 2, 3, 7, 1, 5, 4, 7, 6, 2, 4, 0, 1 ];

coordBuffer = GL.createBuffer();
indexBuffer = GL.createBuffer();
				
           GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indexBuffer);
           GL.bufferData(GL.ELEMENT_ARRAY_BUFFER,  new Int16Array(indices), GL.STATIC_DRAW);
		   GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, null);
		    GL.bindBuffer(GL.ARRAY_BUFFER, coordBuffer);
	        GL.bufferData(GL.ARRAY_BUFFER,  new Float32Array( vertices), GL.STATIC_DRAW);
			GL.bindBuffer(GL.ARRAY_BUFFER, null);

	}
	public function render(camera:Camera):Void
	{
		
		var meshTrasform:Matrix4 = Matrix4.Translation(camera.position.x, camera.position.y, camera.position.z);
		var matrix:Matrix4=Matrix4.multiplyWith(camera.viewMatrix,meshTrasform);
	
		
		shader.Bind();
		shader.setProjMatrix(camera.projMatrix);
		shader.setWorldMatrix(matrix);
		brush.Applay();
		if (texture != null)
		{
		shader.setCubeMap(texture);
		}
		GL.bindBuffer(GL.ARRAY_BUFFER, coordBuffer);
		GL.vertexAttribPointer(shader.vertexAttribute, 3, GL.FLOAT, false, 0, 0); 
    	GL.enableVertexAttribArray (shader.vertexAttribute);
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indexBuffer);
        GL.drawElements(GL.TRIANGLE_STRIP, 14, GL.UNSIGNED_SHORT, 0);
	}
	
}