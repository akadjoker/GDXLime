package com.gdx.scene3d.particles;
import com.gdx.color.Color3;
import com.gdx.math.Vector3;
/**
 * ...
 * @author Luis Santos AKA DJOKER
 */

class Muzzle extends Sprite3D
{


	 public function new (Id:Int) 
	{
	    super(Id);
		active = false;
		
		
	}
	public function shot(startPoint:Vector3)
	{
		position.copyFrom(startPoint);
		reset();
	}
	
	override public function reset () 
	{
	 active = true;	
	 life = 1;
	 frame = Util.randi(7, 9);
	 size =  Util.randf(4, 6);
	 alpha = 1 ;
	}
	override public function move (dt:Float) 
	{
		if (!active) return;
		
		
		
		life  -=  8  * dt;
		//size  +=  14  * dt;
		alpha -= 4 * dt;
		
		
		
		if (life <= 0) active = false;
		
	}
}