package com.gdx.collision;

import com.gdx.math.Plane;
import com.gdx.math.Ray;
import com.gdx.math.Vector3;
import com.gdx.scene3d.buffer.Imidiatemode;
import com.gdx.scene3d.Camera;
import com.gdx.scene3d.Mesh;
import com.gdx.scene3d.Scene;
import com.gdx.scene3d.SceneNode;
import com.gdx.scene3d.Surface;
import haxe.macro.Expr.Position;

/**
 * ...
 * @author Luis Santos AKA DJOKER
 */
class Selector
{
    private var octree:Octree;
	private var qaudtree:QuadTree;
	private var MaxTriangles:Int;
	private var MaxSubdivisions:Int;
	private var useOctree:Bool;
    private var scene:Scene;
	private	 var v1:Vector3 = Vector3.zero;
	private  var v2:Vector3 = Vector3.zero;
	private var v3:Vector3 = Vector3.zero;
	private  var ellipsoid:Vector3 = new Vector3(20, 30, 20);
	
	

	public function new(scene:Scene,colidemesh:Mesh,MaxTriangles:Int,MaxSubdivisions:Int,useOctree:Bool)
	{
		this.scene = scene;
		this.MaxTriangles = MaxTriangles;
		this.MaxSubdivisions = MaxSubdivisions;
		this.useOctree = useOctree;
		
		var vertices:Array<Vector3> = [];
		for (j in 0 ... colidemesh.CountSurfaces())
		{	
		
		var surface:Surface = colidemesh.surfaces[j];
		
	          for (i in 0... surface.CountFaces())
		      {
			
				  var v0:Vector3 = surface.getFace(i, 0);
				  var v1:Vector3 = surface.getFace(i, 1);
				  var v2:Vector3 = surface.getFace(i, 2);
				  
				  vertices.push(v0);
				  vertices.push(v1);
				  vertices.push(v2);
				}
		}
	
		if (useOctree)
		{
		octree = new Octree(MaxTriangles,MaxSubdivisions);
		octree.build(vertices);
		} else
		{
		qaudtree = new QuadTree(MaxTriangles,MaxSubdivisions);
		qaudtree.build(vertices);
		}
		
		
	
	}
	
	 public function rayHit( ray:Ray, lines:Imidiatemode ) :Void
	 {
		 testRayOctree(octree, ray, lines);
	 }
	 public function testRayOctree(pNode:Octree,ray:Ray, lines:Imidiatemode ) :Void
	{
	if(pNode==null) return;
    if(pNode.m_bSubDivided)
	{
		testRayOctree(pNode.m_pOctreeNodes[Octree.TOP_LEFT_FRONT],ray,lines);
		testRayOctree(pNode.m_pOctreeNodes[Octree.TOP_LEFT_BACK],ray,lines);
		testRayOctree(pNode.m_pOctreeNodes[Octree.TOP_RIGHT_BACK],ray,lines);
		testRayOctree(pNode.m_pOctreeNodes[Octree.TOP_RIGHT_FRONT],ray,lines);
		testRayOctree(pNode.m_pOctreeNodes[Octree.BOTTOM_LEFT_FRONT],ray,lines);
		testRayOctree(pNode.m_pOctreeNodes[Octree.BOTTOM_LEFT_BACK],ray,lines);
		testRayOctree(pNode.m_pOctreeNodes[Octree.BOTTOM_RIGHT_BACK],ray,lines);
		testRayOctree(pNode.m_pOctreeNodes[Octree.BOTTOM_RIGHT_FRONT],ray,lines);
	}
	else
	{
		
		if (ray.intersectsBox(pNode.bounding.boundingBox))
		{
		 
	//trace("triangle:int:" + Std.int(pNode.m_pVertices.length / 3));
	
	    for (i in 0 ... Std.int(pNode.m_pVertices.length/3))
		{
	
			v1.x = pNode.m_pVertices[i*3+0].x ;
			v1.y = pNode.m_pVertices[i*3+0].y ;
			v1.z = pNode.m_pVertices[i*3+0].z ;
		
			v2.x = pNode.m_pVertices[i*3+1].x ;
			v2.y = pNode.m_pVertices[i*3+1].y ;
			v2.z = pNode.m_pVertices[i*3+1].z ;
			
			v3.x = pNode.m_pVertices[i*3+2].x ;
			v3.y = pNode.m_pVertices[i*3+2].y ;
			v3.z = pNode.m_pVertices[i * 3 + 2].z ;
			
			
			lines.drawTriangle(v1,v2,v3, 0, 1, 1, 1);
		}
	
		  pNode.bounding.boundingBox.render(lines);
	 
	
  	
	}
		   
		
			
	
	}
	}
	
	inline private function collideEllipsoidWithWorld(pNode:Octree,b:SceneNode,velocity:Vector3, gravity:Vector3, lines:Imidiatemode ) 
	{
		
		
		
	if(pNode==null) return;
    if(pNode.m_bSubDivided)
	{
		collideEllipsoidWithWorld(pNode.m_pOctreeNodes[Octree.TOP_LEFT_FRONT],b,velocity,gravity,lines);
		collideEllipsoidWithWorld(pNode.m_pOctreeNodes[Octree.TOP_LEFT_BACK],b,velocity,gravity,lines);
		collideEllipsoidWithWorld(pNode.m_pOctreeNodes[Octree.TOP_RIGHT_BACK],b,velocity,gravity,lines);
		collideEllipsoidWithWorld(pNode.m_pOctreeNodes[Octree.TOP_RIGHT_FRONT],b,velocity,gravity,lines);
		collideEllipsoidWithWorld(pNode.m_pOctreeNodes[Octree.BOTTOM_LEFT_FRONT],b,velocity,gravity,lines);
		collideEllipsoidWithWorld(pNode.m_pOctreeNodes[Octree.BOTTOM_LEFT_BACK],b,velocity,gravity,lines);
		collideEllipsoidWithWorld(pNode.m_pOctreeNodes[Octree.BOTTOM_RIGHT_BACK],b,velocity,gravity,lines);
		collideEllipsoidWithWorld(pNode.m_pOctreeNodes[Octree.BOTTOM_RIGHT_FRONT],b,velocity,gravity,lines);
	}
	else
	{
		
		
		
					
	if (pNode.bounding.intersects(b.Bounding, true)) 
	{
		 var collisiondata:CollisionData =	Coldet.collideEllipsoidWithVertices(pNode.m_pVertices, b.position, ellipsoid, velocity, gravity, 0.0001, lines);
		 if (collisiondata.foundCollision)
		 {
			 
		 }
		
	}
	
		//  pNode.bounding.boundingBox.render(lines);
	  //   b.Bounding.boundingBox.renderAligned(lines);

	
  	
	}
		   
		
			
	
	}
	 public function collideCamera( b:Camera,p:Vector3,radius:Vector3, velocity:Vector3, gravity:Vector3) :Void
	{
		ellipsoid.copy(radius);
		collideCameraEllipsoidWithWorld(octree,b, p, velocity, gravity, scene.lines);
	}
	public function collideCameraEllipsoidWithWorld(pNode:Octree,b:Camera,p:Vector3,velocity:Vector3, gravity:Vector3, lines:Imidiatemode ) :Void
	{
		
		
		
	if(pNode==null) return ;
    if(pNode.m_bSubDivided)
	{
		collideCameraEllipsoidWithWorld(pNode.m_pOctreeNodes[Octree.TOP_LEFT_FRONT],b,p,velocity,gravity,lines);
		collideCameraEllipsoidWithWorld(pNode.m_pOctreeNodes[Octree.TOP_LEFT_BACK],b,p,velocity,gravity,lines);
		collideCameraEllipsoidWithWorld(pNode.m_pOctreeNodes[Octree.TOP_RIGHT_BACK],b,p,velocity,gravity,lines);
		collideCameraEllipsoidWithWorld(pNode.m_pOctreeNodes[Octree.TOP_RIGHT_FRONT],b,p,velocity,gravity,lines);
		collideCameraEllipsoidWithWorld(pNode.m_pOctreeNodes[Octree.BOTTOM_LEFT_FRONT],b,p,velocity,gravity,lines);
		collideCameraEllipsoidWithWorld(pNode.m_pOctreeNodes[Octree.BOTTOM_LEFT_BACK],b,p,velocity,gravity,lines);
		collideCameraEllipsoidWithWorld(pNode.m_pOctreeNodes[Octree.BOTTOM_RIGHT_BACK],b,p,velocity,gravity,lines);
		collideCameraEllipsoidWithWorld(pNode.m_pOctreeNodes[Octree.BOTTOM_RIGHT_FRONT], b,p, velocity, gravity, lines);
		
	}
	else
	{
		
		
		
	pNode.bounding.boundingBox.render(lines);					
	if (pNode.bounding.isInFrustrum(b.frustumPlanes))
	{
		  var collisiondata:CollisionData =	Coldet.collideEllipsoidWithVertices(pNode.m_pVertices, p, ellipsoid, velocity, gravity, 0.0002, lines);
		  b.position=collisiondata.finalPosition;
		
	}
	

	  //   b.Bounding.boundingBox.renderAligned(lines);

	
  	
	}
		   
		
			
	
	}
}