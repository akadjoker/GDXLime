package com.gdx.math ;

import lime.utils.Float32Array;


/**
 * @author djoker
 */

class Matrix3{

	public static inline var M00:Int = 0;
	public static inline var M01:Int = 3;
	public static inline var M02:Int = 6;
	public static inline var M10:Int = 1;
	public static inline var M11:Int = 4;
	public static inline var M12:Int = 7;
	public static inline var M20:Int = 2;
	public static inline var M21:Int = 5;
	public static inline var M22:Int = 8;

	
private static var __identity = [ 
1.0,
0.0,
0.0,
0.0,
1.0,
0.0,
0.0,
0.0,
1.0];

	public var m:Float32Array;
	public function new() 
	{
	this.m = new Float32Array(__identity);
	}
	
	inline public static function Zero():Matrix3
	{
		return Matrix3.FromValues(
				0.0, 0.0, 0.0,
            0.0, 0.0, 0.0,
            0.0, 0.0, 0.0);
	}
	inline public static function FromValues(
	    m11:Float, m12:Float, m13:Float,
		m21:Float, m22:Float, m23:Float,
		m31:Float, m32:Float, m33:Float	):Matrix3 {
			
		var result:Matrix3 = new Matrix3();

        result.m[M00] = m11;
        result.m[M01] = m12;
        result.m[M02] = m13;

        result.m[M10] = m21;
        result.m[M11] = m22;
        result.m[M12] = m23;

        result.m[M20] = m31;
        result.m[M21] = m32;
        result.m[M22] = m33;

  

        return result;		
	}
	
	
	inline public  function setIdentity():Void
	{
		setValues(
			1.0, 0.0, 0.0,
            0.0, 1.0, 0.0,
            0.0, 0.0, 1.0
		);
	}
	inline public  function setZero():Void
	{
		setValues(
			0.0, 0.0, 0.0,
            0.0, 0.0, 0.0,
            0.0, 0.0, 0.0
		);
	}
inline public function get00() {return m[M00];}
inline public function get01() {return m[M01];}
inline public function get02() {return m[M02];}

  
inline public function get10() {return m[M10];}
inline public function get11() {return m[M11];}
inline public function get12() {return m[M12];}
  
inline public function get20() {return m[M20];}
inline public function get21() {return m[M21];}
inline public function get22() {return m[M22];}

  inline public static function Identity():Matrix3
	{
		return Matrix3.FromValues(
			1.0, 0.0, 0.0,
            0.0, 1.0, 0.0,
            0.0, 0.0, 1.0
		);
	}
	
		
	inline public  function setValues
	(
	    m11:Float, m12:Float, m13:Float,
		m21:Float, m22:Float, m23:Float,
		m31:Float, m32:Float, m33:Float		):Void {
			
		
        m[M00] = m11;
        m[M01] = m12;
        m[M02] = m13;

        m[M10] = m21;
        m[M11] = m22;
        m[M12] = m23;

        m[M20] = m31;
        m[M21] = m32;
        m[M22] = m33;

	
	}
	inline public function copyFrom(other:Matrix3)
	{
		for (index in 0...8) {
            this.m[index] = other.m[index];
        }
	}

   inline public function fromAxes( uAxis:Vector3,  vAxis:Vector3,  wAxis:Vector3):Void 
   {
	    m[M00] = uAxis.x;
        m[M10] = uAxis.y;
        m[M20] = uAxis.z;

        m[M01] = vAxis.x;
        m[M11] = vAxis.y;
        m[M21] = vAxis.z;

        m[M02] = wAxis.x;
        m[M12] = wAxis.y;
        m[M22] = wAxis.z;
    }
	/*
	inline public function scale( scale:Vector3) 
	{
	    m[M00] *= scale.x;
        m[M10] *= scale.x;
        m[M20] *= scale.x;
        m[M01] *= scale.y;
        m[M11] *= scale.y;
        m[M21] *= scale.y;
        m[M02] *= scale.z;
        m[M12] *= scale.z;
        m[M22] *= scale.z;
    }*/
	inline public static function FromValuesToRef(m11:Float, m12:Float, m13:Float, 
		m21:Float, m22:Float, m23:Float, 
		m31:Float, m32:Float, m33:Float,  result:Matrix3):Matrix3 {
		
		result.m[M00] = m11;
        result.m[M01] = m12;
        result.m[M02] = m13;
 
        result.m[M10] = m21;
        result.m[M11] = m22;
        result.m[M12] = m23;

        result.m[M20] = m31;
        result.m[M21] = m32;
        result.m[M22] = m33;


		
		return result;
	}

	


inline public  function FromEulerAnglesXYZ(  yaw:Float,  pitch:Float,  roll:Float ):Matrix3
		{
			var cos :Float= Math.cos( yaw );
			var sin :Float= Math.sin( yaw );
			var xMat:Matrix3 =  Matrix3.FromValues( 1, 0, 0, 0, cos, -sin, 0, sin, cos );

			cos = Math.cos( pitch );
			sin = Math.sin( pitch );
			var yMat:Matrix3 =  Matrix3.FromValues( cos, 0, sin, 0, 1, 0, -sin, 0, cos );

			cos = Math.cos( roll );
			sin = Math.sin( roll );
			var zMat:Matrix3 =  Matrix3.FromValues( cos, -sin, 0, sin, cos, 0, 0, 0, 1 );

			var tmp:Matrix3 = Matrix3.Mult(yMat, zMat);
			return Matrix3.Mult(xMat, tmp);
			//this = xMat * ( yMat * zMat );
		}
  
inline public  function ToEulerAnglesXYZ():Vector3
		{
			var yAngle :Float=0.0;
			var rAngle:Float=0.0;
			var pAngle:Float=0.0;

			pAngle = Math.asin( m[M01] );
			if( pAngle < Math.PI / 2 )
			{
				if( pAngle > -Math.PI / 2 )
				{
					yAngle = Math.atan2( m[M21], m[M11] );
					rAngle = Math.atan2( m[M02], m[M00] );
				}
				else
				{
					// WARNING. Not a unique solution.
					var fRmY = Math.atan2( -m[M20], m[M22] );
					rAngle = 0.0; // any angle works
					yAngle = rAngle - fRmY;
				}
			}
			else
			{
				// WARNING. Not a unique solution.
				var fRpY =  Math.atan2( -m[M20], m[M22] );
				rAngle = 0.0; // any angle works
				yAngle = fRpY - rAngle;
			}

			return new Vector3( yAngle, rAngle, pAngle );
		}
	
		inline public static function Mult(  left:Matrix3,  right:Matrix3 ):Matrix3
		{
			var result= new Matrix3();

	        result.m[M00]= left.m[M00] *right.m[M00] +left.m[M01] *right.m[M10] +left.m[M02] *right.m[M20];
			result.m[M01]= left.m[M00] *right.m[M01] +left.m[M01] *right.m[M11] +left.m[M02] *right.m[M21];
			result.m[M02]= left.m[M00] *right.m[M02] +left.m[M01] *right.m[M12] +left.m[M02] *right.m[M22];

			result.m[M10]= left.m[M10] *right.m[M00] +left.m[M11] *right.m[M10] +left.m[M12] *right.m[M20];
			result.m[M11]= left.m[M10] *right.m[M01] +left.m[M11] *right.m[M11] +left.m[M12] *right.m[M21];
			result.m[M12]= left.m[M10] *right.m[M02] +left.m[M11] *right.m[M12] +left.m[M12] *right.m[M22];

			result.m[M20]= left.m[M20] *right.m[M00] +left.m[M21] *right.m[M10] +left.m[M22] *right.m[M20];
			result.m[M21]= left.m[M20] *right.m[M01] +left.m[M21] *right.m[M11] +left.m[M22] *right.m[M21];
			result.m[M22]= left.m[M20] *right.m[M02] +left.m[M21] *right.m[M12] +left.m[M22] *right.m[M22];

			return result;
		}
	
		
}
