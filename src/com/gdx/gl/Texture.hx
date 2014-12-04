package com.gdx.gl ;

import com.gdx.Clip;

import lime.Assets;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLShader;
import lime.graphics.opengl.GLUniformLocation;
import lime.graphics.opengl.GLTexture;
import lime.graphics.RenderContext;
import lime.utils.Float32Array;
import lime.utils.Int16Array;
import lime.utils.UInt8Array;

import lime.graphics.Image;


/**
 * ...
 * @author djoker
 */
class Texture
{
	public static inline var TEX_REPEAT						 = 0;
	public static inline var TEX_CLAMP						 = 1;
	public static inline var TEX_MIRRORED					 = 2;
	
	public static var Linear:Bool = true;
    public var data:GLTexture;
	public var width:Int;	
	public var height:Int;
	public var texHeight:Int;
	public var texWidth:Int;
	public var name:String;
	private var exists:Bool;
	public var invTexWidth:Float;
	public var invTexHeight:Float;
	public var clip:Clip;
	public var isCube:Bool;
	
	public function Bind(unit:Int=0)
	{
  	GL.activeTexture(GL.TEXTURE0 + unit);
	if (isCube)
	{
		GL.bindTexture(GL.TEXTURE_CUBE_MAP, data);
	}else
	{
	
		GL.bindTexture(GL.TEXTURE_2D, data);
	}
    }

	public function roundUpToPow2( number:Int ):Int
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
	public  function isTextureOk( texture:Image ):Bool
	{
		return ( roundUpToPow2( texture.width ) == texture.width ) && ( roundUpToPow2( texture.height ) == texture.height );
	}

     public function new()
     {
		 isCube = false;
     }

	
	 	public function createCubeTexture(rootUrl:String ):Void 
		{	
			
			var extensions:Array<String> = new Array<String>();
			extensions= ["_px.jpg", "_py.jpg", "_pz.jpg", "_nx.jpg", "_ny.jpg", "_nz.jpg"];
		
			
			data=GL.createTexture(); 
            GL.bindTexture (GL.TEXTURE_CUBE_MAP, data);

		
		isCube = true;
        
		var faces = [
                GL.TEXTURE_CUBE_MAP_POSITIVE_X, GL.TEXTURE_CUBE_MAP_POSITIVE_Y, GL.TEXTURE_CUBE_MAP_POSITIVE_Z,
                GL.TEXTURE_CUBE_MAP_NEGATIVE_X, GL.TEXTURE_CUBE_MAP_NEGATIVE_Y, GL.TEXTURE_CUBE_MAP_NEGATIVE_Z
            ];
		
		function _setTex(imagePath:String, index:Int) 
		{
		var bitmapData:Image = Assets.getImage(imagePath);	
			
		this.width =bitmapData.width;
		this.height = bitmapData.height;
		this.texWidth =  roundUpToPow2(width);
		this.texHeight = roundUpToPow2(height);
		
				
			  #if html5
			var pixelData = bitmapData.getPixels(bitmapData.rect).byteView;
			GL.texImage2D(faces[index], 0, GL.RGBA, width,height, 0, GL.RGBA, GL.UNSIGNED_BYTE,pixelData );
			#else
			GL.texImage2D(faces[index], 0, GL.RGBA, width,height, 0, GL.RGBA, GL.UNSIGNED_BYTE,bitmapData.buffer.data );
			#end
		}
		
		GL.bindTexture(GL.TEXTURE_CUBE_MAP, data);	
		GL.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
		GL.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
		
		
		for (i in 0...extensions.length) {
			if (Assets.exists(rootUrl + extensions[i])) 
			{	
				_setTex(rootUrl + extensions[i], i);
			} else {
				trace("Image '" + rootUrl + extensions[i] + "' doesn't exist !");
			}
		}		

		GL.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
		GL.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MIN_FILTER, GL.LINEAR_MIPMAP_LINEAR);
		GL.generateMipmap(GL.TEXTURE_CUBE_MAP);
	
	//	  GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
		//  GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);

		GL.bindTexture(GL.TEXTURE_CUBE_MAP, null);

		
	}  
	public function loadBitmap(bitmapData:Image, mipmap:Bool = false ) 
	{

		this.width =bitmapData.width;
		this.height = bitmapData.height;
		this.texWidth =  roundUpToPow2(width);
		this.texHeight = roundUpToPow2(height);
		
		
		clip = new Clip(0, 0, width, height);
		exists = false;
         
		data=GL.createTexture(); 
        GL.bindTexture (GL.TEXTURE_2D, data);
		
	
   	GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.REPEAT);
    GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.REPEAT);
    GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);

	var format:Int = 0;
	if (bitmapData.buffer.bitsPerPixel == 4)
	{
	format = GL.RGBA;
	} else
	if (bitmapData.buffer.bitsPerPixel == 3)
	{
	format = GL.RGB;
	} else
	if (bitmapData.buffer.bitsPerPixel == 1)
	{
	format = GL.ALPHA;
	} 
	
	
	
	   if (isTextureOk(bitmapData))
		{
		    #if html5
			var pixelData = bitmapData.getPixels(bitmapData.rect).byteView;
			GL.texImage2D(GL.TEXTURE_2D, 0, format, width,height, 0,format, GL.UNSIGNED_BYTE,pixelData );
			#else
			GL.texImage2D(GL.TEXTURE_2D, 0, format, width,height, 0,  format, GL.UNSIGNED_BYTE,new UInt8Array(bitmapData.buffer.data) );
			#end
	
		} else
		{
			#if debug
			trace("INFO : resize image : width:"+width+" to "+texWidth +", height: "+height+" to "+texHeight);
			#end
			
			#if html5
			bitmapData.resize(texWidth, texHeight);
			var pixelData = bitmapData.getPixels(bitmapData.rect).byteView;
			GL.texImage2D(GL.TEXTURE_2D, 0, format, texWidth,texHeight, 0, format, GL.UNSIGNED_BYTE,pixelData );
			#else
			GL.texImage2D(GL.TEXTURE_2D, 0, format, bitmapData.width,bitmapData.height, 0, format, GL.UNSIGNED_BYTE,new UInt8Array(bitmapData.buffer.data ));
			#end
		}
	
	
			
	
		
		
		
	       if (!mipmap) 
	        {
                GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
            } else 
			{
                GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR_MIPMAP_LINEAR);
                GL.generateMipmap(GL.TEXTURE_2D);
            }
	       
		 GL.bindTexture(GL.TEXTURE_2D, null);
			
	
	}
	
	public function dispose()
	{
		GL.deleteTexture(data);
		clip = null;

	}
	
	
}