package  com.gdx.math;
import com.gdx.scene3d.buffer.Imidiatemode;



/**
 * @author djoker
 */

class BoundingBox {
	
	public var minimum:Vector3;
	public var maximum:Vector3;
	public var vectors:Array<Vector3>;
	public var vectorsWorld:Array<Vector3>;
	
	public var center:Vector3;
	public var _extends:Vector3;
	public var directions:Array<Vector3>;
	
	public var minimumWorld:Vector3;
	public var maximumWorld:Vector3;
	

	public function new(minimum:Vector3 , maximum:Vector3 ) 
	{
		this.minimum = minimum;
        this.maximum = maximum;
        
        // Bounding vectors
        this.vectors = [];
	
		var  aMinX, aMaxX, aMinY, aMaxY, aMinZ, aMaxZ:Float;
		aMinX = minimum.x;
		aMinY = minimum.y;
		aMinZ = minimum.z;
		aMaxX = maximum.x;
		aMaxY = maximum.y;
		aMaxZ = maximum.z;
		
	this.vectors.push(new Vector3(aMinX, aMinY, aMaxZ));
  	this.vectors.push(new Vector3(aMaxX, aMinY, aMaxZ));
  	this.vectors.push(new Vector3(aMaxX, aMaxY, aMaxZ));
  	this.vectors.push(new Vector3(aMinX, aMaxY, aMaxZ));
  	this.vectors.push(new Vector3(aMinX, aMinY, aMinZ));
  	this.vectors.push(new Vector3(aMinX, aMaxY, aMinZ));
  	this.vectors.push(new Vector3(aMaxX, aMaxY, aMinZ));
  	this.vectors.push(new Vector3(aMaxX, aMinY, aMinZ));
	
	         

		
        // OBB
        this.center = this.maximum.add(this.minimum).scale(0.5);
        this._extends = this.maximum.subtract(this.minimum).scale(0.5);
        this.directions = [Vector3.Zero(), Vector3.Zero(), Vector3.Zero()];

        // World
        this.vectorsWorld = [];
        for (index in 0...this.vectors.length) {
            this.vectorsWorld[index] = Vector3.Zero();
        }
        this.minimumWorld = Vector3.Zero();
        this.maximumWorld = Vector3.Zero();

        this.update(Matrix4.Identity());
	}
	
	  public function set(minimum:Vector3, maximum:Vector3) 
		{
		this.minimum = minimum;
        this.maximum = maximum;
		}
		public function copy(minimum:Vector3, maximum:Vector3) 
		{
		this.maximum.copyFrom(maximum);
		this.minimum.copyFrom(minimum);
	 	}
    
		
	  public function reset(v:Vector3) 
	{
		
		maximum.copy(v);
		minimum.copy(v);
		
	}
	public function getCenter():Vector3
	{
	var Center:Vector3 = Vector3.zero;
		Center.x = (minimum.x + maximum.x) / 2;
		Center.y = (minimum.y + maximum.y) / 2;
		Center.z = (minimum.z + maximum.z) / 2;

		return Center;
	}
	
		public function getEdges (edges:Array<Vector3>):Void
	{
		         var middle = getCenter();
			     var diag =  Vector3.Sub( middle , maximum);
					 
	        edges.push(new Vector3(middle.x + diag.x, middle.y + diag.y, middle.z + diag.z));
	        edges.push(new Vector3(middle.x + diag.x, middle.y - diag.y, middle.z + diag.z));
			edges.push(new Vector3(middle.x + diag.x, middle.y + diag.y, middle.z - diag.z));
			edges.push(new Vector3(middle.x + diag.x, middle.y - diag.y, middle.z - diag.z));
			edges.push(new Vector3(middle.x - diag.x, middle.y + diag.y, middle.z + diag.z));
			edges.push(new Vector3(middle.x - diag.x, middle.y - diag.y, middle.z + diag.z));
			edges.push(new Vector3(middle.x - diag.x, middle.y + diag.y, middle.z - diag.z));
			edges.push(new Vector3(middle.x - diag.x, middle.y - diag.y, middle.z - diag.z));
	
		
	}
	public function transfrom(world:Matrix4)
	{
		
		    for (index in 0...this.vectors.length) 
			{
            var v:Vector3 = this.vectorsWorld[index];
            Vector3.TransformCoordinatesToRef(this.vectors[index], world, v);
		    }

		
	}
		public function setFloats(min:Float,max:Float):Void
		{
		  this.minimum.set(min, min, min);
          this.maximum.set(max,max,max);
		  
		}
	public function calculate()
	{
		

		
		var  aMinX, aMaxX, aMinY, aMaxY, aMinZ, aMaxZ:Float;
		aMinX = minimum.x;
		aMinY = minimum.y;
		aMinZ = minimum.z;
		aMaxX = maximum.x;
		aMaxY = maximum.y;
		aMaxZ = maximum.z;
		
	this.vectors[0]=(new Vector3(aMinX, aMinY, aMaxZ));
  	this.vectors[1]=(new Vector3(aMaxX, aMinY, aMaxZ));
  	this.vectors[2]=(new Vector3(aMaxX, aMaxY, aMaxZ));
  	this.vectors[3]=(new Vector3(aMinX, aMaxY, aMaxZ));
  	this.vectors[4]=(new Vector3(aMinX, aMinY, aMinZ));
  	this.vectors[5]=(new Vector3(aMinX, aMaxY, aMinZ));
  	this.vectors[6]=(new Vector3(aMaxX, aMaxY, aMinZ));
  	this.vectors[7]=(new Vector3(aMaxX, aMinY, aMinZ));
	
		

		
        // OBB
        this.center = this.maximum.add(this.minimum).scale(0.5);
        this._extends = this.maximum.subtract(this.minimum).scale(0.5);
        this.directions = [Vector3.Zero(), Vector3.Zero(), Vector3.Zero()];

        // World
        this.vectorsWorld = [];
        for (index in 0...this.vectors.length) 
		{
            this.vectorsWorld[index] = Vector3.Zero();
        }
    }
		public function addInternalVector(v:Vector3):Void
	{
		 addInternalPoint(v.x, v.y, v.z);
	}
    public function addInternalBox(b:BoundingBox):Void
	{
	addInternalVector(b.maximum);
	addInternalVector(b.minimum);
	}
	public function addInternalPoint(x:Float, y:Float,z:Float):Void
	{
		    if (x>maximum.x) maximum.x = x;
			if (y>maximum.y) maximum.y = y;
			if (z>maximum.z) maximum.z = z;

			if (x<minimum.x) minimum.x = x;
			if (y<minimum.y) minimum.y = y;
			if (z<minimum.z) minimum.z = z;
	}
	public function update(world:Matrix4) 
	{
        Vector3.FromFloatsToRef(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY, this.minimumWorld);
        Vector3.FromFloatsToRef(Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY, this.maximumWorld);

        for (index in 0...this.vectors.length) 
		{
            var v:Vector3 = this.vectorsWorld[index];
            Vector3.TransformCoordinatesToRef(this.vectors[index], world, v);

            if (v.x < this.minimumWorld.x)
                this.minimumWorld.x = v.x;
            if (v.y < this.minimumWorld.y)
                this.minimumWorld.y = v.y;
            if (v.z < this.minimumWorld.z)
                this.minimumWorld.z = v.z;

            if (v.x > this.maximumWorld.x)
                this.maximumWorld.x = v.x;
            if (v.y > this.maximumWorld.y)
                this.maximumWorld.y = v.y;
            if (v.z > this.maximumWorld.z)
                this.maximumWorld.z = v.z;
        }

        // OBB
        this.maximumWorld.addToRef(this.minimumWorld, this.center);
        this.center.scaleInPlace(0.5);

        Vector3.FromArrayToRef(world.m, 0, this.directions[0]);
        Vector3.FromArrayToRef(world.m, 4, this.directions[1]);
        Vector3.FromArrayToRef(world.m, 8, this.directions[2]);
    }
	
	public function _isInFrustrum(frustumPlanes:Array<Plane>):Bool 
	{ 
        return BoundingBox.IsInFrustum(this.vectorsWorld, frustumPlanes);
    }

	 public function isPointInside(p:Vector3):Bool
	 {
		return (	p.x >= minimum.x && p.x <= maximum.x &&
							p.y >= minimum.y && p.y <= maximum.y &&
							p.z >= minimum.z && p.z <= maximum.z);
		
     }
	 	public function isEmpty():Bool
	{
		return minimum.equals(maximum);
	}
	public function intersectsPoint(point:Vector3):Bool {
        if (this.maximumWorld.x < point.x || this.minimumWorld.x > point.x)
            return false;

        if (this.maximumWorld.y < point.y || this.minimumWorld.y > point.y)
            return false;

        if (this.maximumWorld.z < point.z || this.minimumWorld.z > point.z)
            return false;

        return true;
    }

	
	public function intersectsBoundingSphere(sphere:BoundingSphere):Bool {
        var vector = Vector3.Clamp(sphere.centerWorld, this.minimumWorld, this.maximumWorld);
        var num = Vector3.DistanceSquared(sphere.centerWorld, vector);
        return (num <= (sphere.radiusWorld * sphere.radiusWorld));
    }
	public function intersectsSphere(sphereCenter:Vector3, sphereRadius:Float):Bool 
	{
        var vector = Vector3.Clamp(sphereCenter, this.minimumWorld, this.maximumWorld);
        var num = Vector3.DistanceSquared(sphereCenter, vector);
        return (num <= (sphereRadius * sphereRadius));
    }

		
	public function isFullInside(other:BoundingBox) :Bool
	{
				return (minimum.x >= other.minimum.x && minimum.y >= other.minimum.y && minimum.z >= other.minimum.z &&
				maximum.x <= other.maximum.x && maximum.y <= other.maximum.y && maximum.z <= other.maximum.z);
	
	}
	public function intersectsWithBox(other:BoundingBox) :Bool
	{
				
		return (minimum.x <= other.maximum.x && minimum.y <= other.maximum.y && minimum.z <= other.maximum.z &&
				maximum.x >= other.minimum.x && maximum.y >= other.minimum.y && maximum.z >= other.minimum.z);
	
	
	}
	public function intersectsWithTrasformBox(other:BoundingBox) :Bool
	{
				
		return (minimumWorld.x <= other.maximumWorld.x && minimumWorld.y <= other.maximumWorld.y && minimumWorld.z <= other.maximumWorld.z &&
				maximumWorld.x >= other.minimumWorld.x && maximumWorld.y >= other.minimumWorld.y && maximumWorld.z >= other.minimumWorld.z);
	
	
	}
	public function intersectsMinMax(min:Vector3, max:Vector3):Bool {
        if (this.maximumWorld.x < min.x || this.minimumWorld.x > max.x)
            return false;

        if (this.maximumWorld.y < min.y || this.minimumWorld.y > max.y)
            return false;

        if (this.maximumWorld.z < min.z || this.minimumWorld.z > max.z)
            return false;

        return true;
    }
	
	public static function intersects(box0:BoundingBox, box1:BoundingBox):Bool {
        if (box0.maximumWorld.x < box1.minimumWorld.x || box0.minimumWorld.x > box1.maximumWorld.x)
            return false;

        if (box0.maximumWorld.y < box1.minimumWorld.y || box0.minimumWorld.y > box1.maximumWorld.y)
            return false;

        if (box0.maximumWorld.z < box1.minimumWorld.z || box0.minimumWorld.z > box1.maximumWorld.z)
            return false;

        return true;
    }
	
	public static function IsInFrustum(boundingVectors:Array<Vector3>, frustumPlanes:Array<Plane>):Bool {
        for (p in 0...6) {
            var inCount:Int = 8;

            for (i in 0...8) {
                if (frustumPlanes[p].dotCoordinate(boundingVectors[i]) < 0) {
                    --inCount;
                } else {
                    break;
                }
            }
            if (inCount == 0)
                return false;
        }
        return true;
    }
	public function renderColor(batch:Imidiatemode,r:Float,g:Float,b:Float)
	{

		batch.lineVector(vectors[0], vectors[1], r,g,b, 1);
		batch.lineVector(vectors[1], vectors[2], r,g,b, 1);
		batch.lineVector(vectors[2], vectors[3], r,g,b, 1);
		batch.lineVector(vectors[3], vectors[0], r,g,b, 1);
		
		batch.lineVector(vectors[4], vectors[5], r,g,b, 1);
		batch.lineVector(vectors[5], vectors[6], r,g,b, 1);
		batch.lineVector(vectors[6], vectors[7], r,g,b, 1);
		batch.lineVector(vectors[7], vectors[4], r,g,b, 1);
	
		batch.lineVector(vectors[0], vectors[4], r,g,b, 1);
		batch.lineVector(vectors[1], vectors[7], r,g,b, 1);
		batch.lineVector(vectors[2], vectors[6], r,g,b, 1);
		batch.lineVector(vectors[3], vectors[5], r,g,b, 1);

		
	}
	public function render(l:Imidiatemode)
	{

		l.lineVector(vectors[0], vectors[1], 1, 0, 1, 1);
		l.lineVector(vectors[1], vectors[2], 1, 0, 1, 1);
		l.lineVector(vectors[2], vectors[3], 1, 0, 1, 1);
		l.lineVector(vectors[3], vectors[0], 1, 0, 1, 1);
		
		l.lineVector(vectors[4], vectors[5], 1, 0, 1, 1);
		l.lineVector(vectors[5], vectors[6], 1, 0, 1, 1);
		l.lineVector(vectors[6], vectors[7], 1, 0, 1, 1);
		l.lineVector(vectors[7], vectors[4], 1, 0, 1, 1);
	
		l.lineVector(vectors[0], vectors[4], 1, 0, 1, 1);
		l.lineVector(vectors[1], vectors[7], 1, 0, 1, 1);
		l.lineVector(vectors[2], vectors[6], 1, 0, 1, 1);
		l.lineVector(vectors[3], vectors[5], 1, 0, 1, 1);

		
	}
	
	public function renderAligned(batch:Imidiatemode)
	{

		batch.lineVector(vectorsWorld[0], vectorsWorld[1], 1, 0, 1, 1);
		batch.lineVector(vectorsWorld[1], vectorsWorld[2], 1, 0, 1, 1);
		batch.lineVector(vectorsWorld[2], vectorsWorld[3], 1, 0, 1, 1);
		batch.lineVector(vectorsWorld[3], vectorsWorld[0], 1, 0, 1, 1);
		
		batch.lineVector(vectorsWorld[4], vectorsWorld[5], 1, 0, 1, 1);
		batch.lineVector(vectorsWorld[5], vectorsWorld[6], 1, 0, 1, 1);
		batch.lineVector(vectorsWorld[6], vectorsWorld[7], 1, 0, 1, 1);
		batch.lineVector(vectorsWorld[7], vectorsWorld[4], 1, 0, 1, 1);
	
		batch.lineVector(vectorsWorld[0], vectorsWorld[4], 1, 0, 1, 1);
		batch.lineVector(vectorsWorld[1], vectorsWorld[7], 1, 0, 1, 1);
		batch.lineVector(vectorsWorld[2], vectorsWorld[6], 1, 0, 1, 1);
		batch.lineVector(vectorsWorld[3], vectorsWorld[5], 1, 0, 1, 1);
		
	}
	
	public function renderAlignedColor(batch:Imidiatemode,r:Float,g:Float,b:Float)
	{

		batch.lineVector(vectorsWorld[0], vectorsWorld[1], r,g,b, 1);
		batch.lineVector(vectorsWorld[1], vectorsWorld[2], r,g,b, 1);
		batch.lineVector(vectorsWorld[2], vectorsWorld[3], r,g,b, 1);
		batch.lineVector(vectorsWorld[3], vectorsWorld[0], r,g,b, 1);
		
		batch.lineVector(vectorsWorld[4], vectorsWorld[5], r,g,b, 1);
		batch.lineVector(vectorsWorld[5], vectorsWorld[6], r,g,b, 1);
		batch.lineVector(vectorsWorld[6], vectorsWorld[7], r,g,b, 1);
		batch.lineVector(vectorsWorld[7], vectorsWorld[4], r,g,b, 1);
	
		batch.lineVector(vectorsWorld[0], vectorsWorld[4], r,g,b, 1);
		batch.lineVector(vectorsWorld[1], vectorsWorld[7], r,g,b, 1);
		batch.lineVector(vectorsWorld[2], vectorsWorld[6], r,g,b, 1);
		batch.lineVector(vectorsWorld[3], vectorsWorld[5], r,g,b, 1);
		
	}
	
	public static  function colideABBWithABB(a:BoundingBox,other:BoundingBox) :Bool
	{
				
		return (a.minimum.x <= other.maximum.x && a.minimum.y <= other.maximum.y && a.minimum.z <= other.maximum.z &&
				a.maximum.x >= other.minimum.x && a.maximum.y >= other.minimum.y && a.maximum.z >= other.minimum.z);
	
	
	}
	public static function colideABBWithOBB(a:BoundingBox,other:BoundingBox) :Bool
	{
				
		return (a.minimum.x <= other.maximumWorld.x && a.minimum.y <= other.maximumWorld.y && a.minimum.z <= other.maximumWorld.z &&
				a.maximum.x >= other.minimumWorld.x && a.maximum.y >= other.minimumWorld.y && a.maximum.z >= other.minimumWorld.z);
	
	
	}
	public static function colideOBBWithOBB(a:BoundingBox,other:BoundingBox) :Bool
	{
				
		return (a.minimumWorld.x <= other.maximumWorld.x && a.minimumWorld.y <= other.maximumWorld.y && a.minimumWorld.z <= other.maximum.z &&
				a.maximumWorld.x >= other.minimumWorld.x && a.maximumWorld.y >= other.minimumWorld.y && a.maximumWorld.z >= other.minimum.z);
	
	
	}
	public static function colideABBWithSphere(a:BoundingBox,sphereCenter:Vector3, sphereRadius:Float):Bool 
	{
        var vector = Vector3.Clamp(sphereCenter, a.minimum, a.maximum);
        var num = Vector3.DistanceSquared(sphereCenter, vector);
        return (num <= (sphereRadius * sphereRadius));
    }

}
