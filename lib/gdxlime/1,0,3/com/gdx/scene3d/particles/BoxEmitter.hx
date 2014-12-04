package com.gdx.scene3d.particles;

import com.gdx.gl.Texture;
import com.gdx.math.Vector3;
import com.gdx.scene3d.particles.ParticleSystem;

/**
 * ...
 * @author djoekr
 */
class BoxEmitter extends ParticleSystem
{
	
	public  var BoxMin:Vector3;
	public  var BoxMax:Vector3;
	
	
	
	public function new (boxMin:Vector3,boxMax:Vector3,texture:Texture,scene:Scene,Parent:SceneNode = null , id:Int = 0) 
    {
        super(texture, scene, Parent, id);
		this.BoxMax = boxMax;
		this.BoxMin = boxMin;
		 
    }


	override public function getStartPosition ():Vector3
    {

		EmitPosition = new Vector3(0, 0, 0);
    	EmitPosition.x = Util.randf(BoxMin.x, BoxMax.x);
		EmitPosition.y = Util.randf(BoxMin.y, BoxMax.y);
		EmitPosition.z = Util.randf(BoxMin.z, BoxMax.z);
		return EmitPosition;
	
	}
	
}