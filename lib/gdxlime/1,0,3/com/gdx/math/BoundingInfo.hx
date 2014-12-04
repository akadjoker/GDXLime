package  com.gdx.math;



/**
 * @author djoker
 */

typedef BoundingInfoMinMax = {
	min: Float,
	max: Float
}

class BoundingInfo {
	
	public var isCalculate:Bool;
	public var boundingBox:BoundingBox;
	public var boundingSphere:BoundingSphere;
	public var minimum:Vector3;
	public var maximum:Vector3;

	public function new(minimum:Vector3, maximum:Vector3) 
	{
		this.minimum = minimum;
		this.maximum = maximum;
		this.boundingBox = new BoundingBox(minimum, maximum);
        this.boundingSphere = new BoundingSphere(minimum, maximum);
		isCalculate = false;
	
	}
	public function clone(b:BoundingInfo):Void
	{
		this.copy(b.minimum, b.maximum);
		this.calculate();
		
	}
	
		public function copy(minimum:Vector3, maximum:Vector3) 
		{
		 boundingBox.copy(minimum, maximum);
	 	 boundingSphere.copy(minimum, maximum);
		}
    
		public function set(minimum:Vector3, maximum:Vector3) 
		{
		 boundingBox.set(minimum, maximum);
	 	 boundingSphere.set(minimum, maximum);
		}
        public function setFloats(min:Float,max:Float)
		
		{
		 boundingBox.setFloats(min,max);
	 	 boundingSphere.setFloats(min, max);
		}
		 public function reset(v:Vector3) 
	{
		
			 boundingBox.reset(v);
	 	     boundingSphere.reset(v);
	
		
	}
		
	public function update(world:Matrix4, scale:Float) 
	{
		if (!isCalculate)
		{
			isCalculate = true;
			calculate();
		}
        this.boundingBox.update(world);
        this.boundingSphere.update(world, scale);
    }
	public function calculate()
	{
	   boundingBox.calculate();
	   boundingSphere.calculate();
	}
   public function addInternalPoint(x:Float, y:Float,z:Float):Void
	{
		   isCalculate = false;
		   boundingBox.addInternalPoint(x, y, z);
		   boundingSphere.addInternalPoint(x, y, z);
	}
		public function addInternalVector(v:Vector3):Void
	{
		
		addInternalPoint(v.x, v.y, v.z);
		   
	}
	function extentsOverlap(min0:Float, max0:Float, min1:Float, max1:Float):Bool {
        return !(min0 > max1 || min1 > max0);
    }
	
	function computeBoxExtents(axis:Vector3, box:BoundingBox):BoundingInfoMinMax {
        var p = Vector3.Dot(box.center, axis);

        var r0 = Math.abs(Vector3.Dot(box.directions[0], axis)) * box._extends.x;
        var r1 = Math.abs(Vector3.Dot(box.directions[1], axis)) * box._extends.y;
        var r2 = Math.abs(Vector3.Dot(box.directions[2], axis)) * box._extends.z;

        var r = r0 + r1 + r2;
        return {
            min: p - r,
            max: p + r
        };
    }
	
	function axisOverlap(axis:Vector3, box0:BoundingBox, box1:BoundingBox):Bool {
        var result0 = computeBoxExtents(axis, box0);
        var result1 = computeBoxExtents(axis, box1);

        return extentsOverlap(result0.min, result0.max, result1.min, result1.max);
    }
	
	public function isInFrustrum(frustumPlanes:Array<Plane>):Bool {
        if (!this.boundingSphere.isInFrustrum(frustumPlanes))
            return false;

        return this.boundingBox._isInFrustrum(frustumPlanes);
    }
	

	
	public function intersectsPoint(point:Vector3):Bool {
        if (this.boundingSphere.centerWorld == null) {
            return false;
        }

        if (!this.boundingSphere.intersectsPoint(point)) {
            return false;
        }

        if (!this.boundingBox.intersectsPoint(point)) {
            return false;
        }

        return true;
    }
	
	public function intersectsBounds(point1:Vector3, point2:Vector3):Bool
	{
       
        if (!this.boundingBox.intersectsMinMax(point1,point2)) {
            return false;
        }

        return true;
    }
	
	public function intersects(boundingInfo:BoundingInfo, precise:Bool) {
        if (this.boundingSphere.centerWorld == null || boundingInfo.boundingSphere.centerWorld == null) {
            return false;
        }

        if (!BoundingSphere.intersects(this.boundingSphere, boundingInfo.boundingSphere)) {
            return false;
        }

        if (!BoundingBox.intersects(this.boundingBox, boundingInfo.boundingBox)) {
            return false;
        }

        if (!precise) 
		{
            return true;
        }

        var box0 = this.boundingBox;
        var box1 = boundingInfo.boundingBox;

        if (!axisOverlap(box0.directions[0], box0, box1)) return false;
        if (!axisOverlap(box0.directions[1], box0, box1)) return false;
        if (!axisOverlap(box0.directions[2], box0, box1)) return false;
        if (!axisOverlap(box1.directions[0], box0, box1)) return false;
        if (!axisOverlap(box1.directions[1], box0, box1)) return false;
        if (!axisOverlap(box1.directions[2], box0, box1)) return false;
        if (!axisOverlap(Vector3.Cross(box0.directions[0], box1.directions[0]), box0, box1)) return false;
        if (!axisOverlap(Vector3.Cross(box0.directions[0], box1.directions[1]), box0, box1)) return false;
        if (!axisOverlap(Vector3.Cross(box0.directions[0], box1.directions[2]), box0, box1)) return false;
        if (!axisOverlap(Vector3.Cross(box0.directions[1], box1.directions[0]), box0, box1)) return false;
        if (!axisOverlap(Vector3.Cross(box0.directions[1], box1.directions[1]), box0, box1)) return false;
        if (!axisOverlap(Vector3.Cross(box0.directions[1], box1.directions[2]), box0, box1)) return false;
        if (!axisOverlap(Vector3.Cross(box0.directions[2], box1.directions[0]), box0, box1)) return false;
        if (!axisOverlap(Vector3.Cross(box0.directions[2], box1.directions[1]), box0, box1)) return false;
        if (!axisOverlap(Vector3.Cross(box0.directions[2], box1.directions[2]), box0, box1)) return false;

        return true;
    }
	
}
