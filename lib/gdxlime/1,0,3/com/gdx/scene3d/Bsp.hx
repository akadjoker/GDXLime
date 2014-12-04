package com.gdx.scene3d;
import com.gdx.collision.Coldet;
import com.gdx.collision.CollisionData;
import com.gdx.math.BoundingBox;
import com.gdx.math.BoundingInfo;
import com.gdx.math.Matrix4;
import com.gdx.math.Plane;
import com.gdx.math.Triangle;
import com.gdx.math.Vector3;
import com.gdx.scene3d.Bsp.BSPNode;
import com.gdx.scene3d.buffer.Imidiatemode;
import com.gdx.scene3d.irr.S3DVertex2TCoords;

/**
 * ...
 * @author Luis Santos AKA DJOKER
 */
class Bsp
{
	
	static public inline var POINT_IN_FRONT_OF_PLANE = 1;
	static public inline var POINT_BEHIND_PLANE = -1;
	static public inline var POINT_ON_PLANE = 0;
	static public inline var POINT_SPANNING = 2;
	
	static public inline var  cFront = 0;
	static public inline var  cBack = 1;
	static public inline var  cTwoFrontOneBack = 2;
	static public inline var  cOneFrontTwoBack = 3;
	static public inline var  cOneFrontOneBack = 4;
	

		 
	
	public var uniqueID:Int;
	private var root:BSPNode;
	public var leafnodecount:Int;
	public var nodecount:Int;
	public var nodesRender:Int;
	public var trisRender:Int;
	
	
	public function new()
	{
		 nodesRender=0;
	    trisRender=0;
	
		uniqueID = 0;
		leafnodecount = 0;
		nodecount = 0;
		root = new BSPNode(this);
		
	}
	public function Build():Void
	{
		root.build();
		root.updateleafbb();
		
		trace(leafnodecount + "  , " + nodecount);	
	}
	public function addTri(a:Vector3,b:Vector3,c:Vector3) 
	{
	
		root.tris.push(new BSPTri(a,b,c));
	
	}
	
	public function UniqueID():Int
	{
		this.uniqueID++;
		return uniqueID;
	}
	public function FindLeaf(p:Vector3):BSPNode
	{
		return Bsp.FindLeafImpl(root, p);
		
	}
	public function colide( p:Vector3, velocitiy:Vector3, radius:Vector3, slide:Float, l:Imidiatemode):Void
	{
			 nodesRender=0;
	    trisRender = 0;
		var tris:Array<BSPTri> = [];
		root.colide( p,  radius,  tris, l);
		
		 var data:CollisionData =	CollideTrianglesAndSlide(tris, p, radius, velocitiy, new Vector3(0,-0.9,0), slide, l);
		p.copyFrom( data.finalPosition);
		
		
	}
		public function CameraColide( c:Camera, velocitiy:Vector3, radius:Vector3, slide:Float, l:Imidiatemode):Void
	{
			 nodesRender=0;
	    trisRender = 0;
		var tris:Array<BSPTri> = [];
		root.cameraColide( c,   tris, l);
		
		 var data:CollisionData =	CollideTrianglesAndSlide(tris, c.position, radius, velocitiy, new Vector3(0,-0.9,0), slide, l);
		c.position.copyFrom( data.finalPosition);
	//	c.LookAt.copyFrom( data.finalPosition);
		
		
	}
	
		public static function collideWithTriangles(recursionDepth:Int,colData:CollisionData,selector:Array<BSPTri>,position:Vector3,  velocity:Vector3,l:Imidiatemode):Vector3
	
	{
		// Set this to match application scale..
       // var unitsPerMeter:Float = 100.0;
       // var unitScale:Float = unitsPerMeter / 100.0;
       // var veryCloseDistance:Float = 0.005 * unitScale;

         var veryCloseDistance:Float =  colData.slidingSpeed;
			   
		if (recursionDepth > 3)
		{
			return position;
		}
		

     

	    colData.velocity=velocity;
		colData.normalizedVelocity = Vector3.Normalize(velocity);
		colData.basePoint = position;
		colData.foundCollision = false;
		colData.nearestDistance = 9999999999999.0;

     var v1:Vector3 = Vector3.zero;
	 var v2:Vector3 = Vector3.zero;
	 var v3:Vector3 = Vector3.zero;
	 
	var sMultx:Float = 1.0 / colData.eRadius.x;
	var sMulty:Float = 1.0 / colData.eRadius.y;
	var sMultz:Float = 1.0 / colData.eRadius.z;
	
	
		
		for (i in 0 ... selector.length)
		{
	
			v1.x = selector[i].vertices[0].x * sMultx;
			v1.y = selector[i].vertices[0].y * sMulty;
			v1.z = selector[i].vertices[0].z * sMultz;
		
			v2.x = selector[i].vertices[1].x * sMultx;
			v2.y = selector[i].vertices[1].y * sMulty;
			v2.z = selector[i].vertices[1].z * sMultz;
			
			v3.x = selector[i].vertices[2].x * sMultx;
			v3.y = selector[i].vertices[2].y * sMulty;
			v3.z = selector[i].vertices[2].z * sMultz;
			

					if (Coldet.testTriangle(colData, v3,v2,v1, l)) 
					{
					//	l.drawFullTriangle(Vector3.ScaleBy(v1, colData.eRadius), Vector3.ScaleBy(v2, colData.eRadius), Vector3.ScaleBy(v3, colData.eRadius), 1, 0, 0, 1);
					}	
				
		}
		
                
     
                // If no collision we just move along the velocity
                if (!colData.foundCollision)
                {
                    return  Vector3.Add(position, velocity);
                }
     
			     // *** Collision occured ***
                // The original destination point
                var destinationPoint:Vector3 = Vector3.Add(position,velocity);
				var newBasePoint:Vector3  = position;
				
				
     
                // only update if we are not already very close
                // and if so we only move very close to intersection..not
                // to the exact spot.
     
				
                if (colData.nearestDistance >= veryCloseDistance)
                {
                    var  V:Vector3 = velocity;
					
                  //  V.normalize();
				//	V = Vector3.Mult(V, (colData.nearestDistance - veryCloseDistance));
					V.setLength(colData.nearestDistance - veryCloseDistance);
					
                    newBasePoint = Vector3.Add(colData.basePoint, V);
     
                    // Adjust polygon intersection point (so sliding
                    // plane will be unaffected by the fact that we
                    // move slightly less than collision tells us)
                    V.normalize();
                    colData.intersectionPoint.x -= (veryCloseDistance*V.x);
					colData.intersectionPoint.y -= (veryCloseDistance*V.y);
					colData.intersectionPoint.z -= (veryCloseDistance*V.z);
				
                }
     
                // calculate sliding plane
                var slidePlaneOrigin:Vector3 = colData.intersectionPoint;
				
				
                var  slidePlaneNormal:Vector3 = Vector3.Sub(newBasePoint, colData.intersectionPoint);
				slidePlaneNormal.normalize();
				
				
				//trace(slidePlaneNormal.toString());
				
			    var slidingPlane:Plane =Plane.FromPositionAndNormal(slidePlaneOrigin, slidePlaneNormal);
     
        
          	    var newDestinationPoint:Vector3 = Vector3.zero;
				
				var d:Float = slidingPlane.signedDistanceTo(destinationPoint);
				
				newDestinationPoint.x = destinationPoint.x - (slidePlaneNormal.x * d);
				newDestinationPoint.y = destinationPoint.y - (slidePlaneNormal.y * d);				
				newDestinationPoint.z = destinationPoint.z - (slidePlaneNormal.z * d);
				
				
				
     
                // Generate the slide vector, which will become our new velocity vector for the next iteration
                var newVelocityVector:Vector3 = Vector3.Sub(newDestinationPoint, colData.intersectionPoint);
			
	
     
                // Recurse: Don't recurse if the new velocity is very small
                if (newVelocityVector.length() < veryCloseDistance)
                {
                    return newBasePoint;
                }
     
               
		return collideWithTriangles(recursionDepth+1,colData,selector,newBasePoint,newVelocityVector,l);
	}
	public static function CollideTrianglesAndSlide(selector:Array<BSPTri>,position:Vector3, radius:Vector3, velocity:Vector3,gravity:Vector3,slidingSpeed:Float,l:Imidiatemode):CollisionData
	{
		
		var  colData:CollisionData = new CollisionData();
        colData.eRadius = radius;
	    colData.R3Velocity=velocity;
	    colData.R3Position = position;
		colData.triangleHits = 0;
		colData.foundCollision = false;
		colData.slidingSpeed = slidingSpeed;
		colData.nearestDistance = 9999999999999.0;
		
		var eSpacePosition:Vector3 = Vector3.zero;
		var eSpaceVelocity:Vector3 = Vector3.zero;
		
		eSpacePosition.x = colData.R3Position.x / colData.eRadius.x;
		eSpacePosition.y = colData.R3Position.y / colData.eRadius.y;
		eSpacePosition.z = colData.R3Position.z / colData.eRadius.z;
		
		eSpaceVelocity.x = colData.R3Velocity.x / colData.eRadius.x;
		eSpaceVelocity.y = colData.R3Velocity.y / colData.eRadius.y;
		eSpaceVelocity.z = colData.R3Velocity.z / colData.eRadius.z;
		
	 var finalPosition:Vector3 = Bsp.collideWithTriangles(0, colData, selector, eSpacePosition, eSpaceVelocity, l);


	 // add gravity
	 
	 if (!gravity.equalsToFloats(0, 0, 0))
	 {
	  
	   colData.R3Position.x =   finalPosition.x * colData.eRadius.x;
	   colData.R3Position.y =   finalPosition.y * colData.eRadius.y;
	   colData.R3Position.z =   finalPosition.z * colData.eRadius.z;
	   colData.R3Velocity = gravity;
	   colData.triangleHits = 0;
	   
	   	eSpaceVelocity.x = gravity.x / colData.eRadius.x;
		eSpaceVelocity.y = gravity.y / colData.eRadius.y;
		eSpaceVelocity.z = gravity.z / colData.eRadius.z;
	   
		finalPosition = Bsp.collideWithTriangles(0, colData, selector, finalPosition, eSpaceVelocity, l);
	 }
	
	finalPosition.x *= colData.eRadius.x;
	finalPosition.y *= colData.eRadius.y;
	finalPosition.z *= colData.eRadius.z;
	
	colData.finalPosition = finalPosition;
	colData.hitPosition.set(colData.intersectionPoint.x * colData.eRadius.x, colData.intersectionPoint.y * colData.eRadius.y, colData.intersectionPoint.z * colData.eRadius.z);
    colData.Falling = (colData.triangleHits == 0);
               
		return colData;
	}	
	
	public static function GetPositionOnTriangles(selector:Array<BSPTri>,position:Vector3, radius:Vector3, velocity:Vector3,slidingSpeed:Float,l:Imidiatemode):CollisionData
	{
		
		var  colData:CollisionData = new CollisionData();
        colData.eRadius = radius;
	    colData.R3Velocity=velocity;
	    colData.R3Position = position;
		colData.triangleHits = 0;
		colData.slidingSpeed = slidingSpeed;
		colData.nearestDistance = 9999999999999.0;
		
		var eSpacePosition:Vector3 = Vector3.zero;
		var eSpaceVelocity:Vector3 = Vector3.zero;
		
		eSpacePosition.x = colData.R3Position.x / colData.eRadius.x;
		eSpacePosition.y = colData.R3Position.y / colData.eRadius.y;
		eSpacePosition.z = colData.R3Position.z / colData.eRadius.z;
		
		eSpaceVelocity.x = colData.R3Velocity.x / colData.eRadius.x;
		eSpaceVelocity.y = colData.R3Velocity.y / colData.eRadius.y;
		eSpaceVelocity.z = colData.R3Velocity.z / colData.eRadius.z;
		
	 colData.finalPosition = Bsp.collideWithTriangles(0, colData, selector, eSpacePosition, eSpaceVelocity, l);

	 
	
	colData.finalPosition.x *= colData.eRadius.x;
	colData.finalPosition.y *= colData.eRadius.y;
	colData.finalPosition.z *= colData.eRadius.z;
	colData.hitPosition.set(colData.intersectionPoint.x * colData.eRadius.x, colData.intersectionPoint.y * colData.eRadius.y, colData.intersectionPoint.z * colData.eRadius.z);
	colData.Falling = (colData.triangleHits == 0);
           
		return colData;
	}	
	static private function FindLeafImpl(node:BSPNode,p:Vector3):BSPNode
	{
		if (node == null) return null;
		var front:Bool = false;
	
		if (node.Leaf) 
		{
			front = true;
			var r:Int = Bsp.ClassifyPoly(node.tris, p);
			if ( r == POINT_BEHIND_PLANE)
			{
			front = false;
			}
			
		
		 if (front) 
		 return node.Front;
		 else
		 return node.Back;
			
		}
		
		else
		
		{
		var side:Int = Bsp.ClassifyPoint(p, node.Planepoint, node.Planenormal);
		if (side == Bsp.POINT_IN_FRONT_OF_PLANE) 
		{
           return FindLeafImpl(node.Front, p);
          
        } else
		{
		   return FindLeafImpl(node.Back, p);
		}
      
		
		}
	
		
		
	}
	public function walkTree( p:Vector3, lines:Imidiatemode)
	{
		 nodesRender=0;
	     trisRender=0;
		 walkBspTree(root, p, lines);
	}
	private function walkBspTree(node:BSPNode,p:Vector3,lines:Imidiatemode)
	{
		if (node == null) return;
		if (node.Leaf == true) return;
		
			var side:Int = ClassifyPoint(p, node.Planepoint, node.Planenormal);
		//	var side:Int = ClassifyPoly(node.tris,p);
			
		if (side == POINT_IN_FRONT_OF_PLANE) 
		{
        
		    walkBspTree(node.Back, p,  lines);
		
			
		//	if (Node.AABB.boundingBox.intersectsSphere(p, 2))
			
			 nodesRender++;
	         trisRender += node.tris.length;
			 
			node.AABB.boundingBox.render(lines);
			for (i in 0...node.tris.length)
			{
				var t = node.tris[i];
				
				lines.drawTriangle(t.vertices[0], t.vertices[1], t.vertices[2], 1, 1, 0, 1);
			}
			
	
		     walkBspTree(node.Front, p,  lines);
		
         return;
        }
		
		 // This happens if we are at back or on plane
      
	
		    walkBspTree(node.Front, p,  lines);
	
		    walkBspTree(node.Back, p,  lines);
		
		
	}
	
	public function render(p:Vector3, lines:Imidiatemode)
	{
		 nodesRender=0;
	     trisRender=0;
		if (root.Front != null) root.render(p, lines);
	
	}
	public function debug(p:Camera, lines:Imidiatemode)
	{
		 nodesRender=0;
	    trisRender=0;
		if (root.Front != null) root.debug(p, lines);
	
	}
	static public function SplitTri(SplitTri:BSPTri, planepoint:Vector3, planenormal:Vector3, tris:Array<BSPTri>):Int
	{
		  var result:Int = cFront;
		  var incount :Int= 0;
          var outcount :Int= 0;
		 var splittrinormal:Vector3 = Vector3.TriangleNormal(SplitTri.vertices[0], SplitTri.vertices[1], SplitTri.vertices[2]);
		 var count:Int = 0;
	
		 var intersection:Vector3 = Vector3.zero;
	var pta:Vector3 = Vector3.zero;
	var ptb:Vector3 = Vector3.zero;
	
	
	 
 var inpts:Array<Vector3> = [];
 var  outpts:Array<Vector3> = [];
	 
	
		 for (loop in 0...3)
		 {
			 if (ClassifyPoint(SplitTri.vertices[loop], planepoint, planenormal) == 0)
				 count++;
				 else
				 break;
			 
		 }
		
	if (count == 3)
	{
        if (ClassifyPoint(splittrinormal, planepoint, planenormal) == 1)
        {
           return cFront;
		}
        if (ClassifyPoint(splittrinormal, planepoint, planenormal) == -1)
        {
         return cBack;
		}
    }

	  pta = SplitTri.vertices[2];
	 var sideA:Int = ClassifyPoint(pta, planepoint, planenormal);
	 
	 	
		
	 for (i in 0...2)
	 {
	   ptb = SplitTri.vertices[i];
	  var sideB:Int = ClassifyPoint(ptb, planepoint, planenormal);

	   if (sideB > 0)
        {
            if (sideA < 0 )
            {
				    intersection = GetEdgeIntersection(pta, ptb, planepoint, planenormal);

					 var v1 = Vector3.Sub(ptb, pta);
					 var v2 = Vector3.Sub(intersection, pta);
			
		  outpts.push(intersection);
		  inpts.push(intersection);
		  outcount++;
		  incount++;
				
			}//sidea
			
			 inpts.push(ptb);
			 incount++;
		}//sideb
		 else
            if (sideB < 0 )
            {
                if (sideA > 0)
                {
					
					intersection = GetEdgeIntersection(pta, ptb, planepoint, planenormal);

					 var v1 = Vector3.Sub(ptb, pta);
					 var v2 = Vector3.Sub(intersection, pta);
			
		           outpts.push(intersection);
		           inpts.push(intersection);
				     outcount++;
		           incount++;
				
		  
		  
				}
				
				 outpts.push(ptb);
				 outcount++;
			} else
			{
				 outpts.push(ptb);
				 inpts.push(pta);
				 outcount++;
				 incount++;
			}
			
			 pta = ptb;
            sideA= sideB;
	 }//for
	 
var result:Int = 0; 
  if (incount == 4)
   {
	   result = cTwoFrontOneBack;
	   if (tris != null)
	   {
		   tris.push(new BSPTri(inpts[0], inpts[1], inpts[2]));
		   tris.push(new BSPTri(inpts[0], inpts[2], inpts[3]));
		   tris.push(new BSPTri(outpts[0], outpts[1], outpts[2]));
	   }
   }
	else
	if (outcount== 4)
	{
		result = cOneFrontTwoBack;
		if (tris != null)
	   {
		   tris.push(new BSPTri(inpts[0], inpts[1], inpts[2]));
		   tris.push(new BSPTri(outpts[0], outpts[1], outpts[2]));
		   tris.push(new BSPTri(outpts[0], outpts[2], outpts[3]));
	   }
	} else
	if ((incount == 3) && (outcount == 3))
	{
		 	  	if (tris != null)
	          { 
				  tris.push(new BSPTri(inpts[0], inpts[1], inpts[2]));
		          tris.push(new BSPTri(outpts[0], outpts[1], outpts[2])); 
			  }
		   
		
	} else
	{
		for (loop in 0...3)
		{
			var temp:Vector3 = SplitTri.vertices[loop];
			var side:Int = ClassifyPoint(temp, planepoint, planenormal);
			if (side == 1)
			{
				result = cFront;
				break;
			}else
			{
				if (side == -1)
				{
					result = cBack;
					break;
				}
			}
		}
	}
	

	
		return result;
	}
	static public function SelectPartitionfromList(tris:Array<BSPTri>, bestfront:Int, bestback:Int):Int
	{
	var count:Int = 0;
	var absdifference :Float= 1000000000;
    var bestplane:Int = 0;
    var numtris:Int = tris.length;
	
	var front:Int = 0;
	var back:Int = 0;
	
	var planepoint:Vector3 = Vector3.zero;
	var planenormal:Vector3 = Vector3.zero;
	
	
	for (potentialplane in 0...numtris)
	{
		front = 0;
		back = 0;
		for (polytoclassify in 0...numtris)
		{
			
			planepoint = tris[potentialplane].vertices[0];
			planenormal = Vector3.TriangleNormal(tris[potentialplane].vertices[0], tris[potentialplane].vertices[1], tris[potentialplane].vertices[2]);
			
			var res:Int =  Bsp.SplitTri(tris[polytoclassify], planepoint, planenormal, null);
			
			switch (res)
			{
			case cFront:front+=1;
			case cBack:back+=1;
		    case cTwoFrontOneBack:
			{
				front += 2;
				back += 1;
			}
			case cOneFrontTwoBack:
				{
					front += 1;
				    back += 2;
				}
				case cOneFrontOneBack:
					{
						front += 1;
						back += 1;
					}
			}
		}
		if (Math.abs(front - back) < absdifference)
		{
			absdifference = Math.abs(front - back);
			bestplane = potentialplane;
			bestfront = front;
			bestback = back;
			
		}
		if ((front == 0) || (back == 0))
		{
			count++;
		}
		
	}
		
		if (count == numtris)
		{
			return -1;
		} else
		{
			return bestplane;
		}
	
	
	
	}
	
	static public function  ClassifyPoint(point:Vector3, p0:Vector3, pN: Vector3):Int
	{
    var dir:Vector3 =Vector3.Sub(p0, point);

    var d :Float=Vector3.Dot(dir, pN);

    if (d < -0.001) 

        return  POINT_IN_FRONT_OF_PLANE;
    else
        if (d > 0.001) 
            return POINT_BEHIND_PLANE;
        else
            return POINT_ON_PLANE;
	}



	static public function  ClassifyPoly(polys:Array<BSPTri>, p:Vector3):Int
	{
     var ifront:Int = 0;
	 var iback:Int = 0;
	 var iin:Int = 0;
		 var plane:Plane = new Plane(0, 0, 0, 0);
	 
	 for (i in 0...polys.length)
	 {
		 plane.copyFromPoints(polys[i].vertices[0], polys[i].vertices[1], polys[i].vertices[2]);
		 
		 var dir:Int = plane.classifyVertex(p);

		 
		 switch (dir)
		 {
			 case POINT_IN_FRONT_OF_PLANE:
				 {
					  ifront++;
				 }
			 case POINT_BEHIND_PLANE:
				 {
					 iback++; 
				 }
			 case POINT_ON_PLANE:
				 {
					
			 ifront++;
			 iback++;
			 iin++; 
				 }
				 
				 
		 }
		}
	 if (iin == polys.length)    return  POINT_ON_PLANE; else
	 if (ifront == polys.length) return  POINT_IN_FRONT_OF_PLANE; else
	 if (iback == polys.length)  return  POINT_BEHIND_PLANE; else
	 return POINT_SPANNING;
	}
	
	static public function GetEdgeIntersection(point0:Vector3, point1:Vector3, planepoint:Vector3, planenormal:Vector3):Vector3
   {  
	   var temp =Vector3.Sub(planepoint, point0);
    var numerator =Vector3.Dot(planenormal, temp);

    temp =Vector3.Sub(point1, point0);
    var denominator = Vector3.Dot(planenormal, temp);
    var t:Float = 0;
    if (denominator > 0 )
        t = numerator / denominator;
    else
        t = 0;

    return Combine(point0, temp, t);
   }
   
   static public function Combine(V1:Vector3, V2:Vector3,F:Float):Vector3
  {
	  var Result:Vector3 = Vector3.zero;
    Result.x = V1.x + V2.x * F;
    Result.y = V1.y + V2.y * F;
    Result.z = V1.z + V2.z * F;
	return Result;
  }

}

 class BSPNode 
 {
   public var Leaf:Bool;
   public var AABB:BoundingInfo;
   public var tris:Array<BSPTri>;
   public var Front: BSPNode;               
   public var Back: BSPNode;    
   public var tree:Bsp;
   public var id:Int;
   public var   Planepoint:Vector3;
   public var   Planenormal:Vector3;
 public		var min:Vector3;
 public     var max:Vector3;
		
			
		
     public function new(t:Bsp) 
	{
	Leaf = false;
	tree = t;
	t.nodecount++;
	id = t.UniqueID();
	AABB = new BoundingInfo(Vector3.zero, Vector3.zero);
	AABB.update(Matrix4.Identity(), 1);
	tris = [];
	Front = null;
	Back = null;
	Planepoint = Vector3.zero;
	Planenormal = Vector3.zero;
	
    }
	public function updateleafbb()
	{
		if (Leaf) 
		{
			 min = new Vector3(90000, 90000, 90000);
			 max = new Vector3( -90000, -90000, -90000);
			for (i in 0...tris.length)
			{
				for (j in 0...3)
				{
					var v:Vector3 = tris[i].vertices[j];
					Vector3.GetMinMax(min, max, v);
				}
			}
			//trace(min.toString());
			//trace(max.toString());
			this.AABB.set(min, max);
			AABB.update(Matrix4.Identity(), 1);
			
		}else
		{
		if(Front!=null)
		{
		Front.updateleafbb();
		Back.updateleafbb();
		}
		}
	}

		public function render(p:Vector3,lines:Imidiatemode)
	{
		if (!Leaf) 
		{
			var side:Int = Bsp.ClassifyPoint(p, Planepoint, Planenormal);
		if (side == -1) 
		{
            Front.render(p,lines);
            Back.render(p,lines);
        }
        else
        {
            Back.render(p,lines);
            Front.render(p,lines);
        }
		
		}
		else
		{
			if (AABB.boundingBox.intersectsSphere(p, 2))
			{
			 tree.nodesRender++;
	         tree.trisRender += tris.length;			 
			 AABB.boundingBox.render(lines);
			for (i in 0...tris.length)
			{
				var t = tris[i];				
				lines.drawTriangle(t.vertices[0], t.vertices[1], t.vertices[2], 1, 1, 0, 1);
			}
			}
		}
	}
	public function colide(p:Vector3,radius:Vector3,pack:Array<BSPTri>,l:Imidiatemode):Void
	{
		if (!Leaf) 
		{
			var side:Int = Bsp.ClassifyPoint(p, Planepoint, Planenormal);
		if (side == -1) 
		{
            Front.colide(p,radius,pack,l);
            Back.colide(p,radius,pack,l);
        }
        else
        {
          Back.colide(p,radius,pack,l);
          Front.colide(p,radius,pack,l);
        }
		
		}
		else
		{
			
	        if (AABB.boundingBox.intersectsSphere(p, (radius.x+radius.y+radius.z)))
			{
			 tree.nodesRender++;
	         tree.trisRender += tris.length;
			 for (i in 0...tris.length)
			 {
				 pack.push(tris[i]);
			 }
			
	        return;
			}
        }
		
		
			 
			
		
	}
	public function cameraColide(c:Camera,pack:Array<BSPTri>,l:Imidiatemode):Void
	{
		if (!Leaf) 
		{
			var side:Int = Bsp.ClassifyPoint(c.position, Planepoint, Planenormal);
		if (side == -1) 
		{
            Front.cameraColide(c,pack,l);
            Back.cameraColide(c,pack,l);
        }
        else
        {
          Back.cameraColide(c,pack,l);
          Front.cameraColide(c,pack,l);
        }
		
		}
		else
		{
			
	       // if (AABB.boundingBox.intersectsSphere(p, (radius.x+radius.y+radius.z)))
		   if (c.MinMaxInFrustum(AABB.boundingBox.minimum,AABB.boundingBox.maximum))
			{
			 tree.nodesRender++;
	         tree.trisRender += tris.length;
			 for (i in 0...tris.length)
			 {
				 pack.push(tris[i]);
			 }
			
	        return;
			}
        }
		
		
			 
			
		
	}
	public function debug(p:Camera,lines:Imidiatemode)
	{
		if (!Leaf) 
		{
			var side:Int = Bsp.ClassifyPoint(p.position, Planepoint, Planenormal);
		if (side == -1) 
		{
            Front.debug(p,lines);
            Back.debug(p,lines);
        }
        else
        {
            Back.debug(p,lines);
            Front.debug(p,lines);
        }
		
		}
		else
		{
			
		//	if (AABB.boundingBox.intersectsSphere(p, 2))
		if (p.MinMaxInFrustum(min,max))
		   //if (AABB.isInFrustrum(p.frustumPlanes))
			{
			 tree.nodesRender++;
	         tree.trisRender += tris.length;
		 	 AABB.boundingBox.render(lines);
		
			
			for (i in 0...tris.length)
			{
				var t = tris[i];
				
				//lines.drawFullTriangle(t.vertices[0], t.vertices[1], t.vertices[2], 1, 1, 0, 1);
			}
			} else
			{
			}
		}
	}
	
	
	
		
	
	public function teste(lines:Imidiatemode)
	{
		if (Leaf) 
		{
			 	AABB.boundingBox.render(lines);
				
				for (i in 0...tris.length)
			{
				var t = tris[i];
				
				lines.drawFullTriangle(t.vertices[0], t.vertices[1], t.vertices[2], 1, 1, 0, 1);
			}
			
		} else
		{
			Front.teste(lines);
			Back.teste(lines);
		}
	}
	
	public function build()
	{
		var frontindex:Int = 0;
		var backindex:Int = 0;
		if (tris.length <= 0) return;
		
		var partplane:Int = Bsp.SelectPartitionfromList(tris, frontindex, backindex);
		
	
	
	 if (partplane == -1) 
    {
        Leaf = true;
        tree.leafnodecount++;
        return;
    }
	
		    Planepoint = tris[partplane].vertices[0];
	  		Planenormal = Vector3.TriangleNormal(tris[partplane].vertices[0], tris[partplane].vertices[1], tris[partplane].vertices[2]);
		
		this.Front = new BSPNode(tree);
		this.Back = new BSPNode(tree);
		
		 var frontindex = 0;
         var backindex = 0;
         var numtris  = tris.length;
		 
		 var output:Array<BSPTri> = [];
		 
		 
		   for ( tritoclassify in 0... numtris)
		   {
			    var res  = Bsp.SplitTri(tris[tritoclassify], Planepoint, Planenormal, output);
				
				switch (res)
				{
				case Bsp.cFront:
					{
						Front.tris.push(tris[tritoclassify]);
					}
					case Bsp.cBack:
					{
						Back.tris.push(tris[tritoclassify]);
					}
					case Bsp.cTwoFrontOneBack:
						{
							Front.tris.push(output[0]);
							Front.tris.push(output[1]);
							Back.tris.push(output[2]);
						}
				case Bsp.cOneFrontTwoBack:
						{
							Front.tris.push(output[0]);
							Back.tris.push(output[1]);
							Back.tris.push(output[2]);
						}
						case Bsp.cOneFrontOneBack:
							{
								Front.tris.push(output[0]);
							    Back.tris.push(output[1]);
							}
		   }
		   }
		   
		   
	
	
		this.Front.build();
		this.Back.build();
	}
	

	
 }

  class BSPTri 
 {
	     public var vertices:Array<Vector3>;
	     public function new(v1:Vector3,v2:Vector3,v3:Vector3)
		 {
			vertices = []; 
			vertices.push(v1);
	        vertices.push(v2);
	        vertices.push(v3);
		 }
	
 }
  