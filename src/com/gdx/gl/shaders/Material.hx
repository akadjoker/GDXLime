package com.gdx.gl.shaders;

import com.gdx.color.Color3;
import com.gdx.color.Color3;
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
 * @author Luis Santos AKA DJOKER
 */
class Material
{
  public var alpha:Float;
  public var CullingFace:Bool;
  public var BlendFace:Bool;
  public var BlendType:Int;
  public var DepthTest:Bool;
  public var DepthMask:Bool;
  public var DiffuseColor:Color3;
  
	public function new() 
	{
	 this.DiffuseColor = new Color3(1.0, 1.0, 1.0);
	 BlendType = 0;
	 DepthTest = true;
	 DepthMask = true;
	 CullingFace =true;
	 BlendFace = false;
	}
	public function setBlend():Void
	{
		
		if (BlendFace)
		{
			switch (BlendType)
			{
			 case 0:Gdx.Instance().setBlendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);//alpha
			 case 1:Gdx.Instance().setBlendFunc(GL.DST_COLOR, GL.ZERO);//multiply
			 case 2:Gdx.Instance().setBlendFunc(GL.SRC_ALPHA, GL.ONE);//additive and alpha
			 case 3:Gdx.Instance().setBlendFunc(GL.ONE, GL.ONE);//blend after texture
				 
				
		}
		}
		
	}
	public function Applay():Void
	{
        Gdx.Instance().numBrush++;
		Gdx.Instance().setDepthMask(DepthMask);
		Gdx.Instance().setDepthTest(DepthTest);
		Gdx.Instance().setCullFace(CullingFace);
		Gdx.Instance().setBlend(BlendFace);
		setBlend();

	}
}