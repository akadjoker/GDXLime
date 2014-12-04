package com.gdx.scene3d.particles;

import com.gdx.gl.Texture;
import com.gdx.math.Vector3;

/**
 * ...
 * @author djoekr
 */
class SphereEmitter extends ParticleSystem
{

	public  var Center:Vector3;
	public  var Radius:Float;
	
	
	public function new (center:Vector3,radius:Float,texture:Texture,scene:Scene,Parent:SceneNode = null , id:Int = 0) 
    {
        super(texture, scene, Parent, id);
		this.Center = center;
		this.Radius = radius;
		 
    }


	override public function getStartPosition ():Vector3
    {
	 EmitPosition = new Vector3(0, 0, 0);
     var  distance = Math.random() * Radius;
     EmitPosition.set(Center.x + distance,Center.y + distance,Center.z + distance);
     EmitPosition.rotateXYBy(Math.random() * 360.0, Center );
     EmitPosition.rotateYZBy(Math.random() * 360.0, Center );
     EmitPosition.rotateXZBy(Math.random() * 360.0, Center );
     return EmitPosition;
    }
	
}