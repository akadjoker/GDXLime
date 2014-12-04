package com.gdx.scene3d.particles;

import com.gdx.Clip;
import com.gdx.color.Color3;
import com.gdx.gl.batch.SpriteBatch;
import com.gdx.gl.BlendMode;
import com.gdx.gl.shaders.Brush;
import com.gdx.gl.Texture;
import com.gdx.math.Matrix4;
import com.gdx.math.Rectangle;
import com.gdx.math.Vector3;
import com.gdx.scene3d.buffer.ArrayBuffer;
import com.gdx.scene3d.buffer.VertexBuffer;
import com.gdx.scene3d.Mesh;
import com.gdx.scene3d.Node;
import com.gdx.scene3d.particles.Sprite3DBatch;
import com.gdx.scene3d.Scene;
import com.gdx.scene3d.SceneNode;
import com.gdx.scene3d.lensflare.LensFlare;
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
import com.gdx.Util;
import haxe.xml.Fast;
import lime.Assets;

class LensFlare3D
{

	
	public var borderLimit:Float;
	public var lensFlares:Array<LensFlare>;
	public var scene:Scene;
	

	private var batch:Sprite3DBatch;

	
	public var _positionX:Float;
	public var _positionY:Float;
	


	private var z:Float;

	public function new(scene:Scene ,batch:Sprite3DBatch) 
	{
		
		this.lensFlares = [];
        this.scene = scene;
		this.batch = batch;	
		borderLimit = 100;
		
		

	}
	
	
	public function addFlare(frame:Int,size:Float, position:Float, ?color:Color3):Void
	{
		var flare:LensFlare = new LensFlare(size*20, position, frame, color, this);
		batch.addSprite(flare);
	
	}
	public function computeEffectivePosition():Bool 
	{
		var position = this.getEmitterPosition();
		var globalViewport:Rectangle = Gdx.Instance().viewPort;

        position = Vector3.Project(position, Matrix4.Identity(),scene.mainCamera.getProjViewMatrix(), globalViewport);

         this._positionX = position.x;
         this._positionY = position.y;
  
  
       position = Vector3.TransformCoordinates(this.getEmitterPosition(), scene.mainCamera.getProjViewMatrix());
	    z = position.z;		
	
      

        if (  position.z > 0) 
		{
            if ((this._positionX > globalViewport.x) && (this._positionX < globalViewport.x + globalViewport.width)) {
                if ((this._positionY > globalViewport.y) && (this._positionY < globalViewport.y + globalViewport.height))
                    return true;
            }
        }

        return false;
	}
	public function getEmitterPosition():Vector3 
	{
		var v:Vector3 = scene.sunPosition.clone();
		v.addInPlace(scene.mainCamera.position);
		return v;
	}
	
	public function _isVisible():Bool 
	{
		/*
		var emitterPosition:Vector3 = this.getEmitterPosition();
        var direction:Vector3 = emitterPosition.subtract(this._scene.activeCamera.position);
        var distance:Float = direction.length();
        direction.normalize();
        
        var ray:Ray = new Ray(this._scene.activeCamera.position, direction);
        var pickInfo = this._scene.pickWithRay(ray, this.meshesSelectionPredicate, true);

        return !pickInfo.hit || pickInfo.distance > distance;
		*/
		return true;
	}
	
	public function render():Bool 
	{
	
        var globalViewport:Rectangle = Gdx.Instance().viewPort;
		  for (index in 0...this.lensFlares.length) 
		{
		 var flare:LensFlare = this.lensFlares[index];	
		 flare.visible = false;
		}
        
        // Position
        if (!this.computeEffectivePosition())
		{
           return false;
        }
        
        // Visibility
        if (!this._isVisible()) 
		{
            return false;
        }

        // Intensity
        var awayX:Float = 0;
        var awayY:Float = 0;

        if (this._positionX < this.borderLimit + globalViewport.x)
		{
            awayX = this.borderLimit + globalViewport.x - this._positionX;
        } else if (this._positionX > globalViewport.x + globalViewport.width - this.borderLimit) {
            awayX = this._positionX - globalViewport.x - globalViewport.width + this.borderLimit;
        } else {
            awayX = 0;
        }

        if (this._positionY < this.borderLimit + globalViewport.y) {
            awayY = this.borderLimit + globalViewport.y - this._positionY;
        } else if (this._positionY > globalViewport.y + globalViewport.height - this.borderLimit) {
            awayY = this._positionY - globalViewport.y - globalViewport.height + this.borderLimit;
        } else {
            awayY = 0;
        }

        var away:Float = (awayX > awayY) ? awayX : awayY;
        if (away > this.borderLimit)
		{
            away = this.borderLimit;
        }

        var intensity:Float = 1.0 - (away / this.borderLimit);
        if (intensity < 0) 
		{
            return false;
        }
        
        if (intensity > 1.0) 
		{
            intensity = 1.0;
        }

		
        // Position
        var centerX:Float = globalViewport.x + globalViewport.width / 2;
        var centerY:Float = globalViewport.y + globalViewport.height / 2;
        var distX:Float = centerX - this._positionX;
        var distY:Float = centerY - this._positionY;
		
	 var flare:LensFlare = this.lensFlares[0];	
	 flare.visible = true;
	 flare.position = scene.mainCamera.screenToWorld(new Vector3( _positionX, _positionY, z));
	 //flare.alpha = Util.lerp(flare.alpha, intensity, 1);


        // Flares
        for (index in 1...this.lensFlares.length) 
		{
            var flare:LensFlare = this.lensFlares[index];
			flare.visible = true;
			flare.alpha =  intensity;
	        var x = centerX - (distX * flare.index);
            var y = centerY - (distY * flare.index);
			flare.position = scene.mainCamera.screenToWorld(new Vector3(x, y, z));
										
		 }
        return true;
	}
	
	public function dispose() 
	{
		

        while (this.lensFlares.length > 0)
		{
            this.lensFlares[0].dispose();
        }

        
	}
	
}


private class LensFlare extends Sprite3D
{
	
 	public var index:Float;
	private var _system:LensFlare3D;
	

	public function new(size:Float, index:Float,frame:Int, ?color:Color3, system:LensFlare3D) 
	{
		super(999);
		this.color = color != null ? color : new Color3(1, 1, 1);
        this.index = index;
        this.size = size;
		this.frame = frame;
		this.alpha = 1;
        this._system = system;
		this.active = true;

        _system.lensFlares.push(this);
	}
	
	public function dispose() 
	{
		this._system.lensFlares.remove(this);
	}
	
}
