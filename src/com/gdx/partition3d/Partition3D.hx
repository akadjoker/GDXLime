package com.gdx.partition3d;
import com.gdx.math.Ray;
import com.gdx.scene3d.buffer.Imidiatemode;
import com.gdx.scene3d.Camera;

/**
 * ...
 * @author Luis Santos AKA DJOKER
 */
class Partition3D
{

	public var rootNode:NodeBase;

    public function new(rootNode:NodeBase) 
	{
         this.rootNode = rootNode ;
              
    }
    
	public function debug(lines:Imidiatemode):Void
	{
		if (rootNode == null) return;
		
		rootNode.debug(lines);
	}
	public function RayHit(ray:Ray,lines:Imidiatemode):Bool
	{
		if (rootNode == null) return false;
		
		return rootNode.RayHit(ray,lines);
	}
	public function renderSurfaces(camera:Camera,lines:Imidiatemode):Void
	{
		if (rootNode == null) return;
		
		rootNode.renderSurfaces(camera, lines);
	}
}