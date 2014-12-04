package com.gdx.scene3d.animators;

/**
 * ...
 * @author Luis Santos AKA DJOKER
 */
class Montion
{
    private var animations:Array<Anim>;
	private var animation:Anim;
	private var lastanimation:Int;
	private var currentAnimation:Int;
	private var rollto_anim:Int;
	private var RollOver:Bool;
	private var currentFrame:Int;
	

	
	public function new() 
	{
	animations = new  Array<Anim>();
	lastanimation = -1;
	currentAnimation = 0;
	currentFrame=0;
	rollto_anim = 0;
	RollOver=false;
	}
	
	public function addAnimation(name:String, startFrame:Int, endFrame:Int, fps:Int):Int
	{
		animations.push(new Anim(name, startFrame, endFrame, fps));
		return (animations.length - 1);
		
	}
	
	public function numAnimations():Int
	{
		return animations.length;
	}
	
	public function BackAnimation():Void
	{
		currentAnimation = (currentAnimation - 1) %  (numAnimations());
		if (currentAnimation < 0) currentAnimation = numAnimations();
	    setAnimation(currentAnimation);
	}
	public function NextAnimation():Void
	{
		currentAnimation = (currentAnimation +1) %  (numAnimations());
		if (currentAnimation >numAnimations()) currentAnimation = 0;
	    setAnimation(currentAnimation);
	}
	public function setAnimation(num:Int):Void
	{
	 if (num == lastanimation) return;
	 if (num > animations.length) return;
		
	 currentAnimation = num;	
	 animation = animations[currentAnimation];
	 currentFrame = animations[currentAnimation].frameStart;
	 lastanimation = currentAnimation;
	}
	public function setAnimationByName(name:String):Void
	{
	 
		for (i in 0 ... animations.length)
		{
			
			if (animations[i].name == name)
			{
				setAnimation(i);
				break;
			}
			
		}
		
	}
	public function SetAnimationRollOver(num:Int,next:Int):Void
	{
		if (num == lastanimation) return;
		if (num > animations.length) return;
		
	 currentAnimation = num;	
	 animation = animations[currentAnimation];
	 currentFrame = animations[currentAnimation].frameStart;
	 lastanimation = currentAnimation;
	 RollOver = true;
	 rollto_anim = next;
	}

	
	public function update():Void 
	{
		
		var time:Float = Gdx.Instance().getTimer();
        var elapsedTime:Float = time - lastTime;
	    var t:Float = elapsedTime / (1000.0 / animation.fps);
		
		
		if (currentFrame > animation.frameEnd)
		{
			currentFrame = animation.frameStart;
		}
	
		if (RollOver)
		{
			if (currentFrame >= animation.frameEnd)
			{
				setAnimation(rollto_anim);
				RollOver = false;
			}
		}
		
		if (elapsedTime >= (1000.0 / animation.fps) )
	    {
    	 currentFrame++;
	     lastTime = time;	
	    }
		
		
	}
}