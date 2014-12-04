package com.gdx.scene3d.particles;

import com.gdx.gl.Texture;
import com.gdx.math.Vector3;
import com.gdx.scene3d.particles.ParticleSystem;

/**
 * ...
 * @author djoker
 */
class RingEmitter extends ParticleSystem
{

	public  var Center:Vector3;
	public  var Radius:Float;
	public  var RingThickness:Float;
	
	
	public function new (center:Vector3,radius:Float,ringThickness:Float,texture:Texture,scene:Scene,Parent:SceneNode = null , id:Int = 0) 
    {
        super(texture, scene, Parent, id);
		this.Center = center;
		this.Radius = radius;
		this.RingThickness = ringThickness;
		 
    }


	override public function getStartPosition ():Vector3
    {
	 EmitPosition = Vector3.Zero();
	var distance:Float = Math.random() * RingThickness * 0.5;
if (Util.randi(0,2) >=1)
distance -= Radius;
else
distance += Radius;

EmitPosition.set(Center.x + distance,Center.y ,Center.z + distance);
EmitPosition.rotateXZBy(Math.random() * 360.0, Center );
return EmitPosition;

    }
	
}