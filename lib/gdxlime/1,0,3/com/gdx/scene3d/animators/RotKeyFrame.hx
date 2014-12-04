package com.gdx.scene3d.animators;
import com.gdx.math.Quaternion;

/**
 * ...
 * @author Luis Santos AKA DJOKER
 */
class RotKeyFrame
{
public var Rot:Quaternion;
public var time:Float;
public function new(t:Float,q:Quaternion)
{
	time = t;
	Rot = q;
}

}