package com.gdx.scene2d.game ;

import com.gdx.Clip;
import com.gdx.gl.Texture;

typedef CallbackFunction = Void -> Void;
typedef CallbackLoopFunction = Int -> Void;


class Animation
{
    public var image:Texture;
	public var name:String;
	public var playMode:Int;
	public var frameDuration:Float;
	public var animationDuration:Float;
	private var ended:Bool;
	public var frameNumber:Int;
	

	public static var  NORMAL:Int= 0;
	public static var  REVERSED :Int= 1;
	public static var  LOOP :Int= 2;
	public static var  LOOP_REVERSED:Int = 3;
	public static var  LOOP_PINGPONG:Int = 4;
	public static var  LOOP_RANDOM :Int = 5;	


	
	public function new(name:String, keyFrames:Array<Clip>,frameDuration:Float,  ?playMode:Int=2,?image:Texture=null)
	{
        this.name       = name;
        this.keyFrames    = keyFrames;
        this.playMode       = playMode;
		this.frameDuration = frameDuration;
        this.animationDuration = keyFrames.length * frameDuration;
		this.image = image;
		this.ended = false;
	}

    public function setFrameDuration(value:Float)
	{
		frameDuration = value;
	}
    public function setPlayMode(m:Int)
	{
		playMode = m;
	}

	
public function getFrames (stateTime:Float,looping:Bool) :Clip
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
	public function getKeyFrame (stateTime:Float):Clip 
	{
		 frameNumber = Std.int(stateTime / frameDuration);

		switch (playMode) 
		{
		case 0:
			frameNumber = Std.int(Math.min(numFrames() - 1, frameNumber));
		case 1:
			frameNumber = frameNumber % numFrames();
		case 2:
			frameNumber = frameNumber % (numFrames() * 2);
			if (frameNumber >= numFrames()) frameNumber = numFrames() - 1 - (frameNumber - numFrames());
		case 3:
			frameNumber =Std.int( Math.random()*(numFrames() - 1));
		case 4:
			frameNumber =Std.int(Math.max(numFrames() - frameNumber - 1, 0));
		case 5:
			frameNumber = frameNumber % numFrames();
			frameNumber = numFrames() - frameNumber - 1;
	
		default:
			frameNumber = Std.int(Math.min(numFrames() - 1, frameNumber));
		}
		
		if (frameNumber >= numFrames())
		{
			ended = true;
		} else
		{
			ended = false;
		}

		
		return keyFrames[frameNumber];
	}

	public var keyFrames(default, null):Array<Clip>;
	
}