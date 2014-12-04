package com.gdx.scene3d.animators;
import com.gdx.math.Vector3;

/**
 * ...
 * @author Luis Santos AKA DJOKER
 */
class PosKeyFrame
{
public var Pos:Vector3;
public var time:Float;
public function new(t:Float,v:Vector3)
{
	Pos = v;
	time = t;
}

}