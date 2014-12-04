package com.gdx.scene3d;

/**
 * ...
 * @author djoekr
 */
class MeshAnimation
{
	public static var  NORMAL:Int= 0;
	public static var  REVERSED :Int= 1;
	public static var  LOOP :Int= 2;
	public static var  LOOP_REVERSED:Int = 3;
	public static var  LOOP_PINGPONG:Int = 4;
	public static var  LOOP_RANDOM:Int = 5;
	public var frameDuration:Float=0;
	public var animationDuration:Float=0;

	private var playMode:Int;
	
	public var name:String;
	public var frameStart:Int;
	public var frameEnd:Int;
	
	public var keyFrames:Array<Int>;

	public function new(name:String,start:Int,end:Int) 
	{
		this.name = name;
		this.frameStart = start;
		this.frameEnd = end;
		playMode = LOOP;
		keyFrames = new Array<Int>();
		for (i in 0...40)
		{
			keyFrames.push( i);
			//trace(start + i);
		}
		setFrameDuration(25.5);
	}
	public function setFrameDuration(value:Float)
	{
		frameDuration = value;
		animationDuration = numFrames() * frameDuration;
	}
	public function getFrames (stateTime:Float,looping:Bool) :Int
	{
		if (looping && (playMode == NORMAL || playMode == REVERSED)) 
		{
			if (playMode == NORMAL)
				playMode = LOOP;
			else
				playMode = LOOP_REVERSED;
		} else if (!looping && !(playMode == NORMAL || playMode == REVERSED))
		{
			if (playMode == LOOP_REVERSED)
				playMode = REVERSED;
			else
				playMode = LOOP;
		}

		return getKeyFrame(stateTime);
	}
	public function numFrames():Int
	{
		return keyFrames.length;
	}
	public function getKeyFrame (stateTime:Float):Int 
	{
		var frameNumber:Int = Std.int(stateTime / frameDuration);

       switch (playMode) 
	   {
		case SpriteSheet.NORMAL:
			frameNumber = Std.int(Math.min(keyFrames.length - 1, frameNumber));
		case SpriteSheet.LOOP:
			frameNumber = frameNumber % keyFrames.length;
		case SpriteSheet.LOOP_PINGPONG:
			frameNumber = frameNumber % (keyFrames.length * 2);
			if (frameNumber >= keyFrames.length) frameNumber = keyFrames.length - 1 - (frameNumber - keyFrames.length);
		case SpriteSheet.LOOP_RANDOM:
			frameNumber =Std.int( Math.random()*(keyFrames.length - 1));
		case SpriteSheet.REVERSED:
			frameNumber = Std.int(Math.max(keyFrames.length - frameNumber - 1, 0));
		case SpriteSheet.LOOP_REVERSED:
			frameNumber = frameNumber % keyFrames.length;
			frameNumber = keyFrames.length - frameNumber - 1;
		default:
			frameNumber =Std.int( Math.min(keyFrames.length - 1, frameNumber));

		}
		return keyFrames[frameNumber];
	}

	
}