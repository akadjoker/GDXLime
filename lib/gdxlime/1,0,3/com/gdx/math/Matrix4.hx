package com.gdx.math ;

import lime.utils.Float32Array;


/**
 * @author djoker
 */

class Matrix4{
    
	public static inline var M00:Int = 0;// 0;
	public static inline var M01:Int = 4;// 1;
	public static inline var M02:Int = 8;// 2;
	public static inline var M03:Int = 12;// 3;
	public static inline var M10:Int = 1;// 4;
	public static inline var M11:Int = 5;// 5;
	public static inline var M12:Int = 9;// 6;
	public static inline var M13:Int = 13;// 7;
	public static inline var M20:Int = 2;// 8;
	public static inline var M21:Int = 6;// 9;
	public static inline var M22:Int = 10;// 10;
	public static inline var M23:Int = 14;// 11;
	public static inline var M30:Int = 3;// 12;
	public static inline var M31:Int = 7;// 13;
	public static inline var M32:Int = 11;// 14;
	public static inline var M33:Int = 15;// 15;
	
private static var __identity = [ 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0 ];

	public var m:Float32Array;

	

	public function new() 
	{
	
		this.m = new Float32Array(__identity);
	


	
	}
		inline public  function getRowCol(row:Int, col:Int):Float
		{
			return m[row * 4 + col];
		}

        inline public  function setRowCol(row:Int, col:Int,v:Float):Void
		{
			 m[row * 4 + col] = v;
		}


	inline public  function getTranslation(v:Vector3):Vector3
	{
			if (v == null)
			{
				v = Vector3.zero;
			}
			v.set(m[12], m[13], m[14]);
			return v;
	}
	 inline public  function setZero():Void 
	{
		this.set(
			0, 0, 0, 0,
            0, 0, 0, 0,
            0, 0, 0, 0,
            0, 0, 0, 0
		);
	}
   inline public  function setIdentity():Void 
	{
		this.set(
			1.0, 0, 0, 0,
            0, 1.0, 0, 0,
            0, 0, 1.0, 0,
            0, 0, 0, 1.0
		);
	}
	inline public  function setRotationDegrees( rotation:Vector3 ):Matrix4
	{
		var cr:Float=Math.cos( rotation.x*Util.Deg2Rad);
		var sr:Float=Math.sin( rotation.x*Util.Deg2Rad );
		var cp:Float=Math.cos( rotation.y*Util.Deg2Rad );
		var sp:Float=Math.sin( rotation.y*Util.Deg2Rad );
		var cy:Float=Math.cos( rotation.z*Util.Deg2Rad );
		var sy:Float=Math.sin( rotation.z*Util.Deg2Rad );

		m[0] = ( cp*cy );
		m[1] = ( cp*sy );
		m[2] = ( -sp );

		var srsp:Float = sr*sp;
		var crsp:Float = cr*sp;

		m[4] = ( srsp*cy-cr*sy );
		m[5] = ( srsp*sy+cr*cy );
		m[6] = ( sr*cp );

		m[8] = ( crsp*cy+sr*sy );
		m[9] = ( crsp*sy-sr*cy );
		m[10] = ( cr*cp );
		
		return this;
	}
	inline public  function setRotationRadians( rotation:Vector3 ):Matrix4
	{
		var cr:Float=Math.cos( rotation.x );
		var sr:Float=Math.sin( rotation.x );
		var cp:Float=Math.cos( rotation.y );
		var sp:Float=Math.sin( rotation.y );
		var cy:Float=Math.cos( rotation.z );
		var sy:Float=Math.sin( rotation.z );

		m[0] = ( cp*cy );
		m[1] = ( cp*sy );
		m[2] = ( -sp );

		var srsp:Float = sr*sp;
		var crsp:Float = cr*sp;

		m[4] = ( srsp*cy-cr*sy );
		m[5] = ( srsp*sy+cr*cy );
		m[6] = ( sr*cp );

		m[8] = ( crsp*cy+sr*sy );
		m[9] = ( crsp*sy-sr*cy );
		m[10] = ( cr*cp );
		
		return this;
	}
	inline public function isIdentity():Bool {
		var ret:Bool = true;
		if (this.m[0] != 1.0 || this.m[5] != 1.0 || this.m[10] != 1.0 || this.m[15] != 1.0)
            ret = false;

        if (this.m[1] != 0.0 || this.m[2] != 0.0 || this.m[3] != 0.0 ||
            this.m[4] != 0.0 || this.m[6] != 0.0 || this.m[7] != 0.0 ||
            this.m[8] != 0.0 || this.m[9] != 0.0 || this.m[11] != 0.0 ||
            this.m[12] != 0.0 || this.m[13] != 0.0 || this.m[14] != 0.0)
            ret = false;

        return ret;
	}
	
	inline public function determinant():Float {
		var temp1 = (this.m[10] * this.m[15]) - (this.m[11] * this.m[14]);
        var temp2 = (this.m[9] * this.m[15]) - (this.m[11] * this.m[13]);
        var temp3 = (this.m[9] * this.m[14]) - (this.m[10] * this.m[13]);
        var temp4 = (this.m[8] * this.m[15]) - (this.m[11] * this.m[12]);
        var temp5 = (this.m[8] * this.m[14]) - (this.m[10] * this.m[12]);
        var temp6 = (this.m[8] * this.m[13]) - (this.m[9] * this.m[12]);

        return ((((this.m[0] * (((this.m[5] * temp1) - (this.m[6] * temp2)) + (this.m[7] * temp3))) - (this.m[1] * (((this.m[4] * temp1) -
                (this.m[6] * temp4)) + (this.m[7] * temp5)))) + (this.m[2] * (((this.m[4] * temp2) - (this.m[5] * temp4)) + (this.m[7] * temp6)))) -
            (this.m[3] * (((this.m[4] * temp3) - (this.m[5] * temp5)) + (this.m[6] * temp6))));
	}
	
	inline public function toArray(): Float32Array
	{
		return this.m;
	}
	
	inline public function invert() {
		this.invertToRef(this);
	}
	
	inline public function invertToRef(other:Matrix4) 
	{
		var l1 = this.m[0];
        var l2 = this.m[1];
        var l3 = this.m[2];
        var l4 = this.m[3];
        var l5 = this.m[4];
        var l6 = this.m[5];
        var l7 = this.m[6];
        var l8 = this.m[7];
        var l9 = this.m[8];
        var l10 = this.m[9];
        var l11 = this.m[10];
        var l12 = this.m[11];
        var l13 = this.m[12];
        var l14 = this.m[13];
        var l15 = this.m[14];
        var l16 = this.m[15];
        var l17 = (l11 * l16) - (l12 * l15);
        var l18 = (l10 * l16) - (l12 * l14);
        var l19 = (l10 * l15) - (l11 * l14);
        var l20 = (l9 * l16) - (l12 * l13);
        var l21 = (l9 * l15) - (l11 * l13);
        var l22 = (l9 * l14) - (l10 * l13);
        var l23 = ((l6 * l17) - (l7 * l18)) + (l8 * l19);
        var l24 = -(((l5 * l17) - (l7 * l20)) + (l8 * l21));
        var l25 = ((l5 * l18) - (l6 * l20)) + (l8 * l22);
        var l26 = -(((l5 * l19) - (l6 * l21)) + (l7 * l22));
        var l27 = 1.0 / ((((l1 * l23) + (l2 * l24)) + (l3 * l25)) + (l4 * l26));
        var l28 = (l7 * l16) - (l8 * l15);
        var l29 = (l6 * l16) - (l8 * l14);
        var l30 = (l6 * l15) - (l7 * l14);
        var l31 = (l5 * l16) - (l8 * l13);
        var l32 = (l5 * l15) - (l7 * l13);
        var l33 = (l5 * l14) - (l6 * l13);
        var l34 = (l7 * l12) - (l8 * l11);
        var l35 = (l6 * l12) - (l8 * l10);
        var l36 = (l6 * l11) - (l7 * l10);
        var l37 = (l5 * l12) - (l8 * l9);
        var l38 = (l5 * l11) - (l7 * l9);
        var l39 = (l5 * l10) - (l6 * l9);

        other.m[0] = l23 * l27;
        other.m[4] = l24 * l27;
        other.m[8] = l25 * l27;
        other.m[12] = l26 * l27;
        other.m[1] = -(((l2 * l17) - (l3 * l18)) + (l4 * l19)) * l27;
        other.m[5] = (((l1 * l17) - (l3 * l20)) + (l4 * l21)) * l27;
        other.m[9] = -(((l1 * l18) - (l2 * l20)) + (l4 * l22)) * l27;
        other.m[13] = (((l1 * l19) - (l2 * l21)) + (l3 * l22)) * l27;
        other.m[2] = (((l2 * l28) - (l3 * l29)) + (l4 * l30)) * l27;
        other.m[6] = -(((l1 * l28) - (l3 * l31)) + (l4 * l32)) * l27;
        other.m[10] = (((l1 * l29) - (l2 * l31)) + (l4 * l33)) * l27;
        other.m[14] = -(((l1 * l30) - (l2 * l32)) + (l3 * l33)) * l27;
        other.m[3] = -(((l2 * l34) - (l3 * l35)) + (l4 * l36)) * l27;
        other.m[7] = (((l1 * l34) - (l3 * l37)) + (l4 * l38)) * l27;
        other.m[11] = -(((l1 * l35) - (l2 * l37)) + (l4 * l39)) * l27;
        other.m[15] = (((l1 * l36) - (l2 * l38)) + (l3 * l39)) * l27;
	}
	public function atan2deg( val:Float,val2:Float):Float
{
	return Util.rad2deg(Math.atan2(val,val2));
}
	inline public function GetPitch():Float
		{
			var x = m[M20];
	    	var y = m[M21];
		    var z = m[M22];
		    return -atan2deg( y, Math.sqrt( x*x+z*z ) );
		}
	inline public function GetYaw():Float
	{

		var x = m[M20];
		var z = m[M22];
		return atan2deg( x,z );

	}
	inline public function GetRoll():Float
	{

	    var iy = m[M01];
		var jy = m[M11];
		return atan2deg( iy, jy );

	}	
	    inline public function rotateVect(r:Vector3 ):Vector3
		{
		var result:Vector3 = Vector3.zero;
		var  ix = r.x;
		var  iy = r.y;
		var  iz = r.z;
		
		result.x =  ( ( m[0] * ix ) + ( m[4] * iy ) + ( m[8]  * iz ) );
		result.y =  ( ( m[1]  * ix ) + ( m[5] * iy ) + ( m[9]  * iz) ) ;
		result.z =  ( ( m[2] * ix ) + ( m[6] * iy ) + ( m[10] * iz ) ) ;
		
		return result; 
		}
	   inline public function translateVector(r:Vector3 ):Vector3
		{
		var result:Vector3 = Vector3.zero;
		
		result.x =  r.x + m[12];
		result.y =  r.y + m[13];
		result.z =  r.z + m[14];
		
		return result; 
		}
	  inline public function inverseTranslateVector(r:Vector3 ):Vector3
		{
		var result:Vector3 = Vector3.zero;
		
		result.x =  r.x - m[12];
		result.y =  r.y - m[13];
		result.z =  r.z - m[14];
		
		return result; 
		}
		  inline public function inverseTranslateVectorRef(r:Vector3 ):Vector3
		{
		r.x =  r.x - m[12];
		r.y =  r.y - m[13];
		r.z =  r.z - m[14];
		
		return r; 
		}
		inline public function inverseRotateVectorRef(r:Vector3):Vector3
		{

	
		var  ix = r.x;
		var  iy = r.y;
		var  iz = r.z;

	
		r.x =   ((ix * m[0]) +
	                  (iy * m[1]) +
					  (iz * m[2]));
		
		r.y =   ((ix * m[4]) +
	                  (iy * m[5]) +
					  (iz * m[6]));
					  
        r.z =   ((ix * m[0]) +
	                  (iy * m[9]) +
					  (iz * m[10]));
		
					  
					  
		
		return r; 
		

	}
		inline public function inverseRotateVector(r:Vector3):Vector3
		{

	
		var  ix = r.x;
		var  iy = r.y;
		var  iz = r.z;

		var result:Vector3 = Vector3.zero;
		result.x =   ((ix * m[0]) +
	                  (iy * m[1]) +
					  (iz * m[2]));
		
		result.y =   ((ix * m[4]) +
	                  (iy * m[5]) +
					  (iz * m[6]));
					  
        result.z =   ((ix * m[0]) +
	                  (iy * m[9]) +
					  (iz * m[10]));
		
					  
					  
		
		return result; 
		

	}
		inline public function transformVector(r:Vector3):Vector3
		{

	
		var  ix = r.x;
		var  iy = r.y;
		var  iz = r.z;

		var result:Vector3 = Vector3.zero;
		result.x =  ( ( m[0] * ix ) + ( m[4] * iy ) + ( m[8]  * iz ) + m[12] ) ;
		result.y =  ( ( m[1]  *ix ) + ( m[5] * iy ) + ( m[9]  * iz ) + m[13]  ) ;
		result.z =  ( ( m[2] * ix ) + ( m[6] * iy ) + ( m[10] * iz ) + m[14]  ) ;
		
		return result; 
		

	}
	
		
		inline public function TransformVec(r:Vector3, addTranslation:Int = 0 ):Vector3
		{

		var  w = 1.0/ ( m[3] + m[7] + m[11] + m[15] );
		var  ix = r.x;
		var  iy = r.y;
		var  iz = r.z;

		addTranslation = addTranslation & 1;

		var result:Vector3 = Vector3.zero;
		result.x =  ( ( m[0] * ix ) + ( m[4] * iy ) + ( m[8]  * iz ) + m[12] * addTranslation ) * w;
		result.y =  ( ( m[1]  *ix ) + ( m[5] * iy ) + ( m[9]  * iz ) + m[13] * addTranslation ) * w;
		result.z =  ( ( m[2] * ix ) + ( m[6] * iy ) + ( m[10] * iz ) + m[14] * addTranslation ) * w;
		
		return result; 
		

	}
	inline public function setbyproduct(m1:Matrix4, m2:Matrix4):Void
	{
		
		m[0] = m1.m[0]*m2.m[0] + m1.m[4]*m2.m[1] + m1.m[8]*m2.m[2] + m1.m[12]*m2.m[3];
		m[1] = m1.m[1]*m2.m[0] + m1.m[5]*m2.m[1] + m1.m[9]*m2.m[2] + m1.m[13]*m2.m[3];
		m[2] = m1.m[2]*m2.m[0] + m1.m[6]*m2.m[1] + m1.m[10]*m2.m[2] + m1.m[14]*m2.m[3];
		m[3] = m1.m[3]*m2.m[0] + m1.m[7]*m2.m[1] + m1.m[11]*m2.m[2] + m1.m[15]*m2.m[3];

		m[4] = m1.m[0]*m2.m[4] + m1.m[4]*m2.m[5] + m1.m[8]*m2.m[6] + m1.m[12]*m2.m[7];
		m[5] = m1.m[1]*m2.m[4] + m1.m[5]*m2.m[5] + m1.m[9]*m2.m[6] + m1.m[13]*m2.m[7];
		m[6] = m1.m[2]*m2.m[4] + m1.m[6]*m2.m[5] + m1.m[10]*m2.m[6] + m1.m[14]*m2.m[7];
		m[7] = m1.m[3]*m2.m[4] + m1.m[7]*m2.m[5] + m1.m[11]*m2.m[6] + m1.m[15]*m2.m[7];

		m[8] = m1.m[0]*m2.m[8] + m1.m[4]*m2.m[9] + m1.m[8]*m2.m[10] + m1.m[12]*m2.m[11];
		m[9] = m1.m[1]*m2.m[8] + m1.m[5]*m2.m[9] + m1.m[9]*m2.m[10] + m1.m[13]*m2.m[11];
		m[10] = m1.m[2]*m2.m[8] + m1.m[6]*m2.m[9] + m1.m[10]*m2.m[10] + m1.m[14]*m2.m[11];
		m[11] = m1.m[3]*m2.m[8] + m1.m[7]*m2.m[9] + m1.m[11]*m2.m[10] + m1.m[15]*m2.m[11];

		m[12] = m1.m[0]*m2.m[12] + m1.m[4]*m2.m[13] + m1.m[8]*m2.m[14] + m1.m[12]*m2.m[15];
		m[13] = m1.m[1]*m2.m[12] + m1.m[5]*m2.m[13] + m1.m[9]*m2.m[14] + m1.m[13]*m2.m[15];
		m[14] = m1.m[2]*m2.m[12] + m1.m[6]*m2.m[13] + m1.m[10]*m2.m[14] + m1.m[14]*m2.m[15];
		m[15] = m1.m[3]*m2.m[12] + m1.m[7]*m2.m[13] + m1.m[11]*m2.m[14] + m1.m[15]*m2.m[15];
	}
	
	inline public function setTranslation(vector3:Vector3) {
		this.m[12] = vector3.x;
        this.m[13] = vector3.y;
        this.m[14] = vector3.z;
	}
	
inline public function get00() {return m[M00];}
inline public function get01() {return m[M01];}
inline public function get02() {return m[M02];}
inline public function get03() {return m[M03];}
inline public function get10() {return m[M10];}
inline public function get11() {return m[M11];}
inline public function get12() {return m[M12];}
inline public function get13() {return m[M13];}
inline public function get20() {return m[M20];}
inline public function get21() {return m[M21];}
inline public function get22() {return m[M22];}
inline public function get23() {return m[M23];}
inline public function get30() {return m[M30];}
inline public function get31() {return m[M31];}
inline public function get32() {return m[M32];}
inline public function get33() {return m[M33];}
	
	inline public function append (lhs:Matrix4):Void 
	{
		
		var m111:Float = this.m[0], m121:Float = this.m[4], m131:Float = this.m[8], m141:Float = this.m[12],
			m112:Float = this.m[1], m122:Float = this.m[5], m132:Float = this.m[9], m142:Float = this.m[13],
			m113:Float = this.m[2], m123:Float = this.m[6], m133:Float = this.m[10], m143:Float = this.m[14],
			m114:Float = this.m[3], m124:Float = this.m[7], m134:Float = this.m[11], m144:Float = this.m[15],
			m211:Float = lhs.m[0], m221:Float = lhs.m[4], m231:Float = lhs.m[8], m241:Float = lhs.m[12],
			m212:Float = lhs.m[1], m222:Float = lhs.m[5], m232:Float = lhs.m[9], m242:Float = lhs.m[13],
			m213:Float = lhs.m[2], m223:Float = lhs.m[6], m233:Float = lhs.m[10], m243:Float = lhs.m[14],
			m214:Float = lhs.m[3], m224:Float = lhs.m[7], m234:Float = lhs.m[11], m244:Float = lhs.m[15];
		
		m[0] = m111 * m211 + m112 * m221 + m113 * m231 + m114 * m241;
		m[1] = m111 * m212 + m112 * m222 + m113 * m232 + m114 * m242;
		m[2] = m111 * m213 + m112 * m223 + m113 * m233 + m114 * m243;
		m[3] = m111 * m214 + m112 * m224 + m113 * m234 + m114 * m244;
		
		m[4] = m121 * m211 + m122 * m221 + m123 * m231 + m124 * m241;
		m[5] = m121 * m212 + m122 * m222 + m123 * m232 + m124 * m242;
		m[6] = m121 * m213 + m122 * m223 + m123 * m233 + m124 * m243;
		m[7] = m121 * m214 + m122 * m224 + m123 * m234 + m124 * m244;
		
		m[8] = m131 * m211 + m132 * m221 + m133 * m231 + m134 * m241;
		m[9] = m131 * m212 + m132 * m222 + m133 * m232 + m134 * m242;
		m[10] = m131 * m213 + m132 * m223 + m133 * m233 + m134 * m243;
		m[11] = m131 * m214 + m132 * m224 + m133 * m234 + m134 * m244;
		
		m[12] = m141 * m211 + m142 * m221 + m143 * m231 + m144 * m241;
		m[13] = m141 * m212 + m142 * m222 + m143 * m232 + m144 * m242;
		m[14] = m141 * m213 + m142 * m223 + m143 * m233 + m144 * m243;
		m[15] = m141 * m214 + m142 * m224 + m143 * m234 + m144 * m244;
		
	}
	
	inline public function multiply(other:Matrix4):Matrix4 {
		var result = new Matrix4();
        this.multiplyToRef(other, result);
        return result;
	}

inline public static function multiplyWith(a:Matrix4, b:Matrix4):Matrix4
{
	var out:Matrix4 = new Matrix4();
	Matrix4.multiplyex(out.m, a.m, b.m);
	return out;
	
}

inline public static function multiplyex(out:  Float32Array , a:   Float32Array , b:  Float32Array):Void
{
var a00 = a[0], a01 = a[1], a02 = a[2], a03 = a[3],
a10 = a[4], a11 = a[5], a12 = a[6], a13 = a[7],
a20 = a[8], a21 = a[9], a22 = a[10], a23 = a[11],
a30 = a[12], a31 = a[13], a32 = a[14], a33 = a[15];
// Cache only the current line of the second matrix
var b0 = b[0], b1 = b[1], b2 = b[2], b3 = b[3];
out[0] = b0*a00 + b1*a10 + b2*a20 + b3*a30;
out[1] = b0*a01 + b1*a11 + b2*a21 + b3*a31;
out[2] = b0*a02 + b1*a12 + b2*a22 + b3*a32;
out[3] = b0*a03 + b1*a13 + b2*a23 + b3*a33;
b0 = b[4]; b1 = b[5]; b2 = b[6]; b3 = b[7];
out[4] = b0*a00 + b1*a10 + b2*a20 + b3*a30;
out[5] = b0*a01 + b1*a11 + b2*a21 + b3*a31;
out[6] = b0*a02 + b1*a12 + b2*a22 + b3*a32;
out[7] = b0*a03 + b1*a13 + b2*a23 + b3*a33;
b0 = b[8]; b1 = b[9]; b2 = b[10]; b3 = b[11];
out[8] = b0*a00 + b1*a10 + b2*a20 + b3*a30;
out[9] = b0*a01 + b1*a11 + b2*a21 + b3*a31;
out[10] = b0*a02 + b1*a12 + b2*a22 + b3*a32;
out[11] = b0*a03 + b1*a13 + b2*a23 + b3*a33;
b0 = b[12]; b1 = b[13]; b2 = b[14]; b3 = b[15];
out[12] = b0*a00 + b1*a10 + b2*a20 + b3*a30;
out[13] = b0*a01 + b1*a11 + b2*a21 + b3*a31;
out[14] = b0*a02 + b1*a12 + b2*a22 + b3*a32;
out[15] = b0*a03 + b1*a13 + b2*a23 + b3*a33;

};

inline public  function fromMatrix3(mat:Matrix3):Void
{
	m[0] = mat.m[0];
	m[1] = mat.m[1];
	m[2] = mat.m[2];
	m[3] = 0.0;
	
	m[4] = mat.m[3];
	m[5] = mat.m[4];
	m[6] = mat.m[5];
	m[7] = 0.0;
	
	m[8] = mat.m[6];
	m[9] = mat.m[7];
	m[10] = mat.m[8];
	m[11] = 0.0;

	m[12] = 0.0;//position
	m[13] = 0.0;
	m[14] = 0.0;
	
	m[15] = 1.0;

	
	
}

 inline public  function makeTransform( position:Vector3, scale:Vector3, orientation:Quaternion):Void
    {
        // Ordering:
        //    1. Scale
        //    2. Rotate
        //    3. Translate

			
        var rot3x3:Matrix3=Matrix3.Zero();
	    orientation.toRotationMatrix3(rot3x3);
	
	
	

        // Set up final matrix with scale, rotation and translation
        m[M00] = scale.x * rot3x3.m[Matrix3.M00];
		m[M01] = scale.y * rot3x3.m[Matrix3.M01];
		m[M02] = scale.z * rot3x3.m[Matrix3.M02];
		m[M03] = position.x;
		
        m[M10] = scale.x * rot3x3.m[Matrix3.M10]; 
		m[M11] = scale.y * rot3x3.m[Matrix3.M11]; 
		m[M12] = scale.z * rot3x3.m[Matrix3.M12];
		m[M13] = position.y;
		
        m[M20] = scale.x * rot3x3.m[Matrix3.M20];
		m[M21] = scale.y * rot3x3.m[Matrix3.M21]; 
		m[M22] = scale.z * rot3x3.m[Matrix3.M22]; 
		m[M23] = position.z;

        // No projection term
        m[M30] = 0;
		m[M31] = 0; 
		m[M32] = 0; 
		m[M33] = 1;

    }
	
	inline public function copyFrom(other:Matrix4) {
		for (index in 0...16) {
            this.m[index] = other.m[index];
        }
	}
	
	inline public function multiplyToRef(other:Matrix4, result:Matrix4) {
		this.multiplyToArray(other, result.m, 0);
	}

	inline public function multiplyToValue(result:  Matrix4 , value:Float):Void
	{
		for (i in 0...4)
		{
		for (j in 0...4)
		{
			result.setRowCol(j, i, getRowCol(j, i) * value);
		}
		}
	}
	inline public function multiplyVector( v:Vector3):Vector3
	{
		var result:Vector3 = Vector3.zero;
		result.x =  getRowCol(0, 0)  *  v.x + getRowCol(1, 0) * v.y + getRowCol(2, 0) * v.z + getRowCol(3, 0);
		result.y =  getRowCol(0, 1)  *  v.x + getRowCol(1, 1) * v.y + getRowCol(2, 1) * v.z + getRowCol(3, 1);
		result.z =  getRowCol(0, 2)  *  v.x + getRowCol(1, 2) * v.y + getRowCol(2, 2) * v.z + getRowCol(3, 2);
		return result;
	}
	inline public function multiplyToArray(other:Matrix4, result:  Float32Array , offset:Int):  Float32Array
	{
		var tm0 = this.m[0];
        var tm1 = this.m[1];
        var tm2 = this.m[2];
        var tm3 = this.m[3];
        var tm4 = this.m[4];
        var tm5 = this.m[5];
        var tm6 = this.m[6];
        var tm7 = this.m[7];
        var tm8 = this.m[8];
        var tm9 = this.m[9];
        var tm10 = this.m[10];
        var tm11 = this.m[11];
        var tm12 = this.m[12];
        var tm13 = this.m[13];
        var tm14 = this.m[14];
        var tm15 = this.m[15];

        var om0 = other.m[0];
        var om1 = other.m[1];
        var om2 = other.m[2];
        var om3 = other.m[3];
        var om4 = other.m[4];
        var om5 = other.m[5];
        var om6 = other.m[6];
        var om7 = other.m[7];
        var om8 = other.m[8];
        var om9 = other.m[9];
        var om10 = other.m[10];
        var om11 = other.m[11];
        var om12 = other.m[12];
        var om13 = other.m[13];
        var om14 = other.m[14];
        var om15 = other.m[15];

        result[offset] = tm0 * om0 + tm1 * om4 + tm2 * om8 + tm3 * om12;
        result[offset + 1] = tm0 * om1 + tm1 * om5 + tm2 * om9 + tm3 * om13;
        result[offset + 2] = tm0 * om2 + tm1 * om6 + tm2 * om10 + tm3 * om14;
        result[offset + 3] = tm0 * om3 + tm1 * om7 + tm2 * om11 + tm3 * om15;

        result[offset + 4] = tm4 * om0 + tm5 * om4 + tm6 * om8 + tm7 * om12;
        result[offset + 5] = tm4 * om1 + tm5 * om5 + tm6 * om9 + tm7 * om13;
        result[offset + 6] = tm4 * om2 + tm5 * om6 + tm6 * om10 + tm7 * om14;
        result[offset + 7] = tm4 * om3 + tm5 * om7 + tm6 * om11 + tm7 * om15;

        result[offset + 8] = tm8 * om0 + tm9 * om4 + tm10 * om8 + tm11 * om12;
        result[offset + 9] = tm8 * om1 + tm9 * om5 + tm10 * om9 + tm11 * om13;
        result[offset + 10] = tm8 * om2 + tm9 * om6 + tm10 * om10 + tm11 * om14;
        result[offset + 11] = tm8 * om3 + tm9 * om7 + tm10 * om11 + tm11 * om15;

        result[offset + 12] = tm12 * om0 + tm13 * om4 + tm14 * om8 + tm15 * om12;
        result[offset + 13] = tm12 * om1 + tm13 * om5 + tm14 * om9 + tm15 * om13;
        result[offset + 14] = tm12 * om2 + tm13 * om6 + tm14 * om10 + tm15 * om14;
        result[offset + 15] = tm12 * om3 + tm13 * om7 + tm14 * om11 + tm15 * om15;
		
		return result;
	}
	
	inline public function equals(value:Matrix4):Bool {
		return (this.m[0] == value.m[0] && this.m[1] == value.m[1] && this.m[2] == value.m[2] && this.m[3] == value.m[3] &&
                this.m[4] == value.m[4] && this.m[5] == value.m[5] && this.m[6] == value.m[6] && this.m[7] == value.m[7] &&
                this.m[8] == value.m[8] && this.m[9] == value.m[9] && this.m[10] == value.m[10] && this.m[11] == value.m[11] &&
                this.m[12] == value.m[12] && this.m[13] == value.m[13] && this.m[14] == value.m[14] && this.m[15] == value.m[15]);
	}
	
	inline public function clone():Matrix4 {
		return Matrix4.FromValues(this.m[0], this.m[1], this.m[2], this.m[3],
            this.m[4], this.m[5], this.m[6], this.m[7],
            this.m[8], this.m[9], this.m[10], this.m[11],
            this.m[12], this.m[13], this.m[14], this.m[15]);
	}
	inline public  function set(m11:Float, m12:Float, m13:Float, m14:Float,
		m21:Float, m22:Float, m23:Float, m24:Float,
		m31:Float, m32:Float, m33:Float, m34:Float,
		m41:Float, m42:Float, m43:Float, m44:Float) {
			
		

        this.m[0] = m11;
        this.m[1] = m12;
        this.m[2] = m13;
        this.m[3] = m14;
        this.m[4] = m21;
        this.m[5] = m22;
        this.m[6] = m23;
        this.m[7] = m24;
        this.m[8] = m31;
        this.m[9] = m32;
        this.m[10] = m33;
        this.m[11] = m34;
        this.m[12] = m41;
        this.m[13] = m42;
        this.m[14] = m43;
        this.m[15] = m44;
	
	}
	inline public  function setOrthoOffCenterLH(left:Float, right:Float, bottom:Float, top:Float, znear:Float, zfar:Float):Void
	{
		this.m[0] = 2.0 / (right - left);
        this.m[1] = 0;
		this.m[2] = 0;
		this.m[3] = 0;
		this.m[4] = 0;
        this.m[5] = 2.0 / (top - bottom);
        this.m[6] = 0.0;
		this.m[7] = 0;        
        this.m[8] = 0;
		this.m[9] = 0;
		this.m[10] = -1 / (znear - zfar);
		this.m[11] = 0;
        this.m[12] = (left + right) / (left - right);
        this.m[13] = (top + bottom) / (bottom - top);
        this.m[14] = znear / (znear - zfar);
        this.m[15] = 1.0;

	}
	inline public  function setOrthoLH(width:Float, height:Float, znear:Float, zfar:Float):Void 
  {
		var hw = 2.0 / width;
        var hh = 2.0 / height;
        var id = 1.0 / (zfar - znear);
        var nid = znear / (znear - zfar);

        set(
			hw, 0, 0, 0,
            0, hh, 0, 0,
            0, 0, id, 0,
            0, 0, nid, 1
		);
	}

	inline public static function FromArray(array:Array<Float>, offset:Int = 0):Matrix4 {
		var result = new Matrix4();
        Matrix4.FromArrayToRef(array, offset, result);
        return result;
	}
	
	inline public static function FromArrayToRef(array:Array<Float>, offset:Int = 0, result:Matrix4):Matrix4 {
		for (index in 0...16) {
            result.m[index] = array[index + offset];
        }
		return result;
	}
	
	inline public static function FromValues(m11:Float, m12:Float, m13:Float, m14:Float,
		m21:Float, m22:Float, m23:Float, m24:Float,
		m31:Float, m32:Float, m33:Float, m34:Float,
		m41:Float, m42:Float, m43:Float, m44:Float):Matrix4 {
			
		var result = new Matrix4();

        result.m[0] = m11;
        result.m[1] = m12;
        result.m[2] = m13;
        result.m[3] = m14;
        result.m[4] = m21;
        result.m[5] = m22;
        result.m[6] = m23;
        result.m[7] = m24;
        result.m[8] = m31;
        result.m[9] = m32;
        result.m[10] = m33;
        result.m[11] = m34;
        result.m[12] = m41;
        result.m[13] = m42;
        result.m[14] = m43;
        result.m[15] = m44;

        return result;		
	}
	
	inline public static function FromValuesToRef(m11:Float, m12:Float, m13:Float, m14:Float,
		m21:Float, m22:Float, m23:Float, m24:Float,
		m31:Float, m32:Float, m33:Float, m34:Float,
		m41:Float, m42:Float, m43:Float, m44:Float, result:Matrix4):Matrix4 {
		
		result.m[0] = m11;
        result.m[1] = m12;
        result.m[2] = m13;
        result.m[3] = m14;
        result.m[4] = m21;
        result.m[5] = m22;
        result.m[6] = m23;
        result.m[7] = m24;
        result.m[8] = m31;
        result.m[9] = m32;
        result.m[10] = m33;
        result.m[11] = m34;
        result.m[12] = m41;
        result.m[13] = m42;
        result.m[14] = m43;
        result.m[15] = m44;
		
		return result;
	}


	inline public static function Identity():Matrix4 
	{
		return Matrix4.FromValues(
			1.0, 0, 0, 0,
            0, 1.0, 0, 0,
            0, 0, 1.0, 0,
            0, 0, 0, 1.0
		);
	}
	
	inline public static function IdentityToRef(result:Matrix4):Matrix4 {
		Matrix4.FromValuesToRef(
			1.0, 0, 0, 0,
            0, 1.0, 0, 0,
            0, 0, 1.0, 0,
            0, 0, 0, 1.0, result
		);
		
		return result;
	}
	
	inline public static function Zero():Matrix4 
	{
		return Matrix4.FromValues(
			0, 0, 0, 0,
            0, 0, 0, 0,
            0, 0, 0, 0,
            0, 0, 0, 0
		);
	}
	
	inline public static function RotationX(angle:Float):Matrix4 {
		var result = new Matrix4();
        Matrix4.RotationXToRef(angle, result);

        return result;
	}
	
	inline public static function RotationXToRef(angle:Float, result:Matrix4):Matrix4 {
		var s = Math.sin(angle);
        var c = Math.cos(angle);

        result.m[0] = 1.0;
        result.m[15] = 1.0;

        result.m[5] = c;
        result.m[10] = c;
        result.m[9] = -s;
        result.m[6] = s;

        result.m[1] = 0;
        result.m[2] = 0;
        result.m[3] = 0;
        result.m[4] = 0;
        result.m[7] = 0;
        result.m[8] = 0;
        result.m[11] = 0;
        result.m[12] = 0;
        result.m[13] = 0;
        result.m[14] = 0;
		
		return result;
	}
	
	inline public static function RotationY(angle:Float):Matrix4 {
		var result = new Matrix4();
        Matrix4.RotationYToRef(angle, result);

        return result;
	}
	
	inline public static function RotationYToRef(angle:Float, result:Matrix4):Matrix4 {
		var s = Math.sin(angle);
        var c = Math.cos(angle);

        result.m[5] = 1.0;
        result.m[15] = 1.0;

        result.m[0] = c;
        result.m[2] = -s;
        result.m[8] = s;
        result.m[10] = c;

        result.m[1] = 0;
        result.m[3] = 0;
        result.m[4] = 0;
        result.m[6] = 0;
        result.m[7] = 0;
        result.m[9] = 0;
        result.m[11] = 0;
        result.m[12] = 0;
        result.m[13] = 0;
        result.m[14] = 0;
		
		return result;
	}
	
	inline public static function RotationZ(angle:Float):Matrix4 {
		var result = new Matrix4();
        Matrix4.RotationZToRef(angle, result);

        return result;
	}
	
	inline public static function RotationZToRef(angle:Float, result:Matrix4):Matrix4 {
		var s = Math.sin(angle);
        var c = Math.cos(angle);

        result.m[10] = 1.0;
        result.m[15] = 1.0;

        result.m[0] = c;
        result.m[1] = s;
        result.m[4] = -s;
        result.m[5] = c;

        result.m[2] = 0;
        result.m[3] = 0;
        result.m[6] = 0;
        result.m[7] = 0;
        result.m[8] = 0;
        result.m[9] = 0;
        result.m[11] = 0;
        result.m[12] = 0;
        result.m[13] = 0;
        result.m[14] = 0;
		
		return result;
	}
	
	inline public static function RotationAxis(axis:Vector3, angle:Float):Matrix4 {
		var s = Math.sin(-angle);
        var c = Math.cos(-angle);
        var c1 = 1 - c;

        axis.normalize();
        var result = Matrix4.Zero();

        result.m[0] = (axis.x * axis.x) * c1 + c;
        result.m[1] = (axis.x * axis.y) * c1 - (axis.z * s);
        result.m[2] = (axis.x * axis.z) * c1 + (axis.y * s);
        result.m[3] = 0.0;

        result.m[4] = (axis.y * axis.x) * c1 + (axis.z * s);
        result.m[5] = (axis.y * axis.y) * c1 + c;
        result.m[6] = (axis.y * axis.z) * c1 - (axis.x * s);
        result.m[7] = 0.0;

        result.m[8] = (axis.z * axis.x) * c1 - (axis.y * s);
        result.m[9] = (axis.z * axis.y) * c1 + (axis.x * s);
        result.m[10] = (axis.z * axis.z) * c1 + c;
        result.m[11] = 0.0;

        result.m[15] = 1.0;

        return result;
	}
	
	inline public static function RotationYawPitchRoll(yaw:Float, pitch:Float, roll:Float):Matrix4 {
		var result = new Matrix4();
        Matrix4.RotationYawPitchRollToRef(yaw, pitch, roll, result);

        return result;
	}
	
	inline public static function RotationYawPitchRollToRef(yaw:Float, pitch:Float, roll:Float, result:Matrix4):Matrix4 {
		var tempQuaternion = new Quaternion(); // For RotationYawPitchRoll
		tempQuaternion = Quaternion.RotationYawPitchRollToRef(yaw, pitch, roll, tempQuaternion);

        return tempQuaternion.toRotationMatrix(result);
	}
	
	inline public static function Scaling(x:Float, y:Float, z:Float):Matrix4 {
		var result = Matrix4.Zero();
        Matrix4.ScalingToRef(x, y, z, result);

        return result;
	}
	
	inline public static function ScalingToRef(x:Float, y:Float, z:Float, result:Matrix4):Matrix4 {
		result.m[0] = x;
        result.m[1] = 0;
        result.m[2] = 0;
        result.m[3] = 0;
        result.m[4] = 0;
        result.m[5] = y;
        result.m[6] = 0;
        result.m[7] = 0;
        result.m[8] = 0;
        result.m[9] = 0;
        result.m[10] = z;
        result.m[11] = 0;
        result.m[12] = 0;
        result.m[13] = 0;
        result.m[14] = 0;
        result.m[15] = 1.0;
		
		return result;
	}
	
	inline public static function Translation(x:Float, y:Float, z:Float):Matrix4 {
		var result = Matrix4.Identity();
        Matrix4.TranslationToRef(x, y, z, result);

        return result;
	}
	
	inline public static function TranslationToRef(x:Float, y:Float, z:Float, result:Matrix4) {
		Matrix4.FromValuesToRef(
			1.0, 0, 0, 0,
            0, 1.0, 0, 0,
            0, 0, 1.0, 0,
            x, y, z, 1.0, result
		);
	}
	
	inline public static function LookAtLH(eye:Vector3, target:Vector3, up:Vector3):Matrix4 {
		var result = Matrix4.Zero();
        Matrix4.LookAtLHToRef(eye, target, up, result);

        return result;
	}
	
	inline public static function LookAtLHToRef(eye:Vector3, target:Vector3, up:Vector3, result:Matrix4):Matrix4 {
		var xAxis = Vector3.Zero();
		var yAxis = Vector3.Zero();
		var zAxis = Vector3.Zero();
		
		// Z axis
        target.subtractToRef(eye, zAxis);
        zAxis.normalize();

        // X axis
        Vector3.CrossToRef(up, zAxis, xAxis);
        xAxis.normalize();

        // Y axis
        Vector3.CrossToRef(zAxis, xAxis, yAxis);
        yAxis.normalize();

        // Eye angles
        var ex = -Vector3.Dot(xAxis, eye);
        var ey = -Vector3.Dot(yAxis, eye);
        var ez = -Vector3.Dot(zAxis, eye);

        return Matrix4.FromValuesToRef(xAxis.x, yAxis.x, zAxis.x, 0,
            xAxis.y, yAxis.y, zAxis.y, 0,
            xAxis.z, yAxis.z, zAxis.z, 0,
            ex, ey, ez, 1, result);
	}
	inline public  function setLookAtLH(eye:Vector3, target:Vector3, up:Vector3):Void
	{
		var xAxis = Vector3.Zero();
		var yAxis = Vector3.Zero();
		var zAxis = Vector3.Zero();
		
		// Z axis
        target.subtractToRef(eye, zAxis);
        zAxis.normalize();

        // X axis
        Vector3.CrossToRef(up, zAxis, xAxis);
        xAxis.normalize();

        // Y axis
        Vector3.CrossToRef(zAxis, xAxis, yAxis);
        yAxis.normalize();

        // Eye angles
        var ex = -Vector3.Dot(xAxis, eye);
        var ey = -Vector3.Dot(yAxis, eye);
        var ez = -Vector3.Dot(zAxis, eye);

       set(xAxis.x, yAxis.x, zAxis.x, 0,
            xAxis.y, yAxis.y, zAxis.y, 0,
            xAxis.z, yAxis.z, zAxis.z, 0,
            ex, ey, ez, 1);
	}
	inline public static function OrthoLH(width:Float, height:Float, znear:Float, zfar:Float):Matrix4 {
		var hw = 2.0 / width;
        var hh = 2.0 / height;
        var id = 1.0 / (zfar - znear);
        var nid = znear / (znear - zfar);

        return Matrix4.FromValues(
			hw, 0, 0, 0,
            0, hh, 0, 0,
            0, 0, id, 0,
            0, 0, nid, 1
		);
	}
	
	inline public static function OrthoOffCenterLH(left:Float, right:Float, bottom:Float, top:Float, znear:Float, zfar:Float):Matrix4 {
		var result = Matrix4.Zero();
        Matrix4.OrthoOffCenterLHToRef(left, right, bottom, top, znear, zfar, result);

        return result;
	}
		
	inline public static function OrthoOffCenterLHToRef(left:Float, right:Float, bottom:Float, top:Float, znear:Float, zfar:Float, result:Matrix4):Matrix4 {
		result.m[0] = 2.0 / (right - left);
        result.m[1] = 0.0;
		result.m[2] = 0.0;
		result.m[3] = 0.0;
		result.m[4] = 0.0;
        result.m[5] = 2.0 / (top - bottom);
        result.m[6] = 0.0;
		result.m[7] = 0.0;        
        result.m[8] = 0.0;
		result.m[9] = 0.0;
		result.m[10] = -1 / (znear - zfar);
		result.m[11] = 0;
        result.m[12] = (left + right) / (left - right);
        result.m[13] = (top + bottom) / (bottom - top);
        result.m[14] = znear / (znear - zfar);
        result.m[15] = 1.0;
		
		
		return result;
	}
	
	inline public static function PerspectiveLH(width:Float, height:Float, znear:Float, zfar:Float):Matrix4 {
	var matrix = Matrix4.Zero();

        matrix.m[0] = (2.0 * znear) / width;
        matrix.m[1] = 0.0;
		matrix.m[2] = 0.0;
		matrix.m[3] = 0.0;
        matrix.m[5] = (2.0 * znear) / height;
        matrix.m[4] = 0.0;
		matrix.m[6] = 0.0;
		matrix.m[7] = 0.0;
        matrix.m[10] = -zfar / (znear - zfar);
        matrix.m[8] = 0.0;
		matrix.m[9] = 0.0;
        matrix.m[11] = 1.0;
        matrix.m[12] = 0.0;
		matrix.m[13] = 0.0;
		matrix.m[15] = 0.0;
        matrix.m[14] = (znear * zfar) / (znear - zfar);

        return matrix;
	}
	
	inline public static function PerspectiveFovLH(fov:Float, aspect:Float, znear:Float, zfar:Float):Matrix4 {
		var matrix = Matrix4.Zero();
       // Matrix4.PerspectiveFovLHToRef(fov, aspect, znear, zfar, matrix);

	   for (i in 0...matrix.m.length)
		{
			trace(matrix.m[i]);
		}
		
		
        return matrix;
	}

		inline public  function setPerspectiveFovLH(fov:Float, aspect:Float, znear:Float, zfar:Float):Void
		{
		var tan = 1.0 / (Math.tan(fov * 0.5));     
	    m[0] = tan / aspect;
        m[1] = 0.0;
		m[2] = 0.0;
		m[3] = 0.0;
	
        m[5] = tan;
	
        m[4] = 0.0;
		m[6] = 0.0;
		m[7] = 0.0;
	
        m[8] = 0.0;
		m[9] = 0.0;
		
        m[10] = -zfar / (znear - zfar);
	
        m[11] = 1.0;
	
        m[12] = 0.0;
		m[13] = 0.0;
		m[15] = 0.0;
	
		m[14] = (znear * zfar) / (znear - zfar);
		

		
	}
	

	inline public static function PerspectiveFovLHToRef(fov:Float, aspect:Float, znear:Float, zfar:Float, result:Matrix4):Matrix4 
	{
		var tan = 1.0 / (Math.tan(fov * 0.5));

        result.m[0] = tan / aspect;
        result.m[1] = 0.0;
		result.m[2] = 0.0;
		result.m[3] = 0.0;
        result.m[5] = tan;
        result.m[4] = 0.0;
		result.m[6] = 0.0;
		result.m[7] = 0.0;
        result.m[8] = 0.0;
		result.m[9] = 0.0;
        result.m[10] = -zfar / (znear - zfar);
        result.m[11] = 1.0;
        result.m[12] = 0.0;
		result.m[13] = 0.0;
		result.m[15] = 0.0;
        result.m[14] = (znear * zfar) / (znear - zfar);
		
		return result;
	}
	
	/*public static function AffineTransformation(scaling:Float, rotationCenter:Vector3, rotation:Quaternion, translation:Vector3):Matrix4 {
		return Matrix4.Scaling(scaling, scaling, scaling) * Matrix4.Translation(-rotationCenter) *
            Matrix4.RotationQuaternion(rotation) * Matrix4.Translation(rotationCenter) * Matrix4.Translation(translation);
	}*/
	
	inline public static function GetFinalMatrix3D(viewport:Clip, world:Matrix4, view:Matrix4, projection:Matrix4, zmin:Float, zmax:Float):Matrix4 {
		var cw = viewport.width;
        var ch = viewport.height;
        var cx = viewport.x;
        var cy = viewport.y;

        var viewportMatrix3D = Matrix4.FromValues(
			cw / 2.0, 0, 0, 0,
            0, -ch / 2.0, 0, 0,
            0, 0, zmax - zmin, 0,
            cx + cw / 2.0, ch / 2.0 + cy, zmin, 1
		);

        return world.multiply(view).multiply(projection).multiply(viewportMatrix3D);
	}
	
	inline public static function Transpose(matrix:Matrix4):Matrix4 {
		var result = new Matrix4();

        result.m[0] = matrix.m[0];
        result.m[1] = matrix.m[4];
        result.m[2] = matrix.m[8];
        result.m[3] = matrix.m[12];

        result.m[4] = matrix.m[1];
        result.m[5] = matrix.m[5];
        result.m[6] = matrix.m[9];
        result.m[7] = matrix.m[13];

        result.m[8] = matrix.m[2];
        result.m[9] = matrix.m[6];
        result.m[10] = matrix.m[10];
        result.m[11] = matrix.m[14];

        result.m[12] = matrix.m[3];
        result.m[13] = matrix.m[7];
        result.m[14] = matrix.m[11];
        result.m[15] = matrix.m[15];

        return result;
	}
	
	inline public static function CreateShadowMatrix(plane:Plane, lightDirection:Vector3):Matrix4
	{
		var result = new Matrix4();
		plane.normalize();
		
        var dot:Float = (plane.normal.x * lightDirection.x) + (plane.normal.y * lightDirection.y) + (plane.normal.z * lightDirection.z);
   			
		//xna is inverted ??
        var x = -plane.normal.x;
        var y = -plane.normal.y;
        var z = -plane.normal.z;
		var d = -plane.d;
 
        result.m[0] = (x * lightDirection.x) + dot;
        result.m[1] = x * lightDirection.y;
        result.m[2] = x * lightDirection.z;
        result.m[3] = 0.0;
		
        result.m[4] = y * lightDirection.x;
        result.m[5] = (y * lightDirection.y) + dot;
        result.m[6] = y * lightDirection.z;
        result.m[7] = 0.0;
		
        result.m[8] = z * lightDirection.x;
        result.m[9] = z * lightDirection.y;
        result.m[10] = (z * lightDirection.z) + dot;
        result.m[11] = 0.0;
		
		
        result.m[12] = d * lightDirection.x;
        result.m[13] =d * lightDirection.y;
        result.m[14] =d * lightDirection.z;
        result.m[15] = dot;
		
		return result;

	}
	
	inline public static function Reflection(plane:Plane):Matrix4 {
		var matrix = new Matrix4();
        Matrix4.ReflectionToRef(plane, matrix);

        return matrix;
	}
	
	inline public static function ReflectionToRef(plane:Plane, result:Matrix4):Matrix4 {
		plane.normalize();
        var x = plane.normal.x;
        var y = plane.normal.y;
        var z = plane.normal.z;
        var temp = -2 * x;
        var temp2 = -2 * y;
        var temp3 = -2 * z;
        result.m[0] = (temp * x) + 1;
        result.m[1] = temp2 * x;
        result.m[2] = temp3 * x;
        result.m[3] = 0.0;
        result.m[4] = temp * y;
        result.m[5] = (temp2 * y) + 1;
        result.m[6] = temp3 * y;
        result.m[7] = 0.0;
        result.m[8] = temp * z;
        result.m[9] = temp2 * z;
        result.m[10] = (temp3 * z) + 1;
        result.m[11] = 0.0;
        result.m[12] = temp * plane.d;
        result.m[13] = temp2 * plane.d;
        result.m[14] = temp3 * plane.d;
        result.m[15] = 1.0;
		
		return result;
	}
	
}
