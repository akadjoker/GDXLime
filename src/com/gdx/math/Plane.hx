package  com.gdx.math ;


/**
 * @author DJOKER
 */

class Plane {

	
	public var normal:Vector3;
	public var d:Float;

	public function new(a:Float, b:Float, c:Float, d:Float) {
		this.normal = new Vector3(a, b, c);
        this.d = d;
	}
	
	public function clone():Plane {
		return new Plane(this.normal.x, this.normal.y, this.normal.z, this.d);
	}

	inline public function normalize() {
		var norm = (Math.sqrt((this.normal.x * this.normal.x) + (this.normal.y * this.normal.y) + (this.normal.z * this.normal.z)));
        var magnitude:Float = 0;

        if (norm != 0) {
            magnitude = 1.0 / norm;
        }

        this.normal.x *= magnitude;
        this.normal.y *= magnitude;
        this.normal.z *= magnitude;

        this.d *= magnitude;
		}
		inline public function IntersectionWithRay(r:Ray, outIntersection:Vector3):Bool
		{
			
			var t:Float = -(
			normal.x * r.origin.x + 
			normal.y * r.origin.y + 
			normal.z * r.origin.z + d) /
			
			(normal.x * r.direction.x + 
			normal.y * r.direction.y + 
			normal.z * r.direction.z + d) ;
			
			outIntersection.x = r.origin.x + (r.direction.x * t);
			outIntersection.y = r.origin.y + (r.direction.y * t);
			outIntersection.z = r.origin.z + (r.direction.z * t);
			
		if (t <= 0.0)
		return false;
		else 
		return true;	

			
		
		}
	
	inline public function transform(transformation:Matrix4):Plane {
		var transposedMatrix = Matrix4.Transpose(transformation);
        var x = this.normal.x;
        var y = this.normal.y;
        var z = this.normal.z;
        var d = this.d;

        var normalX = (((x * transposedMatrix.m[0]) + (y * transposedMatrix.m[1])) + (z * transposedMatrix.m[2])) + (d * transposedMatrix.m[3]);
        var normalY = (((x * transposedMatrix.m[4]) + (y * transposedMatrix.m[5])) + (z * transposedMatrix.m[6])) + (d * transposedMatrix.m[7]);
        var normalZ = (((x * transposedMatrix.m[8]) + (y * transposedMatrix.m[9])) + (z * transposedMatrix.m[10])) + (d * transposedMatrix.m[11]);
        var finalD = (((x * transposedMatrix.m[12]) + (y * transposedMatrix.m[13])) + (z * transposedMatrix.m[14])) + (d * transposedMatrix.m[15]);

        return new Plane(normalX, normalY, normalZ, finalD);
	}
	inline public function classifyVertex(point:Vector3):Int
	{
		var d:Float = this.signedDistanceTo(point);
		
		if (d < -0.001) 
        return  1;
    else
        if (d > 0.001) 
            return -1;
        else
            return 0;
	}
	inline public function dotCoordinate(point:Vector3):Float {
		return ((((this.normal.x * point.x) + (this.normal.y * point.y)) + (this.normal.z * point.z)) + this.d);
	}
	
	inline public function copyFromPoints(point1:Vector3, point2:Vector3, point3:Vector3) {
		var x1 = point2.x - point1.x;
        var y1 = point2.y - point1.y;
        var z1 = point2.z - point1.z;
        var x2 = point3.x - point1.x;
        var y2 = point3.y - point1.y;
        var z2 = point3.z - point1.z;
        var yz = (y1 * z2) - (z1 * y2);
        var xz = (z1 * x2) - (x1 * z2);
        var xy = (x1 * y2) - (y1 * x2);
        var pyth = (Math.sqrt((yz * yz) + (xz * xz) + (xy * xy)));
        var invPyth;

        if (pyth != 0) {
            invPyth = 1.0 / pyth;
        }
        else {
            invPyth = 0;
        }

        this.normal.x = yz * invPyth;
        this.normal.y = xz * invPyth;
        this.normal.z = xy * invPyth;
        this.d = -((this.normal.x * point1.x) + (this.normal.y * point1.y) + (this.normal.z * point1.z));
	}
	
	inline public function isFrontFacingTo(direction:Vector3, epsilon:Float):Bool 
	{
		var dot = Vector3.Dot(this.normal, direction);

        return (dot <= epsilon);
	}
	
	inline public function DistanceTo(point:Vector3):Float {
		return normal.x*point.x + normal.y*point.y + normal.z*point.z + this.d;
	}
	inline public function signedDistanceTo(point:Vector3):Float {
		return Vector3.Dot(point, this.normal) + this.d;
	}

	inline public static function FromArray(array:Array<Float>):Plane {
		return new Plane(array[0], array[1], array[2], array[3]);
	}
	
	inline public static function setPlane(point1:Vector3, point2:Vector3, point3:Vector3):Plane 
	{
		var result = new Plane(0, 0, 0, 0);
	  var vVector1:Vector3 = Vector3.Sub(point2 , point1);
	  var vVector2:Vector3 = Vector3.Sub(point3 , point1);
      result.normal = Vector3.Cross(vVector1, vVector2);
	  result.normalize();
	  
	  result.d = -Vector3.Dot(point1, result.normal);
	
		
        return result;
	}
	
	
	
	inline public static function FromPoints(point1:Vector3, point2:Vector3, point3:Vector3):Plane {
		var result = new Plane(0, 0, 0, 0);
        result.copyFromPoints(point1, point2, point3);

        return result;
	}
	
	inline public static function FromPositionAndNormal(origin:Vector3, normal:Vector3):Plane {
		var result = new Plane(0, 0, 0, 0);
        normal.normalize();

        result.normal = normal;
        result.d = -(normal.x * origin.x + normal.y * origin.y + normal.z * origin.z);

        return result;
	}
	
	inline public static function SignedDistanceToPlaneFromPositionAndNormal(origin:Vector3, normal:Vector3, point:Vector3):Float {
		var d = -(normal.x * origin.x + normal.y * origin.y + normal.z * origin.z);

        return Vector3.Dot(point, normal) + d;
	}	
	public function toString():String
	{
		return normal.toString()+", d:" + d;
	}
}
