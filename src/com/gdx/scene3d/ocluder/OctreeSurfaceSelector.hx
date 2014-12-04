package com.gdx.scene3d.ocluder;
import com.gdx.math.Aabbox3d;
import com.gdx.math.BoundingBox;
import com.gdx.math.Matrix4;
import com.gdx.math.Triangle;
import com.gdx.math.Vector3;
import com.gdx.scene3d.buffer.Imidiatemode;
import com.gdx.scene3d.Surface;

/**
 * ...
 * @author Luis Santos AKA DJOKER
 */
class OctreeSurfaceSelector extends Mesh
{
     public var  Root:SurfaceOctreeNode;
	 public var NodeCount:Int;
	 public var MinimalPolysPerNode:Int;
	 private var meshTrasform:Matrix4;
	 
	
	 	
public function new(minimalPolysPerNode:Int,surfaces:Array<Surface>,scene:Scene,Parent:SceneNode = null , id:Int = 0, name:String="OctreeSurfaceSelector") 
	{
		 super(scene,Parent, id, name); 
			 
		this.MinimalPolysPerNode = minimalPolysPerNode;
		this.NodeCount = 0;
		var maxTriangles:Int = surfaces.length;
		var beginTime:Float = Gdx.Instance().getTimer();
		
		meshTrasform = Matrix4.Identity();
		
		Root = new SurfaceOctreeNode();
		for ( i in 0...surfaces.length)
		{
		Root.Surfaces.push( surfaces[i]);
		}
	//    this.Bounding.boundingBox.reset(triangles[0].Bounding.boundingBox.center);
		constructOctree(Root);
		
	
	
		var endTime:Float = Gdx.Instance().getTimer();
		var timepass:Float = endTime - beginTime;
		
		trace( "Needed " + timepass + ":ms to create OctTree .(" + NodeCount+ " nodes, "+surfaces.length+" polys)" );
	}
	
	override public function render(camera:Camera) 
	{
			
      
		Bounding.update(meshTrasform, 1);		
		scene.shader.setWorldMatrix(meshTrasform);
		if (!Bounding.isInFrustrum(camera.frustumPlanes)) return;
		Gdx.Instance().numMesh++;
		renderNodes(Root,camera,scene, scene.lines);
		//this.Bounding.boundingBox.renderColor(scene.lines, 1, 1, 1);
		//renderLines(scene.lines);
		
	}
	public function renderNodes(node:SurfaceOctreeNode,camera:Camera,s:Scene,lines:Imidiatemode):Void
	{
     if (node == null) return;
	 if (this.Root == null) return;
	 node.Box.update(meshTrasform);
	 if (!node.Box._isInFrustrum(camera.frustumPlanes)) return;
	for (i in 0 ... node.Surfaces.length)
	{
		
	                var m:Surface =  node.Surfaces[i];
					 m.Bounding.update(meshTrasform, 1);
					 if (!m.Bounding.isInFrustrum(camera.frustumPlanes)) continue;
			        s.shader.setMaterialType(m.brush.materialType);
					s.shader.setColor(m.brush.DiffuseColor.r, m.brush.DiffuseColor.g,m.brush.DiffuseColor.b, m.brush.alpha);
					m.brush.Applay();		
		 		    m.render();
		
	}
	
	

	
	for (i in 0...8)
	{
		if (node.Child[i] != null)
		{
			renderNodes(node.Child[i],camera,s,lines);
		}
	}
	}
	private function constructOctree(node:SurfaceOctreeNode):Void
{
	++NodeCount;

	node.Box.reset(node.Surfaces[0].Bounding.boundingBox.center);
	
		// get bounding box
	var cnt:Int = node.Surfaces.length;
	for( i in 0... cnt)
	{
		node.Box.addInternalBox(node.Surfaces[i].Bounding.boundingBox);
		
	}

	 node.Box.calculate();
	
	var middle:Vector3 = node.Box.getCenter();
	
	
	var edges:Array<Vector3> = [];
	 node.Box.getEdges(edges);
	 
	 this.Bounding.boundingBox.addInternalBox(node.Box);


	var box:BoundingBox = new BoundingBox(Vector3.zero,Vector3.zero);
	
	

	// calculate children

	if (!node.Box.isEmpty() && Std.int(node.Surfaces.length) > MinimalPolysPerNode)
	for (ch in 0 ...8)
	{
	
		box.reset(middle);
		box.addInternalVector(edges[ch]);
		
		node.Child[ch] = new SurfaceOctreeNode();
 	   var i = 0;
        while (i < node.Surfaces.length) 
		{
			
			 if (node.Surfaces[i].Bounding.boundingBox.isFullInside(box))
			{
			
				node.Child[ch].Surfaces.push(node.Surfaces[i]);
				node.Surfaces.splice(i,1);
				--i;
			} 
			++i;
		}
	
		if (node.Child[ch].Surfaces.length<=0)
		{
			node.Child[ch].Surfaces = null;
			node.Child[ch] = null;
		}
		else
			constructOctree(node.Child[ch]);
	}
	
}
public function renderLines(l:Imidiatemode):Void
{
	if (this.Root == null) return;
	Root.Box.renderColor(l, 1, 1, 1);
	Debugtrace(this.Root, l);
}

private function Debugtrace(node:SurfaceOctreeNode,l:Imidiatemode):Void
{
	node.Box.renderColor(l, 1, 0, 1);
	for (i in 0...8)
	{
		if (node.Child[i] != null)
		{
			Debugtrace(node.Child[i],l);
		}
	}
}


	
}


class SurfaceOctreeNode
{
	
	public var Child:Array<SurfaceOctreeNode>;
	public var Box:BoundingBox;
	public var Surfaces:Array<Surface>;
	public function new() 
	{
		Child = [];
		Surfaces = [];
		Box = new BoundingBox(new Vector3(999999,999999,999999),new Vector3(-999999,-999999,-999999));
	}
	
}