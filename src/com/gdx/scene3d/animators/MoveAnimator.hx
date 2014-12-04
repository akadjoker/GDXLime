package com.gdx.scene3d.animators;
import com.gdx.math.Vector3;

/**
 * ...
 * @author Luis Santos AKA DJOKER
 */
class MoveAnimator extends Animator
{
private var direction:Vector3;

	public function new(dir:Vector3) 
	{
		super();
		direction = Vector3.zero;
		direction.copyFrom(dir);
	}
	override public function animate(node:SceneNode):Void
	{
		var pos = node.position;
		pos.addInPlace(direction);
		
	}
}