package com.gdx.tweens.motion;

import com.gdx.math.Vector2;
import com.gdx.tweens.Tween;
import com.gdx.tweens.Ease;


/**
 * Base class for motion Tweens.
 */
class Motion extends Tween
{
	/**
	 * Current x position of the Tween.
	 */
	public var x:Float;

	/**
	 * Current y position of the Tween.
	 */
	public var y:Float;

	/**
	 * Constructor.
	 * @param	duration	Duration of the Tween.
	 * @param	complete	Optional completion callback.
	 * @param	type		Tween type.
	 * @param	ease		Optional easer function.
	 */
	public function new(duration:Float, ?complete:Dynamic -> Void, ?type:TweenType, ease:Float -> Float = null)
	{
		x = y = 0;
		super(duration, type, complete, ease);
	}
}
