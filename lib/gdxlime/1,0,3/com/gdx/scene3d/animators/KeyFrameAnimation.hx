package com.gdx.scene3d.animators;
import com.gdx.math.Quaternion;
import com.gdx.math.Vector3;
import com.gdx.scene3d.Scene;

/**
 * ...
 * @author Luis Santos AKA DJOKER
 */

 
class KeyFrameAnimation
{
	    public var Pos:Array<PosKeyFrame>;
		public var Rot:Array<RotKeyFrame>;
		public var total:Int;
		public var timeline:Float;
		public var lastFrame:Float;
		public var run:Bool;
		public var loop:Bool;
		public var currentIndex:Int;
		public var nextIndex:Int;
		private var currPosition:Vector3 = Vector3.zero;
		private var currRotation:Quaternion = Quaternion.Zero();
		private var TicksPerSecond:Float = 1;
		private var useCatmull:Bool;
		private var scene:Scene;
		private var angle:Vector3;
		
		
		   
	
	public function new(scene:Scene,Catmull:Bool,TicksPerSecond:Float=1) 
	{
		this.scene = scene;
		Pos = [];
		Rot = [];
		total = 0;
		currentIndex = 0;
		nextIndex = 0;
		run = false;
		loop = true;
		timeline = 0;
		lastFrame = 0;
		angle = Vector3.zero;
		this.TicksPerSecond = TicksPerSecond;
		useCatmull = Catmull;
	}
	public function addKey(time:Float, x:Float, y:Float, z:Float,pitch:Float, yaw:Float,  roll:Float):Int
	{
		return addKeyFrame(time, new Vector3(x, y, z), Quaternion.RotationYawPitchRoll(-Util.deg2rad(yaw),Util.deg2rad(pitch), Util.deg2rad(roll)));
		}
	
	public function addKeyFrame(time:Float, p:Vector3, rotation:Quaternion,debug:Bool=false):Int
	{
		Pos.push(new PosKeyFrame(time, p));
		Rot.push(new RotKeyFrame(time, rotation));
		
		if (debug)
		{
		var m = scene.addCube();
		m.setPositionVector(p);
		m.rotate(rotation);
		m.getBrush(0).DiffuseColor.set(1, 0, 0);
		}
		
		lastFrame = (time > lastFrame) ? time : lastFrame;
		++total;
		return total;
	}
	public function Start():Void
        {
            timeline = 0;
            currentIndex = 0;
            run = true;
        }
	public function getPosition():Vector3
	{
		return currPosition;
	}
	public function getRotation():Quaternion
	{
		return currRotation;
	}
	public function getAngle():Vector3
	{
		 var euler:Vector3 = currRotation.toEulerAngles();
		 return angle;
	}	
	private function FindPosition(time:Float):Int
	{
		for (i in 0...Pos.length-1)
		{
			if (time < Pos[i + 1].time)
			{
				return i;
			}
		}
		return 0;
	}
	private function  wrap( value:Int,  max:Int):Int
        {
            while (value > max)
                value -= max;

            while (value < 0)
                value += max;

            return value;
        }
	public function Update(gameTime:Float):Void
	{
		   if (run)
            {
				
				
                timeline += gameTime * TicksPerSecond;
				//var AnimationTime:Float = (timeline % lastFrame);//restart auto..
 
			
			currentIndex = FindPosition(timeline);
            nextIndex = (currentIndex + 1);
			
			
			
			if (timeline >= lastFrame) 
			{ 
			 if (loop)
				{
					Start();
					
				} else
				{
				run = false;
				return;
				}
			}
			if (nextIndex > Pos.length)
			{
				if (loop)
				{
			      Start();
				} else
				{
				run = false;
				return;
				}
			}  
			 var DeltaTime :Float= (Pos[nextIndex].time -Pos[currentIndex].time);
             var Factor = (timeline - Pos[currentIndex].time) / DeltaTime;
			 
			 if (useCatmull)
			 {
				  var framesCount:Int = Pos.length;
				  
				  currPosition = Vector3.CatmullRom(
				  Pos[wrap(currentIndex - 1, framesCount - 1)].Pos, 
				  Pos[wrap(currentIndex , framesCount - 1)].Pos, 
				  Pos[wrap(currentIndex + 1, framesCount - 1)].Pos, 
				  Pos[wrap(currentIndex + 2, framesCount - 1)].Pos, Factor);
				  
			 } else
			 {
				 
				   currPosition = Vector3.Lerp(Pos[currentIndex].Pos, Pos[nextIndex].Pos, Factor);
				  
			 }
			 
	
			
			  
			   
				currRotation = Quaternion.Slerp(Rot[currentIndex].Rot, Rot[nextIndex].Rot, Factor);
		
			
             }
				
	}
	
			 
	
}