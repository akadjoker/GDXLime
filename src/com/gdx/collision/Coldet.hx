package  com.gdx.collision;

import com.gdx.math.BoundingBox;
import com.gdx.math.Matrix4;
import com.gdx.math.Plane;
import com.gdx.math.Triangle;
import com.gdx.math.Vector3;
import com.gdx.scene3d.buffer.Imidiatemode;




typedef LowestResult = {
	root: Float,
	found: Bool
}

typedef LowestRoot = {
	root: Float,
	found: Bool
}

typedef TimeBool = {
	tMax: Float,
	found: Bool
}
typedef TimeBoolNormal = {
	tMax: Float,
	found: Bool,
	normal:Vector3
}

/**
 * ...
 * @author Luis Santos AKA DJOKER
 */
class Coldet
{

	public function new() 
	{
		
	}
	
	public static function  getLowestRoot(a:Float, b:Float, c:Float, maxR:Float):LowestResult {
        var determinant = b * b - 4.0 * a * c;
        var result:LowestResult = { root: 0, found: false };

        if (determinant < 0)
            return result;

        var sqrtD = Math.sqrt(determinant);
        var r1 = (-b - sqrtD) / (2.0 * a);
        var r2 = (-b + sqrtD) / (2.0 * a);

        if (r1 > r2) {
            var temp = r2;
            r2 = r1;
            r1 = temp;
        }

        if (r1 > 0 && r1 < maxR) {
            result.root = r1;
            result.found = true;
            return result;
        }

        if (r2 > 0 && r2 < maxR) {
            result.root = r2;
            result.found = true;
            return result;
        }

        return result;
    }

	
	///**************************************************************************************************************************
	public static function collideWithVertices(recursionDepth:Int,colData:CollisionData,selector:Array<Vector3>,position:Vector3,  velocity:Vector3,l:Imidiatemode):Vector3
	{
		
		
		// Set this to match application scale..
        var unitsPerMeter:Float = 100.0;
        var unitScale:Float = unitsPerMeter / 100.0;
        var veryCloseDistance:Float = 0.005 * unitScale;

    //     var veryCloseDistance:Float =  colData.slidingSpeed;
			   
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
	
	
		
		for (i in 0 ... Std.int(selector.length/3))
		{
	
			v1.x = selector[i*3+0].x * sMultx;
			v1.y = selector[i*3+0].y * sMulty;
			v1.z = selector[i*3+0].z * sMultz;
		
			v2.x = selector[i*3+1].x * sMultx;
			v2.y = selector[i*3+1].y * sMulty;
			v2.z = selector[i*3+1].z * sMultz;
			
			v3.x = selector[i*3+2].x * sMultx;
			v3.y = selector[i*3+2].y * sMulty;
			v3.z = selector[i*3+2].z * sMultz;
			

					if (Coldet.testTriangle(colData, v3,v2,v1, l)) 
					{
						//l.drawTriangle(Vector3.ScaleBy(v3, colData.eRadius), Vector3.ScaleBy(v2, colData.eRadius), Vector3.ScaleBy(v1, colData.eRadius), 0, 1, 0, 1);
						//break;
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
				
				
				///trace(slidePlaneNormal.toString());
				
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
     
               
		return collideWithVertices(recursionDepth+1,colData,selector,newBasePoint,newVelocityVector,l);
	}
	//*************************************************************************************************************************
	public static function collideWithTriangles(recursionDepth:Int,colData:CollisionData,selector:Array<Triangle>,position:Vector3,  velocity:Vector3,l:Imidiatemode):Vector3
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
		

     

	    colData.velocity.copyFrom(velocity);
		colData.normalizedVelocity = Vector3.Normalize(velocity);
		colData.basePoint.copyFrom(position);
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
	
			v1.x = selector[i].a.x * sMultx;
			v1.y = selector[i].a.y * sMulty;
			v1.z = selector[i].a.z * sMultz;
		
			v2.x = selector[i].b.x * sMultx;
			v2.y = selector[i].b.y * sMulty;
			v2.z = selector[i].b.z * sMultz;
			
			v3.x = selector[i].c.x * sMultx;
			v3.y = selector[i].c.y * sMulty;
			v3.z = selector[i].c.z * sMultz;
			

					if (Coldet.testTriangle(colData, v1,v2,v3, l)) 
					{
						//l.drawFullTriangle(Vector3.ScaleBy(v3, colData.eRadius), Vector3.ScaleBy(v2, colData.eRadius), Vector3.ScaleBy(v1, colData.eRadius), 1, 0, 0, 1);
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
	
	
	
	


	public static function GetPositionOnTriangles(selector:Array<Triangle>,position:Vector3, radius:Vector3, velocity:Vector3,slidingSpeed:Float,l:Imidiatemode):CollisionData
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
		
	 colData.finalPosition = Coldet.collideWithTriangles(0, colData, selector, eSpacePosition, eSpaceVelocity, l);

	 
	
	colData.finalPosition.x *= colData.eRadius.x;
	colData.finalPosition.y *= colData.eRadius.y;
	colData.finalPosition.z *= colData.eRadius.z;
	colData.hitPosition.set(colData.intersectionPoint.x * colData.eRadius.x, colData.intersectionPoint.y * colData.eRadius.y, colData.intersectionPoint.z * colData.eRadius.z);
	colData.Falling = (colData.triangleHits == 0);
           
		return colData;
	}	
	public static function GetPositionOnVertices(selector:Array<Vector3>,position:Vector3, radius:Vector3, velocity:Vector3,slidingSpeed:Float,l:Imidiatemode):CollisionData
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
		
	 colData.finalPosition = Coldet.collideWithVertices(0, colData, selector, eSpacePosition, eSpaceVelocity, l);

	 
	
	colData.finalPosition.x *= colData.eRadius.x;
	colData.finalPosition.y *= colData.eRadius.y;
	colData.finalPosition.z *= colData.eRadius.z;
	colData.hitPosition.set(colData.intersectionPoint.x * colData.eRadius.x, colData.intersectionPoint.y * colData.eRadius.y, colData.intersectionPoint.z * colData.eRadius.z);
	colData.Falling = (colData.triangleHits == 0);
           
		return colData;
	}	
		public static function CollideVerticesAndSlide(selector:Array<Vector3>,position:Vector3, radius:Vector3, velocity:Vector3,gravity:Vector3,slidingSpeed:Float,l:Imidiatemode):CollisionData
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
		
	 var finalPosition:Vector3 = Coldet.collideWithVertices(0, colData, selector, eSpacePosition, eSpaceVelocity, l);


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
	   
		finalPosition = Coldet.collideWithVertices(0, colData, selector, finalPosition, eSpaceVelocity, l);
	 }
	
	finalPosition.x *= colData.eRadius.x;
	finalPosition.y *= colData.eRadius.y;
	finalPosition.z *= colData.eRadius.z;
	
	colData.finalPosition = finalPosition;
	colData.hitPosition.set(colData.intersectionPoint.x * colData.eRadius.x, colData.intersectionPoint.y * colData.eRadius.y, colData.intersectionPoint.z * colData.eRadius.z);
    colData.Falling = (colData.triangleHits == 0);
               
		return colData;
	}	
	public static function CollideTrianglesAndSlide(selector:Array<Triangle>,position:Vector3, radius:Vector3, velocity:Vector3,gravity:Vector3,slidingSpeed:Float,l:Imidiatemode):CollisionData
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
		
	 var finalPosition:Vector3 = Coldet.collideWithTriangles(0, colData, selector, eSpacePosition, eSpaceVelocity, l);


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
	   
		finalPosition = Coldet.collideWithTriangles(0, colData, selector, finalPosition, eSpaceVelocity, l);
	 }
	
	finalPosition.x *= colData.eRadius.x;
	finalPosition.y *= colData.eRadius.y;
	finalPosition.z *= colData.eRadius.z;
	
	colData.finalPosition = finalPosition;
	colData.hitPosition.set(colData.intersectionPoint.x * colData.eRadius.x, colData.intersectionPoint.y * colData.eRadius.y, colData.intersectionPoint.z * colData.eRadius.z);
    colData.Falling = (colData.triangleHits == 0);
               
		return colData;
	}	
	

	public static function collideEllipsoidWithTrianglesSimple(selector:Array<Triangle>,position:Vector3, radius:Vector3, velocity:Vector3,slidingSpeed:Float,l:Imidiatemode):CollisionData
	{
		var  colData:CollisionData = new CollisionData();
        colData.eRadius = radius;
	    colData.R3Velocity.copyFrom(velocity);
	    colData.R3Position.copyFrom(position);
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
		
	colData.finalPosition.copyFrom(Coldet.collideWithTriangles(0, colData, selector, eSpacePosition, eSpaceVelocity, l));
	
	colData.finalPosition.x *= colData.eRadius.x;
	colData.finalPosition.y *= colData.eRadius.y;
	colData.finalPosition.z *= colData.eRadius.z;
	
	
               
		return colData;
	}

	public static function collideEllipsoidWithTriangles(selector:Array<Triangle>,position:Vector3, radius:Vector3, velocity:Vector3,gravity:Vector3,slidingSpeed:Float,l:Imidiatemode):CollisionData
	{
		
		var  colData:CollisionData = new CollisionData();
        colData.eRadius.copyFrom(radius);
	    colData.R3Velocity.copyFrom(velocity);
	    colData.R3Position.copyFrom(position);
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
		
	 var finalPosition:Vector3 = Coldet.collideWithTriangles(0, colData, selector, eSpacePosition, eSpaceVelocity, l);

      colData.Falling = false;
	 // add gravity
 
	 if (gravity.y!=0.0)
	 {
	  
	   colData.R3Position.x =   finalPosition.x * colData.eRadius.x;
	   colData.R3Position.y =   finalPosition.y * colData.eRadius.y;
	   colData.R3Position.z =   finalPosition.z * colData.eRadius.z;
	   colData.R3Velocity.copyFrom(gravity);
	   colData.triangleHits = 0;
	   
	   	eSpaceVelocity.x = gravity.x / colData.eRadius.x;
		eSpaceVelocity.y = gravity.y / colData.eRadius.y;
		eSpaceVelocity.z = gravity.z / colData.eRadius.z;
	   
		finalPosition.copyFrom(Coldet.collideWithTriangles(0, colData, selector, finalPosition, eSpaceVelocity, l));
		
		
		colData.Falling = (colData.triangleHits == 0);
	 }
	
	finalPosition.x *= colData.eRadius.x;
	finalPosition.y *= colData.eRadius.y;
	finalPosition.z *= colData.eRadius.z;
	
	colData.finalPosition.copyFrom(finalPosition);
	
	colData.hitPosition.set(colData.intersectionPoint.x * colData.eRadius.x, colData.intersectionPoint.y * colData.eRadius.y, colData.intersectionPoint.z * colData.eRadius.z);
          
		return colData;
	}	

	public static function collideEllipsoidWithVertices(selector:Array<Vector3>,position:Vector3, radius:Vector3, velocity:Vector3,gravity:Vector3,slidingSpeed:Float,l:Imidiatemode):CollisionData
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
		
	 var finalPosition:Vector3 = Coldet.collideWithVertices(0, colData, selector, eSpacePosition, eSpaceVelocity, l);

      colData.Falling = false;
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
	   
		finalPosition = Coldet.collideWithVertices(0, colData, selector, finalPosition, eSpaceVelocity, l);
		
		
		colData.Falling = (colData.triangleHits == 0);
	 }
	
	finalPosition.x *= colData.eRadius.x;
	finalPosition.y *= colData.eRadius.y;
	finalPosition.z *= colData.eRadius.z;
	
	colData.finalPosition = finalPosition;
	
	colData.hitPosition.set(colData.intersectionPoint.x * colData.eRadius.x, colData.intersectionPoint.y * colData.eRadius.y, colData.intersectionPoint.z * colData.eRadius.z);
          
		return colData;
	}	

	public static function getCollisionResultPosition(selector:Array<Triangle>,position:Vector3, radius:Vector3, velocity:Vector3,slidingSpeed:Float,l:Imidiatemode):Vector3
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
		
	colData.finalPosition = Coldet.collideWithTriangles(0,colData, selector, eSpacePosition, eSpaceVelocity, l);
	
	colData.finalPosition.x *= colData.eRadius.x;
	colData.finalPosition.y *= colData.eRadius.y;
	colData.finalPosition.z *= colData.eRadius.z;
	
	
               
		return colData.finalPosition;
	}
	
	
	public static function  testTriangle(colData:CollisionData, p1:Vector3, p2:Vector3, p3:Vector3, lines:Imidiatemode):Bool 
	{
		
		var a:Float = 0;
		var b:Float = 0;
		var c:Float = 0;
		
        var t0:Float = 0;
        var embeddedInPlane:Bool = false;
		
		var _tempVector:Vector3 = Vector3.zero;

		colData.trianglePlane.copyFromPoints(p1, p2, p3);// = Plane.FromPoints(p1, p2, p3);
		var trianglePlane:Plane = colData.trianglePlane;
      
       if ( !trianglePlane.isFrontFacingTo(colData.normalizedVelocity, 0))
		{
				
		 // lines.drawTriangle(Vector3.ScaleBy(p3, colData.eRadius), Vector3.ScaleBy(p2, colData.eRadius), Vector3.ScaleBy(p1, colData.eRadius), 0, 1, 1, 1);
			
	     return false;
		}

        var signedDistToTrianglePlane = trianglePlane.signedDistanceTo(colData.basePoint);
        var normalDotVelocity = Vector3.Dot(trianglePlane.normal, colData.velocity);

        if (normalDotVelocity == 0)
		{
            if (Math.abs(signedDistToTrianglePlane) >= 1.0)
			{
		          return false;
			}
            embeddedInPlane = true;
            t0 = 0;
        }
        else {
            t0 = (-1.0 - signedDistToTrianglePlane) / normalDotVelocity;
            var t1 = (1.0 - signedDistToTrianglePlane) / normalDotVelocity;

            if (t0 > t1) {
                var temp = t1;
                t1 = t0;
                t0 = temp;
            }
 // Check that at least one result is within range:
            if (t0 > 1.0 || t1 < 0.0)
			{
		           return false;// both t values are outside 1 and 0, no collision possible
			}
            if (t0 < 0.0)
                t0 = 0.0;
            if (t0 > 1.0)
                t0 = 1.0;
			if (t1 < 0.0)
                t1 = 0.0;
            if (t1 > 1.0)
                t1 = 1.0;
        }

        var collisionPoint:Vector3 = Vector3.zero;

        var found = false;
        var t = 1.0;

        if (!embeddedInPlane) 
		{
			//var planeIntersectionPoint:Vector3 = Vector3.Mult( Vector3.Sub(colData.basePoint, trianglePlane.normal), t0);
			
			var planeIntersectionPoint:Vector3 = Vector3.zero;// Vector3.Mult( Vector3.Sub(colData.basePoint, trianglePlane.normal), t0);
			
		planeIntersectionPoint.x = (colData.basePoint.x - trianglePlane.normal.x) +  (colData.velocity.x * t0);
		planeIntersectionPoint.y = (colData.basePoint.y - trianglePlane.normal.y) +  (colData.velocity.y * t0);
		planeIntersectionPoint.z = (colData.basePoint.z - trianglePlane.normal.z) +  (colData.velocity.z * t0);
		
		
			
			
			
			
			 //if (Coldet.PointInTriangle(planeIntersectionPoint,p1,p2,p3,trianglePlane.normal))
			 if (Coldet.CheckPointInTriangle(planeIntersectionPoint,p1,p2,p3))
 			{
                found = true;
                t = t0;
	            collisionPoint.copyFrom(planeIntersectionPoint);
           }
        }

        if (!found) 
		{
			var velocity:Vector3 = colData.velocity;
			var base:Vector3 = colData.basePoint;
            var velocitySquaredLength = velocity.lengthSquared();
             a = velocitySquaredLength;
			
			//p1
             b = 2.0 * (Vector3.Dot(velocity,Vector3.Sub(base, p1)));
             c = Vector3.Sub(p1,base).lengthSquared() - 1.0;

            var lowestRoot:LowestResult = Coldet.getLowestRoot(a, b, c, t);
            if (lowestRoot.found) {
                t = lowestRoot.root;
                found = true;
                collisionPoint.copyFrom(p1);
            }

			
			//p2
             b = 2.0 * (Vector3.Dot(velocity,Vector3.Sub(base, p2)));
             c = Vector3.Sub(p2,base).lengthSquared() - 1.0;
            lowestRoot = Coldet.getLowestRoot(a, b, c, t);
            if (lowestRoot.found) {
                t = lowestRoot.root;
                found = true;
                collisionPoint.copyFrom(p2);
            }
			//p3

             b = 2.0 * (Vector3.Dot(velocity,Vector3.Sub(base, p3)));
             c = Vector3.Sub(p3,base).lengthSquared() - 1.0;

            lowestRoot = Coldet.getLowestRoot(a, b, c, t);
            if (lowestRoot.found) {
                t = lowestRoot.root;
                found = true;
                collisionPoint.copyFrom(p3);
            }

			
			// check against edges
			
			//p1 - p2
			var edge:Vector3 = Vector3.Sub(p2, p1);
			var baseToVertex:Vector3 = Vector3.Sub(p1, base);
		
			var edgeSquaredLength = edge.lengthSquared();
            var edgeDotVelocity = Vector3.Dot(edge, velocity);
            var edgeDotBaseToVertex = Vector3.Dot(edge, baseToVertex);

            a = edgeSquaredLength * (-velocitySquaredLength) + edgeDotVelocity * edgeDotVelocity;
            b = edgeSquaredLength * (2.0 * Vector3.Dot(colData.velocity, baseToVertex)) - 2.0 * edgeDotVelocity * edgeDotBaseToVertex;
            c = edgeSquaredLength * (1.0 - baseToVertex.lengthSquared()) + edgeDotBaseToVertex * edgeDotBaseToVertex;

            lowestRoot = Coldet.getLowestRoot(a, b, c, t);
            if (lowestRoot.found) 
			{
                var f = (edgeDotVelocity * lowestRoot.root - edgeDotBaseToVertex) / edgeSquaredLength;

                if (f >= 0.0 && f <= 1.0)
				{
                    found = true;
					t = lowestRoot.root;
                	collisionPoint.x = p1.x + (edge.x * f);
					collisionPoint.y = p1.y + (edge.y * f);
					collisionPoint.z = p1.z + (edge.z * f);

                }
            }

			//p2 - p3
           	 edge = Vector3.Sub(p3, p2);
			 baseToVertex = Vector3.Sub(p2, base);
			
            edgeSquaredLength = edge.lengthSquared();
            edgeDotVelocity = Vector3.Dot(edge, velocity);
            edgeDotBaseToVertex = Vector3.Dot(edge, baseToVertex);

            a = edgeSquaredLength * (-velocitySquaredLength) + edgeDotVelocity * edgeDotVelocity;
            b = edgeSquaredLength * (2.0 * Vector3.Dot(colData.velocity, baseToVertex)) - 2.0 * edgeDotVelocity * edgeDotBaseToVertex;
            c = edgeSquaredLength * (1.0 - baseToVertex.lengthSquared()) + edgeDotBaseToVertex * edgeDotBaseToVertex;
            lowestRoot = Coldet.getLowestRoot(a, b, c, t);
            if (lowestRoot.found) 
			{
                var f = (edgeDotVelocity * lowestRoot.root - edgeDotBaseToVertex) / edgeSquaredLength;

                if (f >= 0.0 && f <= 1.0) 
				{
                     found = true;
					t = lowestRoot.root;
                	collisionPoint.x = p2.x + (edge.x * f);
					collisionPoint.y = p2.y + (edge.y * f);
					collisionPoint.z = p2.z + (edge.z * f);
                }
            }

			//p3 -p1
           	 edge = Vector3.Sub(p1, p3);
			 baseToVertex = Vector3.Sub(p3, base);
		
            edgeSquaredLength = edge.lengthSquared();
            edgeDotVelocity = Vector3.Dot(edge, velocity);
            edgeDotBaseToVertex = Vector3.Dot(edge, baseToVertex);

            a = edgeSquaredLength * (-velocitySquaredLength) + edgeDotVelocity * edgeDotVelocity;
            b = edgeSquaredLength * (2.0 * Vector3.Dot(colData.velocity, baseToVertex)) - 2.0 * edgeDotVelocity * edgeDotBaseToVertex;
            c = edgeSquaredLength * (1.0 - baseToVertex.lengthSquared()) + edgeDotBaseToVertex * edgeDotBaseToVertex;

            lowestRoot = Coldet.getLowestRoot(a, b, c, t);
            if (lowestRoot.found) 
			{
                var f = (edgeDotVelocity * lowestRoot.root - edgeDotBaseToVertex) / edgeSquaredLength;

                if (f >= 0.0 && f <= 1.0) {
                    t = lowestRoot.root;
                    found = true;
                    collisionPoint.x = p3.x + (edge.x * f);
					collisionPoint.y = p3.y + (edge.y * f);
					collisionPoint.z = p3.z + (edge.z * f);
                }
            }
        }

        if (found)
		{
			// distance to collision is t
            var distToCollision:Float = t * colData.velocity.length();

            if (!colData.foundCollision || distToCollision < colData.nearestDistance) 
			{
           
				// does this triangle qualify for closest hit?
                colData.intersectionPoint.copyFrom(collisionPoint);
                colData.nearestDistance = distToCollision;                
                colData.foundCollision = true;
				++colData.triangleHits;
		        return  true;
             
            }
        }
		
		return false;
    }
	
//game institute

public static function CheckPointInTriangle(point:Vector3, a:Vector3, b:Vector3, c:Vector3):Bool
{
	// using barycentric method - this is supposedly the fastest method there is for this.
	// from http://www.blackpawn.com/texts/pointinpoly/default.html
	// Compute vectors
	
	var v0:Vector3 = Vector3.Sub(c, a);
	var v1:Vector3 = Vector3.Sub(b, a);
	var v2:Vector3 = Vector3.Sub(point, a);
	
	var  dot00:Float = Vector3.Dot(v0, v0);
	var  dot01:Float = Vector3.Dot(v0, v1);
	var  dot02:Float = Vector3.Dot(v0, v2);
	var  dot11:Float = Vector3.Dot(v1, v1);
	var  dot12:Float = Vector3.Dot(v1, v2);
	
   // Compute barycentric coordinates
	var invDenom:Float = 1 / (dot00 * dot11 - dot01 * dot01);
	var u:Float = (dot11 * dot02 - dot01 * dot12) * invDenom;
	var v:Float = (dot00 * dot12 - dot01 * dot02) * invDenom;

	// Check if point is in triangle
	return (u > 0) && (v > 0) && (u + v < 1);
	
	
}

public static function PointInTriangle(Point:Vector3, v1:Vector3, v2:Vector3, v3:Vector3, TriNormal:Vector3):Bool
{
	 var Edge:Vector3      = Vector3.zero;
	var Direction:Vector3  = Vector3.zero;
	var EdgeNormal:Vector3 = Vector3.zero;


	 Edge      = Vector3.Sub(v2 , v1);
	 Direction  = Vector3.Sub(v1 , Point);
	 EdgeNormal = Vector3.Cross(Edge, TriNormal);
	 if ( Vector3.Dot(Direction, EdgeNormal) < 0.0) return false;
	
	
	  
	
	 // Second edge
	 
     Edge      = Vector3.Sub(v3 , v2);
	 Direction = Vector3.Sub(v2 , Point);
	 EdgeNormal = Vector3.Cross(Edge, TriNormal);
	if ( Vector3.Dot(Direction, EdgeNormal) < 0.0) return false;

	
    
   // Third edge
     Edge      = Vector3.Sub(v1 , v3);
	 Direction = Vector3.Sub(v3 , Point);
	 EdgeNormal = Vector3.Cross(Edge, TriNormal);
     if ( Vector3.Dot(Direction, EdgeNormal) < 0.0) return false;

return true;

}

public static function SolveCollision(a:Float,b:Float,c:Float,t:Float ):LowestRoot
{
    var d, one_over_two_a, t0, t1, temp:Float = 0;
	  var result:LowestRoot = { root: 0, found: false };
		

    // Basic equation solving
    d = b*b - 4*a*c;

    // No root if d < 0
    if (d < 0.0) return result;

    // Setup for calculation
    d = Math.sqrt( d );
    one_over_two_a = 1.0 / (2.0 * a);

    // Calculate the two possible roots
    t0 = (-b - d) * one_over_two_a;
    t1 = (-b + d) * one_over_two_a;

    // Order the results
    if (t1 < t0) 
	{ 
		temp = t0; 
		t0 = t1; 
		t1 = temp; 
	}

    // Fail if both results are negative
    if (t1 < 0.0) return result;

    // Return the first positive root
    if (t0 < 0.0) 
	{
	t = t1; 
	}
	else 
	{
	t = t0;
	}
	
	result.root = t;
	result.found = true;

    // Solution found
    return result;

}

public static function SphereIntersectPoint( Center:Vector3, Radius:Float, Velocity:Vector3,  Point:Vector3):TimeBoolNormal
{
var result:TimeBoolNormal =
	{
	   tMax: 0,
	   found: false,
	   normal:Vector3.zero }
   
    var       a:Float = 0;
	var       b:Float = 0;
	var       c:Float = 0;
	var       l2:Float = 0;
	var       t:Float = 0;
	var l : Float = 0;
	
	

    // Setup the equation values
    var L:Vector3  = Vector3.Sub(Center , Point);
	l2 = L.lengthSquared();
   
    // Setup the input values for the quadratic equation
    a = Velocity.lengthSquared();
    b = 2.0 * Vector3.Dot( Velocity, L );
    c = l2 - (Radius * Radius);

    // If c < 0 then we are overlapping, return the overlap
    if ( c < 0.0 )
    {
        // Remember, when we're overlapping we have no choice 
        // but to return a physical distance (the penetration depth)
        l = Math.sqrt( l2 );
        t = l - Radius;
        
        // Outside our range?
        if (result.tMax < t)
		{
		  return result;
		}

        // Generate the collision normal
        result.normal = Vector3.divEquals( L, l);
		result.found = true;
        // Store t and return
        result.tMax = t;

        // Vertex Overlap
        return result;
    
    } // End if overlapping 

    // If we are already checking for overlaps, return
    if ( result.tMax < 0.0 ) return result;

    // Solve the quadratic for t
    //if (!SolveCollision(a, b, c, t)) return false;
	var lowestRoot:LowestRoot = Coldet.SolveCollision(a, b, c, t);
	if (!lowestRoot.found) return result;
	t = lowestRoot.root;
	 

    // Is the vertex too far away?
    if ( t > result.tMax ) return result;

    // Calculate the new sphere position at the time of contact
   var CollisionCenter:Vector3 =Vector3.Mult(Vector3.Add( Center , Velocity),  t);
       // We can now generate our normal, store the interval and return
    
	result.normal = Vector3.Normalize(Vector3.Sub(CollisionCenter , Point));
    result.tMax = t;
	result.found = true;

    // Intersecting!
    return result;
}


public static function SphereIntersectLineSegment( Center:Vector3,  Radius:Float,  Velocity:Vector3, v1:Vector3, v2:Vector3) :TimeBoolNormal
{
 //   D3DXVECTOR3 E, L, X, Y, PointOnEdge, CollisionCenter;
 
 
	var result:TimeBoolNormal =
	{
	   tMax: 0,
	   found: false,
	   normal:Vector3.zero }
	   
 
   var   a:Float = 0;
   var b:Float = 0;
   var c:Float = 0;
   var d:Float = 0;
   var e:Float = 0;
   var t:Float = 0;
   var n:Float = 0;
   var E:Vector3 = Vector3.zero;
   var L:Vector3 = Vector3.zero;
   var X:Vector3 = Vector3.zero;
   var Y:Vector3 = Vector3.zero;
   var PointOnEdge:Vector3 = Vector3.zero;
   var CollisionCenter:Vector3 = Vector3.zero;
	

    // Setup the equation values
	E.x = v2.x - v1.x;
	E.y = v2.y - v1.y;
	E.z = v2.z - v1.z;
	
  //  var E:Vector3 = Vector3.Sub(v2 , v1);
  //  var L:Vector3 = Vector3.Sub(Center, v1);
  L.x = Center.x - v1.x;
  L.y = Center.y - v1.y;
  L.z = Center.z - v1.z;

    // Re-normalise the cylinder radius with segment length (((P - C) x E)² = r²)
    e = E.length();

    // If e == 0 we can't possibly succeed, the edge is degenerate and we'll
    // get a divide by 0 error in the normalization and 2nd order solving.
    if ( e < 1e-5 ) 
	{

	return result;
	}

    // Normalize the line vector
	//var E:Vector3 = Vector3.divEquals(E, e);
	E.x /= e;
	E.y /= e;
	E.z /= e;

	
    //E /= e;

    // Generate cross values
     X = Vector3.Cross(L, E );
	 Y = Vector3.Cross(Velocity, E );
	
  
  
    // Setup the input values for the quadratic equation
    a = Y.lengthSquared();
    b = 2.0 * Vector3.Dot(X, Y );
    c = X.lengthSquared() - (Radius*Radius);

    // If the sphere centre is already inside the cylinder, we need an overlap test
    if ( c < 0.0 )
    {
        // Find the distance along the line where our sphere center is positioned.
        // (i.e. sphere center projected down onto line)
        d = Vector3.Dot( L, E );

        // Is this before or after line start?
        if (d < 0.0)
        {
            // The point is before the beginning of the line, test against the first vertex
            return SphereIntersectPoint( Center, Radius, Velocity, v1 );
        
        } // End if before line start
        else if ( d > e )
        {
            // The point is after the end of the line, test against the second vertex
            return SphereIntersectPoint( Center, Radius, Velocity, v2 );
        
        } // End if after line end
        else
        {
            // Point within the line segment
			  PointOnEdge.x = v1.x + E.x * d;
			  PointOnEdge.y = v1.y + E.y * d;
			  PointOnEdge.z = v1.z + E.z * d;

		   

            // Generate collision normal
            result.normal.x = Center.x - PointOnEdge.x;
			result.normal.y = Center.y - PointOnEdge.y;
			result.normal.z = Center.z - PointOnEdge.z;
			
            n = result.normal.length();
			
            result.normal.x /= n;
			result.normal.y /= n;
			result.normal.z /= n;
			
            // Calculate t value (remember we only enter here if we're already overlapping)
            // Remember, when we're overlapping we have no choice but to return a physical distance (the penetration depth)
            t = n - Radius;
            if (result.tMax < t)
			{

			return result;
			}
            
            // Store t and return
            result.tMax = t;
			result.found = true;

            // Edge Overlap
            return result;
        
        } // End if inside line segment
    
    } // End if sphere inside cylinder

    // If we are already checking for overlaps, return
    if ( result.tMax < 0.0 ) return result;
    
    // Solve the quadratic for t
    //if ( !SolveCollision(a, b, c, t) ) return false;
    var lowestRoot:LowestRoot = Coldet.SolveCollision(a, b, c, t);
	if (!lowestRoot.found) return result;
	t = lowestRoot.root;

    // Is the segment too far away?
    if ( t > result.tMax ) return result;

    // Calculate the new sphere center at the time of collision
	CollisionCenter.x = Center.x + Velocity.x * t;
	CollisionCenter.y = Center.y + Velocity.y * t;
	CollisionCenter.z = Center.z + Velocity.z * t;
	
    
    // Project this down onto the edge
    d = Vector3.Dot( Vector3.Sub(CollisionCenter , v1), E );

    // Simply check whether we need to test the end points as before
    if ( d < 0.0 )
        return SphereIntersectPoint( Center, Radius, Velocity, v1  );
    else if ( d > e )
        return SphereIntersectPoint( Center, Radius, Velocity, v2)  ;
    
    // Caclulate the Point of contact on the line segment
     PointOnEdge.x = v1.x + E.x * d;
	 PointOnEdge.y = v1.y + E.y * d;
	 PointOnEdge.z = v1.z + E.z * d;
	 
	 
	

    // We can now generate our normal, store the interval and return
    result.normal=Vector3.Normalize(Vector3.Sub(CollisionCenter , PointOnEdge) );
    result.tMax = t;
	result.found = true;

    // Intersecting!
    return result;

}

public static function SphereIntersectPlane( Center:Vector3,  Radius:Float,  Velocity:Vector3, PlaneNormal:Vector3, PlanePoint:Vector3):TimeBool
{
    var numer:Float = 0;
	var denom:Float = 0;
	var t:Float=0;
    
    var result:TimeBool = { tMax: 0, found: false };
	
	
    // Setup equation
    numer = Vector3.Dot(Vector3.Sub(Center , PlanePoint), PlaneNormal ) - Radius;
    denom = Vector3.Dot(Velocity, PlaneNormal );

    // Are we already overlapping?
    if ( numer < 0.0 || denom > -0.0000001 )
    {
        // The sphere is moving away from the plane
	
        if ( denom > - 1e-5 ) return result;
	 // trace(1e-5 );

	
        // Sphere is too far away from the plane
        if ( numer < -Radius ) return result;

        // Calculate the penetration depth
        result.tMax = numer;
		result.found = true;
		

        // Intersecting!
        return result;
    
    } // End if overlapping

    // We are not overlapping, perform ray-plane intersection
    t = -(numer / denom);


    // Ensure we are within range
    if ( t < 0.0 || t > result.tMax ) 
	{
		
	return result;
	}

    // Store interval
    result.tMax = t;
	result.found = true;

    // Intersecting!
    return result;
}
public static function SphereIntersectTriangle( Center:Vector3,  Radius:Float,  Velocity:Vector3, v1:Vector3, v2:Vector3,v3:Vector3,TriNormal:Vector3 ):TimeBoolNormal
{

	
	
	var result:TimeBoolNormal =
	{
		tMax: 0,
	   found: false,
	   normal:Vector3.zero}
  
      var CollisionCenter:Vector3 = Vector3.zero;
	  var       t:Float = 0;

    // Find the time of collision with the triangle's plane.
	
	var spPlane:TimeBool = SphereIntersectPlane( Center, Radius, Velocity, TriNormal, v1 );
	if (!spPlane.found)
	{
		return result;
	}

    t = spPlane.tMax;
    
    // Calculate the sphere's center at the point of collision with the plane
    if ( t < 0 )
	{
        CollisionCenter.x = Center.x + (TriNormal.x * -t);
		CollisionCenter.y = Center.y + (TriNormal.y * -t);
		CollisionCenter.z = Center.z + (TriNormal.z * -t);
	}
    else
	{
        CollisionCenter.x = Center.x + (TriNormal.x * t);
		CollisionCenter.y = Center.y + (TriNormal.y * t);
		CollisionCenter.z = Center.z + (TriNormal.z * t);

  	}

    // If this point is within the bounds of the triangle, we have found the collision
    if ( PointInTriangle( CollisionCenter, v1, v2, v3, TriNormal ) )
    {
        // Collision normal is just the triangle normal
        result.normal = TriNormal;
		result.found = true;
		
        result.tMax          = t;


        // Intersecting!
        return result;

    } // End if point within triangle interior

//return result;

var ege1:TimeBoolNormal = SphereIntersectLineSegment( Center, Radius, Velocity, v1, v2);
var ege2:TimeBoolNormal = SphereIntersectLineSegment( Center, Radius, Velocity, v2, v3);
var ege3:TimeBoolNormal = SphereIntersectLineSegment( Center, Radius, Velocity, v3, v1);

if(ege1.found)
{
	return ege1;
}
if(ege2.found)
{
	return ege2;
}
if(ege2.found)
{
	return ege2;
}

   return result;
}
public static function EllipsoidIntersectScene( Center:Vector3,  Radius:Vector3,  Velocity:Vector3, v1:Vector3, v2:Vector3, v3:Vector3, TriNormal:Vector3):TimeBoolNormal
{
	var InvRadius:Vector3 = new Vector3(1.0 / Radius.x, 1.0 / Radius.y, 1.0 / Radius.z);
	
	var eCenter:Vector3 = Vector3.ScaleBy(Center, InvRadius);
	var eVelocity:Vector3 = Vector3.ScaleBy(Velocity, InvRadius);
	return EllipsoidIntersectBuffers(eCenter, Radius, InvRadius, Velocity, v1, v2, v3, TriNormal);

}
public static function EllipsoidIntersectBuffers( eCenter:Vector3,  Radius:Vector3,invRadius:Vector3,  eVelocity:Vector3, v1:Vector3, v2:Vector3, v3:Vector3, TriNormal:Vector3 ):TimeBoolNormal
{

var p1:Vector3 = Vector3.ScaleBy(v1, invRadius);
var p2:Vector3 = Vector3.ScaleBy(v2, invRadius);
var p3:Vector3 = Vector3.ScaleBy(v3, invRadius);
var n:Vector3 = Vector3.ScaleBy(TriNormal, invRadius);
n.normalize();
		
	  	var result:TimeBoolNormal = Coldet.SphereIntersectTriangle( eCenter, 1.0, eVelocity, p1, p2, p3, n);
	
		if (result.found)
		{
    
            // Calculate our new sphere center at the point of intersection
            if ( result.tMax > 0 )
			{
               // eNewCenter = eCenter + (eVelocity * eInterval);
			}
            else
			{
               // eNewCenter = eCenter - (eIntersectNormal * eInterval);
			}
          
        }
		return result;
}

public static function IntersectedPlane(vPoly:Triangle, vLine0:Vector3, vLine1:Vector3, vNormal:Vector3, originDistance:Float):Bool
	
{
	var distance1:Float = 0; 
	var distance2:Float=0;						// The distances from the 2 points of the line from the plane
			
	

	// Let's find the distance our plane is from the origin.  We can find this value
	// from the normal to the plane (polygon) and any point that lies on that plane (Any vertex)
	originDistance = Vector3.PlaneDistance(vPoly.normal, vPoly.a);

	// Get the distance from point1 from the plane using: Ax + By + Cz + D = (The distance from the plane)

	distance1 = ((vPoly.normal.x * vLine0.x)  +					// Ax +
		         (vPoly.normal.y * vLine0.y)  +					// Bx +
				 (vPoly.normal.z * vLine0.z)) + originDistance;	// Cz + D
	
	// Get the distance from point2 from the plane using Ax + By + Cz + D = (The distance from the plane)
	
	distance2 = ((vPoly.normal.x * vLine1.x)  +					// Ax +
		         (vPoly.normal.y * vLine1.y)  +					// Bx +
				 (vPoly.normal.z * vLine1.z)) + originDistance;	// Cz + D

	// Now that we have 2 distances from the plane, if we times them together we either
	// get a positive or negative number.  If it's a negative number, that means we collided!
	// This is because the 2 points must be on either side of the plane (IE. -1 * 1 = -1).

	if(distance1 * distance2 >= 0)			// Check to see if both point's distances are both negative or both positive
	   return false;						// Return false if each point has the same sign.  -1 and 1 would mean each point is on either side of the plane.  -1 -2 or 3 4 wouldn't...
					
	return true;							// The line intersected the plane, Return TRUE
}
public static function getIntersectionLine(v:Vector3, v0:Vector3, v1:Vector3):Vector3
	{
		var d0:Float=v.x * v0.x + v.y * v0.y + v.z * v0.z ;
		var d1:Float=v.x * v1.x + v.y * v1.y + v.z * v1.z ;
		var m:Float=d1 /(d1 - d0);
		return new Vector3(
			v1.x +(v0.x - v1.x)* m,
			v1.y +(v0.y - v1.y)* m,
			v1.z +(v0.z - v1.z)* m);
	}
public static function ClosestPointOnLine(vA:Vector3, vB:Vector3,vPoint:Vector3):Vector3 
		{
			var vVector1:Vector3 =  Vector3.Sub(vPoint, vA);
			var vVector2:Vector3 = Vector3.Normalize(Vector3.Sub(vB, vA));
		
			var d:Float = Vector3.Distance(vA, vB);
			var t:Float=Vector3.Dot(vVector2, vVector1);
        	if (t <= 0)  return vA;
            if (t >= d) 		return vB;
            var  vVector3:Vector3 = Vector3.Mult(vVector2 , t);
            return Vector3.Add(vA, vVector3);
		}
public static function IntersectionPoint(vNormal:Vector3, vLine0:Vector3, vLine1:Vector3, distance:Float):Vector3
{
	var Numerator:Float = 0.0;
	var Denominator:Float = 0.0;
	var dist:Float = 0.0;

	// 1)  First we need to get the vector of our line, Then normalize it so it's a length of 1
	var vLineDir:Vector3 =Vector3.Sub( vLine1 , vLine0);		// Get the Vector of the line
	vLineDir = Vector3.Normalize(vLineDir);				// Normalize the lines vector


	// 2) Use the plane equation (distance = Ax + By + Cz + D) to find the 
	// distance from one of our points to the plane.
	Numerator = - (vNormal.x * vLine0.x +		// Use the plane equation with the normal and the line
				   vNormal.y * vLine0.y +
				   vNormal.z * vLine0.z + distance);

	// 3) If we take the dot product between our line vector and the normal of the polygon,
	Denominator = Vector3.Dot(vNormal, vLineDir);		// Get the dot product of the line's vector and the normal of the plane
				  
	// Since we are using division, we need to make sure we don't get a divide by zero error
	// If we do get a 0, that means that there are INFINATE points because the the line is
	// on the plane (the normal is perpendicular to the line - (Normal.Vector = 0)).  
	// In this case, we should just return any point on the line.

	if( Denominator == 0.0)						// Check so we don't divide by zero
		return vLine0;						// Return an arbitrary point on the line

	dist = Numerator / Denominator;				// Divide to get the multiplying (percentage) factor
	
	var vPoint:Vector3 = Vector3.Zero();
	// Now, like we said above, we times the dist by the vector, then add our arbitrary point.
	vPoint.x = (vLine0.x + (vLineDir.x * dist));
	vPoint.y = (vLine0.y + (vLineDir.y * dist));
	vPoint.z = (vLine0.z + (vLineDir.z * dist));

	return vPoint;								// Return the intersection point
}


public static function IntersectedTriangle(vPoly:Triangle, vLine0:Vector3, vLine1:Vector3):Bool
{
	var vNormal=Vector3.Zero();
	var originDistance:Float = 0;

	// First, make sure our line intersects the plane
									 // Reference   // Reference
	if(!IntersectedPlane(vPoly, vLine0,vLine1,   vNormal,   originDistance))
		return false;

	// Now that we have our normal and distance passed back from IntersectedPlane(), 
	// we can use it to calculate the intersection point.  
	var vIntersection:Vector3 = IntersectionPoint(vNormal, vLine0,vLine1, originDistance);

	// Now that we have the intersection point, we need to test if it's inside the polygon.
	if(PointInTriangle(vIntersection, vPoly.a,vPoly.b,vPoly.c,vPoly.normal))
		return true;							// We collided!	  Return success

	return false;								// There was no collision, so return false
}
public static function FaceSphereCollision(vCenter:Vector3,v0:Vector3,v1:Vector3,v2:Vector3,radius:Float):Bool
{
	var tri:Array<Vector3> = [];
	tri.push(v0);
	tri.push(v1);
	tri.push(v2);
	
	for (i in 0...3)
	{
		var vPoint:Vector3 = Vector3.ClosestPointOnLine(tri[i],tri[(i+1)%3], vCenter);
		var distance:Float=Vector3.Distance(vPoint, vCenter);
		if (distance < radius)
		{
			return true;
	   }
	}
	return false;
}
public static function EdgeSphereCollision(vCenter:Vector3,vPolygon:Triangle,radius:Float):Bool
{
	var tri:Array<Vector3> = [];
	tri.push(vPolygon.a);
	tri.push(vPolygon.b);
	tri.push(vPolygon.c);
	
	for (i in 0...3)
	{
		var vPoint:Vector3 = Vector3.ClosestPointOnLine(tri[i],tri[(i+1)%3], vCenter);
		var distance:Float=Vector3.Distance(vPoint, vCenter);
		if (distance < radius)
		{
			return true;
	   }
	}
	return false;
}
public static function  ClassifySphere(vCenter:Vector3,vNormal:Vector3, vPoint:Vector3,  radius:Float, distance:Float):Int
{
	
//#define BEHIND		0
//#define INTERSECTS	1
//#define FRONT		2

	// First we need to find the distance our polygon plane is from the origin.
	var d:Float = Vector3.PlaneDistance(vNormal, vPoint);

	// Here we use the famous distance formula to find the distance the center point
	// of the sphere is from the polygon's plane.  
	distance = (vNormal.x * vCenter.x + vNormal.y * vCenter.y + vNormal.z * vCenter.z + d);
	
	



	// If the absolute value of the distance we just found is less than the radius, 
	// the sphere intersected the plane.
	if (Math.abs(distance) < radius)
	{
		return 1;
	// Else, if the distance is greater than or equal to the radius, the sphere is
	// completely in FRONT of the plane.
	}
	else if (distance >= radius)
	{
			return 2;
	}
	
	// If the sphere isn't intersecting or in FRONT of the plane, it must be BEHIND
	return 0;
}
public static function SphereTriangleCollision(vCenter:Vector3,vPolygon:Triangle,radius:Float):Bool
{
	// 1) STEP ONE - Finding the sphere's classification
	
	// Let's use our Normal() function to return us the normal to this polygon
	var vNormal:Vector3 = vPolygon.normal;

	// This will store the distance our sphere is from the plane
	var distance:Float = 0.0;

	// This is where we determine if the sphere is in FRONT, BEHIND, or INTERSECTS the plane
	var classification:Int = ClassifySphere(vCenter, vNormal, vPolygon.a, radius, distance);

	// If the sphere intersects the polygon's plane, then we need to check further
	if(classification == 1) 
	{
		// 2) STEP TWO - Finding the psuedo intersection point on the plane

		// Now we want to project the sphere's center onto the polygon's plane
		var vOffset:Vector3 = Vector3.Mult( vNormal , distance);
		
		
		// Once we have the offset to the plane, we just subtract it from the center
		// of the sphere.  "vPosition" now a point that lies on the plane of the polygon.
		var vPosition:Vector3 = Vector3.Sub(vCenter , vOffset);

		// 3) STEP THREE - Check if the intersection point is inside the polygons perimeter

		// If the intersection point is inside the perimeter of the polygon, it returns true.
		// We pass in the intersection point, the list of vertices and vertex count of the poly.
		if(CheckPointInTriangle(vPosition, vPolygon.a,vPolygon.b,vPolygon.c))
			return true;	// We collided!
		else
		{
			// 4) STEP FOUR - Check the sphere intersects any of the polygon's edges

			// If we get here, we didn't find an intersection point in the perimeter.
			// We now need to check collision against the edges of the polygon.
			if(EdgeSphereCollision(vCenter, vPolygon,  radius))
			{
				return true;	// We collided!
			}
		}
	}

	// If we get here, there is obviously no collision
	return false;
}

public static function dDOTByColumn(v:Vector3, m:Matrix4, aColumn:Int):Float
{

return      v.x *m.getRowCol(0, aColumn)
              +v.y *m.getRowCol(1, aColumn)
              +v.z *m.getRowCol(2, aColumn);
}

public static function dDotByRow(v:Vector3, m:Matrix4, aRow:Int):Float
{

return         v.x *m.getRowCol(aRow, 0)
              +v.y *m.getRowCol(aRow, 1)
              +v.z *m.getRowCol(aRow, 2);
}
public static function dDotMatrByColumn(v:Vector3, m:Matrix4):Vector3
{
	
	var v:Vector3 = Vector3.zero;
   
	v.x = dDOTByColumn(v, m, 0);
    v.y = dDOTByColumn(v, m, 1);
    v.z = dDOTByColumn(v, m, 2);
	return v;
}
public static function dDotMatrByRow(v:Vector3, m:Matrix4):Vector3
{
		var v:Vector3 = Vector3.zero;
	v.x = dDotByRow(v, m, 0);
    v.y = dDotByRow(v, m, 1);
    v.z = dDotByRow(v, m, 2);
	return v;
}

public static function IntersectSphereBox(
     SpherePos     : Vector3,
     SphereRadius  : Float,
     BoxMatrix     : Matrix4,
     BoxScale      : Vector3,
     intersectPoint    : Vector3,
     normal            : Vector3,
     depth             : Float
  ) : Bool
  {
	
	  var tmp:Vector3 = Vector3.zero;
	  var l:Vector3 = Vector3.zero;
	  var t:Vector3 = Vector3.zero;
	  var p:Vector3 = Vector3.zero;
	  var q:Vector3 = Vector3.zero;
	  var r:Vector3 = Vector3.zero;
	  
	 
  var FaceDistance:Float = 0.0;
  var MinDistance:Float=0.0;
  var Depth1:Float = 0.0;
  var mini:Int = 0; 
  var isSphereCenterInsideBox : Bool ;
  
  var p:Vector3 = Vector3.zero;
  p.x = SpherePos.x -BoxMatrix.getRowCol(3, 0);
  p.y = SpherePos.y -BoxMatrix.getRowCol(3, 1);
  p.z = SpherePos.z -BoxMatrix.getRowCol(3, 2);
  
  isSphereCenterInsideBox = true;
  
  for (i in 0...3 )
  {
    l.setBy(i, 0.5 *BoxScale.get(i));
    t.setBy(i,dDotByRow(p, BoxMatrix, i));
     if (t.get(i) < -l.get(i))
	 {
      t.setBy(i, -l.get(i));
      isSphereCenterInsideBox = false;
	 } else 
	 if (t.get(i) >  l.get(i))
	 {
      t.setBy(i, l.get(i));
      isSphereCenterInsideBox = false;
	 }
  }
  
  if (isSphereCenterInsideBox)
  {

    MinDistance = l.x -Math.abs(t.x);
    mini = 0;
    for (i in 0...3)
	{
      FaceDistance = l.get(i) -Math.abs(t.get(i));
      if (FaceDistance < MinDistance)
	  {
        MinDistance = FaceDistance;
        mini        = i;
      }
    }
  
	intersectPoint.copyFrom(SpherePos);
	
	  if (t.get(mini) > 0)  
	  tmp.setBy(mini, 1);else
      tmp.setBy(mini, -1);
      normal.copyFrom(dDotMatrByRow(tmp, BoxMatrix));
    

  
      depth= MinDistance +SphereRadius;

   return true;
  } else
  {
	   q      = dDotMatrByColumn(t, BoxMatrix);
       r      =Vector3.Sub(p, q);
       Depth1 = SphereRadius - r.length();
    if (Depth1 < 0)
	{
      return false;
    } else 
	{
        intersectPoint = Vector3.Add(q, new Vector3(BoxMatrix.m[12], BoxMatrix.m[13], BoxMatrix.m[14]));
		r.normalize();
        normal.copyFrom(r);
        depth= Depth1;
    return true;
    }
  }
   return false;
  }
  
  

}