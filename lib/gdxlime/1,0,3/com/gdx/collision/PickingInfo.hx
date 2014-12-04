package com.gdx.collision;
import com.gdx.math.Vector3;
import com.gdx.scene3d.Mesh;
import com.gdx.scene3d.Surface;

/**
 * ...
 * @author Luis Santos AKA DJOKER
 */
class PickingInfo
{

	public var hit:Bool = false;
    public var distance:Float;
    public var pickedPoint:Vector3;
    public var pickedMesh:Mesh;
	public var pickedSurface:Surface;

	public function new() {
		this.hit = false;
		this.distance = 0;
		this.pickedPoint = null;
		this.pickedMesh = null;
	}
	
	
}