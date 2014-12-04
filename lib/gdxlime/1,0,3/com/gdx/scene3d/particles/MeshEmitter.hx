package com.gdx.scene3d.particles;

import com.gdx.gl.Texture;
import com.gdx.math.Triangle;
import com.gdx.math.Vector3;
import com.gdx.scene3d.Mesh;
import com.gdx.scene3d.particles.ParticleSystem;
import com.gdx.scene3d.Surface;

/**
 * ...
 * @author djoekr
 */
class MeshEmitter extends ParticleSystem
{
	
	public  var mesh:Mesh;
	public var triangles:Array<Triangle>; 
	
	
	
	
	public function new (node:Mesh,texture:Texture,scene:Scene,Parent:SceneNode = null , id:Int = 0) 
    {
        super(texture, scene, Parent, id);
	    mesh = node;
		triangles = [];
		for (i in 0...node.surfaces.length)
		{
			var surf:Surface = node.surfaces[i];
			var tris:Array<Triangle> = surf.getTriangles();
			for (x in 0...tris.length)
			{
				triangles.push(tris[x]);
			}
		}
		 EmitPosition = triangles[0].c;
    }


	override public function getStartPosition ():Vector3
    {

		
		
		var count:Int = triangles.length;
		var tri:Triangle = triangles[Util.randi(0, count)];
	   	EmitPosition = tri.a;
		EmitPosition=Vector3.TransformCoordinates(	EmitPosition,	mesh.AbsoluteTransformation);
		return EmitPosition;
	
	}
	
}