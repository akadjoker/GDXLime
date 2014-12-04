package  com.gdx.collision;
import com.gdx.math.Aabbox3d;
import com.gdx.math.BoundingBox;
import com.gdx.math.Plane;
import com.gdx.math.Ray;
import com.gdx.math.Triangle;
import com.gdx.math.Vector3;
import com.gdx.scene3d.buffer.Imidiatemode;
import com.gdx.scene3d.Camera;
import com.gdx.scene3d.Mesh;
import com.gdx.scene3d.Scene;
import com.gdx.scene3d.SceneNode;
import com.gdx.scene3d.Surface;
import com.gdx.collision.OctreeTriangleSelector;





typedef LowestRootResult = {
	root: Float,
	found: Bool
}

class Collider {
	
	public var radius:Vector3;
	public var retry:Int;
	public var basePoint:Vector3;
	public var basePointWorld:Vector3;
	public var velocityWorld:Vector3;
	public var normalizedVelocity:Vector3;				// Vector2 or Vector3 or Matrix   ???
	public var velocityWorldLength:Float;
	public var velocity:Vector3;
	public var collisionFound:Bool;
	public var onFloor:Bool;
	public var epsilon:Float;
	public var nearestDistance:Float = 0;
	
	private	 var v1:Vector3 = Vector3.zero;
	private  var v2:Vector3 = Vector3.zero;
	private var v3:Vector3 = Vector3.zero;
	 
	public var intersectionPoint:Vector3;
//	public var initialVelocity:Vector3;
	//public var initialPosition:Vector3;
	
	private var _collisionPoint:Vector3;
	private var _planeIntersectionPoint:Vector3;
	private var _tempVector:Vector3;
	private var _tempVector2:Vector3;
	private var _tempVector3:Vector3;
	private var _tempVector4:Vector3;
	private var _edge:Vector3;
	private var _baseToVertex:Vector3;
	
	public var trianglePlane:Plane;
	public var slidePlaneNormal:Vector3;
	public var destinationPoint:Vector3;
	public var displacementVector:Vector3;
	
	private var models:Array<Mesh>;
	private var staticMesh:Array<Mesh>;
	
	private var useOctree:Bool;

	public var Falling:Bool;
	public var triangleHits:Int;
	public var Triangles:Array<Triangle>;
	public var scene:Scene;
	
	public var selector:OctreeTriangleSelector;

	public function new(scene:Scene,colidemesh:Array<Mesh>,minimalPolysPerNode:Int)
	{
	this.scene = scene;
     models = [];
	 Triangles = [];
	 staticMesh = [];
	 Falling = true;
     triangleHits = 0;
		
	selector = new OctreeTriangleSelector(minimalPolysPerNode);
	
	for (m in 0... colidemesh.length)
	{
		staticMesh.push(colidemesh[m]);
		for (j in 0 ... colidemesh[m].CountSurfaces())
		{	
		
		var surface:Surface = colidemesh[m].surfaces[j];
		
	          for (i in 0... surface.CountFaces())
		      {
			
				  var v0:Vector3 = surface.getFace(i, 0);
				  var v1:Vector3 = surface.getFace(i, 1);
				  var v2:Vector3 = surface.getFace(i, 2);
				  selector.AddTriangle(v2, v1, v0,surface.getFaceNormal(i,0));
				  //Triangles.push(new Triangle(v2,v1,v0,surface.getFaceNormal(i,0));
			}
		}
	}
		 
     selector.Build();

		
		
		this.radius = new Vector3(1, 1, 1);
        this.retry = 0;

		this.basePoint = Vector3.Zero();
		this.velocity = Vector3.Zero();
		
        this.basePointWorld = Vector3.Zero();
        this.velocityWorld = Vector3.Zero();
        this.normalizedVelocity = Vector3.Zero();
        
        // Internals
        this._collisionPoint = Vector3.Zero();
        this._planeIntersectionPoint = Vector3.Zero();
        this._tempVector = Vector3.Zero();
        this._tempVector2 = Vector3.Zero();
        this._tempVector3 = Vector3.Zero();
        this._tempVector4 = Vector3.Zero();
        this._edge = Vector3.Zero();
        this._baseToVertex = Vector3.Zero();
        this.destinationPoint = Vector3.Zero();
        this.slidePlaneNormal = Vector3.Zero();
        this.displacementVector = Vector3.Zero();
		trianglePlane = new Plane(0, 0,0, 0);
	}
	public function addModel(mesh:Mesh):Void
	{
		this.models.push(mesh);
	}
	public function initialize(source:Vector3, dir:Vector3, e:Float) {
        this.velocity = dir;
        Vector3.NormalizeToRef(dir, this.normalizedVelocity);
        this.basePoint = source;

        source.multiplyToRef(this.radius, this.basePointWorld);
        dir.multiplyToRef(this.radius, this.velocityWorld);

        this.velocityWorldLength = this.velocityWorld.length();

        this.epsilon = e;
        this.collisionFound = false;

	
		
    }
	public function intersectBoxAASphere(boxMin:Vector3, boxMax:Vector3, sphereCenter:Vector3, sphereRadius:Float) {
        if (boxMin.x > sphereCenter.x + sphereRadius)
            return false;

        if (sphereCenter.x - sphereRadius > boxMax.x)
            return false;

        if (boxMin.y > sphereCenter.y + sphereRadius)
            return false;

        if (sphereCenter.y - sphereRadius > boxMax.y)
            return false;

        if (boxMin.z > sphereCenter.z + sphereRadius)
            return false;

        if (sphereCenter.z - sphereRadius > boxMax.z)
            return false;

        return true;
    }
	public function _canDoCollision(sphereCenter:Vector3, sphereRadius:Float, vecMin:Vector3, vecMax:Vector3):Bool {
        var distance:Float = Vector3.Distance(this.basePointWorld, sphereCenter);

        var max:Float = Math.max(this.radius.x, this.radius.y);
        max = Math.max(max, this.radius.z);

        if (distance > this.velocityWorldLength + max + sphereRadius) {
            return false;
        }

        if (!intersectBoxAASphere(vecMin, vecMax, this.basePointWorld, this.velocityWorldLength + max))
            return false;

        return true;
    }
	public function _checkPointInTriangle(point:Vector3, pa:Vector3, pb:Vector3, pc:Vector3, n:Vector3):Bool {
        pa.subtractToRef(point, this._tempVector);
        pb.subtractToRef(point, this._tempVector2);

        Vector3.CrossToRef(this._tempVector, this._tempVector2, this._tempVector4);
        var d:Float = Vector3.Dot(this._tempVector4, n);
        if (d < 0)
            return false;

        pc.subtractToRef(point, this._tempVector3);
        Vector3.CrossToRef(this._tempVector2, this._tempVector3, this._tempVector4);
        d = Vector3.Dot(this._tempVector4, n);
        if (d < 0)
            return false;

        Vector3.CrossToRef(this._tempVector3, this._tempVector, this._tempVector4);
        d = Vector3.Dot(this._tempVector4, n);
        return d >= 0;
    }
	
	
	
	public function getLowestRoot(a:Float, b:Float, c:Float, maxR:Float):LowestRootResult {
        var determinant = b * b - 4.0 * a * c;
        var result:LowestRootResult = { root: 0, found: false };

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
	
	
	public function testTriangle( p1:Vector3, p2:Vector3, p3:Vector3):Bool {
        var t0:Float = 0;
        var embeddedInPlane:Bool = false;
		

		//trianglePlane=Plane.FromPoints(p1, p2, p3);
		trianglePlane.copyFromPoints(p1, p2, p3);
      
       if ( !trianglePlane.isFrontFacingTo(this.normalizedVelocity, 0))
		{
	     return false;
		}

        var signedDistToTrianglePlane = trianglePlane.signedDistanceTo(this.basePoint);
        var normalDotVelocity = Vector3.Dot(trianglePlane.normal, this.velocity);

        if (normalDotVelocity == 0) {
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

            if (t0 > 1.0 || t1 < 0.0)
			{
		           return false;
			}
            if (t0 < 0)
                t0 = 0;
            if (t0 > 1.0)
                t0 = 1.0;
        }

        this._collisionPoint.copyFromFloats(0, 0, 0);

        var found = false;
        var t = 1.0;

        if (!embeddedInPlane) 
		{
            this.basePoint.subtractToRef(trianglePlane.normal, this._planeIntersectionPoint);
            this.velocity.scaleToRef(t0, this._tempVector);
            this._planeIntersectionPoint.addInPlace(this._tempVector);

            if (this._checkPointInTriangle(this._planeIntersectionPoint, p1, p2, p3, trianglePlane.normal))
			{
                found = true;
                t = t0;
                this._collisionPoint.copyFrom(this._planeIntersectionPoint);
            }
        }

        if (!found) 
		{
            var velocitySquaredLength = this.velocity.lengthSquared();

            var a = velocitySquaredLength;

            this.basePoint.subtractToRef(p1, this._tempVector);
            var b = 2.0 * (Vector3.Dot(this.velocity, this._tempVector));
            var c = this._tempVector.lengthSquared() - 1.0;

            var lowestRoot:LowestRootResult = getLowestRoot(a, b, c, t);
            if (lowestRoot.found) {
                t = lowestRoot.root;
                found = true;
                this._collisionPoint.copyFrom(p1);
            }

            this.basePoint.subtractToRef(p2, this._tempVector);
            b = 2.0 * (Vector3.Dot(this.velocity, this._tempVector));
            c = this._tempVector.lengthSquared() - 1.0;

            lowestRoot = getLowestRoot(a, b, c, t);
            if (lowestRoot.found) {
                t = lowestRoot.root;
                found = true;
                this._collisionPoint.copyFrom(p2);
            }

            this.basePoint.subtractToRef(p3, this._tempVector);
            b = 2.0 * (Vector3.Dot(this.velocity, this._tempVector));
            c = this._tempVector.lengthSquared() - 1.0;

            lowestRoot = getLowestRoot(a, b, c, t);
            if (lowestRoot.found) {
                t = lowestRoot.root;
                found = true;
                this._collisionPoint.copyFrom(p3);
            }

            p2.subtractToRef(p1, this._edge);
            p1.subtractToRef(this.basePoint, this._baseToVertex);
            var edgeSquaredLength = this._edge.lengthSquared();
            var edgeDotVelocity = Vector3.Dot(this._edge, this.velocity);
            var edgeDotBaseToVertex = Vector3.Dot(this._edge, this._baseToVertex);

            a = edgeSquaredLength * (-velocitySquaredLength) + edgeDotVelocity * edgeDotVelocity;
            b = edgeSquaredLength * (2.0 * Vector3.Dot(this.velocity, this._baseToVertex)) - 2.0 * edgeDotVelocity * edgeDotBaseToVertex;
            c = edgeSquaredLength * (1.0 - this._baseToVertex.lengthSquared()) + edgeDotBaseToVertex * edgeDotBaseToVertex;

            lowestRoot = getLowestRoot(a, b, c, t);
            if (lowestRoot.found) {
                var f = (edgeDotVelocity * lowestRoot.root - edgeDotBaseToVertex) / edgeSquaredLength;

                if (f >= 0.0 && f <= 1.0) {
                    t = lowestRoot.root;
                    found = true;
                    this._edge.scaleInPlace(f);
                    p1.addToRef(this._edge, this._collisionPoint);
                }
            }

            p3.subtractToRef(p2, this._edge);
            p2.subtractToRef(this.basePoint, this._baseToVertex);
            edgeSquaredLength = this._edge.lengthSquared();
            edgeDotVelocity = Vector3.Dot(this._edge, this.velocity);
            edgeDotBaseToVertex = Vector3.Dot(this._edge, this._baseToVertex);

            a = edgeSquaredLength * (-velocitySquaredLength) + edgeDotVelocity * edgeDotVelocity;
            b = edgeSquaredLength * (2.0 * Vector3.Dot(this.velocity, this._baseToVertex)) - 2.0 * edgeDotVelocity * edgeDotBaseToVertex;
            c = edgeSquaredLength * (1.0 - this._baseToVertex.lengthSquared()) + edgeDotBaseToVertex * edgeDotBaseToVertex;
            lowestRoot = getLowestRoot(a, b, c, t);
            if (lowestRoot.found) {
                var f = (edgeDotVelocity * lowestRoot.root - edgeDotBaseToVertex) / edgeSquaredLength;

                if (f >= 0.0 && f <= 1.0) {
                    t = lowestRoot.root;
                    found = true;
                    this._edge.scaleInPlace(f);
                    p2.addToRef(this._edge, this._collisionPoint);
                }
            }

            p1.subtractToRef(p3, this._edge);
            p3.subtractToRef(this.basePoint, this._baseToVertex);
            edgeSquaredLength = this._edge.lengthSquared();
            edgeDotVelocity = Vector3.Dot(this._edge, this.velocity);
            edgeDotBaseToVertex = Vector3.Dot(this._edge, this._baseToVertex);

            a = edgeSquaredLength * (-velocitySquaredLength) + edgeDotVelocity * edgeDotVelocity;
            b = edgeSquaredLength * (2.0 * Vector3.Dot(this.velocity, this._baseToVertex)) - 2.0 * edgeDotVelocity * edgeDotBaseToVertex;
            c = edgeSquaredLength * (1.0 - this._baseToVertex.lengthSquared()) + edgeDotBaseToVertex * edgeDotBaseToVertex;

            lowestRoot = getLowestRoot(a, b, c, t);
            if (lowestRoot.found) {
                var f = (edgeDotVelocity * lowestRoot.root - edgeDotBaseToVertex) / edgeSquaredLength;

                if (f >= 0.0 && f <= 1.0) {
                    t = lowestRoot.root;
                    found = true;
                    this._edge.scaleInPlace(f);
                    p3.addToRef(this._edge, this._collisionPoint);
                }
            }
        }
         
        if (found)
		{
			
            var distToCollision:Float = t * this.velocity.length();

            if (!this.collisionFound || distToCollision < this.nearestDistance) 
			{
                if (this.intersectionPoint == null) 
				{
                    this.intersectionPoint = this._collisionPoint.clone();
                } else 
				{
                    this.intersectionPoint.copyFrom(this._collisionPoint);
                }
                this.nearestDistance = distToCollision;                
                this.collisionFound = true;
				++triangleHits;
				//trace("colide:" + trianglePlane.normal.toString());
			 //  scene.lines.drawFullTriangle(Vector3.ScaleBy(p3,radius),Vector3.ScaleBy(p2,radius),Vector3.ScaleBy(p1,radius),0,1,0, 1);
				//lines.drawFullTriangle(p1,p2,p3,0,1,0, 1);
				
				
			    return  true;
             
            }
        }
		
		return false;
    }
	
	public function rayHit( ray:Ray):Bool
	{
	      scene.inpactPoint.set(0, 0, 0);
	       scene.inpactNormal.set(0, 0, 0);
		   
	 var result:Bool = false;
	 if ( testRay(this.selector.Root, ray)) result = true;
	
	   if (this.models.length > 0)
		{
			for (i in 0...this.models.length)
			{
				var mesh:Mesh = this.models[i];
				if (mesh == null) continue;
				
				 if (mesh.rayTrace(ray, true))
				 {
					 return true;
				 }
				
			}
		}
	
	
	return result;
		
	}
	
	 private function testRay(pNode:SOctreeNode, ray:Ray ) :Bool
	 {
		 var bResult:Bool = false;
		 if (pNode == null) return bResult;	 
	
		 if (ray.intersectsBox(pNode.Box))
    	{	 
	        for (i in 0 ... Std.int(pNode.Triangles.length))
	        {
			var triangle:Triangle = pNode.Triangles[i];
			scene.inpactPlane.copyFromPoints(triangle.a, triangle.b, triangle.c);
			if (!scene.inpactPlane.isFrontFacingTo(ray.direction, 0.001)) continue;
			
			 scene.inpactDistance = ray.intersectsTriangle(triangle.a, triangle.b, triangle.c);
			if(scene.inpactDistance>0)
			{
		    scene.inpactTriangle.a.copyFrom(triangle.a);
			scene.inpactTriangle.b.copyFrom(triangle.b);
			scene.inpactTriangle.c.copyFrom(triangle.c);
			scene.inpactTriangle.normal.copyFrom(triangle.normal);
	        scene.inpactNormal.x = scene.inpactTriangle.normal.x;
			scene.inpactNormal.y = scene.inpactTriangle.normal.y;
			scene.inpactNormal.z = scene.inpactTriangle.normal.z;
			
			
			scene.inpactPoint.x = ray.origin.x + (ray.direction.x * scene.inpactDistance);
			scene.inpactPoint.y = ray.origin.y + (ray.direction.y * scene.inpactDistance);
			scene.inpactPoint.z = ray.origin.z + (ray.direction.z * scene.inpactDistance);
			
			
		
			return  true;
			}
		}
		
	}

	for (i in 0...8)
	{
		if (pNode.Child[i] != null)
		{
			if (testRay(pNode.Child[i],ray)) bResult = true;
		}
	}
		
		
	
	return bResult;
	 }
	
	public function RayPickBoundingBoxes(ray:Ray ) :Bool
	 {
		 var result:Bool = false;
		 
		 for (m in 0...this.staticMesh.length)
		 {
			var mesh = staticMesh[m];
			for (s in  0...mesh.CountSurfaces())
			{
				var surface = mesh.getSurface(s);
				if (ray.intersectsBox(surface.Bounding.boundingBox))
				{
					surface.Bounding.boundingBox.renderColor(scene.lines, 0, 1, 1);
					surface.Bounding.boundingBox.renderAlignedColor(scene.lines, 1, 1, 0);
					result = true;
					break;
				}
			}
		 }
		 
		 for (m in 0...this.models.length)
		 {
			var mesh = this.models[m];
			for (s in  0...mesh.CountSurfaces())
			{
				var surface = mesh.getSurface(s);
				if (ray.intersectsTransformedBox(surface.Bounding.boundingBox))
				{
					surface.Bounding.boundingBox.renderAlignedColor(scene.lines, 1, 1, 0);
					surface.Bounding.boundingBox.renderColor(scene.lines, 0, 1, 1);
					result = true;
					break;
				}
			}
		 }
		 
		 return result;
	 }
	public function RayPick(ray:Ray,fastCheck:Bool ) :Bool
	 {

		 /*
	level.scene.lines.lineVector(ray.origin, ray.direction, 1, 0, 0, 1);
	var l:Float = 100;
	level.scene.lines.line3D(
	ray.origin.x,ray.origin.y,ray.origin.z,
	ray.origin.x + (ray.direction.x + l),
	ray.origin.y + (ray.direction.y + l),
	ray.origin.z + (ray.direction.z + l), 1, 1, 1,1);*/
		 
		 
		 
		 var result:Bool = false;
	    if ( testRay(this.selector.Root, ray)) result = true;

				
	   if (this.models.length > 0)
		{
			for (i in 0...this.models.length)
			{
				var mesh:Mesh = this.models[i];
				if (mesh == null) continue;
				
				 if (mesh.rayTrace(ray, fastCheck))
				 {
					result = true;
					break;
				 }
				
			}
		}
	
	
	return result;
		
	 }

	
	inline public function testAABBOX(pNode:SOctreeNode,box:BoundingBox) :Bool
	{

		 var bResult:Bool = false;
		 if (pNode == null) return bResult;	 
	
		 
	if (!box.intersectsWithBox(pNode.Box)) return bResult;
		 
			 
	var sMultx:Float = 1.0 / radius.x;
	var sMulty:Float = 1.0 / radius.y;
	var sMultz:Float = 1.0 / radius.z;

	

	
	//trace("triangle:int:" + Std.int(pNode.Triangles.length));
	
	    for (i in 0 ... Std.int(pNode.Triangles.length))
		{
	
			v1.x = pNode.Triangles[i].a.x * sMultx;
			v1.y = pNode.Triangles[i].a.y * sMulty;
			v1.z = pNode.Triangles[i].a.z * sMultz;
			
		    v2.x = pNode.Triangles[i].b.x * sMultx;
			v2.y = pNode.Triangles[i].b.y * sMulty;
			v2.z = pNode.Triangles[i].b.z * sMultz;
			
			v3.x = pNode.Triangles[i].c.x * sMultx;
			v3.y = pNode.Triangles[i].c.y * sMulty;
			v3.z = pNode.Triangles[i].c.z * sMultz;
			testTriangle( v1, v2, v3);		
		    if (this.collisionFound)
			{
				
				bResult = true;
			//break;
			}
		}
		 
		
	
		//node.Box.render(lines, 0, 1, 1);

	for (i in 0...8)
	{
		if (pNode.Child[i] != null)
		{
			if (testAABBOX(pNode.Child[i],box)) bResult = true;
		}
	}
		
		
	
	return bResult;
	}
			

	inline public function TraceBox(box:BoundingBox ) 
	{
		testAABBOX(this.selector.Root, box);
		
		if (this.models.length > 0)
		{
			var sMultx:Float = 1.0 / radius.x;
	        var sMulty:Float = 1.0 / radius.y;
	        var sMultz:Float = 1.0 / radius.z;

	
			for (i in 0...this.models.length)
			{
				var mesh:Mesh = this.models[i];
				if (mesh == null) continue;
				if (!BoundingBox.colideABBWithOBB(box, mesh.Bounding.boundingBox)) continue;
				 for (s in 0...mesh.CountSurfaces())
	              {
	               var surf:Surface = mesh.getSurface(s);
		           for (f in 0... surf.CountTriangles())
		           {
			        var p0 = surf.getFace(f, 2);
			        var p1 = surf.getFace(f, 1);
			        var p2 = surf.getFace(f, 0);
				
			    		
					var a = Vector3.TransformCoordinates(p0, mesh.getAbsoluteTransformation());
					var b = Vector3.TransformCoordinates(p1, mesh.getAbsoluteTransformation());
					var c = Vector3.TransformCoordinates(p2, mesh.getAbsoluteTransformation());
					
				//	scene.lines.drawFullTriangle(a, b, c, 0, 1, 0, 1);
				
				
					v1.x = a.x * sMultx;
			        v1.y = a.y * sMulty;
			        v1.z = a.z * sMultz;
			
		            v2.x = b.x * sMultx;
			        v2.y = b.y * sMulty;
			        v2.z = b.z * sMultz;
			
			        v3.x = c.x * sMultx;
			        v3.y = c.y * sMulty;
			        v3.z = c.z * sMultz;
			        if (testTriangle( v1, v2, v3))
			        {
					  continue;
			         }	
				   }
				  }
				
			}
		}
	
    }
	inline public function TraceModelsByBox(box:BoundingBox ) 
	{
		
		
			 
	var sMultx:Float = 1.0 / radius.x;
	var sMulty:Float = 1.0 / radius.y;
	var sMultz:Float = 1.0 / radius.z;

		
		if (this.models.length > 0)
		{
			for (i in 0...this.models.length)
			{
				var mesh:Mesh = this.models[i];
				if (!BoundingBox.colideABBWithOBB(box, mesh.Bounding.boundingBox)) continue;
				 for (s in 0...mesh.CountSurfaces())
	              {
	               var surf:Surface = mesh.getSurface(s);
		           for (f in 0... surf.CountTriangles())
		           {
			        var p0 = surf.getFace(f, 2);
			        var p1 = surf.getFace(f, 1);
			        var p2 = surf.getFace(f, 0);
			    		
					var a = Vector3.TransformCoordinates(p0, mesh.getAbsoluteTransformation());
					var b = Vector3.TransformCoordinates(p1, mesh.getAbsoluteTransformation());
					var c = Vector3.TransformCoordinates(p2, mesh.getAbsoluteTransformation());
					
				//	lines.drawFullTriangle(a,b,c,0,1,0, 1);
           
				
					v1.x = a.x * sMultx;
			        v1.y = a.y * sMulty;
			        v1.z = a.z * sMultz;
			
		            v2.x = b.x * sMultx;
			        v2.y = b.y * sMulty;
			        v2.z = b.z * sMultz;
			
			        v3.x = c.x * sMultx;
			        v3.y = c.y * sMulty;
			        v3.z = c.z * sMultz;
			        if (testTriangle( v1, v2, v3))
			        {
				//      continue;
			         }	
				   }
				  }
				
			}
		}
    }
	inline public function TraceSphere(selector:Array<Triangle>,center:Vector3,rad:Float ) 
	{
		
		
			 
	var sMultx:Float = 1.0 / radius.x;
	var sMulty:Float = 1.0 / radius.y;
	var sMultz:Float = 1.0 / radius.z;

	    for (i in 0 ... Std.int(selector.length))
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
			if (testTriangle( v1, v2, v3))
			{
				continue;
			}
		}
		
	
		
		if (this.models.length > 0)
		{
			for (i in 0...this.models.length)
			{
				var mesh:Mesh = this.models[i];
				if (!BoundingBox.colideABBWithSphere( mesh.Bounding.boundingBox,center,rad)) continue;
				 for (s in 0...mesh.CountSurfaces())
	              {
	               var surf:Surface = mesh.getSurface(s);
		           for (f in 0... surf.CountTriangles())
		           {
			        var p0 = surf.getFace(f, 2);
			        var p1 = surf.getFace(f, 1);
			        var p2 = surf.getFace(f, 0);
			    		
					var a = Vector3.TransformCoordinates(p0, mesh.getAbsoluteTransformation());
					var b = Vector3.TransformCoordinates(p1, mesh.getAbsoluteTransformation());
					var c = Vector3.TransformCoordinates(p2, mesh.getAbsoluteTransformation());
					
				//	lines.drawFullTriangle(a,b,c,0,1,0, 1);
           
				
					v1.x = a.x * sMultx;
			        v1.y = a.y * sMulty;
			        v1.z = a.z * sMultz;
			
		            v2.x = b.x * sMultx;
			        v2.y = b.y * sMulty;
			        v2.z = b.z * sMultz;
			
			        v3.x = c.x * sMultx;
			        v3.y = c.y * sMulty;
			        v3.z = c.z * sMultz;
			        if (testTriangle( v1, v2, v3))
			        {
				      continue;
			         }	
				   }
				  }
				
			}
		}
    }
	inline public function getResponse(pos:Vector3, vel:Vector3) 
	{
        pos.addToRef(vel, this.destinationPoint);
        vel.scaleInPlace((this.nearestDistance / vel.length()));
        this.basePoint.addToRef(vel, pos);
        pos.subtractToRef(this.intersectionPoint, this.slidePlaneNormal);
        this.slidePlaneNormal.normalize();
	    this.slidePlaneNormal.scaleToRef(this.epsilon, this.displacementVector);
        pos.addInPlace(this.displacementVector);
        this.intersectionPoint.addInPlace(this.displacementVector);
        this.slidePlaneNormal.scaleInPlace(Plane.SignedDistanceToPlaneFromPositionAndNormal(this.intersectionPoint, this.slidePlaneNormal, this.destinationPoint));
        this.destinationPoint.subtractInPlace(this.slidePlaneNormal);
	    this.destinationPoint.subtractToRef(this.intersectionPoint, vel);
		
    }
	
}
