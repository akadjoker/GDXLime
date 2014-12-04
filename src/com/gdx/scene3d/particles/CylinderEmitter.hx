package com.gdx.scene3d.particles;

import com.gdx.gl.Texture;
import com.gdx.math.Vector3;
import com.gdx.scene3d.particles.ParticleSystem;

/**
 * ...
 * @author djoker
 */
class CylinderEmitter extends ParticleSystem
{

	public  var Normal:Vector3;
	public  var Length:Float;
	
	public  var Radius:Float;
	public  var Center:Vector3;

	public  var OutlineOnly:Bool;
	
	
	public function new (normal:Vector3,lenght:Float,center:Vector3,radius:Float,outlineOnly:Bool,texture:Texture,scene:Scene,Parent:SceneNode = null , id:Int = 0) 
    {
        super(texture, scene, Parent, id);
		this.Center = center;
		this.Normal = normal;
		this.Length = lenght;
		this.Radius = radius;
		this.OutlineOnly = outlineOnly;
		 
    }


	override public function getStartPosition ():Vector3
    {
	 EmitPosition = Vector3.Zero();


var distance = (!OutlineOnly) ? (Math.random() *Radius) : Radius;
EmitPosition.set(Center.x + distance,Center.y ,Center.z + distance);
EmitPosition.rotateXZBy(Math.random() * 360.0, Center );
var  length:Float = Math.random() * Length;
EmitPosition.x += Normal.x * length;
EmitPosition.y += Normal.y * length;
EmitPosition.z += Normal.z * length;

return EmitPosition;

    }
	
}