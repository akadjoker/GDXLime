package com.gdx.util;


import lime.utils.Float32Array;
import lime.graphics.Image;
import lime.graphics.ImageBuffer;
import lime.Assets;

/**
 * ...
 * @author Luis Santos AKA DJOKER
 */
class HeightMap
{
  public static inline var PRECISION_LOW:Int = 32;
  public static inline var PRECISION_HIGH:Int = 8;
  public static inline var PRECISION_AVERAGE:Int = 16;
  public static inline var PRECISION_BEST:Int = 4;
  public static inline var PRECISION_ULTRA:Int = 2;
  
public var data:Float32Array;
public var width:Int;
public var height:Int;
public var precision:Float;

	public function new() 
	{
		data = null;
		width = 0;
		height = 0;
	}
	public function setFromImagePixels(filename:String):Void
	{
		if (Assets.exists(filename))
		{
	 var image:Image =  Assets.getImage(filename);
	 width  = image.width;
	 height = image.height;
	 
	 data = new Float32Array(width * height );
	 for (x in 0...width)
	 {
		 for (y in 0...height)
		 {
			        var color:Int = image.getPixel(x,y);
					var r = Util.getRed(color)  / 255;
		            var g = Util.getGreen(color) / 255;
		            var b = Util.getBlue(color) / 255;
		            var gradient = r * 0.3 + g * 0.59 + b * 0.11;
			        setData(x, y, gradient);
		 }
	 }
		}
	}
	public function setFromImage(filename:String,Precision:Float = 2):Void
	{
	precision = Precision;
	if (Assets.exists(filename))
	{
	 var image:Image =  Assets.getImage(filename);
	 width = Math.round( image.width  / Precision);
     height= Math.round( image.height / Precision);
	 
	 data = new Float32Array(width * height );
	 for (x in 0...width)
	 {
		 for (y in 0...height)
		 {
			 
			        var xl = Math.round(x / (width-1  ) * image.width  );
		            var yl = Math.round(y / (height-1 ) * image.height );
					
					var color:Int = image.getPixel(xl,yl);
					var r = Util.getRed(color)  / 255;
		            var g = Util.getGreen(color) / 255;
		            var b = Util.getBlue(color) / 255;
		            var gradient = r * 0.3 + g * 0.59 + b * 0.11;
				    setData(x, y, gradient);
		 }
	 }
		}
	}
	public function setData(x:Int, y:Int, v:Float):Void
	{
		data[x + (y * width)] = v;
	}
	public function getData(x:Int, y:Int):Float
	{
		return data[x + (y * width)];
	}
}