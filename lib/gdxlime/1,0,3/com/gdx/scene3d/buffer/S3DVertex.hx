package com.gdx.scene3d.buffer;
import com.gdx.color.Color4;
import com.gdx.math.Vector2;
import com.gdx.math.Vector3;
/**
 * ...
 * @author Luis Santos AKA DJOKER
 */
class S3DVertex
{
	public var  Pos:Vector3;
	public var  Normal:Vector3;
	public var  TCoords:Vector2;
	public var  Color:Color4;
	
	public function new() 
	{
		Color = new Color4(1, 1, 1, 1);
		Pos = Vector3.zero;
		Normal = Vector3.zero;
		TCoords = Vector2.zero;
		
	}
	
}