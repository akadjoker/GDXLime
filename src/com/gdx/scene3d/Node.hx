package com.gdx.scene3d;
import com.gdx.math.BoundingInfo;
import com.gdx.math.Vector3;
import com.gdx.math.Vector3;

/**
 * ...
 * @author Luis Santos AKA DJOKER
 */
class Node
{
	public var Visible (default, default) :Bool = true;
	public var Bounding:BoundingInfo;
	public var id:Int;
	public var name:String;
	
	public var position:Vector3;
	public var rotation:Vector3;
	public var scaling:Vector3;
	public var velocity:Vector3;
	
	
	

	public function new(id:Int = 0, name:String="Body") 
	{
		this.id = id;
		this.name = name;
		Bounding = new BoundingInfo(new Vector3(99999999,99999999,99999999), new Vector3(-99999999,-99999999,-99999999));
		this.position = Vector3.zero;
        this.rotation = Vector3.zero;
        this.scaling = new Vector3(1, 1, 1);	
		velocity = Vector3.zero;
				

	}
	
}