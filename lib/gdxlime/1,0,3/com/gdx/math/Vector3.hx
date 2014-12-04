package com.gdx.math;
import haxe.ds.Vector;
import lime.utils.Float32Array;


/**
 * @author djoker
 */

 typedef VectorMinMax = {
	minimum: Vector3,
	maximum: Vector3
}

class Vector3 {
	
	static public var v:Vector3 = new Vector3(0, 0, 0);
	static public var v0:Vector3 = new Vector3(0, 0, 0);
	static public var v1:Vector3 = new Vector3(0, 0, 0);
	static public var v2:Vector3 = new Vector3(0, 0, 0);
	
	static public var zero(get_zero, null):Vector3;	static private function get_zero():Vector3 { return new Vector3(0, 0, 0); }
	static public var axisX(get_axisX, null):Vector3;	static private function get_axisX():Vector3 { return new Vector3(1, 0, 0); }
	static public var axisY(get_axisY, null):Vector3;	static private function get_axisY():Vector3 { return new Vector3(0, 1, 0); }
	static public var axisZ(get_axisZ, null):Vector3;	static private function get_axisZ():Vector3 { return new Vector3(0, 0, 1); }
	

	static public var one(get_one, null):Vector3;
	static private function get_one():Vector3 { return new Vector3(1, 1, 1); }
	static public var right(get_right, null):Vector3;
	static private function get_right():Vector3 { return new Vector3(1, 0, 0); }
	static public var up(get_up, null):Vector3;
	static private function get_up():Vector3 { return new Vector3(0, 1, 0); }
	static public var forward(get_forward, null):Vector3;
	static private function get_forward():Vector3 { return new Vector3(0, 0, 1); }
	public var x:Float;
	public var y:Float;
	public var z:Float;
	

	
	public static inline function ExtractMinAndMax(positions:Array<Float>, start:Int, count:Int):VectorMinMax {
      
		var minimum:Vector3 = new Vector3(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY);
       var maximum:Vector3 = new Vector3(Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY);

  //  var minimum:Vector3 = new Vector3(999999, 999999, 999999);
   // var maximum:Vector3 = new Vector3(-999999, -999999, -999999);

	for (index in start...start + count) {
            var current = new Vector3(positions[index * 3], positions[index * 3 + 1], positions[index * 3 + 2]);

            minimum = Vector3.Minimize(current, minimum);
            maximum = Vector3.Maximize(current, maximum);
        }

	
		
        return {
            minimum: minimum,
            maximum: maximum
        };
    }
	
	public function new(initialX:Float=0, initialY:Float=0, initialZ:Float=0) {
		this.x = initialX;
		this.y = initialY;
		this.z = initialZ;
	}
	public function set(initialX:Float, initialY:Float, initialZ:Float):Vector3 {
		this.x = initialX;
		this.y = initialY;
		this.z = initialZ;
		return this;
	}

	public function get(index:Int):Float
	{
		
		switch (index)
		{
		case 0:return x;
		case 1:return y;
		case 2:return z;
	    }
		return -1;
	}
	public function setBy(index:Int,v:Float):Void
	{
		
		switch (index)
		{
		case 0:x = v;
		case 1:y = v;
		case 2:z = v;
	    }
	}
	public function toString():String {
		return "{X:" + this.x + " Y:" + this.y + " Z:" + this.z + "}";
	}
	
		public function toVectorString():String {
        return x + "," + y +","+z;
    }
	
	inline public function asArray():Array<Float> {
        var result = [];
        this.toArray(result, 0);
        return result;
    }
	
	inline public function toArray(array:Array<Float>, index:Int = 0):Array<Float> {
		array[index] = this.x;
        array[index + 1] = this.y;
        array[index + 2] = this.z;
		return array;
	}

	inline public function addInPlace(otherVector:Vector3) {
		this.x += otherVector.x;
		this.y += otherVector.y;
		this.z += otherVector.z;
	}
	
	inline public function add(otherVector:Vector3):Vector3 {
		return new Vector3(this.x + otherVector.x, this.y + otherVector.y, this.z + otherVector.z);
	}
	
	inline public function addToRef(otherVector:Vector3, result:Vector3):Vector3 {
		result.x = this.x + otherVector.x;
        result.y = this.y + otherVector.y;
        result.z = this.z + otherVector.z;
		return result;
	}
	
	inline public function subtractInPlace(otherVector:Vector3) {
		this.x -= otherVector.x;
		this.y -= otherVector.y;
		this.z -= otherVector.z;
	}
	
	inline public function subtract(otherVector:Vector3):Vector3 {
		return new Vector3(this.x - otherVector.x, this.y - otherVector.y, this.z - otherVector.z);
	}
	
	inline public function setLength(l:Float):Void 
	{
		var len:Float = Math.sqrt(x * x + y * y + z * z);
	    x *= l / len;
	    y *= l / len;
	    z *= l / len;
	}
	
	

    inline public static function Mult(v:Vector3, d:Float):Vector3 
	{
		return new Vector3(  v.x * d, 
		                     v.y * d, 
							 v.z * d);
	}
	


	inline public static function Sub(a:Vector3, b:Vector3):Vector3 
	{
		return new Vector3(a.x - b.x, 
		                   a.y - b.y, 
						   a.z - b.z);
	}
	inline public static function Add(a:Vector3, b:Vector3):Vector3 
	{
		return new Vector3(a.x + b.x,
		                   a.y + b.y, 
						   a.z + b.z);
	}
	inline public static function Length(v:Vector3):Float 
	{
		return Math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
	}
	inline public static function Magnitude(v:Vector3):Float 
	{
		return Math.sqrt((v.x * v.x) + (v.y * v.y) + (v.z * v.z));
	}
	inline public static function angle(v1:Vector3, v2:Vector3):Float 
	{
				return Util.ArcCos(Vector3.Dot(Vector3.Normalize(v1), Vector3.Normalize(v2)));
	}


	inline public static function SameSide(p1:Vector3, p2:Vector3,a:Vector3,b:Vector3):Bool 
	{
		  

			
		var cp1:Vector3=Vector3.Cross(Vector3.Sub(b, a), Vector3.Sub(p1, a));
		var cp2:Vector3=Vector3.Cross(Vector3.Sub(b, a), Vector3.Sub(p2, a));
		if (Vector3.Dot(cp1, cp2) >= 0)
		{
			return true;
		} else
		{
			return false;
		}
		
				
	}
	inline public function subtractToRef(otherVector:Vector3, result:Vector3) {
		result.x = this.x - otherVector.x;
        result.y = this.y - otherVector.y;
        result.z = this.z - otherVector.z;
	}
	
	inline public function subtractFromFloats(x:Float, y:Float, z:Float):Vector3 {
		return new Vector3(this.x - x, this.y - y, this.z - z);
	}
	
	inline public function subtractFromFloatsToRef(x:Float, y:Float, z:Float, result:Vector3) {
		result.x = this.x - x;
        result.y = this.y - y;
        result.z = this.z - z;
	}
	
	inline public function negate():Vector3 {
		return new Vector3( -this.x, -this.y, -this.z);
	}
	
	inline public function scaleInPlace(scale:Float) {
		this.x *= scale;
        this.y *= scale;
        this.z *= scale;
	}
	
	inline public function scale(scale:Float):Vector3 
	{
		return new Vector3(this.x * scale, this.y * scale, this.z * scale);
	}


	inline public function scaleToRef(scale:Float, result:Vector3) {
		result.x = this.x * scale;
        result.y = this.y * scale;
        result.z = this.z * scale;
	}
	
	inline public function equals(otherVector:Vector3):Bool 
	{
		return this.x == otherVector.x && this.y == otherVector.y && this.z == otherVector.z;
	}
	inline public function equalsWithEpsilon(otherVector:Vector3):Bool 
	{
		var Epsilon:Float = 0.001;
		return Math.abs(this.x - otherVector.x) < Epsilon && Math.abs(this.y - otherVector.y) < Epsilon && Math.abs(this.z - otherVector.z) < Epsilon;
	}
	

		
	inline public function equalsToFloats(x:Float, y:Float, z:Float):Bool {
		return this.x == x && this.y == y && this.z == z;
	}
	
	inline public function multiplyInPlace(otherVector:Vector3) {
		this.x *= otherVector.x;
        this.y *= otherVector.y;
        this.z *= otherVector.z;
	}

	inline public function multiplyBy(f:Float):Void 
	{
		this.x *= f;
		this.y *= f;
		this.z *= f;
	}
	inline public function multiply(otherVector:Vector3):Vector3 {
		return new Vector3(this.x * otherVector.x, this.y * otherVector.y, this.z * otherVector.z);
	}
	
	inline public function multiplyToRef(otherVector:Vector3, result:Vector3) {
		result.x = this.x * otherVector.x;
        result.y = this.y * otherVector.y;
        result.z = this.z * otherVector.z;
	}
	
	inline public function multiplyByFloats(x:Float, y:Float, z:Float):Vector3 {
		return new Vector3(this.x * x, this.y * y, this.z * z);
	}
	
	inline public function divideby(otherVector:Vector3):Void
	{
		this.x /= otherVector.x;
		this.y /= otherVector.y;
		this.z /= otherVector.z;
		
	}
	
	inline public function divide(otherVector:Vector3):Vector3 {
		return new Vector3(this.x / otherVector.x, this.y / otherVector.y, this.z / otherVector.z);
	}
	
	inline public function divideToRef(otherVector:Vector3, result:Vector3) {
		result.x = this.x / otherVector.x;
        result.y = this.y / otherVector.y;
        result.z = this.z / otherVector.z;
	}
	
	inline public function length():Float {
		return Math.sqrt(this.x * this.x + this.y * this.y + this.z * this.z);
	}
	
	inline public function lengthSquared():Float {
		return (this.x * this.x + this.y * this.y + this.z * this.z);
	}
	
	inline public function normalize() :Void
	{
		var len = this.length();

        if (len != 0) {
			var num = 1.0 / len;

			this.x *= num;
			this.y *= num;
			this.z *= num;
		}
	}
	
	inline public function clone():Vector3 {
		return new Vector3(this.x, this.y, this.z);
	}

	inline public function copy(source:Vector3) {
		this.x = source.x;
        this.y = source.y;
        this.z = source.z;
	}		
	inline public function copyFrom(source:Vector3) {
		this.x = source.x;
        this.y = source.y;
        this.z = source.z;
	}
	
	inline public function copyFromFloats(x:Float, y:Float, z:Float) {
		this.x = x;
        this.y = y;
        this.z = z;
	}
	

	inline public static function FromArray(array:Array<Float>, offset:Int = 0) {
        return new Vector3(array[offset], array[offset + 1], array[offset + 2]);
	}
	
	inline public static function FromArrayToRef(array:Float32Array  , offset:Int = 0, result:Vector3) {
		result.x = array[offset];
        result.y = array[offset + 1];
        result.z = array[offset + 2];
	}
	
	inline public static function FromFloatsToRef(x:Float, y:Float, z:Float, result:Vector3) {
		result.x = x;
        result.y = y;
        result.z = z;
	}
	public static function One():Vector3 {
		return new Vector3(1.0, 1.0, 1.0);
	}
	public static function Zero():Vector3 {
		return new Vector3(0.0, 0.0, 0.0);
	}
	
	public static function Up():Vector3 {
		return new Vector3(0, 1.0, 0);
	}
	
	   inline public static function TransformByQuaternion(value:Vector3, rotation: Quaternion):Vector3
	   {
            var x:Float = 2 * (rotation.y * value.z - rotation.z * value.y);
            var y:Float = 2 * (rotation.z * value.x - rotation.x * value.z);
            var z:Float = 2 * (rotation.x * value.y - rotation.y * value.x);

			var result:Vector3 = new Vector3();
            result.x = value.x + x * rotation.w + (rotation.y * z - rotation.z * y);
            result.y = value.y + y * rotation.w + (rotation.z * x - rotation.x * z);
            result.z = value.z + z * rotation.w + (rotation.x * y - rotation.y * x);
			return result;
        }
		
	inline public static function GetMinMax(min:Vector3, max:Vector3,vec:Vector3):Void 
	{
		

  if (min.x >vec.x)  min.x =vec.x;
  if (min.y > vec.y)  min.y = vec.y;
  if (min.z > vec.z)  min.z = vec.z;

  if (max.x < vec.x)  max.x = vec.x;
  if (max.y < vec.y)  max.y = vec.y;
  if (max.z < vec.z)  max.z = vec.z;
    
        
	}
	
	inline public static function TransformCoordinates(vector:Vector3, transformation:Matrix4):Vector3 {
		var result = Vector3.Zero();

        Vector3.TransformCoordinatesToRef(vector, transformation, result);

        return result;
	}
	inline public static function TransformCoordinatesToRef(vector:Vector3, transformation:Matrix4, result:Vector3) 
	{
		var x = (vector.x * transformation.m[0]) + (vector.y * transformation.m[4]) + (vector.z * transformation.m[8]) + transformation.m[12];
        var y = (vector.x * transformation.m[1]) + (vector.y * transformation.m[5]) + (vector.z * transformation.m[9]) + transformation.m[13];
        var z = (vector.x * transformation.m[2]) + (vector.y * transformation.m[6]) + (vector.z * transformation.m[10]) + transformation.m[14];
        var w = (vector.x * transformation.m[3]) + (vector.y * transformation.m[7]) + (vector.z * transformation.m[11]) + transformation.m[15];

        result.x = x / w;
        result.y = y / w;
        result.z = z / w;
	}
	
	inline public static function TransformCoordinatesFromFloatsToRef(x:Float, y:Float, z:Float, transformation:Matrix4, result:Vector3):Vector3 {
		var rx = (x * transformation.m[0]) + (y * transformation.m[4]) + (z * transformation.m[8]) + transformation.m[12];
        var ry = (x * transformation.m[1]) + (y * transformation.m[5]) + (z * transformation.m[9]) + transformation.m[13];
        var rz = (x * transformation.m[2]) + (y * transformation.m[6]) + (z * transformation.m[10]) + transformation.m[14];
        var rw = (x * transformation.m[3]) + (y * transformation.m[7]) + (z * transformation.m[11]) + transformation.m[15];

        result.x = rx / rw;
        result.y = ry / rw;
        result.z = rz / rw;
		
		return result;
	}
	
	inline public static function TransformNormal(vector:Vector3, transformation:Matrix4):Vector3 {
		var result = Vector3.Zero();

        Vector3.TransformNormalToRef(vector, transformation, result);

        return result;
	}
	
	inline public static function TransformNormalToRef(vector:Vector3, transformation:Matrix4, result:Vector3) {
		result.x = (vector.x * transformation.m[0]) + (vector.y * transformation.m[4]) + (vector.z * transformation.m[8]);
        result.y = (vector.x * transformation.m[1]) + (vector.y * transformation.m[5]) + (vector.z * transformation.m[9]);
        result.z = (vector.x * transformation.m[2]) + (vector.y * transformation.m[6]) + (vector.z * transformation.m[10]);
	}
	
	inline public static function TransformNormalFromFloatsToRef(x:Float, y:Float, z:Float, transformation:Matrix4, result:Vector3) {
		result.x = (x * transformation.m[0]) + (y * transformation.m[4]) + (z * transformation.m[8]);
        result.y = (x * transformation.m[1]) + (y * transformation.m[5]) + (z * transformation.m[9]);
        result.z = (x * transformation.m[2]) + (y * transformation.m[6]) + (z * transformation.m[10]);
	}
	

	inline public static function CatmullRom(value1:Vector3, value2:Vector3, value3:Vector3, value4:Vector3, amount:Float):Vector3 {
		var squared = amount * amount;
        var cubed = amount * squared;

        var x = 0.5 * ((((2.0 * value2.x) + ((-value1.x + value3.x) * amount)) +
                (((((2.0 * value1.x) - (5.0 * value2.x)) + (4.0 * value3.x)) - value4.x) * squared)) +
            ((((-value1.x + (3.0 * value2.x)) - (3.0 * value3.x)) + value4.x) * cubed));

        var y = 0.5 * ((((2.0 * value2.y) + ((-value1.y + value3.y) * amount)) +
                (((((2.0 * value1.y) - (5.0 * value2.y)) + (4.0 * value3.y)) - value4.y) * squared)) +
            ((((-value1.y + (3.0 * value2.y)) - (3.0 * value3.y)) + value4.y) * cubed));

        var z = 0.5 * ((((2.0 * value2.z) + ((-value1.z + value3.z) * amount)) +
                (((((2.0 * value1.z) - (5.0 * value2.z)) + (4.0 * value3.z)) - value4.z) * squared)) +
            ((((-value1.z + (3.0 * value2.z)) - (3.0 * value3.z)) + value4.z) * cubed));

        return new Vector3(x, y, z);
	}
	
	inline public static function random( min:Vector3, max:Vector3):Vector3 {
	
		return new Vector3(
		Util.randf(min.x, max.x),
		Util.randf(min.y, max.y),
		Util.randf(min.z, max.z));
	}
	inline public static function Clamp(value:Vector3, min:Vector3, max:Vector3):Vector3 {
		var x = value.x;
        x = (x > max.x) ? max.x : x;
        x = (x < min.x) ? min.x : x;

        var y = value.y;
        y = (y > max.y) ? max.y : y;
        y = (y < min.y) ? min.y : y;

        var z = value.z;
        z = (z > max.z) ? max.z : z;
        z = (z < min.z) ? min.z : z;

        return new Vector3(x, y, z);
	}
	
	inline public static function Hermite(value1:Vector3, tangent1:Vector3, value2:Vector3, tangent2:Vector3, amount:Float):Vector3 {
		var squared = amount * amount;
        var cubed = amount * squared;
        var part1 = ((2.0 * cubed) - (3.0 * squared)) + 1.0;
        var part2 = (-2.0 * cubed) + (3.0 * squared);
        var part3 = (cubed - (2.0 * squared)) + amount;
        var part4 = cubed - squared;

        var x = (((value1.x * part1) + (value2.x * part2)) + (tangent1.x * part3)) + (tangent2.x * part4);
        var y = (((value1.y * part1) + (value2.y * part2)) + (tangent1.y * part3)) + (tangent2.y * part4);
        var z = (((value1.z * part1) + (value2.z * part2)) + (tangent1.z * part3)) + (tangent2.z * part4);

        return new Vector3(x, y, z);
	}
	
	inline public static function Lerp(start:Vector3, end:Vector3, amount:Float):Vector3 {
		var x = start.x + ((end.x - start.x) * amount);
        var y = start.y + ((end.y - start.y) * amount);
        var z = start.z + ((end.z - start.z) * amount);

        return new Vector3(x, y, z);
	}

	inline public  function DotProduct( other:Vector3):Float 
	{
		return (x * other.x + y * other.y + z * other.z);
	}
	
	inline public static function Dot(left:Vector3, right:Vector3):Float 
	{
		return (left.x * right.x + left.y * right.y + left.z * right.z);
	}
	
	inline public static function Cross(left:Vector3, right:Vector3):Vector3 {
		var result = Vector3.Zero();
        Vector3.CrossToRef(left, right, result);
        return result;
	}
	
	inline public static function CrossToRef(left:Vector3, right:Vector3, result:Vector3) {
		result.x = left.y * right.z - left.z * right.y;
        result.y = left.z * right.x - left.x * right.z;
        result.z = left.x * right.y - left.y * right.x;
	}
	
	inline public static function Normalize(vector:Vector3):Vector3 {
		var result = Vector3.Zero();
        Vector3.NormalizeToRef(vector, result);
        return result;
	}
	
	inline public static function NormalizeToRef(vector:Vector3, result:Vector3) {
		result.copyFrom(vector);
        result.normalize();
	}
	
	inline public static function Project(vector:Vector3, world:Matrix4, transform:Matrix4, viewport:Rectangle):Vector3 {
		var cw = viewport.width;
        var ch = viewport.height;
        var cx = viewport.x;
        var cy = viewport.y;

        var viewportMatrix = Matrix4.FromValues(
										cw / 2.0, 0, 0, 0,
									    0, -ch / 2.0, 0, 0,
										0, 0, 1, 0,
										cx + cw / 2.0, ch / 2.0 + cy, 0, 1);
        
        var finalMatrix = world.multiply(transform).multiply(viewportMatrix);

        return Vector3.TransformCoordinates(vector, finalMatrix);
	}

	
	inline public static function Unproject(source:Vector3, viewportWidth:Float, viewportHeight:Float, world:Matrix4, view:Matrix4, projection:Matrix4):Vector3 {
		var matrix = world.multiply(view).multiply(projection);
        matrix.invert();
        source.x = source.x / viewportWidth * 2 - 1;
        source.y = -(source.y / viewportHeight * 2 - 1);
        var vector = Vector3.TransformCoordinates(source, matrix);
        var num = source.x * matrix.m[3] + source.y * matrix.m[7] + source.z * matrix.m[11] + matrix.m[15];

        if (Util.WithinEpsilon(num, 1.0)) {
            vector = vector.scale(1.0 / num);
        }

        return vector;
	}	
inline public static function UnprojectVector(source:Vector3, viewportWidth:Float, viewportHeight:Float, view:Matrix4, projection:Matrix4):Vector3 
{
		var matrix = view.multiply(projection);
        matrix.invert();
        source.x = source.x / viewportWidth * 2 - 1;
        source.y = -(source.y / viewportHeight * 2 - 1);
        var vector = Vector3.TransformCoordinates(source, matrix);
        var num = source.x * matrix.m[3] + source.y * matrix.m[7] + source.z * matrix.m[11] + matrix.m[15];

        if (Util.WithinEpsilon(num, 1.0)) {
            vector = vector.scale(1.0 / num);
        }

        return vector;
	}	
	
	inline public static function Minimize(left:Vector3, right:Vector3):Vector3 {
		var x = (left.x < right.x) ? left.x : right.x;
        var y = (left.y < right.y) ? left.y : right.y;
        var z = (left.z < right.z) ? left.z : right.z;
        return new Vector3(x, y, z);
	}
	
	inline public static function Maximize(left:Vector3, right:Vector3):Vector3 {
		var x = (left.x > right.x) ? left.x : right.x;
        var y = (left.y > right.y) ? left.y : right.y;
        var z = (left.z > right.z) ? left.z : right.z;
        return new Vector3(x, y, z);
	}
	
	inline public static function Distance(value1:Vector3, value2:Vector3):Float {
		return Math.sqrt(Vector3.DistanceSquared(value1, value2));
	}
	
	inline public static function DistanceSquared(value1:Vector3, value2:Vector3):Float {
		var x = value1.x - value2.x;
        var y = value1.y - value2.y;
        var z = value1.z - value2.z;

        return (x * x) + (y * y) + (z * z);
	}
	
	inline public static function ScaleBy(v1:Vector3,v2:Vector3):Vector3
	{
		return new Vector3(v1.x * v2.x, v1.y * v2.y, v1.z * v2.z);
	}
	inline public static function DivideBy(v1:Vector3,v2:Vector3):Vector3
	{
		return new Vector3(v1.x / v2.x, v1.y / v2.y, v1.z / v2.z);
	}
	
	inline public  function getHorizontalAngle(angle:Vector3):Vector3
	{
			if (angle == null)
			{
				angle = Vector3.zero;
			}
			

			angle.y = ((Math.atan2(x, z) * Util.Rad2Deg));

			if (angle.y < 0.0)
				angle.y += 360.0;
			if (angle.y >= 360.0)
				angle.y -= 360.0;

			var z1:Float = Math.sqrt(x*x + z*z);

			angle.x = (Math.atan2(z1, y) *Util.Rad2Deg - 90.0);

			if (angle.x < 0.0)
				angle.x += 360.0;
			if (angle.x >= 360.0)
				angle.x -= 360.0;

			return angle;
		}
	inline public  function rotateXYBy(degrees:Float, center:Vector3):Void
	{
		var cs:Float = Math.cos(Util.deg2rad(degrees));
		var sn:Float = Math.sin(Util.deg2rad(degrees));
		x -= center.x;
		y -= center.y;
		set((x * cs - y * sn), (x * sn +y * cs), z);
		x += center.x;
		y += center.y;	
		
	}
	inline public  function rotateXZBy(degrees:Float, center:Vector3):Void
	{
		var cs:Float = Math.cos(Util.deg2rad(degrees));
		var sn:Float = Math.sin(Util.deg2rad(degrees));
		x -= center.x;
		z -= center.z;
		set((x * cs - z * sn),y, (x * sn + z * cs));
		x += center.x;
		z += center.z;	
		
	}
	inline public  function rotateYZBy(degrees:Float, center:Vector3):Void
	{
		var cs:Float = Math.cos(Util.deg2rad(degrees));
		var sn:Float = Math.sin(Util.deg2rad(degrees));
		z -= center.z;
		y -= center.y;
		set(x,(y * cs - z * sn), (y * sn + z * cs));
		z += center.z;
		y += center.y;	
		
	}
	
	
	public static function getNorm( v:Vector3 ):Float
		{
			return Math.sqrt( v.x*v.x + v.y*v.y + v.z*v.z );
		}
		public static function divEquals(v:Vector3,s:Float):Vector3 {
			if (s == 0) s = 0.0001;
			return new Vector3(	v.x / s ,
								v.y  / s ,
								v.z / s );
		}
		public static function divEqualsTo(v:Vector3,s:Vector3):Vector3 {
			return new Vector3(	v.x / s.x ,
								v.y  / s.y ,
								v.z / s.z );
		}	
	
	public static function getAngleWeight(v1:Vector3, v2:Vector3,v3:Vector3):Vector3 {

	// Calculate this triangle's weight for each of its three vertices
	// start by calculating the lengths of its sides
	var a = Vector3.DistanceSquared(v2,v3);
	var asqrt = Math.sqrt(a);
	var b = Vector3.DistanceSquared(v1,v3);
	var bsqrt = Math.sqrt(b);
	var c = Vector3.DistanceSquared(v1,v2);
	var csqrt = Math.sqrt(c);

	// use them to find the angle at each vertex
	return new Vector3(
		Math.acos((b + c - a) / (2.0 * bsqrt * csqrt)),
		Math.acos((-b + c + a) / (2.0 * asqrt * csqrt)),
		Math.acos((b - c + a) / (2.0 * bsqrt * asqrt)));
}

public static function PlaneDistance( Normal:Vector3, Point:Vector3):Float
{	
return  - ((Normal.x * Point.x) + (Normal.y * Point.y) + (Normal.z * Point.z));
}
public static function PlaneDistanceN( Normal:Vector3, Point:Vector3):Float
{	
return   ((Normal.x * Point.x) + (Normal.y * Point.y) + (Normal.z * Point.z));
}

	public static function IntersectedPlane(vPoly:Array<Vector3>, vLine0:Vector3, vLine1:Vector3, vNormal:Vector3, originDistance:Float):Bool
	
{
	var distance1:Float = 0; 
	var distance2:Float=0;						// The distances from the 2 points of the line from the plane
			
	vNormal = Vector3.PolyNormal(vPoly);							// We need to get the normal of our plane to go any further

	// Let's find the distance our plane is from the origin.  We can find this value
	// from the normal to the plane (polygon) and any point that lies on that plane (Any vertex)
	originDistance = Vector3.PlaneDistance(vNormal, vPoly[0]);

	// Get the distance from point1 from the plane using: Ax + By + Cz + D = (The distance from the plane)

	distance1 = ((vNormal.x * vLine0.x)  +					// Ax +
		         (vNormal.y * vLine0.y)  +					// Bx +
				 (vNormal.z * vLine0.z)) + originDistance;	// Cz + D
	
	// Get the distance from point2 from the plane using Ax + By + Cz + D = (The distance from the plane)
	
	distance2 = ((vNormal.x * vLine1.x)  +					// Ax +
		         (vNormal.y * vLine1.y)  +					// Bx +
				 (vNormal.z * vLine1.z)) + originDistance;	// Cz + D

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
	public static function AngleBetweenVectors( V1:Vector3,  V2:Vector3):Float
    {							
	var dotProduct:Float = Vector3.Dot(V1, V2);
	var vectorsMagnitude:Float = Vector3.Magnitude(V1) * Vector3.Magnitude(V2) ;

	// Get the angle in radians between the 2 vectors
	var angle:Float = Math.acos( dotProduct / vectorsMagnitude );

	// Here we make sure that the angle is not a -1.#IND0000000 number, which means indefinate
	if (Math.isNaN(angle)) return 0;
	//if(_isnan(angle))
		//return 0;
	
	// Return the angle in radians
	return angle ;
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
public static function InsidePolygon(vIntersection:Vector3,vPoly:Array<Vector3>,verticeCount:Int):Bool
{
	var MATCH_FACTOR:Float = 0.99;		// Used to cover up the error in floating point
	var Angle:Float = 0.0;						// Initialize the angle
	var vA:Vector3;
	var vB:Vector3;						// Create temp vectors
	
	for (i in 0...verticeCount)
	{
		vA = Vector3.Sub( vPoly[i] , vIntersection);
		vB = Vector3.Sub( vPoly[(i+1)% verticeCount] , vIntersection);
												
		Angle += AngleBetweenVectors(vA, vB);	// Find the angle between the 2 vectors and add them all up as we go along
	}
	
	if(Angle >= (MATCH_FACTOR * (2.0 * Math.PI)) )	// If the angle is greater than 2 PI, (360 degrees)
		return true;							// The point is inside of the polygon
		
	return false;								// If you get here, it obviously wasn't inside the polygon, so Return FALSE
}

public static function IntersectedPolygon(vPoly:Array<Vector3>,verticeCount:Int, vLine0:Vector3, vLine1:Vector3):Bool
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
	if(InsidePolygon(vIntersection, vPoly,verticeCount))
		return true;							// We collided!	  Return success

	return false;								// There was no collision, so return false
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

public static function EdgeSphereCollision(vCenter:Vector3,vPolygon:Array<Vector3>,verticeCount:Int,radius:Float):Bool
{
	
	for (i in 0...verticeCount)
	{
		var vPoint:Vector3 = Vector3.ClosestPointOnLine(vPolygon[i],vPolygon[(i+1)%verticeCount], vCenter);
		var distance:Float=Vector3.Distance(vPoint, vCenter);
		if (distance < radius)
		{
			return true;
	   }
	}
	return false;
}

public static function TriangleNormal(vPolygon1:Vector3,vPolygon2:Vector3,vPolygon3:Vector3):Vector3					
{
	var a:Vector3 = Vector3.Sub(vPolygon3 , vPolygon1);
	var b:Vector3 = Vector3.Sub(vPolygon2 , vPolygon1);
	var vNormal:Vector3 = Vector3.Cross(a, b);		
    vNormal = Vector3.Normalize(vNormal);	
	return vNormal;						
	
}

public static function PolyNormal(vPolygon:Array<Vector3>):Vector3					
{
	// Get 2 vectors from the polygon (2 sides), Remember the order!
	var vVector1:Vector3 = Vector3.Sub(vPolygon[2] , vPolygon[0]);
	var vVector2:Vector3 = Vector3.Sub(vPolygon[1] , vPolygon[0]);
	

		
	 // var p1p2 = p1.subtract(p2);
     // var p3p2 = p3.subtract(p2);

	var vNormal:Vector3 = Vector3.Cross(vVector1, vVector2);		
	// Take the cross product of our 2 vectors to get a perpendicular vector

	// Now we have a normal, but it's at a strange length, so let's make it length 1.

	vNormal = Vector3.Normalize(vNormal);						
	// Use our function we created to normalize the normal (Makes it a length of one)

	return vNormal;						
	// Return our normal at our desired length
}

public static function SpherePolygonCollision(vCenter:Vector3,vPolygon:Array<Vector3>,verticeCount:Int,radius:Float):Bool
{
	// 1) STEP ONE - Finding the sphere's classification
	
	// Let's use our Normal() function to return us the normal to this polygon
	var vNormal:Vector3=Vector3.PolyNormal(vPolygon);

	// This will store the distance our sphere is from the plane
	var distance:Float = 0.0;

	// This is where we determine if the sphere is in FRONT, BEHIND, or INTERSECTS the plane
	var classification:Int = ClassifySphere(vCenter, vNormal, vPolygon[0], radius, distance);

	// If the sphere intersects the polygon's plane, then we need to check further
	if(classification == 1) 
	{
		// 2) STEP TWO - Finding the psuedo intersection point on the plane

		// Now we want to project the sphere's center onto the polygon's plane
		var vOffset:Vector3 = Vector3.Mult( vNormal , distance);
		
		vCenter.addInPlace(vOffset);

		// Once we have the offset to the plane, we just subtract it from the center
		// of the sphere.  "vPosition" now a point that lies on the plane of the polygon.
		var vPosition:Vector3 = Vector3.Sub(vCenter , vOffset);

		// 3) STEP THREE - Check if the intersection point is inside the polygons perimeter

		// If the intersection point is inside the perimeter of the polygon, it returns true.
		// We pass in the intersection point, the list of vertices and vertex count of the poly.
		if(InsidePolygon(vPosition, vPolygon, 3))
			return true;	// We collided!
		else
		{
			// 4) STEP FOUR - Check the sphere intersects any of the polygon's edges

			// If we get here, we didn't find an intersection point in the perimeter.
			// We now need to check collision against the edges of the polygon.
			if(EdgeSphereCollision(vCenter, vPolygon, verticeCount, radius))
			{
				return true;	// We collided!
			}
		}
	}

	// If we get here, there is obviously no collision
	return false;
}

public static function GetCollisionOffset(vNormal:Vector3,  radius:Float, distance:Float):Vector3
{
	var vOffset:Vector3 = Vector3.Zero();
    if(distance > 0)
	{
		var distanceOver:Float = radius - distance;
		vOffset =Vector3.Mult(vNormal , distanceOver);
	}
	else // Else colliding from behind the polygon
	{
		var distanceOver:Float = radius + distance;
		vOffset =Vector3.Mult(vNormal , -distanceOver);
	}
	



	return vOffset;
}


}