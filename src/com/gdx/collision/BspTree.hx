package com.gdx.collision;
import com.gdx.collision.BspTree.BspNode;
import com.gdx.math.BoundingInfo;
import com.gdx.math.Plane;
import com.gdx.math.Triangle;
import com.gdx.math.Vector3;
import com.gdx.scene3d.buffer.Imidiatemode;
import com.gdx.scene3d.Camera;

/**
 * ...
 * @author Luis Santos AKA DJOKER
 */
class BspTree
{
	static public inline var POINT_IN_FRONT_OF_PLANE = 1;
	static public inline var POINT_BEHIND_PLANE = 2;
	static public inline var POINT_ON_PLANE = 0;

	
static public inline var   EPS =  0.0001;
public var root:BspNode;
public var NodeCount:Int;
public var rendercount:Int;

	public function new(triangles:Array<Triangle>) 
	{
		NodeCount = 0;
		root = BuildNode(triangles);
		trace("BUILD:"+NodeCount+" c: "+triangles.length);
	}
	
	public function debug(camera:Camera,l:Imidiatemode):Void
	{
		_Debug(camera, root,l);
	}
	private function _Debug(camera:Camera, node:BspNode,l:Imidiatemode):Void
	{
	
		if (node != null)
		{
		node.AABB.boundingBox.renderColor(l,0,1,1);
			if (node.AABB.isInFrustrum(camera.frustumPlanes))
			//if (node.Splitter.IsInFrustum(camera.frustumPlanes))
			{
				if (node.RChild != null)
				_Debug(camera, node.RChild, l);
				
				
				rendercount++;
				l.drawTriangle(node.Splitter.a, node.Splitter.b, node.Splitter.c, 1, 0, 1, 1);
				
				if (node.LChild != null)
				_Debug(camera, node.LChild, l);
				
				return;
			}
			
		    
				
				
				if (node.LChild!= null)
				_Debug(camera, node.LChild, l);
			
				if (node.RChild != null)
				_Debug(camera, node.RChild, l);
				
			
		 
		}
	}
	public function Traverse(position:Vector3,l:Imidiatemode):Void
	{
		rendercount = 0;
		_Traverse(position, root,l);
	}
	
	public function Colide(position:Vector3,velocitiy:Vector3,radius:Vector3,slide:Float,l:Imidiatemode):Bool
	{
		rendercount = 0;
		return _Colide(root,position,velocitiy,radius,slide,l);
	}
	public function _Colide(node:BspNode,position:Vector3,velocitiy:Vector3,radius:Vector3,slide:Float,l:Imidiatemode):Bool
	{
		var result:Bool = false;
	
		if (node != null)
		{
			var d:Int = classifyPoint(position, node.plane);
			//if (node.AABB.intersectsPoint(position))
			if (d == 2)
			{
				if (node.RChild != null)
				{
				if (_Colide(node.RChild, position, velocitiy, radius, slide, l)) result = true;
				}
				
				
				
				l.drawFullTriangle(node.Splitter.a, node.Splitter.b, node.Splitter.c, 1, 0, 1, 0.9);
				node.AABB.boundingBox.renderColor(l, 0, 1, 1);
				
			  
				if (node.LChild != null)
				{
				if (_Colide(node.LChild, position, velocitiy, radius, slide, l)) result = true;
				}
			
				
			
		
			
				
				rendercount++;
				return result;
			} 
			
			
			
						
				if (node.LChild!= null)
				if (_Colide(node.LChild, position, velocitiy, radius, slide, l)) result = true;
				if (node.RChild != null)
				if (_Colide(node.RChild, position, velocitiy, radius, slide, l)) result = true;
				
				
				
		}
		return result;
	}
	public  function  ClassifySphere(vCenter:Vector3, plane:Plane,  radius:Float):Int
{
	
//#define BEHIND		0
//#define INTERSECTS	1
//#define FRONT		2
	var distance:Int=Std.int(plane.DistanceTo(vCenter));
	if (Math.abs(distance) < radius)
	{
		return 1;
	}
	else if (distance >= radius)
	{
			return 2;
	}
	return 0;
}

	public function classifyPoint(vCenter:Vector3,plane:Plane):Int
	{
	var distance:Int=Std.int(plane.DistanceTo(vCenter));
	
	if (Math.abs(distance) < 0.001)
	{
		return 1;
	}
	else if (distance >= 0.001)
	{
			return 2;
	}
	return 0;

	
	}

	private function _Traverse(position:Vector3, node:BspNode,l:Imidiatemode):Void
	{
	var triangles:Array<Triangle> = [];
	
		//if (node != null)
		{
	
							
//#define BEHIND		0
//#define INTERSECTS	1
//#define FRONT		2


			//var result:Int = Vector3.ClassifySphere(position, Vector3.TriangleNormal(node.Splitter.a,node.Splitter.b,node.Splitter.c), node.Splitter.a, 1, distance);
			var result:Int = ClassifySphere(position, node.plane, 2);
		//	var result:Int = classifyPoint(position, node.plane);
			if (result == 1)
			{
				if (node.RChild != null)
				_Traverse(position, node.RChild, l);
				
				triangles.push(node.Splitter);
				node.AABB.boundingBox.renderColor(l, 0, 1, 1);
				var result:CollisionData = Coldet.collideEllipsoidWithTriangles(triangles, position, new Vector3(1, 4, 1), Vector3.Mult(position, 0.5), Vector3.zero, 0.0005, l);
				position = result.finalPosition;
				
				l.drawFullTriangle(node.Splitter.a, node.Splitter.b, node.Splitter.c, 1, 0, 1, 0.5);
				if (node.LChild != null)
				_Traverse(position, node.LChild, l);
				rendercount++;
				return;
			}
						
				if (node.LChild!= null)
				_Traverse(position, node.LChild, l);
				if (node.RChild != null)
				_Traverse(position, node.RChild, l);
		}
	}
	
	private function SplitPoly(poly:Triangle, plane:Plane,Front:Array<Triangle>,Back:Array<Triangle>):Void
   { 
	 var tri:Array<Vector3> = [];
	 tri.push(poly.a);
	 tri.push(poly.b);
	 tri.push(poly.c);
	 

	 
 var inpts:Array<Vector3> = [];
 var  outpts:Array<Vector3> = [];
	 
	 var v:Vector3 = Vector3.zero;
	 var factor:Float = 0;
	 
	 // { Slice a polygon in half using the supplied partitioning plane. The procedure
    //creates front and back, two arrays of triangles. }
  var ptA:Vector3 = tri[2];
  var sideA:Float = plane.DistanceTo(ptA);
  
  for ( i in 0...3 )
  {
	  var ptB:Vector3 = tri[i];
     var sideB:Float = plane.DistanceTo(ptB);
    if (sideB > EPS)
    {
      if (sideA < -EPS)
      {
		   v = Vector3.Sub(ptB, ptA);
		   factor = -plane.signedDistanceTo(ptA) / Vector3.Dot(plane.normal, v);
		   var result:Vector3 = Vector3.Add(ptA, Vector3.Mult(v, factor));
		  outpts.push(result);
		  inpts.push(result);
	
		  
      }
	  outpts.push(ptB);

	}else
	if (sideB <-EPS)
    {
      if (sideA > EPS)
      {
		    v = Vector3.Sub(ptA, ptB);
		   factor = -plane.signedDistanceTo(ptA) / Vector3.Dot(plane.normal, v);
	      var result:Vector3 = Vector3.Add(ptA, Vector3.Mult(v, factor));
		  outpts.push(result);
		  inpts.push(result);
	
      }
	  inpts.push(ptB);

	}else
	 {
		 
		 outpts.push(ptB);
		 inpts.push(ptB);

		   
	 }
	 
	 ptA = ptB;
	 sideA = sideB;
	 
	
   }
 

	
   if (outpts.length == 4)
   {
	//  Front = [];
	  Front.push(new Triangle(outpts[0], outpts[1], outpts[2], Vector3.zero));
	  Front.push(new Triangle(outpts[2], outpts[3], outpts[0], Vector3.zero));
   }else
   if (outpts.length == 3)
   {
	//  Front = [];
	  Front.push(new Triangle(outpts[0], outpts[1], outpts[2], Vector3.zero));
	  trace("add to front");
	  
   }

   if (inpts.length == 4)
   {
	//   Back = [];
	  Back.push(new Triangle(inpts[0], inpts[1], inpts[2], Vector3.zero));
	  Back.push(new Triangle(inpts[2], inpts[3], inpts[0], Vector3.zero));
   }else
   if (inpts.length == 3)
   {
     //  Back = [];
	   Back.push(new Triangle(inpts[0], inpts[1], inpts[2], Vector3.TriangleNormal(inpts[0], inpts[1], inpts[2])));
	 //  trace("add to back");
	  
   }
   

   
   }

	private function BuildNode( trilist:Array<Triangle>):BspNode
	{
	
		var f:Float =0;
		
	if (trilist.length == 0) 
	{
	return null;
	} else
	{
		
	
		
		
		
		    // Pick any splitter from the list: the first triangle for example.
    var k:Triangle = trilist[0];
	
		var frontlist:Array<Triangle> = [];
		var backlist:Array<Triangle> = [];
	

	for (i in 1...trilist.length)
	{
	    f = Triangle.InFrontOf(trilist[i], k);
      if (f > 0)
	  {
		  frontlist.push( trilist[i]);
	  } // Triangle is behind the splitter.
      else if (f < 0)
	  {
		 backlist.push( trilist[i]); 
	  }
      else 
	  {
	
       	var fl:Array<Triangle> = [];
		var bl:Array<Triangle> = [];
		
		  SplitPoly(trilist[i], Plane.FromPoints(k.a, k.b, k.c), fl, bl);
		  
		
		  
		  
        // Add the parts of the triangle to the right lists.
        for (j  in 0... fl.length)
		{
          frontlist.push(fl[j]);
		 trace(fl[j].toString());
        }
		
        for (j in 0... bl.length)
		{
		//	trace(bl[j].toString());
          backlist.push(bl[j]);
        }
      }
	  
	 // trace(i);
    }
    // Create a BSP node and its two subtrees from the processed triangles.
	
    return CombineTree(BuildNode(frontlist), k, BuildNode(backlist));
  	}
	
	}

	private function CombineTree(front:BspNode, t:Triangle,back: BspNode): BspNode
	{
		var result:BspNode = new BspNode();
		result.Splitter = t;
		
		
		function checkExtends(v:Vector3, min:Vector3, max:Vector3) {
            if (v.x < min.x)
                min.x = v.x;
            if (v.y < min.y)
                min.y = v.y;
            if (v.z < min.z)
                min.z = v.z;

            if (v.x > max.x)
                max.x = v.x;
            if (v.y > max.y)
                max.y = v.y;
            if (v.z > max.z)
                max.z = v.z;
        }

        var min = new Vector3(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY);
        var max = new Vector3(Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY);

      var tris:Array<Vector3> = [];
	  tris.push(t.c);
	  tris.push(t.b);
	  tris.push(t.a);
			
	  for (i in 0...3)
	  {
              checkExtends(tris[i], min, max);
	  }	 
         
			
        
		
		result.AABB = new BoundingInfo(min, max);	
		result.plane = Plane.FromPoints(t.a, t.b, t.c);
		result.AABB.calculate();
		result.LChild = front;
		result.RChild = back;
		NodeCount++;
		return result;
	}
	
}

class BspNode
{
public var  Splitter: Triangle;        // Triangle that defines the partitioning plane.
public var  LChild:BspNode;
public var 	RChild:BspNode;   // Subtrees.
public var IsLeaf:Bool;
public var AABB:BoundingInfo;
public var plane:Plane;
	
	public function new() 
	{
	}
	
}
