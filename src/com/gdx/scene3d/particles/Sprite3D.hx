package com.gdx.scene3d.particles;
import com.gdx.color.Color3;
import com.gdx.math.Vector3;

/**
 * ...
 * @author Luis Santos AKA DJOKER
 */
 class Sprite3D
{
    public var position :Vector3;
	public var alpha :Float ;
    public var life :Float ;
	public var size :Float ;
	public var type:Int;
	public var active:Bool;
	public var frame:Int;
	public var color:Color3;
	public var remove:Bool;
	public var Id:Int;
	
    public function new (Id:Int) 
	{
		this.Id = Id;
	    this.active = false;
		this.type = 0;
		this.position = Vector3.zero;
	    this.alpha = 1;
		this.life = 1;
		this.size = 1;
		this.frame = 0;
		this.color = new Color3(1, 1, 1);
		this.remove = false;
	}
	public function reset () 
	{
		
	}
	public function move (dt:Float) 
	{
		
	}
}