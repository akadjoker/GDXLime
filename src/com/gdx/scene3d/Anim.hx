package com.gdx.scene3d;

/**
 * ...
 * @author djoekr
 */
class Anim
{
	public var name:String;
	public var frameStart:Int;
	public var frameEnd:Int;
	public var fps:Int;

	public function new(name:String, start:Int, end:Int, fps:Int ) 
	{
		this.name = name;
		this.frameStart = start;
		this.frameEnd = end;
		this.fps = fps;
	
		
	}
	
}