package com.gdx.scene3d.particles;
import com.gdx.color.Color3;
import com.gdx.math.Vector3;
/**
 * ...
 * @author Luis Santos AKA DJOKER
 */
class Bullet extends Sprite3D
{
private var start:Vector3;
private var end:Vector3;
private var WayLength:Float;
private var TimeFactor:Float;
private var time:Int;
private var path:Vector3;


	 public function new (Id:Int) 
	{
	    super(Id);
		active = false;
		start = Vector3.zero;
		end = Vector3.zero;
		WayLength = 0.0;
		size = 1;
		frame = 1;
		
	}
	public function shot(startPoint:Vector3,endPoint:Vector3,TimeForWay:Int)
	{
		position.copyFrom(startPoint);
		start.copyFrom(startPoint);
		end.copyFrom(endPoint);
		time = TimeForWay;
		recalculateImidiateValues();
		reset();
	}
	private function recalculateImidiateValues():Void
	{
	
		path = Vector3.Sub(end, start);
		WayLength = path.length();
		TimeFactor = WayLength / time;
		life = WayLength/100;
	}
	override public function reset () 
	{
	 active = true;	
	}
	override public function move (dt:Float) 
	{
		if (!active) return;
		life-=  dt;
		if (life <= 0) active = false;
		position.x += path.x * (dt * TimeFactor);
		position.y += path.y * (dt * TimeFactor);
		position.z += path.z * (dt * TimeFactor);
		
	}
}