package com.gdx.math ;

/**
 * @author DJOKER
 */

class Quaternion {

	public var x:Float;		
	public var y:Float;
	public var z:Float;
	public var w:Float;

	public function toString():String {
		return "{X: " + this.x + " Y:" + this.y + " Z:" + this.z + " W:" + this.w + "}";
	}

	public function new(initialX:Float = 0, initialY:Float = 0, initialZ:Float = 0, initialW:Float = 0) {
		this.x = initialX;
        this.y = initialY;
        this.z = initialZ;
        this.w = initialW;
	}
    inline public static function Zero():Quaternion 
	{
		return new Quaternion();
	}
	inline public function equals(otherQuaternion:Quaternion):Bool {
		return this.x == otherQuaternion.x && this.y == otherQuaternion.y && this.z == otherQuaternion.z && this.w == otherQuaternion.w;
	}
	
	inline public function clone():Quaternion {
		return new Quaternion(this.x, this.y, this.z, this.w);
	}
	inline public function Inverse():Quaternion
		{
			var norm = this.w * this.w + this.x * this.x + this.y * this.y + this.z * this.z;
			if( norm > 0.0 )
			{
				var inverseNorm = 1.0 / norm;
				return new Quaternion( this.w * inverseNorm, -this.x * inverseNorm, -this.y * inverseNorm, -this.z * inverseNorm );
			}
			else
			{
				// return an invalid result to flag the error
				return Quaternion.Zero();
			}
		}
		
	inline public function copyFrom(other:Quaternion) {
		this.x = other.x;
        this.y = other.y;
        this.z = other.z;
        this.w = other.w;
	}

	inline public function dot( q:Quaternion):Float 
	{
        return w * q.w + x * q.x + y * q.y + z * q.z;
    }
	inline public function normal():Float 
	{
        return w * w + x * x + y * y + z * z;
    }
	
	
	
	inline public  function   fromAngleAxis( angle:Float, axis:Vector3) :Quaternion
	{
        axis.normalize();
	    fromAngleNormalAxis(angle, axis);
        return this;
    }
	inline public  function   fromAngleNormalAxis( angle:Float, axis:Vector3) :Quaternion
	{
        if (axis.x == 0 && axis.y == 0 && axis.z == 0) 
		{
            loadIdentity();
        } else {
             var halfAngle:Float = 0.5 * angle;
            var sin:Float = Math.sin(halfAngle);
            w = Math.cos(halfAngle);
            x = sin * axis.x;
            y = sin * axis.y;
            z = sin * axis.z;
        }
        return this;
    }
	 public function loadIdentity() :Void
	 {
        x = y = z = 0;
        w = 1;
    }
	inline public function add(other:Quaternion):Quaternion {
		return new Quaternion(this.x + other.x, this.y + other.y, this.z + other.z, this.w + other.w);
	}
	
	inline public function scale(value:Float):Quaternion {
		return new Quaternion(this.x * value, this.y * value, this.z * value, this.w * value);
	}
	
	inline public function multLeft(q:Quaternion):Void
	{
	    var newX = q.w * x + q.x * w + q.y * z - q.z * y;
		var newY = q.w * y + q.y * w + q.z * x - q.x * z;
		var newZ = q.w * z + q.z * w + q.x * y - q.y * x;
		var newW = q.w * w - q.x * x - q.y * y - q.z * z;
		x = newX;
		y = newY;
		z = newZ;
		w = newW;
	}
	
	inline public function multiply(q1:Quaternion):Quaternion {
		var result = new Quaternion(0, 0, 0, 1.0);
        this.multiplyToRef(q1, result);

        return result;
	}
	
	inline public function multiplyToRef(q1:Quaternion, result:Quaternion):Quaternion
	{
		result.x = this.x * q1.w + this.y * q1.z - this.z * q1.y + this.w * q1.x;
        result.y = -this.x * q1.z + this.y * q1.w + this.z * q1.x + this.w * q1.y;
        result.z = this.x * q1.y - this.y * q1.x + this.z * q1.w + this.w * q1.z;
        result.w = -this.x * q1.x - this.y * q1.y - this.z * q1.z + this.w * q1.w;
		
		return result;
	}
	
	inline public function length():Float {
		return Math.sqrt((this.x * this.x) + (this.y * this.y) + (this.z * this.z) + (this.w * this.w));
	}
	
	inline public function normalize() {
		var length = 1.0 / this.length();
        this.x *= length;
        this.y *= length;
        this.z *= length;
        this.w *= length;
	}
	
	inline public function toEulerAngles():Vector3 {
		var qx = this.x;
        var qy = this.y;
        var qz = this.z;
        var qw = this.w;

        var sqx = qx * qx;
        var sqy = qy * qy;
        var sqz = qz * qz;

        var yaw = Math.atan2(2.0 * (qy * qw - qx * qz), 1.0 - 2.0 * (sqy + sqz));
        var pitch = Math.asin(2.0 * (qx * qy + qz * qw));
        var roll = Math.atan2(2.0 * (qx * qw - qy * qz), 1.0 - 2.0 * (sqx + sqz));

        var gimbaLockTest = qx * qy + qz * qw;
        if (gimbaLockTest > 0.499) {
            yaw = 2.0 * Math.atan2(qx, qw);
            roll = 0;
        } else if (gimbaLockTest < -0.499) {
            yaw = -2.0 * Math.atan2(qx, qw);
            roll = 0;
        }

        return new Vector3(pitch, yaw, roll);
	}
	inline public  function toRotationMatrix3(result:Matrix3) :Matrix3
	{

		var xx = this.x * this.x;
        var yy = this.y * this.y;
        var zz = this.z * this.z;
        var xy = this.x * this.y;
        var zw = this.z * this.w;
        var zx = this.z * this.x;
        var yw = this.y * this.w;
        var yz = this.y * this.z;
        var xw = this.x * this.w;

        result.m[0] = 1.0 - (2.0 * (yy + zz));
        result.m[1] = 2.0 * (xy + zw);
        result.m[2] = 2.0 * (zx - yw);
       
		result.m[3] = 2.0 * (xy - zw);
        result.m[4] = 1.0 - (2.0 * (zz + xx));
        result.m[5] = 2.0 * (yz + xw);
        
		result.m[6] = 2.0 * (zx + yw);
        result.m[7] = 2.0 * (yz - xw);
        result.m[8] = 1.0 - (2.0 * (yy + xx));
        
		return result;
		/*
		    var rotation:Matrix3 = new Matrix3();
            var tx = 2.0 * this.x;
			var ty = 2.0 * this.y;
			var tz = 2.0 * this.z;
			var twx = tx * this.w;
			var twy = ty * this.w;
			var twz = tz * this.w;
			var txx = tx * this.x;
			var txy = ty * this.x;
			var txz = tz * this.x;
			var tyy = ty * this.y;
			var tyz = tz * this.y;
			var tzz = tz * this.z;

	        rotation.m[Matrix3.M00]= 1.0 - ( tyy + tzz );
			rotation.m[Matrix3.M01]= txy - twz;
			rotation.m[Matrix3.M02]= txz + twy;
			rotation.m[Matrix3.M10]= txy + twz;
			rotation.m[Matrix3.M11]= 1.0 - ( txx + tzz );
			rotation.m[Matrix3.M12]= tyz - twx;
			rotation.m[Matrix3.M20]= txz - twy;
			rotation.m[Matrix3.M21]= tyz + twx;
			rotation.m[Matrix3.M22]= 1.0 - ( txx + tyy );

        return rotation;
		*/
    }
	inline public function toRotationMatrix(result:Matrix4):Matrix4 
	{
		var xx = this.x * this.x;
        var yy = this.y * this.y;
        var zz = this.z * this.z;
        var xy = this.x * this.y;
        var zw = this.z * this.w;
        var zx = this.z * this.x;
        var yw = this.y * this.w;
        var yz = this.y * this.z;
        var xw = this.x * this.w;

        result.m[0] = 1.0 - (2.0 * (yy + zz));
        result.m[1] = 2.0 * (xy + zw);
        result.m[2] = 2.0 * (zx - yw);
        result.m[3] = 0;
        result.m[4] = 2.0 * (xy - zw);
        result.m[5] = 1.0 - (2.0 * (zz + xx));
        result.m[6] = 2.0 * (yz + xw);
        result.m[7] = 0;
        result.m[8] = 2.0 * (zx + yw);
        result.m[9] = 2.0 * (yz - xw);
        result.m[10] = 1.0 - (2.0 * (yy + xx));
        result.m[11] = 0;
        result.m[12] = 0;
        result.m[13] = 0;
        result.m[14] = 0;
        result.m[15] = 1.0;
		
		return result;
	}
	
inline public function toRotationMatrixTranslate(pos:Vector3,result:Matrix4):Matrix4 
	{
		var xx = this.x * this.x;
        var yy = this.y * this.y;
        var zz = this.z * this.z;
        var xy = this.x * this.y;
        var zw = this.z * this.w;
        var zx = this.z * this.x;
        var yw = this.y * this.w;
        var yz = this.y * this.z;
        var xw = this.x * this.w;

        result.m[0] = 1.0 - (2.0 * (yy + zz));
        result.m[1] = 2.0 * (xy + zw);
        result.m[2] = 2.0 * (zx - yw);
        result.m[3] = 0;
        result.m[4] = 2.0 * (xy - zw);
        result.m[5] = 1.0 - (2.0 * (zz + xx));
        result.m[6] = 2.0 * (yz + xw);
        result.m[7] = 0;
        result.m[8] = 2.0 * (zx + yw);
        result.m[9] = 2.0 * (yz - xw);
        result.m[10] = 1.0 - (2.0 * (yy + xx));
        result.m[11] = 0;
        result.m[12] = pos.x;
        result.m[13] = pos.y;
        result.m[14] = pos.z;
        result.m[15] = 1.0;
		
		return result;
	}

	inline public static function FromArray(array:Array<Float>, offset:Int = 0):Quaternion {
		return new Quaternion(array[offset], array[offset + 1], array[offset + 2], array[offset + 3]);
	}
	
	inline public static function RotationYawPitchRoll(yaw:Float, pitch:Float, roll:Float):Quaternion {
		var result = new Quaternion();
        Quaternion.RotationYawPitchRollToRef(yaw, pitch, roll, result);

        return result;
	}

	
		inline public  function RotationYawPitchRollTo(yaw:Float, pitch:Float, roll:Float):Void 
		{
		var halfRoll = roll * 0.5;
        var halfPitch = pitch * 0.5;
        var halfYaw = yaw * 0.5;

        var sinRoll = Math.sin(halfRoll);
        var cosRoll = Math.cos(halfRoll);
        var sinPitch = Math.sin(halfPitch);
        var cosPitch = Math.cos(halfPitch);
        var sinYaw = Math.sin(halfYaw);
        var cosYaw = Math.cos(halfYaw);

        x = (cosYaw * sinPitch * cosRoll) + (sinYaw * cosPitch * sinRoll);
        y = (sinYaw * cosPitch * cosRoll) - (cosYaw * sinPitch * sinRoll);
        z = (cosYaw * cosPitch * sinRoll) - (sinYaw * sinPitch * cosRoll);
        w = (cosYaw * cosPitch * cosRoll) + (sinYaw * sinPitch * sinRoll);
		
		
	}
	
	inline public static function RotationYawPitchRollToRef(yaw:Float, pitch:Float, roll:Float, result:Quaternion):Quaternion {
		var halfRoll = roll * 0.5;
        var halfPitch = pitch * 0.5;
        var halfYaw = yaw * 0.5;

        var sinRoll = Math.sin(halfRoll);
        var cosRoll = Math.cos(halfRoll);
        var sinPitch = Math.sin(halfPitch);
        var cosPitch = Math.cos(halfPitch);
        var sinYaw = Math.sin(halfYaw);
        var cosYaw = Math.cos(halfYaw);

        result.x = (cosYaw * sinPitch * cosRoll) + (sinYaw * cosPitch * sinRoll);
        result.y = (sinYaw * cosPitch * cosRoll) - (cosYaw * sinPitch * sinRoll);
        result.z = (cosYaw * cosPitch * sinRoll) - (sinYaw * sinPitch * cosRoll);
        result.w = (cosYaw * cosPitch * cosRoll) + (sinYaw * sinPitch * sinRoll);
		
		return result;
	}
	inline public static function Add(q1:Quaternion, q2:Quaternion):Quaternion 
	{
		var result:Quaternion = new Quaternion(q1.x + q2.x, q1.y + q2.y, q1.z + q2.z, q1.w + q2.w);
		return result;
	}
	inline public static function Sub(q1:Quaternion, q2:Quaternion):Quaternion 
	{
		var result:Quaternion = new Quaternion(q1.x - q2.x, q1.y - q2.y, q1.z - q2.z, q1.w - q2.w);
		return result;
	}
		inline public static function Mult(q:Quaternion,d:Float):Quaternion 
	{
		var result:Quaternion = new Quaternion(q.x *d, q.y *d, q.z *d, q.w *d);
		return result;
	}
	inline public static function Dot(q1:Quaternion, q2:Quaternion):Float 
	{
		return ((q1.x * q2.x) + (q1.y * q2.y) + (q1.z * q2.z) +  (q1.w + q2.w));
		
	}
	inline public static function Lerp(q1:Quaternion, q2:Quaternion, amount:Float):Quaternion 
	{
		if ( Dot(q1, q2) < 0)
		{
			return Sub(q1, Mult(Add(q2, q1), amount));
		} else
		{
			return Add(q1, Mult(Add(q2, q1), amount));
		}
	}
	inline public static function Slerp(left:Quaternion, right:Quaternion, amount:Float):Quaternion {
		var num2:Float;
        var num3:Float;
        var num = amount;
        var num4 = (((left.x * right.x) + (left.y * right.y)) + (left.z * right.z)) + (left.w * right.w);
        var flag = false;

        if (num4 < 0) {
            flag = true;
            num4 = -num4;
        }

        if (num4 > 0.999999) {
            num3 = 1 - num;
            num2 = flag ? -num : num;
        }
        else {
            var num5 = Math.acos(num4);
            var num6 = (1.0 / Math.sin(num5));
            num3 = (Math.sin((1.0 - num) * num5)) * num6;
            num2 = flag ? ((-Math.sin(num * num5)) * num6) : ((Math.sin(num * num5)) * num6);
        }

        return new Quaternion((num3 * left.x) + (num2 * right.x), (num3 * left.y) + (num2 * right.y), (num3 * left.z) + (num2 * right.z), (num3 * left.w) + (num2 * right.w));
	}
		
	
	
	inline public static function   CreateFromMatrix( pMatrix:Matrix4) :Quaternion
	{
		
		 var diagonal:Float = pMatrix.m[0] + pMatrix.m[5] + pMatrix.m[10] + 1;
	    var scale :Float= 0.0;
	
		var q:Quaternion= new Quaternion(0, 0, 0, 1);
		
		
		if(diagonal > 0.00000001)
	{
		// Calculate the scale of the diagonal
		scale = (Math.sqrt(diagonal ) * 2);

		// Calculate the x, y, x and w of the quaternion through the respective equation
		q.x = ( pMatrix.m[9] - pMatrix.m[6] ) / scale;
		q.y = ( pMatrix.m[2] - pMatrix.m[8] ) / scale;
		q.z = ( pMatrix.m[4] - pMatrix.m[1] ) / scale;
		q.w = 0.25 * scale;
	}
	else 
	{
		// If the first element of the diagonal is the greatest value
		if ( pMatrix.m[0] > pMatrix.m[5] && pMatrix.m[0] > pMatrix.m[10] )  
		{	
			// Find the scale according to the first element, and double that value
			scale  = Math.sqrt( 1.0 + pMatrix.m[0] - pMatrix.m[5] - pMatrix.m[10] ) * 2.0;

			// Calculate the x, y, x and w of the quaternion through the respective equation
			q.x = 0.25 * scale;
			q.y = (pMatrix.m[4] + pMatrix.m[1] ) / scale;
			q.z = (pMatrix.m[2] + pMatrix.m[8] ) / scale;
			q.w = (pMatrix.m[9] - pMatrix.m[6] ) / scale;	
		} 
		// Else if the second element of the diagonal is the greatest value
		else if ( pMatrix.m[5] > pMatrix.m[10] ) 
		{
			// Find the scale according to the second element, and double that value
			scale  = Math.sqrt( 1.0 + pMatrix.m[5] - pMatrix.m[0] - pMatrix.m[10] ) * 2.0;
			
			// Calculate the x, y, x and w of the quaternion through the respective equation
			q.x = (pMatrix.m[4] + pMatrix.m[1] ) / scale;
			q.y = 0.25 * scale;
		 	q.z = (pMatrix.m[9] + pMatrix.m[6] ) / scale;
			q.w = (pMatrix.m[2] - pMatrix.m[8] ) / scale;
		} 
		// Else the third element of the diagonal is the greatest value
		else 
		{	
			// Find the scale according to the third element, and double that value
			scale  = Math.sqrt( 1.0 + pMatrix.m[10] - pMatrix.m[0] - pMatrix.m[5] ) * 2.0;

			// Calculate the x, y, x and w of the quaternion through the respective equation
			q.x = (pMatrix.m[2] + pMatrix.m[8] ) / scale;
			q.y = (pMatrix.m[9] + pMatrix.m[6] ) / scale;
			q.z = 0.25 * scale;
			q.w = (pMatrix.m[4] - pMatrix.m[1] ) / scale;
		}
           
	}
        
        return q;
	}
	
	inline public static function   CreateFromAngleAxis( angle:Float, axis:Vector3) :Quaternion
	{
		var q:Quaternion= new Quaternion(0, 0, 0, 1);
		
            var halfAngle:Float = 0.5 * angle;
            var sin:Float = Math.sin(halfAngle);
            q.w = Math.cos(halfAngle);
            q.x = sin * axis.x;
            q.y = sin * axis.y;
            q.z = sin * axis.z;
        
        return q;
    }
}
