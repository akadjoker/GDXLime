package com.gdx.scene2d.game ;

import com.gdx.Clip;
import com.gdx.gl.Texture;

/**
 * ...
 * @author djoker
 */
class Animator
{
	 private var  animations:Map<String,Animation>;
	 private var  _animation:Animation;
	 private var _frame:Clip;

	public function new() 
	{
		animations = new Map<String,Animation>();
		_animation = null;
		_frame = null;
	}
	
	public function play(name:String,?playMode:Int=1)
	{
		if (animations.exists(name))
		{
			_animation = animations.get(name);
			_animation.setPlayMode(playMode);
		} else
		{
			
		}
		
	}
	

	public function addFrames(name:String, keyFrames:Array<Clip>,frames:Array<Int>,frameDuration:Float, ?image:Texture=null):Animation
	{
		var  selecFrames:Array<Clip> = [];
	
		for (i in 0...frames.length)
		{
			selecFrames.push(keyFrames[frames[i]]);
		}
		
		var anim = new Animation(name, selecFrames, frameDuration, 2, image);
		animations.set(name, anim);
		selecFrames = null;
		return anim;
	}
	
	public function add(name:String, keyFrames:Array<Clip>,frameDuration:Float,  ?image:Texture=null):Animation
	{
		var anim = new Animation(name, keyFrames, frameDuration, 2, image);
		animations.set(name, anim);
		return anim;
	}
	
	public function update(time:Float)
	{
		if (_animation != null) 
		{
	     _frame = _animation.getKeyFrame(time);
		}
	}
	public var image(get_image, null):Texture;
	private function get_image():Texture 
	{
		if (_animation != null) 
		{
		  if ( _animation.image != null) return _animation.image; else return null;
		}
		else return null;
	}
	public var frame(get_frame, null):Clip;
	private function get_frame():Clip 
	{
		if (_animation != null) return _frame; 
		else return null;
	}
	public var animation(get_animation, null):Animation;
	private function get_animation():Animation
	{
		if (_animation != null) return _animation; 
		else return null;
		}

	
}