package com.gdx.scene3d.lensflare ;

import com.gdx.Clip;
import com.gdx.color.Color3;
import com.gdx.gl.shaders.Brush;
import com.gdx.gl.Texture;
import com.gdx.math.Matrix4;
import com.gdx.math.Vector3;
import com.gdx.scene3d.buffer.ArrayBuffer;
import com.gdx.scene3d.buffer.VertexBuffer;
import com.gdx.scene3d.particles.Sprite3D;
import com.gdx.scene3d.SceneNode;
import com.gdx.Util;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLShader;
import lime.graphics.opengl.GLUniformLocation;
import lime.graphics.opengl.GLTexture;
import lime.graphics.RenderContext;
import lime.utils.Float32Array;
import lime.utils.Int16Array;



class LensFlare 
{
	
    public var alpha :Float ;
	public var color:Color3;
	public var size :Float ;
	public var index:Float;
	public var frame:Int;
	private var _system:LensFlareSystem;
	

	public function new(size:Float, index:Float,frame:Int, ?color:Color3, system:LensFlareSystem) 
	{
		
		this.color = color != null ? color : new Color3(1, 1, 1);
        this.index = index;
        this.size = size;
		this.frame = frame;
		this.alpha = 1;
        this._system = system;

        _system.lensFlares.push(this);
	}
	
	public function dispose() 
	{
		this._system.lensFlares.remove(this);
	}
	
}
