package com.gdx ;

import com.gdx.math.Vector3;
import com.gdx.math.Vector2;
import com.gdx.util.Vector;
import lime.graphics.Image;
import lime.utils.Float32Array;

import lime.math.Rectangle;
import com.gdx.math.Matrix2D;
import com.gdx.math.Matrix4;

import haxe.Constraints.FlatEnum;
import lime.Assets;
import lime.graphics.Image;

import lime.utils.ByteArray;


import com.gdx.math.Matrix2D;
import com.gdx.math.Transform;


#if neko
import sys.io.File;
import sys.io.FileOutput;
#end


 enum Scaling {
	/** Scales the source to fit the target while keeping the same aspect ratio. This may cause the source to be smaller than the
	 * target in one direction. */
	fit;
	/** Scales the source to fill the target while keeping the same aspect ratio. This may cause the source to be larger than the
	 * target in one direction. */
	fill;
	/** Scales the source to fill the target in the x direction while keeping the same aspect ratio. This may cause the source to be
	 * smaller or larger than the target in the y direction. */
	fillX;
	/** Scales the source to fill the target in the y direction while keeping the same aspect ratio. This may cause the source to be
	 * smaller or larger than the target in the x direction. */
	fillY;
	/** Scales the source to fill the target. This may cause the source to not keep the same aspect ratio. */
	stretch;
	/** Scales the source to fill the target in the x direction, without changing the y direction. This may cause the source to not
	 * keep the same aspect ratio. */
	stretchX;
	/** Scales the source to fill the target in the y direction, without changing the x direction. This may cause the source to not
	 * keep the same aspect ratio. */
	stretchY;
	/** The source is not scaled. */
none; }

/**
 * ...
 * @author djoker
 */
 class Util
 {
public static  var v1:Vector3 = new Vector3(0, 0, 0);
public static  var v2:Vector3 = new Vector3(0, 0, 0);
public static  var v3:Vector3 = new Vector3(0, 0, 0);



	 
public static inline var ALIGN_LEFT:Int = 0;
public static  inline var ALIGN_RIGHT:Int = 1;
public static inline var ALIGN_CENTER:Int = 2;
public static  var DEG:Float = -180 / Math.PI;
public static  var  RAD:Float = Math.PI / -180;
public static inline var EPSILON:Float = 0.00000001;
public static var r1:Rectangle = new Rectangle();
public static var r2:Rectangle = new Rectangle();
public static var point:Vector2 = new Vector2();
public static var point2:Vector2 = new Vector2();
    public static inline var E = 2.718281828459045;
    public static inline var LN2 = 0.6931471805599453;
    public static inline var LN10 = 2.302585092994046;
    public static inline var LOG2E = 1.4426950408889634;
    public static inline var LOG10E = 0.43429448190325176;
    public static inline var PI = 3.141592653589793;
    public static inline var SQRT1_2 = 0.7071067811865476;
    public static inline var SQRT2 = 1.4142135623730951;	
	static public var Epsilon 			= 1.0 / 100000.0;
	static public var Rad2Deg 			= 180.0 / PI;
 	static public var Deg2Rad 			= PI / 180.0;
	private static var _seed:Int = 0;
	
	public static var sinTable:Array<Float> = new Array<Float>();
	public static var cosTable:Array<Float> = new Array<Float>();
	
	
		 
	    // Haxe doesn't specify the size of an int or float, in practice it's 32 bits
    /** The lowest integer value in Flash and JS. */
    public static inline var INT_MIN :Int = -2147483648;

    /** The highest integer value in Flash and JS. */
    public static inline var INT_MAX :Int = 2147483647;

    /** The lowest float value in Flash and JS. */
    public static inline var FLOAT_MIN = -1.79769313486231e+308;

    /** The highest float value in Flash and JS. */
    public static inline var FLOAT_MAX = 1.79769313486231e+308;
	
	
	public static inline function createCosSin()
	{
		for (i in 0...360)
        {
         sinTable[i] = Math.sin(Math.PI / 180 * i);
		 cosTable[i] = Math.cos(Math.PI / 180 * i);
        }
	}
	
	public static inline function Sin(angle:Float):Float
	{
		 var a:Int = Std.int(angle);
		 if (a < 0) a = 360;
 		 if (a >360 ) a = 0;
         return sinTable[a] ;
   }
   public static inline function Cos(angle:Float):Float
	{
		 var a:Int = Std.int(angle);
		 if (a < 0) a = 360;
 		 if (a >360 ) a = 0;
         return cosTable[a] ;
   }
   public static inline function ArcCos(x:Float):Float
   {
	   return Math.atan2(Math.sqrt(1 - x * x), x);
   }
     public static inline function Absolute(num:Float):Float
{
	// If num is less than zero, we want to return the absolute value of num.
	// This is simple, either we times num by -1 or subtract it from 0.
	if(num < 0)
		return (0 - num);

	// Return the original number because it was already positive
	return num;
}
	

public static inline function isEquivalent(a:Float, b:Float, epsilon:Float=0.0001):Bool
        {
            return (a - epsilon < b) && (a + epsilon > b);
        }
        
public static inline function normalizeAngle(angle:Float):Float
        {
            // move into range [-180 deg, +180 deg]
            while (angle < -Math.PI) angle += Math.PI * 2.0;
            while (angle >  Math.PI) angle -= Math.PI * 2.0;
            return angle;
        }

public static inline function WithinEpsilon(a:Float, b:Float):Bool {
        var num:Float = a - b;
        return -1.401298E-45 <= num && num <= 1.401298E-45;
    }

public static inline function getColorValue(color:Int):Float
	{
		var h:Int = (color >> 16) & 0xFF;
		var s:Int = (color >> 8) & 0xFF;
		var v:Int = color & 0xFF;

		return Std.int(Math.max(h, Math.max(s, v))) / 255;
	}
public static inline function deg2rad(deg:Float):Float
    {
        return deg / 180.0 * Math.PI;   
    }
public static inline function rad2deg(rad:Float):Float
    {
        return rad / Math.PI * 180.0;            
    }

inline static public function CurveValue(newvalue:Float, oldvalue:Float, increments:Float):Float
{
if (increments>1.0)  oldvalue=oldvalue-(oldvalue-newvalue)/increments;
if (increments <= 1.0) oldvalue = newvalue;

return oldvalue;
}

		/*
public static inline function getScaled(source:BitmapData, newWidth:Int, newHeight:Int):BitmapData 
	{
	   var bmp:BitmapData = new BitmapData(newWidth, newHeight, true,0);
		bmp.copyPixels( source, source.rect, new Point(), null, null, true );
		source.dispose();
		return bmp;
	}

	
inline static public function getScaledDraw(source:BitmapData, newWidth:Int, newHeight:Int):BitmapData
{
var m:flash.geom.Matrix = new flash.geom.Matrix();
m.scale(newWidth / source.width, newHeight / source.height);

var bmp:BitmapData = new BitmapData(newWidth, newHeight, true,0);

bmp.draw(source, m);
return bmp;
}
	*/
//helper methods
	public static inline function roundUpToPow2( number:Int ):Int
	{
		number--;
		number |= number >> 1;
		number |= number >> 2;
		number |= number >> 4;
		number |= number >> 8;
		number |= number >> 16;
		number++;
		return number;
	}
	/*
	public static inline function isTextureOk( texture:BitmapData ):Bool
	{
		return ( roundUpToPow2( texture.width ) == texture.width ) && ( roundUpToPow2( texture.height ) == texture.height );
	}
	
	public static inline function getScaledDontFit( texture:BitmapData ):BitmapData
	{
		return if ( isTextureOk( texture ) )
		{
			texture;
		}
		else
		{
			var newTexture:BitmapData = new BitmapData( roundUpToPow2( texture.width ), roundUpToPow2( texture.height ), false, 0xffffff);
			
			newTexture.copyPixels( texture, texture.rect, new Point(), null, null, true );
			
			texture.dispose();
			
			newTexture;
		}
	}
	
	
	

	
	
public static  function flipBitmapData(original:BitmapData, axis:String = "y"):BitmapData
{
     var flipped:BitmapData = new BitmapData(original.width, original.height, true, 0);
     var matrix:Matrix;
     if(axis == "x"){
          matrix = new Matrix( -1, 0, 0, 1, original.width, 0);
     } else {
          matrix = new Matrix( 1, 0, 0, -1, 0, original.height);
     }
     flipped.draw(original, matrix , null, null, null, true);
     return flipped;
}
public static inline function setBitmapDataCK(original:String, color:UInt):BitmapData
{
         var image:BitmapData = getBitmap(original);
		 replaseColorBitmapData(image, color, 0);
		 return image;
}
public static inline function convertImageCK(original:String,savefile:String, color:UInt)
{

         var image:BitmapData = getBitmap(original);
		 replaseColorBitmapData(image, color, 0);
		 saveBitmapData(image, savefile);
}
public static inline function convertImageCK1Pixel(original:String,savefile:String, color:UInt)
{

         var image:BitmapData = getBitmap(original);
		 replaseColorBitmapData1pixel(image, color);
		 saveBitmapData(image, savefile);
}

public static inline function convertImageCKwith(original:String,savefile:String, color:UInt,newcolor:UInt)
{

         var image:BitmapData = getBitmap(original);
		 replaseColorBitmapData(image, color, newcolor);
		 saveBitmapData(image, savefile);
}

public static inline function replaseColorBitmapData1pixel(original:BitmapData,dst:UInt)
{
 
	var src:UInt = original.getPixel(0, 0);
	
for(x in 0...original.width)
{
    for(y in 0...original.height)
    {
		
        if(original.getPixel(x,y) == src)
        {
             original.setPixel32(x, y, dst);
        }
    }
	
}
}
public static inline function replaseColorBitmapData(original:BitmapData,src:UInt,dst:UInt)
{
 
for(x in 0...original.width)
{
    for(y in 0...original.height)
    {
		
        if(original.getPixel(x,y) == src)
        {
             original.setPixel32(x, y, dst);
        }
    }
	
}
}
public static inline function getBitmap( filename:String):BitmapData
{
	      return  Assets.getBitmapData(filename);
}
public static inline function saveBitmapData(data:BitmapData,filename:String)
{
#if neko
  var b:ByteArray = data.encode("png");
  var f:FileOutput = File.write(filename);
  f.writeString(b.toString());
  f.close();
#end
}
*/

public static inline function removeColorBitmapData(original:Image,color:UInt)
{
 if (original == null)
 {
	 throw("Bitmap is NULL dumb ass");
 }
for(x in 0...original.width)
{
    for(y in 0...original.height)
    {
		
        if(original.getPixel(x,y) == color)
        {
            
            original.setPixel32(x, y, 0xFF000000);
        }
    }
	
}
}

public static inline function saveBitmapData(data:Image,filename:String)
{
#if neko

  var b:ByteArray = data.encode("png");
  var f:FileOutput = File.write(filename);
trace(b.bytesAvailable);
//  f.writeString(b.toString());
  f.close();
#end
}
public static inline function setMatrix3DOrtho(m:Matrix4,x0:Float, x1:Float,  y0:Float, y1:Float, zNear:Float, zFar:Float) :Void
   {
      var sx = 1.0 / (x1 - x0);
      var sy = 1.0 / (y1 - y0);
      var sz = 1.0 / (zFar - zNear);

	 m.m=new Float32Array([
         2.0*sx,       0,          0,                 0,
         0,            2.0*sy,     0,                 0,
         0,            0,          -2.0*sz,           0,
         - (x0+x1)*sx, - (y0+y1)*sy, - (zNear+zFar)*sz,  1,
      ]);

	  
     
   }
   public static inline function setMatrix3D2D(m:Matrix4,x:Float, y:Float, scale:Float = 1, rotation:Float = 0):Void 
   {
      var theta = rotation * Math.PI / 180.0;
      var c = Math.cos(theta);
      var s = Math.sin(theta);


	 m.m=new Float32Array([
        c*scale,  -s*scale, 0,  0,
        s*scale,  c*scale, 0,  0,
        0,        0,        1,  0,
       x,        y,        0,  1
      ]);

	
	  
	  

   }
public static inline function skew(matrix:Matrix2D, skewX:Float, skewY:Float)
        {
            var sinX:Float = Math.sin(skewX);
            var cosX:Float = Math.cos(skewX);
            var sinY:Float = Math.sin(skewY);
            var cosY:Float = Math.cos(skewY);
           
            matrix.setTo(matrix.a  * cosY - matrix.b  * sinX,
                         matrix.a  * sinY + matrix.b  * cosX,
                         matrix.c  * cosY - matrix.d  * sinX,
                         matrix.c  * sinY + matrix.d  * cosX,
                         matrix.tx * cosY - matrix.ty * sinX,
                         matrix.tx * sinY + matrix.ty * cosX);
        }
		
		  /** Uses a matrix to transform 2D coordinates into a different space. If you pass a 
         *  'resultPoint', the result will be stored in this point instead of creating a new object.*/
        public static inline function transformCoords(matrix:Matrix2D, x:Float, y:Float,
                                               resultPoint:Vector2=null):Vector2
        {
            if (resultPoint == null) resultPoint = new Vector2();   
            
            resultPoint.x = matrix.a * x + matrix.c * y + matrix.tx;
            resultPoint.y = matrix.d * y + matrix.b * x + matrix.ty;
            
            return resultPoint;
        }
  public static inline function transform(m:Matrix2D,x :Float, y :Float, ?result :Vector2) :Vector2
    {
        if (result == null) 
		{
            result = new Vector2();
			
        }
	
        result.x = x*m.a + y*m.c + m.tx;
        result.y = x*m.b + y*m.d + m.ty;
        return result;
    }


public static inline function createOrtho(x0:Float, x1:Float,  y0:Float, y1:Float, zNear:Float, zFar:Float) :Matrix4
   {
      var sx = 1.0 / (x1 - x0);
      var sy = 1.0 / (y1 - y0);
      var sz = 1.0 / (zFar - zNear);

      
	  var result:Matrix4 = new  Matrix4();
	  

	 result.m==new Float32Array( [
         2.0*sx,       0,          0,                 0,
         0,            2.0*sy,     0,                 0,
         0,            0,          -2.0*sz,           0,
         - (x0+x1)*sx, - (y0+y1)*sy, - (zNear+zFar)*sz,  1,
      ]);

	
	 
	  return result;
   }

public static inline function getExponantOfTwo(value:Int, max:Int):Int {
        var count:Int = 1;

        do {
            count *= 2;
        } while (count < value);

        if (count > max)
            count = max;

        return count;
    }
	
public static inline function getNextPowerOfTwo(number:Int):Int
    {
        if (number > 0 && (number & (number - 1)) == 0) // see: http://goo.gl/D9kPj
            return number;
        else
        {
            var result:Int = 1;
            while (result < number) result <<= 1;
            return result;
        }
    }
	
public static inline function createMtrix2D(x:Float, y:Float, scale:Float = 1, rotation:Float = 0):Matrix4 
   {
      var theta = rotation * Math.PI / 180.0;
      var c = Math.cos(theta);
      var s = Math.sin(theta);

	  var mat:Matrix4 = new Matrix4();
	  
	
	 mat.m=new Float32Array([
        c*scale,  -s*scale, 0,  0,
        s*scale,  c*scale, 0,  0,
        0,        0,        1,  0,
       x,        y,        0,  1
      ]);

	
	 
	  return mat;
   }	


/*
public static inline function createClipSheets( img:Texture,frameWidth:Int, frameHeight:Int):Array<Clip>
	{
		if (img == null) return null;
	    var keyFrames:Array<Clip> = [];
		var columns:Int =Std.int( img.width  / frameWidth) ;
		var rows:Int    = Std.int( img.height / frameHeight ); 
		
		//	trace('WIDTH:' + frameWidth + '<>HEIGH' + frameHeight + '<> COLUMNS:' + columns + '<> ROWS:' + rows + '<> num frames:' + columns*rows);
			
	    for ( y in 0...rows)
	    {
		 for (x in 0...columns)
		 {
		  var rect:Clip = new Clip(x * frameWidth, y * frameHeight, frameWidth, frameHeight, 0, 0);
	      keyFrames.push(rect);	
		}
	}
	return keyFrames;
	}
public static inline function createClipSheetsEx( img:Texture,countx:Int,county:Int):Array<Clip>
	{
		if (img == null) return null;
	    var keyFrames:Array<Clip> = [];
		var frameWidth:Int  = Std.int(img.width  / countx);
		var frameHeight:Int = Std.int(img.height / county);
		var columns:Int =Std.int( img.width  / frameWidth );
		var rows:Int    =Std.int( img.height / frameHeight ); 

	for ( y in 0...rows)
	{
		for (x in 0...columns)
		{
		var rect:Clip = new Clip(x * frameWidth, y * frameHeight, frameWidth, frameHeight, 0, 0);
	   keyFrames.push(rect);	
		}
	}
	return keyFrames;
	}	
public static inline function createClipSheetsBorder( img:Texture,frameWidth:Int, frameHeight:Int,margin:Int,spacing:Int):Array<Clip>
	{
		if (img == null) return null;
	    var keyFrames:Array<Clip> = [];
		var columns:Int =Std.int( img.width  / frameWidth );
		var rows:Int    = Std.int( img.height / frameHeight ); 
		var count = (columns * rows);
		for (num in 0...count)
		{
			
			var rect:Clip=new  Clip(
			margin + (frameWidth  + spacing) * num % columns,
			margin + (frameHeight + spacing) * Std.int(num / columns),
			frameWidth, frameHeight);
			keyFrames.push(rect);
		}
     return keyFrames;
	}
	*/
public static inline function distAbs(x1:Float,  x2:Float ):Float
	{
		return Util.sign(Math.atan(x1-x2));
	}
	
public static inline function anglerad(x1:Float, y1:Float, x2:Float, y2:Float):Float
		{
			return Math.atan2(y2 - y1, x2 - x1) ;
	
		}
		
public static inline function VectorAngle(a:Vector2, b:Vector2): Float
{
return 	anglerad(a.x, a.y, b.x, b.y);
}
public static inline function VectorAnglTan(a:Vector2): Float
{
return Math.atan2(a.y,a.x);
}

public static inline function VectorNormalize( v: Vector2) :Vector2
{
 return VectorDivS(v,VectorMagnitude(v));
}
public static inline function VectorMagnitude(v: Vector2):Float
        {return Math.sqrt((v.x*v.x) + (v.y*v.y));}
   
public static inline function VectorDivS(v:Vector2, s: Float):Vector2
{

  point.x = v.x/s;
  point.y = v.y / s;
  return point;
}


public static inline function VectorScale( v: Vector2, Scalar: Float):Vector2
{
  v.x = v.x * Scalar;
  v.y = v.y * Scalar;
  return v;
}
public static inline function VectorIncrement( a:Vector2,b:Vector2):Vector2
{
  a.x = a.x + b.x;
  a.y = a.y + b.y;
  return a;
}
	public static inline function scale(value:Float, min:Float, max:Float, min2:Float, max2:Float):Float
	{
		return min2 + ((value - min) / (max - min)) * (max2 - min2);
	}
public static inline function fMod(n:Float, d:Float):Float	
{
	var i:Int = Math.round(n / d);
	return n - d * i;
}
	

		public static function iclamp(value:Int, min:Int, max:Int):Int
	{
		if (max > min)
		{
			if (value < min) return min;
			else if (value > max) return max;
			else return value;
		}
		else
		{
			// Min/max swapped
			if (value < max) return max;
			else if (value > min) return min;
			else return value;
		}
	}
	public static function percentage(  value:Float,  min:Float,  max:Float ):Float
    {
     value = Util.clamp( value, min, max );
    return ( value - min ) / ( max - min );
    }
	public static function clamp(value:Float, min:Float, max:Float):Float
	{
		if (max > min)
		{
			if (value < min) return min;
			else if (value > max) return max;
			else return value;
		}
		else
		{
			// Min/max swapped
			if (value < max) return max;
			else if (value > min) return min;
			else return value;
		}
	}
  	public static inline function isValidElement(element:Xml):Bool
	{
		return Std.string(element.nodeType) == "element";
	}
	
	public static inline function distance(x1:Float, y1:Float, x2:Float = 0, y2:Float = 0):Float
	{
		return Math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
	}
		public static inline function distanceSquared(x1:Float, y1:Float, x2:Float = 0, y2:Float = 0):Float
	{
		return (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1);
	}
	
	public static inline function lerp(a:Float, b:Float, t:Float = 1):Float
	{
		return a + (b - a) * t;
	}	
		public static inline function round(num:Float, precision:Int):Float
	{
		var exp:Float = Math.pow(10, precision);
		return Math.round(num * exp) / exp;
	}
		public static inline function bound(Value:Float, Min:Float, Max:Float):Float
	{
		var lowerBound:Float = (Value < Min) ? Min : Value;
		return (lowerBound > Max) ? Max : lowerBound;
	}
		public static inline function sign(value:Float):Int
	{
		return value < 0 ? -1 : (value > 0 ? 1 : 0);
	}
	public static inline function signf(value:Float):Float
	{
		return value < 0 ? -1 : (value > 0 ? 1 : 0);
	}
	
	//**************************************************************
	
	public static function base64ToArray(chunk:String, lineWidth:Int, compressed:Bool):Array<Int>{
		var result:Array<Int> = new Array<Int>();
		var data:ByteArray = base64ToByteArray(chunk);

		if(compressed)
			#if js
				throw "No support for compressed maps in html5 target!";
			#end
			#if !js
				data.uncompress();
			#end
		data.endian = "LITTLE_ENDIAN";

		while(data.position < data.length){
			result.push(data.readInt());
		}
		return result;
	}

	private static inline var BASE64_CHARS:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

	public static function base64ToByteArray(data:String):ByteArray{
		var output:ByteArray = new ByteArray();

		//initialize lookup table
		var lookup:Array<Int> = new Array<Int>();
		var c:Int;
		for (c in 0...BASE64_CHARS.length){
			lookup[BASE64_CHARS.charCodeAt(c)] = c;
		}

		var i:Int = 0;

		while (i < data.length - 3) {
			// Ignore whitespace
			if (data.charAt(i) == " " || data.charAt(i) == "\n"){
				i++; continue;
			}

			//read 4 bytes and look them up in the table
			var a0:Int = lookup[data.charCodeAt(i)];
			var a1:Int = lookup[data.charCodeAt(i + 1)];
			var a2:Int = lookup[data.charCodeAt(i + 2)];
			var a3:Int = lookup[data.charCodeAt(i + 3)];

			// convert to and write 3 bytes
			if(a1 < 64)
				output.writeByte((a0 << 2) + ((a1 & 0x30) >> 4));
			if(a2 < 64)
				output.writeByte(((a1 & 0x0f) << 4) + ((a2 & 0x3c) >> 2));
			if(a3 < 64)
				output.writeByte(((a2 & 0x03) << 6) + a3);

			i += 4;
		}

		// Rewind & return decoded data
		output.position = 0;
		return output;
	}
	
	//*******************************************************
	public static inline function clearArray(arr:Array<Dynamic>){
       #if (cpp||php)
          arr.splice(0,arr.length);
       #else
          untyped arr.length = 0;
       #end
   }
   //******************************************
   	public static inline function getColorRGB(R:Int = 0, G:Int = 0, B:Int = 0):Int
	{
		return R << 16 | G << 8 | B;
	}
		public static inline function getColorRGBA(R:Int = 0, G:Int = 0, B:Int = 0,A:Int=0):Int
	{
		return A<<24 | R << 16 | G << 8 | B;
	}
	//********************************************
	 public static inline function   Linear( timePassed:Float,  start:Float,  distance:Float,  duration:Float):Float
        {
            return distance * timePassed / duration + start;
        }

        public static inline function   EaseOutExpo( timePassed:Float,  start:Float,  distance:Float,  duration:Float):Float
        {
            if (timePassed == duration)
            {
                return start + distance;
            }
            return distance * (-Math.pow(2, -10 * timePassed / duration) + 1) + start;
        }

        public static inline function   EaseInExpo( timePassed:Float,  start:Float,  distance:Float,  duration:Float):Float
        {
            if (timePassed == 0)
            {
                return start;
            }
            else
            {
                return distance * Math.pow(2, 10 * (timePassed / duration - 1)) + start;
            }
        }

        public static inline function   EaseOutCirc( timePassed:Float,  start:Float,  distance:Float,  duration:Float):Float
        {
            return distance * Math.sqrt(1 - (timePassed = timePassed / duration - 1) * timePassed) + start;
        }

        public static inline function   EaseInCirc( timePassed:Float,  start:Float,  distance:Float,  duration:Float):Float
        {
            return -distance * (Math.sqrt(1 - (timePassed /= duration) * timePassed) - 1) + start;
        }

        public static inline function   BounceEaseOut( timePassed:Float,  start:Float,  distance:Float,  duration:Float)
        {
            if ((timePassed /= duration) < (1 / 2.75))
                return distance * (7.5625 * timePassed * timePassed) + start;
            else if (timePassed < (2 / 2.75))
                return distance * (7.5625 * (timePassed -= (1.5 / 2.75)) * timePassed + 0.75) + start;
            else if (timePassed < (2.5 / 2.75))
                return distance * (7.5625 * (timePassed -= (2.25 / 2.75)) * timePassed + 0.9375) + start;
            else
                return distance * (7.5625 * (timePassed -= (2.625 / 2.75)) * timePassed + 0.984375) + start;
        }

        public static inline function   BounceEaseIn( timePassed:Float,  start:Float,  distance:Float,  duration:Float):Float
        {
            return distance - BounceEaseOut(duration - timePassed, 0, distance, duration) + start;
        }

        public static inline function   BounceEaseInOut( timePassed:Float,  start:Float,  distance:Float,  duration:Float):Float
        {
            if (timePassed < duration / 2)
                return BounceEaseIn(timePassed * 2, 0, distance, duration) * 0.5 + start;
            else
                return BounceEaseOut(timePassed * 2 - duration, 0, distance, duration) * 0.5 + distance * 0.5 + start;
        }

		  public static inline function getScale(mode:Scaling, sourceWidth:Float, sourceHeight:Float,  targetWidth:Float, targetHeight:Float):Vector2
		  {
			  var temp:Vector2 = new Vector2();
			  	  var targetRatio:Float = 0;
		          var sourceRatio:Float = 0;
				   var  scale:Float = 0;
				   
	
		  
		  switch (mode) {
		case fit: {
		   targetRatio = targetHeight / targetWidth;
		   sourceRatio = sourceHeight / sourceWidth;
		   scale = targetRatio > sourceRatio ? targetWidth / sourceWidth : targetHeight / sourceHeight;
			temp.x = sourceWidth * scale;
			temp.y = sourceHeight * scale;
	
		}
		case fill: {
		 targetRatio = targetHeight / targetWidth;
		   sourceRatio = sourceHeight / sourceWidth;
			 scale = targetRatio < sourceRatio ? targetWidth / sourceWidth : targetHeight / sourceHeight;
			temp.x = sourceWidth * scale;
			temp.y = sourceHeight * scale;
	
		}
		case fillX: {
			 targetRatio = targetHeight / targetWidth;
			 sourceRatio = sourceHeight / sourceWidth;
			 scale = targetWidth / sourceWidth;
			 temp.x = sourceWidth * scale;
			temp.y = sourceHeight * scale;
	
		}
		case fillY: {
			 targetRatio = targetHeight / targetWidth;
			 sourceRatio = sourceHeight / sourceWidth;
			 scale = targetHeight / sourceHeight;
			temp.x = sourceWidth * scale;
			temp.y = sourceHeight * scale;
	
		}
		case stretch:
			{
			temp.x = targetWidth;
			temp.y = targetHeight;
			}
		case stretchX:
			{
			temp.x = targetWidth;
			temp.y = sourceHeight;
			}
		case stretchY:
			{
			temp.x = sourceWidth;
			temp.y = targetHeight;
			}
		case none:
			{
			temp.x = sourceWidth;
			temp.y = sourceHeight;
			}
		
		}
		return temp;
	}
	
	public static inline function randf(max:Float, min:Float ):Float
{	
     return Math.random() * (max - min) + min;
}
public static inline function randi(max:Int, min:Int ):Int
{
	return Std.int(Math.random() * (max - min) + min);
     
}

/**
	 * The random seed used by HXP's random functions.
	 */
	public static var randomSeed(default, set):Int = 0;
	private static inline function set_randomSeed(value:Int):Int
	{
		_seed = Std.int(clamp(value, 1.0, INT_MAX - 1));
		randomSeed = _seed;
		return _seed;
	}

	/**
	 * Randomizes the random seed using Flash's Math.random() function.
	 */
	public static inline function randomizeSeed()
	{
		randomSeed = Std.int(INT_MAX * Math.random());
	}

	/**
	 * A pseudo-random Float produced using HXP's random seed, where 0 <= Float < 1.
	 */
	public static var random(get, null):Float;
	private static inline function get_random():Float
	{
		_seed = Std.int((_seed * 16807.0) % INT_MAX);
		return _seed / INT_MAX;
	}

	/**
	 * Returns a pseudo-random Int.
	 * @param	amount		The returned Int will always be 0 <= Int < amount.
	 * @return	The Int.
	 */
	public static inline function rand(amount:Int):Int
	{
		_seed = Std.int((_seed * 16807.0) % INT_MAX);
		return Std.int((_seed / INT_MAX) * amount);
	}

	/**
	 * The choose function randomly chooses and returns one of the provided values.
	 */
	public static var choose = Reflect.makeVarArgs(function(objs:Array<Dynamic>) {
		if (objs == null || objs.length == 0)
		{
			throw "Can't choose a random element on an empty array";
		}

		if (Std.is(objs[0], Array)) // Passed an Array
		{
			var c:Array<Dynamic> = cast(objs[0], Array<Dynamic>);

			if (c.length != 0)
			{
				return c[rand(c.length)];
			}
			else
			{
				throw "Can't choose a random element on an empty array";
			}
		}
		else // Passed multiple args
		{
			return objs[rand(objs.length)];
		}
	});
	
	/**
	 * Empties an array of its' contents
	 * @param array filled array
	 */
	public static inline function clear(array:Array<Dynamic>)
	{
#if (cpp || php)
		array.splice(0, array.length);
#else
		untyped array.length = 0;
#end
	}
	    /** Converts an angle in degrees to radians. */
    inline public static function toRadians (degrees :Float) :Float
    {
        return degrees * PI/180;
    }

    /** Converts an angle in radians to degrees. */
    inline public static function toDegrees (radians :Float) :Float
    {
        return radians * 180/PI;
    }


	/**
	 * Finds the red factor of a color.
	 * @param	color		The color to evaluate.
	 * @return	A Int from 0 to 255.
	 */
	public static inline function getRed(color:Int):Int
	{
		return color >> 16 & 0xFF;
	}

	/**
	 * Finds the green factor of a color.
	 * @param	color		The color to evaluate.
	 * @return	A Int from 0 to 255.
	 */
	public static inline function getGreen(color:Int):Int
	{
		return color >> 8 & 0xFF;
	}

	/**
	 * Finds the blue factor of a color.
	 * @param	color		The color to evaluate.
	 * @return	A Int from 0 to 255.
	 */
	public static inline function getBlue(color:Int):Int
	{
		return color & 0xFF;
	}


 
private static inline	function degTorad(degrees:Float):Float
{
	 var M_PI:Float =3.14159265358979323846;
     var DEG_CIRCLE:Float =360;
     var DEG_TO_RAD:Float= (M_PI / (DEG_CIRCLE / 2));
    return degrees * DEG_TO_RAD;
 
}
private static inline	function radTodeg(degrees:Float):Float
{
	 var M_PI:Float =3.14159265358979323846;
     var DEG_CIRCLE:Float =360;
     var RAD_TO_DEG:Float = ((DEG_CIRCLE / 2) / M_PI);
	 return degrees * RAD_TO_DEG;
 
}	
public static inline	function cosdeg(degrees:Float):Float
{
	return  Math.cos(degTorad(degrees));  
}

public static inline function sindeg( degrees:Float):Float
{
	return return  Math.sin(degTorad(degrees));
}

public static inline function ComputeNormal(positions:Array<Float>, normals:Array<Float>, indices:Array<Int>) 
  {
		var positionVectors:Array<Vector3> = [];
        var facesOfVertices:Array<Array<Int>> = [];
		
        var index:Int = 0;

		while (index < positions.length) 
		{
            var vector3 = new Vector3(positions[index], positions[index + 1], positions[index + 2]);
            positionVectors.push(vector3);
            facesOfVertices.push([]);
			index += 3;
        }
		
        // Compute normals
        var facesNormals:Array<Vector3> = [];
        for (index in 0...Std.int(indices.length / 3)) {
            var i1 = indices[index * 3];
            var i2 = indices[index * 3 + 1];
            var i3 = indices[index * 3 + 2];

            var p1 = positionVectors[i1];
            var p2 = positionVectors[i2];
            var p3 = positionVectors[i3];

            var p1p2 = p1.subtract(p2);
            var p3p2 = p3.subtract(p2);

            facesNormals[index] = Vector3.Normalize(Vector3.Cross(p1p2, p3p2));
            facesOfVertices[i1].push(index);
            facesOfVertices[i2].push(index);
            facesOfVertices[i3].push(index);
        }

        for (index in 0...positionVectors.length) 
		{
            var faces:Array<Int> = facesOfVertices[index];

            var normal:Vector3 = Vector3.Zero();
            for (faceIndex in 0...faces.length) 
			{
                normal.addInPlace(facesNormals[faces[faceIndex]]);
            }

            normal = Vector3.Normalize(normal.scale(1.0 / faces.length));

            normals[index * 3] = normal.x;
            normals[index * 3 + 1] = normal.y;
            normals[index * 3 + 2] = normal.z;
        }
	}
	public static function toByteArray(data:Dynamic):ByteArray
		{
			if (Std.is(data, Class)) {
				//data = new data();
				data = Type.createInstance(data,[]);
			}
			
			if (Std.is(data, ByteArray))
				return data;
			else
				return null;
		}
		
	
		public static function toString(data:Dynamic, length:UInt = 0):String
		{
			var ba:ByteArray;

			if (length==0) length = 0xffffffff;
			
			if (Std.is(data, String)) {
				var dS:String = cast data;
				return dS.substr(0, Std.int(Math.min(length, dS.length)));
			}
					
			ba = toByteArray(data);
			if (ba!=null) {
				ba.position = 0;
				return ba.readUTFBytes(Std.int(Math.min(ba.bytesAvailable, length)));
			}
			
			return null;
		}
		
			public static function reSize<T>( either:AcceptEither<Array<T>,Vector<T>>, count:Int, ?defaultValue:Dynamic = null) {
		switch either.type {
        	case Left(arr):
				var c = arr.length;		
				while (c < count) {
					arr.push(defaultValue);
					c++;
				}				
				while (c > count) {
					arr.pop();
					c--;
				}			
				for (i in 0...arr.length) {
					arr[i] = defaultValue;
				}
        	case Right(arr):
				var c = arr.length;		
				while (c < count) {
					arr.push(defaultValue);
					c++;
				}				
				while (c > count) {
					arr.pop();
					c--;
				}			
				for (i in 0...arr.length) {
					arr[i] = defaultValue;
				}
		}
	}


	public static function Prefill<T>( either:AcceptEither<Array<T>,Vector<T>>, count:Int, ?elem:T ):Dynamic {
		switch either.type {
        	case Left(arr):
				arr.splice(0, arr.length);
				var c:Int = 0;
				while (c++ < count) {
					arr.push(elem);
				}
				return arr;
        	case Right(vec): 
				vec.splice(0, vec.length);
				var c:Int = 0;
				while (c++ < count) {
					vec.push(elem);
				}
				return vec;
     	}
	}
	
}

abstract AcceptEither<A,B> (Either<A,B>) {
	
	public inline function new( e:Either<A,B> ) this = e;
	
	public var value(get,never):Dynamic;
	public var type(get,never):Either<A,B>;

	inline function get_value() switch this { case Left(v) | Right(v): return v; }
	@:to inline function get_type() return this;
	
	@:from static function fromA( v:A ):AcceptEither<A,B> return new AcceptEither( Left(v) );
	@:from static function fromB( v:B ):AcceptEither<A,B> return new AcceptEither( Right(v) );
}

enum Either<A,B> {
	Left( v:A );
	Right( v:B );
}