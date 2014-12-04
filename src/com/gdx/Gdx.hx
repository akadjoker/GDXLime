package com.gdx;

import com.gdx.math.Matrix4;
import com.gdx.math.Rectangle;
import com.gdx.math.Vector2;
import com.gdx.math.Vector3;

import com.gdx.gl.batch.BatchPrimitives;
import com.gdx.gl.batch.SpriteCloud;
import com.gdx.gl.batch.SpriteBatch;
import com.gdx.gl.batch.FastSpriteBatch;
import com.gdx.gl.batch.SpriteAtlas;
import com.gdx.gl.batch.NormalSpriteBatch;

import lime.graphics.Image;
import lime.graphics.ImageBuffer;
import lime.system.System;

import lime.app.Application;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLShader;
import lime.graphics.opengl.GLUniformLocation;
import lime.graphics.RenderContext;


import lime.Assets;







import com.gdx.gl.batch.BatchPrimitives;
import com.gdx.gl.batch.SpriteBatch;
import com.gdx.gl.batch.SpriteCloud;
import com.gdx.gl.batch.SpriteAtlas;
import com.gdx.gl.Texture;
import com.gdx.math.Transform;
import com.gdx.Util;
import com.gdx.scene2d.CameraOrtho;
import com.gdx.Clip;

import haxe.Timer;
import com.gdx.tweens.Tween;
import com.gdx.tweens.Tweener;
import com.gdx.tweens.Ease;
import com.gdx.tweens.TweenEvent;
import com.gdx.tweens.misc.Alarm;
import com.gdx.tweens.misc.AngleTween;
import com.gdx.tweens.misc.ColorTween;
import com.gdx.tweens.misc.MultiVarTween;
import com.gdx.tweens.misc.NumTween;
import com.gdx.tweens.misc.VarTween;
import com.gdx.tweens.motion.CircularMotion;
import com.gdx.tweens.motion.CubicMotion;
import com.gdx.tweens.motion.LinearMotion;
import com.gdx.tweens.motion.LinearPath;
import com.gdx.tweens.motion.Motion;
import com.gdx.tweens.motion.QuadMotion;
import com.gdx.tweens.motion.QuadPath;


/**
 * ...
 * @author djoekr
 */
class Gdx 
{

		private var  BlendSource:Int;
		private var  BlendDestination:Int;
		private var  Blend:Bool;

		private var CullFaceMode:Int;
		private var CullFace:Bool;

		private var  DepthFunc:Int;
		private var DepthMask:Bool;
		private var DepthTest:Bool;
		
	private var ASPECT_RATIO:Float;
	public var deltaTime:Float;
	public var fixedTime:Float;
	public var  timecount:Float;
	
	public var currentBaseTexture0:Texture;
	public var currentBaseTexture1:Texture;
	public var numTextures:Int;
	public var numVertex:Int;
	public var numTris:Int;
	public var numSurfaces:Int;
	public var numMesh:Int;
	public var numBrush:Int;
	public var status:String;
	public var dummyTexture:Texture;
	public var viewPort:Rectangle;
	private var keys:Array<Int>;
	
	private static var __startTime:Float = Timer.stamp ();

		

	public static var gdx:Gdx = null;
    public  var width:Int = 0;
    public  var height:Int = 0;
	private var startWidth:Int;
	private var startHeight:Int;
	

	private var isPause:Bool;
	
    private var screen:Screen;
    public var textures:Map<String,Texture>;

    public var 	    avgFPS :Int;
    public var     bestFPS :Int;
    public var     lastFPS :Int;
    public var     worstFPS :Int;
    public var     triangleCount :Int;
    public var     bestFrameTime :Int;
    public var     worstFrameTime :Int;
    public var     mLastTime :Int;
    public var     mLastSecond :Int;
    public var     mFrameCount :Int;
	//private var txtfps:TextField;
     private var pt:Int = 0;
     private var fps:Float = -1.0;
     private var timeStamp:Int = 0;

	 

	 private var _r:Float;
	 private var _g:Float;
	 private var _b:Float;
	 
	 private var mousePointer:Vector2;
	 private var previousMouse:Vector2;
	 private var MouseSpeed:Vector2;
	 
	public function new() 
	{
	
	
		 
		
	
		 
		
	}

	
	   public function init(w:Int, h:Int)
	   {
		 	
		   viewPort = new Rectangle(0, 0, w, h);
	

	currentBaseTexture0 = null;
	currentBaseTexture1 = null;
	numTextures = 0;
	numVertex=0;
	numTris = 0;
	numSurfaces = 0;
	numMesh = 0;
	numBrush = 0;

	keys = [];
	for (i in 0...256)
	{
		keys[i] = 0;
	}
	
		for (i in 0...20)
		{
			TouchX[i] =- 1;
			TouchY[i] =- 1;
		}

        timecount = 0;
		width  = w;
        height = h;
		ASPECT_RATIO =(width /  height);
	
		setViewPort(0, 0, width, height);

		startWidth = width;
	    startHeight = height;
	
		
	    avgFPS = 0;
        bestFPS = 0;
        lastFPS = 0;
        worstFPS = 999;
        triangleCount = 0;
        bestFrameTime = 999999;
        worstFrameTime = 0;
        mLastTime = getTimer();
        mLastSecond = mLastTime;
        mFrameCount = 0;
		fixedTime = 0;
		deltaTime = 0;
		
		isPause = false;

		
		 BlendSource = -1;
		 BlendDestination = -1;
		 DepthFunc = -1;
		 Blend=true;

		 CullFaceMode=GL.BACK;
		 CullFace=false;
		 DepthFunc=GL.LESS;
		 DepthMask=false;
		 DepthTest=false;
	

	GL.pixelStorei(GL.PACK_ALIGNMENT,1);
	GL.hint(GL.GENERATE_MIPMAP_HINT, GL.FASTEST);
	GL.clearDepth(1.0);
	GL.colorMask(true, true, true, true);

	     
		
    clearColor(0, 0, 0.4);
	
	

	
       setDepthMask(true);
	   setDepthTest(true);
	   setCullFace(true);
	   setBlend(false); 
	   setDepthFunc(GL.LEQUAL);
	   
	
	
	mousePointer = Vector2.Zero();
	previousMouse = Vector2.Zero();
	MouseSpeed= Vector2.Zero();
  
	
	
	textures = new  Map<String,Texture>();
	
	
	dummyTexture = new Texture();
	var bmp:Image = new Image(null, 0, 0, 64, 64, 0xffffffff);
	dummyTexture.loadBitmap(bmp, true);
	textures.set("dummy",dummyTexture);
	
	
		
		
		 pt = getTimer();
		
	   }

	
	public function onKeyDown (keyCode:Int):Void 
	{
	if (keyCode <= 256) keys[keyCode] = 1;
	if (screen != null) screen.KeyDown(keyCode);

   }
	public function onKeyUp (keyCode:Int):Void
	{
	if (keyCode <= 256) keys[keyCode] = 0;
	  if (screen != null) screen.KeyUp(keyCode);
	}
	public function GetMouseSpeed():Vector2
	{
		return MouseSpeed;
	}	
	public function GetMousePos():Vector2
	{
		return mousePointer;
	}
	public function setMousePos(x:Float,y:Float):Void
	{
		 mousePointer.set(x, y);
	}
	public function keyPress(keyCode:Int):Bool
    {
	    return  (keys[keyCode]) != 0 ;
	}	
	public function getTextureCubemap(url:String ):Texture 
   {
	if (textures.exists(url))
	{
		return textures.get(url);
	} else
	{	
	var tex = new Texture();
	tex.createCubeTexture(url);
	#if debug
	trace("INFO: Load ("+url+") Bitmap to Texture");
	#end
	
	textures.set(url,tex);
	return tex;
	}
   }
	public function getTexture(url:String, mipmap:Bool = false ):Texture 
   {
	if (textures.exists(url))
	{
		return textures.get(url);
	} else
	{	
	var tex = new Texture();
	tex.loadBitmap(Assets.getImage(url), mipmap );
	#if debug
	trace("INFO: Load ("+url+") Bitmap to Texture");
	#end
	
	textures.set(url,tex);
	return tex;
	}
   }
   public function getTextureEx(img:Image, mipmap:Bool = false ):Texture 
   {
	
	var tex = new Texture();
	tex.loadBitmap(img, mipmap );
	return tex;
	
   }
    public function setTextureFilter(linear:Bool)
	{
		if (linear)
		{
				 GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
	             GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
			
		}else
		{
				 GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
	             GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
			
		}
		
	}
   	public function setTextureWrap(mode:Int)
	{
		switch (mode)
		{
		case 0:
			{
				 GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.REPEAT);
                 GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.REPEAT);			
			}
			case 1:
				{
		        GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
                GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);			
				}
				case 2:
					{
					GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.MIRRORED_REPEAT);
                    GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.MIRRORED_REPEAT);			
					}
		
		}
	}
	
	
	

	public function getWidth():Int
	{
	 return width;
	}
	public function getHeight():Int
	{
		return height;
		
	}
	
	
	public function clearColor(red:Float = 0, green:Float = 0, blue:Float = 0)
   {
	 _r = red;
	 _g = green;
	 _b = blue;
	  GL.clearColor(_r,_g,_b, 1);
   }
   
   public function resetStatus()
   {
	    avgFPS = 0;
        bestFPS = 0;
        lastFPS = 0;
        worstFPS = 999;
        triangleCount = 0;
        bestFrameTime = 999999;
        worstFrameTime = 0;
   }
   private function updateStates():Void
   {
	   ++mFrameCount;
        var thisTime:Int =  getTimer ();
        var frameTime:Int = thisTime - mLastTime ;
        mLastTime = thisTime ;

        bestFrameTime = Std.int(Math.min(bestFrameTime, frameTime));
        worstFrameTime = Std.int(Math.max(worstFrameTime, frameTime));
		
		   // check if new second (update only once per second)
        if (thisTime - mLastSecond > 1000) 
        { 
            // new second - not 100% precise
            lastFPS = Std.int(mFrameCount / (thisTime - mLastSecond) * 1000);

            if (avgFPS == 0)
                avgFPS = lastFPS;
            else
                avgFPS = Std.int((avgFPS + lastFPS) / 2); // not strictly correct, but good enough

            bestFPS = Std.int(Math.max(bestFPS, lastFPS));
			
            worstFPS = Std.int(Math.min(worstFPS, lastFPS));

            mLastSecond = thisTime ;
            mFrameCount  = 0;

        }

       status = "FPS:" +lastFPS + 
		 "\nBest:" + bestFPS + 
		 "\nWorst:" + worstFPS +
	     "\nTris:"+this.numTris+"/Vtx:"+this.numVertex+"/Surf:"+numSurfaces+"/Mesh:"+numMesh+
		 "\nTextures" + numTextures;
	    
   }
   public function clear():Void
   {
	   GL.clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT );

}


		
   	public function setViewPort(x:Float,y:Float,w:Float,h:Float):Void
	{
		GL.viewport(Std.int(x) , Std.int(y), Std.int(w), Std.int(h));
		viewPort.setTo(x, y, w, h);
	}
	public function Update(dt:Float)
	{
		 fixedTime = Math.min(1 / 40, 1 / 200 + timeStamp * 1e-5 * 30);
		 deltaTime = dt;
		if (screen != null) screen.update(dt);
	}
	
	 public function render( ):Void 
	{

		 if (isPause) return;
		 

	
		/*
		var aspectRatio:Float = (r.width/r.height);
        var scale:Float = 1;
        var crop:Point = new Point(0, 0);
		
		 if(aspectRatio > ASPECT_RATIO)
        {
            scale = r.height/height;
            crop.x = (r.width - width*scale)/2;
        }
        else if(aspectRatio < ASPECT_RATIO)
        {
            scale = r.width/width;
            crop.y = (r.height - height*scale)/2;
        }
        else
        {
            scale = r.width/width;
        }

        var w:Float = width*scale;
        var h:Float = height * scale;
		setViewPort(crop.x, crop.y, w, h);
		*/
	currentBaseTexture0 = null;
	currentBaseTexture1 = null;
	numTextures = 0;
	numVertex=0;
	numTris = 0;
	numSurfaces = 0;
	numMesh = 0;
	numBrush = 0;
	
        setDepthMask(true);
		setDepthTest(true);
		setCullFace(true);
		setBlend(false);
		setBlendFunc(GL.SRC_ALPHA, GL.DST_ALPHA);
		
		 
	//	nextFrame = getTimer();
       // deltaTime = (nextFrame - prevFrame) * 0.001;
	//	prevFrame = nextFrame;
	
	
     
		
	   
	  // GL.viewport (Std.int (r.x), Std.int (r.y), Std.int (r.width), Std.int (r.height));
	  // GL.scissor (Std.int (r.x), Std.int (r.y), Std.int (r.width), Std.int (r.height));
	  
    //   GL.clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT | GL.STENCIL_BUFFER_BIT);

        clear();
	 
	 
	
	  if (screen != null) screen.render();	
      timeStamp++;

	  
	
	
	
	
		 
		
	  
	/*	
	  GL.useProgram(null);
	  GL.bindBuffer(GL.ARRAY_BUFFER, null);
	  GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, null);
	  GL.activeTexture(GL.TEXTURE0);
 */
	  updateStates();
	  
	  if (!DepthTest)
	  {
		  trace("DepthTest is disable");
	  }
	}

   
	public function onShow():Void
	{
     if (screen != null) screen.resume();	
	 isPause = false;
	}
	public function onHide():Void
	{
	if (screen != null) screen.pause();
	isPause = true;
	}
	public function onClose():Void
	{
	 dispose();
	}
	public function onresize(Width:Int, Height:Int):Void
	{
	    this.width  = Width;
		this.height = Height;
		if (screen != null) screen.resize(width, height);
		ASPECT_RATIO =(width /  height);
	
		

		//txtfps.y = height - 80;
		
		fullScaleX = (startWidth / width);
		fullScaleY = (startHeight / height);
      // trace(viewWidth+","+viewHeight+","+Width+","+Height+","+fullScaleX + "," + fullScaleY);
	}


	public function setScreen ( screen:Screen):Void 
	{
		if (this.screen != null) this.screen.hide();
		this.screen = screen;
		if (this.screen != null) 
		{
			this.screen.show();
			this.screen.resize(getWidth(),getHeight());
		}
	}
	public function getScreen () :Screen
	{
		return screen;
	}
	public function dispose()
	{
	  GL.useProgram(null);
      GL.bindBuffer(GL.ARRAY_BUFFER, null);
      GL.blendFunc(GL.SRC_ALPHA, GL.DST_ALPHA );	
	  
		#if !js
		if (screen != null) screen.dipose();
			for (tex in this.textures)
		{
			tex.dispose();
		}
		textures = null;
		#end
	}
	public function mouseDown(x:Float, y:Float, button:Int):Void
	{
	    TouchX[button] =x;
		TouchY[button] =y;
	    ++TouchID ;
		TouchDown = true;
		if (screen != null) screen.TouchDown(x,y,button);
	}

	
	public function mouseUp(x:Float, y:Float, button:Int):Void
	{
		 MouseSpeed.set(0, 0);
	    TouchX[button] =x;
		TouchY[button] =y;
	    --TouchID ;
		TouchDown = false;
		if (screen != null) screen.TouchUp(x,y,button);
	}

	
	public function mouseMove(x:Float, y:Float, button:Int):Void
	{
	     TouchX[button] =x;
		 TouchY[button] = y;
    	 mousePointer.set(x,y);
		 if (TouchDown)
		 {
		 MouseSpeed.x = x-previousMouse.x ;
		 MouseSpeed.y = y - previousMouse.y  ;
		 }
		 previousMouse.set( x,y);
		
	   if (screen != null) screen.TouchMove(x,y,button);
	}
	public  function onTouchBegin(x:Float, y:Float, id:Int)
	{
		TouchX[id] = x;
		TouchY[id] = y;
	    ++TouchID ;
		TouchDown = true;
		if (screen != null) screen.TouchDown(x,y,id);
	}

	public  function onTouchMove(x:Float, y:Float, id:Int)
	{
		
		if (TouchDown)
		{
		mousePointer.set(x,y);
		MouseSpeed.x = x-previousMouse.x ;
		 MouseSpeed.y = y-previousMouse.y  ;
		 previousMouse.set( x,y);
		}
		TouchX[id] = x;
		TouchY[id] = y;
		if (screen != null) screen.TouchMove(x,y,id);
	}

	public  function onTouchEnd(x:Float, y:Float, id:Int)
	{
		TouchX[id] = -1;
		TouchY[id] = -1;
		--TouchID ;
		TouchDown = false;
		if (screen != null) screen.TouchUp(x,y,id);
		
	}
	
	
	 public function getAspectRatio():Float
	  {
		   
		     var vw:Float =width;
		     var vh:Float =height;
		     return (vw/ vh);
	       
    }
	
	public function getTimer():Int
	{
		return Std.int ((Timer.stamp () - __startTime) * 1000);
	}
	public function getTicks():Int
	{
		return Std.int (Timer.stamp ()); 
	}
	
	
	public static function Instance() : Gdx 
	{
		if (Gdx.gdx == null)
		{
			Gdx.gdx = new Gdx();
		}
		return Gdx.gdx;
		
	}
	
	public function setDepthTest( enable:Bool)
	{
		if (DepthTest != enable)
		{
			if (enable)
				GL.enable(GL.DEPTH_TEST);
			else
				GL.disable(GL.DEPTH_TEST);

			DepthTest = enable;
		}
		

	}
	public function setDepthMask(enable:Bool)
	{
		if (DepthMask != enable)
		{
			if (enable)
				GL.depthMask(true);
			else
				GL.depthMask(false);

			DepthMask = enable;
		}
	
	}
	public function setDepthFunc( mode:Int)
	{
		if (DepthFunc != mode)
		{
			GL.depthFunc(mode);

			DepthFunc = mode;
		}
	}
	public function setCullFace( enable:Bool)
	{
		if (CullFace != enable)
		{
			if (enable)
				GL.enable(GL.CULL_FACE);
			else
				GL.disable(GL.CULL_FACE);

			CullFace = enable;
	    }

	}
	public function setCullFaceFunc( mode:Int)
	{
		if (CullFaceMode != mode)
		{
			GL.cullFace(mode);

			CullFaceMode = mode;
		}
	}
	public function setBlend( enable:Bool)
	{
		if (Blend != enable)
		{
			if (enable)
				GL.enable(GL.BLEND);
			else
				GL.disable(GL.BLEND);

			Blend = enable;
		}
		
	}
	public function setBlendFunc( source:Int, destination:Int)
	{
		if (BlendSource != source || BlendDestination != destination)
		{
			GL.blendFunc(source, destination);

			BlendSource = source;
			BlendDestination = destination;
		}
	}

	public var fullScaleX(default, null):Float = 1;
	public var fullScaleY(default, null):Float = 1;
	public  var multiTouchSupported(default, null):Bool = false;
	public  var TouchDown:Bool = false;
	public  var TouchX:Array<Float> = new Array<Float>();
	public  var TouchY:Array<Float> = new Array<Float>();
	public  var TouchID:Int = 0;
}