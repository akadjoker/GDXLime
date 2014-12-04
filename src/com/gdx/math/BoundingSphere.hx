package  com.gdx.math;



/**
 * @author djoker
 */



class BoundingSphere {
	
	public var minimum:Vector3;
	public var maximum:Vector3;
	
	public var center:Vector3;
	public var radius:Float;
	
	public var centerWorld:Vector3;
	public var radiusWorld:Float;
	

	public function new(minimum:Vector3, maximum:Vector3) {
		this.minimum = minimum;
        this.maximum = maximum;
        
        var distance:Float = Vector3.Distance(minimum, maximum);
        
        this.center = Vector3.Lerp(minimum, maximum, 0.5);
        this.radius = distance * 0.5;

        this.centerWorld = Vector3.Zero();
        this.update(Matrix4.Identity());
	}
	/*
		public function set(minimum:Vector3, maximum:Vector3) 
		{
		this.minimum = minimum;
        this.maximum = maximum;
        
        var distance:Float = Vector3.Distance(minimum, maximum);
        
        this.center = Vector3.Lerp(minimum, maximum, 0.5);
        this.radius = distance * 0.5;

        this.centerWorld = Vector3.Zero();
        this.update(Matrix4.Identity());
	}
	*/
	 public function reset(v:Vector3) 
	{
		
		maximum.copy(v);
		minimum.copy(v);
		
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
    
	
	 public function setFloats(min:Float,max:Float):Void
		{
	      this.minimum.set(min, min, min);
          this.maximum.set(max,max,max);
		  
		}
	public function calculate()
	{
       var distance:Float = Vector3.Distance(minimum, maximum);
        
        this.center = Vector3.Lerp(minimum, maximum, 0.5);
        this.radius = distance * 0.5;

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
	public function update(world:Matrix4, scale:Float = 1.0) 
	{
        Vector3.TransformCoordinatesToRef(this.center, world, this.centerWorld);
        this.radiusWorld = this.radius * scale;
    }
	
	public function isInFrustrum(frustumPlanes:Array<Plane>):Bool {
        for (i in 0...6) {
            if (frustumPlanes[i].dotCoordinate(this.centerWorld) <= -this.radiusWorld)
                return false;
        }

        return true;
    }
	
	public function intersectsPoint(point:Vector3):Bool {
        var x = this.centerWorld.x - point.x;
        var y = this.centerWorld.y - point.y;
        var z = this.centerWorld.z - point.z;

        var distance = Math.sqrt((x * x) + (y * y) + (z * z));

        if (this.radiusWorld < distance)
            return false;

        return true;
    }
	public  function colideSphere(center:Vector3,rad:Float):Bool {
        var x = center.x - centerWorld.x;
        var y = center.y - centerWorld.y;
        var z = center.z - centerWorld.z;

        var distance = Math.sqrt((x * x) + (y * y) + (z * z));

        if (rad + radiusWorld < distance)
            return false;

        return true;
    }	
	public static function colide(center:Vector3,rad:Float, sphere:BoundingSphere):Bool {
        var x = center.x - sphere.centerWorld.x;
        var y = center.y - sphere.centerWorld.y;
        var z = center.z - sphere.centerWorld.z;

        var distance = Math.sqrt((x * x) + (y * y) + (z * z));

        if (rad + sphere.radiusWorld < distance)
            return false;

        return true;
    }
	public static function intersects(sphere0:BoundingSphere, sphere1:BoundingSphere):Bool {
        var x = sphere0.centerWorld.x - sphere1.centerWorld.x;
        var y = sphere0.centerWorld.y - sphere1.centerWorld.y;
        var z = sphere0.centerWorld.z - sphere1.centerWorld.z;

        var distance = Math.sqrt((x * x) + (y * y) + (z * z));

        if (sphere0.radiusWorld + sphere1.radiusWorld < distance)
            return false;

        return true;
    }
	
}
