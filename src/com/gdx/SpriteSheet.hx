package com.gdx;

import com.gdx.gl.Texture;
import haxe.xml.Fast;
import lime.Assets;

/**
 * ...
 * @author djoker
 */
class SpriteSheet
{
	public var clipsIndex:Array<Clip>;
	public var clips:Map<String,Clip>;
	public var keyFrames:Array<Clip>;
		
	public var image:Texture;
	
	public static var  NORMAL:Int= 0;
	public static var  REVERSED :Int= 1;
	public static var  LOOP :Int= 2;
	public static var  LOOP_REVERSED:Int = 3;
	public static var  LOOP_PINGPONG:Int = 4;
	public static var  LOOP_RANDOM:Int = 5;
		

	public var frameDuration:Float=0;
	public var animationDuration:Float=0;

	private var playMode:Int;
	
	public function new() 
	{
		clips = new  Map<String,Clip>();
		clipsIndex = new Array<Clip>();
		keyFrames = [];
		image = null;
		playMode = NORMAL;
	}
	public function dispose()
	{
		clips = null;
		keyFrames = null;
		clipsIndex = null;
	}
	public function addClip(name:String,c:Clip)
	{
		clips.set(name, c);
		clipsIndex.push(c);
	}
	
	public  function createSheet( img:Texture,name:String, frameWidth:Int, frameHeight:Int)
	{
	    this.image = img;
		var row:Int = Math.floor(img.width / frameWidth);
		var column:Int = Math.floor(img.height / frameHeight);
		var index:Int = 0;
		for (i in 0 ... row)
		{
			for (j in 0 ... column)
			{
				    var frame:Clip = new Clip (i * frameWidth, j * frameHeight, frameWidth, frameHeight, 0, 0);
				    addClip(name+"_"+index,frame);
					index++;
			}
		}
	}
	  public   function createSheetsBorder( img:Texture,name:String,frameWidth:Int, frameHeight:Int,margin:Int,spacing:Int)
	{
	    this.image = img;
		var row:Int = Math.floor(img.width / frameWidth);
		var column:Int = Math.floor(img.height / frameHeight);
		var index:Int = 0;
		for (x in 0 ... row)
		{
			for (y in 0 ... column)
			{
			var rect:Clip = new Clip();
			rect.y = y * (frameHeight + spacing);
			rect.y += margin;
			rect.height = frameHeight;
			rect.x = x * (frameWidth + spacing);
			rect.x += margin;
			rect.width = frameWidth;
			addClip(name+"_"+index,rect);
			index++;
				
			}
		}
	}
	public function loadSparrow(filename:String, path:String)
	{
		parseSparrow(Assets.getText(path+filename),path);
		
	}
	private  function isValidElement(element:Xml):Bool
	{
		return Std.string(element.nodeType) == "element";
	}
	public function parseSparrow(data:String, path:String)
	{

		var xml:Xml = Xml.parse (data);
		var spriteSheetNode = xml.firstElement();
		var initFrameX = 0;
		var initFrameY = 0;
		var offsetFrameX = 0;
		var offsetFrameY = 0;
		var name:String="";
		var i = 0;
		

		
		image = Gdx.Instance().getTexture(path + spriteSheetNode.get("imagePath"),false);
		
		

		for (frameNode in spriteSheetNode.elements()) 
		{
			
			var frameNodeFast = new Fast(frameNode);
		
			
			  if (frameNodeFast.has.frameX)
				{
					initFrameX = Std.parseInt ( frameNodeFast.att.frameX );
					offsetFrameX = Std.parseInt (frameNodeFast.att.frameX) - initFrameX;
				}
				if (frameNodeFast.has.frameY)
				{
					initFrameY = Std.parseInt ( frameNodeFast.att.frameY );
					offsetFrameY = Std.parseInt (frameNodeFast.att.frameY) - initFrameY;
				}
	
	
				name = frameNodeFast.att.name;
			   var frame:Clip = new Clip (
			   Std.parseInt (frameNodeFast.att.x),
			   Std.parseInt (frameNodeFast.att.y),
			   Std.parseInt (frameNodeFast.att.width),
			   Std.parseInt (frameNodeFast.att.height),
			   -offsetFrameX,
			   -offsetFrameY);
			    addClip(name,frame);
		//	trace(frame);
		}
		
		

	}
	public function loadSWFCorona(fname:String,path:String)
	{
		parseXMLSFWCorona(Assets.getText(path+fname),path);
	}
	private  function parseXMLSFWCorona (data:String,path:String):Void 
		{
		var frameIndex:Map <String,Int> = new Map <String,Int> ();
		
		var xml:Xml = Xml.parse (data);
		var spriteSheetNode:Xml = xml.firstElement ();
		
		image = new Texture();
		//image.load(path + spriteSheetNode.get("path"));
		
		var name:String = spriteSheetNode.get("name");
		
        var index:Int = 0;
		
		for (behaviorNode in spriteSheetNode.elements ()) 
		{

			var behaviorNodeFast:Fast = new Fast (behaviorNode);
			var behaviorFrames:Array <Int> = new Array <Int> ();
			
			var allFramesText:String = behaviorNodeFast.innerData;
			var framesText:Array <String> = allFramesText.split (";");
			
			for (frameText in framesText) 
			{
				if (!frameIndex.exists (frameText)) 
				{
					var components:Array < String > = frameText.split (",");
				    var frame:Clip = new Clip (Std.parseInt (components[0]), Std.parseInt (components[1]), Std.parseInt (components[2]), Std.parseInt (components[3]), -Std.parseInt (components[4]), -Std.parseInt (components[5]));
				    addClip(name + "_" + index, frame);
					index++;
				}
			}
		}
	}


	public function getClip(index:Int):Clip
	{
	 return clipsIndex[index];
	}
	public function getClipbyName(name:String):Clip
	{
	 return clips.get(name);
	}	
	public function setFrameDuration(value:Float)
	{
		frameDuration = value;
		animationDuration = numFrames() * frameDuration;
	}
	public function getFrames (stateTime:Float,looping:Bool) :Clip
	{
		if (looping && (playMode == NORMAL || playMode == REVERSED)) 
		{
			if (playMode == NORMAL)
				playMode = LOOP;
			else
				playMode = LOOP_REVERSED;
		} else if (!looping && !(playMode == NORMAL || playMode == REVERSED))
		{
			if (playMode == LOOP_REVERSED)
				playMode = REVERSED;
			else
				playMode = LOOP;
		}

		return getKeyFrame(stateTime);
	}
	public function numFrames():Int
	{
		return keyFrames.length;
	}
	public function getKeyFrame (stateTime:Float):Clip 
	{
		var frameNumber:Int = Std.int(stateTime / frameDuration);

       switch (playMode) 
	   {
		case SpriteSheet.NORMAL:
			frameNumber = Std.int(Math.min(keyFrames.length - 1, frameNumber));
		case SpriteSheet.LOOP:
			frameNumber = frameNumber % keyFrames.length;
		case SpriteSheet.LOOP_PINGPONG:
			frameNumber = frameNumber % (keyFrames.length * 2);
			if (frameNumber >= keyFrames.length) frameNumber = keyFrames.length - 1 - (frameNumber - keyFrames.length);
		case SpriteSheet.LOOP_RANDOM:
			frameNumber =Std.int( Math.random()*(keyFrames.length - 1));
		case SpriteSheet.REVERSED:
			frameNumber = Std.int(Math.max(keyFrames.length - frameNumber - 1, 0));
		case SpriteSheet.LOOP_REVERSED:
			frameNumber = frameNumber % keyFrames.length;
			frameNumber = keyFrames.length - frameNumber - 1;
		default:
			frameNumber =Std.int( Math.min(keyFrames.length - 1, frameNumber));

		}
		return keyFrames[frameNumber];
	}

	     public function getClips(prefix:String=""):Array<Clip>
        {
            var result:Array<Clip>= [];
            var names:Array<String> = getNames(prefix);
			for (name in names)
			{
				if (clips.exists(name))
				{
					result.push(clips.get(name));
				}
			}
            return result;
        }
		
		public function createAnimation(fps:Float,prefix:String = "",playermode:Int)
		{
			this.playMode = playermode;
			frameDuration = fps;
			keyFrames = [];
			var names:Array<String> = getNames(prefix);
			for (name in names)
			{
				if (clips.exists(name))
				{  
					keyFrames.push(clips.get(name));
				}
			}
			names=null;
		}
      public function getNames(prefix:String=""):Array<String>
        {
            var result:Array<String> = [];
			
			for (name in clips.keys())
			{
				 if (name.indexOf(prefix) == 0)
				 {
					 result.push(name);
				 }
			}
			
			result.sort( function strSort(a:String, b:String):Int
             {
             a = a.toLowerCase();b = b.toLowerCase();
             if (a < b) return -1;if (a > b) return 1;return 0;} );
			 
			 
			return result;

        }
	
}