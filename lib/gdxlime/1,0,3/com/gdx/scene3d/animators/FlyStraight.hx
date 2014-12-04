package com.gdx.scene3d.animators;
import com.gdx.math.Vector3;

/**
 * ...
 * @author Luis Santos AKA DJOKER
 */
class FlyStraight extends Animator
{
private var start:Vector3;
private var end:Vector3;
private var pos:Vector3;
private var WayLength:Float;
private var TimeFactor:Float;
private var time:Int;
private var path:Vector3;

    public function new(startPoint:Vector3,endPoint:Vector3,TimeForWay:Int) 
	{
		super();
		start = Vector3.zero;
		end = Vector3.zero;
		pos = Vector3.zero;
		pos.copyFrom(startPoint);
		start.copyFrom(startPoint);
		end.copyFrom(endPoint);
		WayLength = 0.0;
		time = TimeForWay;
		recalculateImidiateValues();
		
	}
	private function recalculateImidiateValues():Void
	{
	
		path = Vector3.Sub(end, start);
		WayLength = path.length();
		TimeFactor = WayLength / time;
	}
	override public function animate(node:SceneNode):Void
	{
	
		pos.x += path.x * (Gdx.Instance().deltaTime * TimeFactor);
		pos.y += path.y * (Gdx.Instance().deltaTime * TimeFactor);
		pos.z += path.z * (Gdx.Instance().deltaTime * TimeFactor);
		node.position.copyFrom(pos);
		//trace(path.toString());
	}
	
}