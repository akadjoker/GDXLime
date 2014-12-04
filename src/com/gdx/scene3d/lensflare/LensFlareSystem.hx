package com.gdx.scene3d.lensflare;

import com.gdx.Clip;
import com.gdx.color.Color3;
import com.gdx.gl.batch.SpriteBatch;
import com.gdx.gl.BlendMode;
import com.gdx.gl.shaders.Brush;
import com.gdx.gl.Texture;
import com.gdx.math.Matrix4;
import com.gdx.math.Ray;
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
import com.gdx.SpriteSheet;
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

class LensFlareSystem 
{

	
	public var borderLimit:Float;
	public var lensFlares:Array<LensFlare>;
	public var scene:Scene;
	

	
	public var _positionX:Float;
	public var _positionY:Float;
	

	private var z:Float;
	private var spriteSheet:SpriteSheet;

	public function new(scene:Scene ,spriteSheet:SpriteSheet) 
	{
		
		this.lensFlares = [];
        this.scene = scene;
		this.spriteSheet = spriteSheet;
		borderLimit = 100;
	
	
		

	}
	
		
	public function addFlare(frame:Int,size:Float, position:Float, ?color:Color3):Void
	{
		var flare:LensFlare = new LensFlare(size, position, frame,color, this);
	
	}
	public function computeEffectivePosition():Bool 
	{
		var position = this.getEmitterPosition();
		var globalViewport:Rectangle = Gdx.Instance().viewPort;

        position = Vector3.Project(position, Matrix4.Identity(), scene.mainCamera.getProjViewMatrix(), globalViewport);
		
		

        this._positionX = position.x;
        this._positionY = position.y;
	
       z = position.z;

        if (z > 0) 
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
		return scene.sunPosition;//new Vector3(21.84, 50, -28.26);
	}
	
	public function _isVisible():Bool 
	{
		
		var emitterPosition:Vector3 = this.getEmitterPosition();
        var direction:Vector3 = emitterPosition.subtract(scene.mainCamera.position);
        var distance:Float = direction.length();
        direction.normalize();
		
		var angle = Util.rad2deg(Vector3.AngleBetweenVectors(scene.mainCamera.LookAt, emitterPosition));
		if (angle > 90) return false;
		
      
		if (scene.collider == null) return true;
		
        var ray:Ray = new Ray(scene.mainCamera.position, direction);
        var pickInfo = scene.collider.RayPick(ray, true);

		

        return !pickInfo || scene.inpactDistance > distance;
		
	
		return true;
	}
	
	public function render(batch:SpriteBatch):Bool 
	{
	
        var globalViewport:Rectangle = Gdx.Instance().viewPort;
        
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
	 
    batch.RenderScaleRotateClipColorAlpha(spriteSheet.image, _positionX, _positionY, flare.size, flare.size, Math.sin(Gdx.Instance().getTimer()/10)*0.01, spriteSheet.getClip(flare.frame),  flare.color.r, flare.color.g, flare.color.b, flare.alpha, BlendMode.ADD);
        

        // Flares
        for (index in 1...this.lensFlares.length) 
		{
            var flare:LensFlare = this.lensFlares[index];

            var x = centerX - (distX * flare.index);
            var y = centerY - (distY * flare.index);
		    var cw = flare.size;
            var ch = flare.size;// * Gdx.Instance().getAspectRatio();
	
       		batch.RenderScaleRotateClipColorAlpha(spriteSheet.image, x, y, cw, ch, 0, spriteSheet.getClip(flare.frame),  flare.color.r, flare.color.g, flare.color.b, intensity, BlendMode.ADD);
			
									
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
