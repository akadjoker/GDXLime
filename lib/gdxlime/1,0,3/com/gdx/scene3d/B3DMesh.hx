package com.gdx.scene3d ;


import com.gdx.color.Color4;
import com.gdx.gl.shaders.Brush;
import com.gdx.math.Matrix4;
import com.gdx.math.Quaternion;
import com.gdx.math.Vector2;
import com.gdx.math.Vector3;
import com.gdx.scene3d.animators.PosKeyFrame;
import com.gdx.scene3d.animators.RotKeyFrame;
import haxe.io.Path;
import lime.Assets;
import lime.utils.ByteArray;


class B3DWight
{
	public var boneId:Int;
	public var Wight:Float;
		public function new(id:Int,w:Float) 
	    {
			boneId = id;
			Wight = w;
		}
}

class B3DVertex
{
	public var  Pos:Vector3;
	public var  Normal:Vector3;
	public var  TCoords0:Vector2;
	public var  TCoords1:Vector2;
	public var  Color:Color4;
	public var  bones:Array<B3DWight>;
	public var numBones:Int;

	
	public function new() 
	{
		Color = new Color4(1, 1, 1, 1);
		Pos = Vector3.zero;
		Normal = Vector3.zero;
		TCoords0 = Vector2.zero;
		TCoords1 = Vector2.zero;
	    bones = [];
		bones.push(new B3DWight( -1, 1));
		bones.push(new B3DWight( -1, 1));
		bones.push(new B3DWight( -1, 1));
		bones.push(new B3DWight( -1, 1));
		numBones = 0;
		
	}
	public function sort():Void
	{
	
		bones.sort(function WightIndex(a:B3DWight, b:B3DWight):Int
    {

    if (a.Wight < b.Wight) return -1;
    if (a.Wight > b.Wight) return 1;
    return 0;
    } 
	);
	}
}



class B3DBone extends SceneNode
{
	  
     	public var Pos:Array<PosKeyFrame>;
		public var Scl:Array<PosKeyFrame>;
		public var Rot:Array<RotKeyFrame>;
	    public  var offMatrix:Matrix4 = Matrix4.Identity(); 
		public var index:Int;
		public var numKeys:Int;
		


		public function new(scene:Scene,Parent:SceneNode,id:Int , name:String)
	    {
		 super(scene, Parent, id, name);

		 Pos = [];
		 Rot = [];
	    Scl = [];
	/*
	  var debug:Mesh = scene.addCube(this);
		  debug.MeshScale(0.2, 0.2, 0.2);
		 debug.getBrush(0).DiffuseColor.set(1, 0, 0);
		 */
		 index = 0;
	

		
		
		}
		
		public function initialize():Void
		{
			
		             rotationQuaternion.toRotationMatrix(localRotation);
	                 LocalWorld.makeTransform(position, scaling, rotationQuaternion);
	                 if (this.parent != null)
				      {
						  
					  LocalWorld.append(parent.AbsoluteTransformation);
					  }
					  
					  LocalWorld.invertToRef(offMatrix);
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
	private function FindRotation(time:Float):Int
	{
		for (i in 0...Rot.length-1)
		{
			if (time < Rot[i + 1].time)
			{
				return i;
			}
		}
		return 0;
	}

	private function FindScale(time:Float):Int
	{
		for (i in 0...Scl.length-1)
		{
			if (time < Scl[i + 1].time)
			{
				return i;
			}
		}
		return 0;
	}

	
	private function animteRotation(movetime:Float):Void
	{
		    if (Rot.length <= 0) return;
		    var currentIndex:Int = FindRotation(movetime);
            var nextIndex:Int = (currentIndex + 1);
			
			if (nextIndex > Pos.length)
			{
				return;
			}  
			
			 var DeltaTime :Float= (Rot[nextIndex].time -Rot[currentIndex].time);
             var Factor = (movetime - Rot[currentIndex].time) / DeltaTime;
			 rotate(Quaternion.Slerp(Rot[currentIndex].Rot, Rot[nextIndex].Rot, Factor));
	}
	
	private function animteScale(movetime:Float):Void
	{
		if (Scl.length <= 0) return;
		    var currentIndex:Int = FindScale(movetime);
            var nextIndex:Int = (currentIndex + 1);
			
			if (nextIndex > Scl.length)
			{
	
				return;
			}  
			
			 var DeltaTime :Float= (Scl[nextIndex].time -Scl[currentIndex].time);
             var Factor = (movetime - Scl[currentIndex].time) / DeltaTime;
			 this.scaling = Vector3.Lerp(Scl[currentIndex].Pos, Scl[nextIndex].Pos, Factor);
			
	}
		private function animtePosition(movetime:Float):Void
	{
		  if (Pos.length <= 0) return;
		    var currentIndex:Int = FindPosition(movetime);
            var nextIndex:Int = (currentIndex + 1);
			
			if (nextIndex > Pos.length)
			{
	
				return;
			}  
			
			 var DeltaTime :Float= (Pos[nextIndex].time -Pos[currentIndex].time);
             var Factor = (movetime - Pos[currentIndex].time) / DeltaTime;
			 this.position = Vector3.Lerp(Pos[currentIndex].Pos, Pos[nextIndex].Pos, Factor);
	}
	
	
		public function animateJoints(TimeInSeconds:Float):Void
		{
		   
		  // animteScale(AnimationTime);
		   animtePosition(TimeInSeconds);
		   animteRotation(TimeInSeconds);
		   
		   UpdateAbsoluteTransformation();
		

		 var vector:Vector3 = Vector3.zero;
		 var parentvector:Vector3 = Vector3.zero;
		 
		 vector=AbsoluteTransformation.transformVector(vector);
		 
		 if (parent != null)
		 {
			parentvector = parent.AbsoluteTransformation.transformVector(parentvector);
			scene.lines.lineVector(vector, parentvector, 1, 0, 0, 1);
		 } else
		 {
			 scene.lines.lineVector(vector, vector, 1, 0, 0, 1);
		 }
		 
 		}
}

class B3DMesh extends Mesh
{
	
private var  file:ByteArray;
private var b3d_tos:Int;
private var b3d_stack:Array<Int>;
private var listVertex:Array<B3DVertex>;

private var textures:Array<String>;

private var brushes:Array<Brush> = new Array<Brush>();
private var texturepath:String;
private var isAnimated:Bool;

private var Bones:Array<B3DBone>;

    public var NumFrames:Int;
    private var lastTime:Float;
    private var TicksPerSecond:Float;
	private var StartFrame:Int;
	private var EndFrame:Int;
	private var FramesPerSecond:Float;
	private var CurrentFrameNr:Float;
    private var LastTimeMs:Int;
	private	var Looping:Bool;
	private var CurrentTime:Float;
	

	public function new(scene:Scene,Parent:SceneNode = null , id:Int = 0, name:String="B3DMesh")  
	{
		 super(scene, Parent, id, name);
		
		 b3d_tos = 0;
		 b3d_stack = [];
	
		 textures = [];
		 brushes = [];
		 Bones = [];
    
		 FramesPerSecond = 0.025;
		 StartFrame = 0;
		 EndFrame = 0;
		 CurrentFrameNr = 0;
		 LastTimeMs = 0;
		 Looping = true;
		isAnimated = false;
		
		 NumFrames=0;
  
		 lastTime = Gdx.Instance().getTimer();

		
	}
	
	private function processBone():Void
	{
	
	}

	public  function loadB3D(filename:String,path:String):Void
	
	{
		
		  if (!Assets.exists(filename))
			{
				trace("ERROR:Model " + filename+"dont exists..");
				return;
			}
		texturepath = path;
		file =	Assets.getBytes(filename);
	    file.endian = "littleEndian";
        if (file.bytesAvailable <= 0) return;
	    file.position = 0;
		
		ReadChunk();
		file.readInt();
		
while (getChunkSize() != 0)
{
  var ChunkName = ReadChunk();
  if(ChunkName=='TEXS') 
  {
	 readTEX(); 
  } else
  if(ChunkName=='BRUS') 
  {
	readBRUS();
   } else
  if(ChunkName=='NODE') 
  {
	readNODE(null);
  }
   breakChunk();
}
breakChunk();
		
processBone();
		
    setFrameLoop(0,NumFrames);
	setAnimationSpeed(TicksPerSecond);

	
		brushes = null;
	}
	public function getAnimationSpeed():Float
{
	return FramesPerSecond * 1000.0;
}
public function getFrameNr():Int
{
	return Std.int(CurrentFrameNr);
}
	private function  ReadChunk():String
	{
    var tag:String = file.readUTFBytes(4);
    var size = file.readInt();
	
	//trace('read tag:'+tag+','+size);
	
    b3d_tos++;
     b3d_stack[b3d_tos] = file.position +size;
	return tag;
	}
	
	private function getChunkSize():Int
    { 
    return b3d_stack[b3d_tos] - file.position;
	}

	private function breakChunk():Void
    {
    file.position = b3d_stack[b3d_tos];
    --b3d_tos;
	}
	
	private function readstring():String {
        var name:String = "";
         for (j in 0...256) 
		{
            var ch:Int = file.readUnsignedByte();
			if (ch == 0) break;
            name += String.fromCharCode(ch);
        }
        return name;
    }
	private function readANIM():Void
   {
	 var flags:Int=  file.readInt();//flags
	 NumFrames=  file.readInt();//ketframecount
	 TicksPerSecond =  file.readFloat();//fps
	 if (TicksPerSecond <= 0) 
	 {
	 TicksPerSecond = 25.0;
	 }
	 var duration:Float = (NumFrames / TicksPerSecond);
	if(NumFrames>1) isAnimated = true;
	 trace('Animation - duration' +duration +',flags:' + flags + ', totalframes:' + NumFrames + ', fps:' + TicksPerSecond);
   }
 
	   
   private function readBone(bone:B3DBone):Void
   {
	   while (getChunkSize()!=0) 
      {
	   var id:Int  =file.readInt();//vertexid
	   var vw:Float =  file.readFloat();//wight

	 
	
	   for (count in 0...4)
	   {
	    if (this.listVertex[id].bones[count].boneId == -1)
		{
			this.listVertex[id].bones[count].boneId = bone.index;
			
		    	if (vw < 0.001)  vw = 0.0;
				if (vw > 0.999)  vw = 1.0;
				
				
			this.listVertex[id].bones[count].Wight = vw;
			this.listVertex[id].numBones++;
			
		//	trace('num bones per vertex :'+ count+' index:'+bone.index+' w:'+vw);
			break;
		}
	   }
	  this.listVertex[id].sort();
	  /*
	  for (i in 0...this.listVertex[id].numBones)
	  {
		  trace(i+' - id :'+ this.listVertex[id].bones[i].boneId +' w:'+this.listVertex[id].bones[i].Wight);
	  }
	  */ 
	   
	  }
   }

	private function readTEX():Void
   {
    while (getChunkSize()!=0) 
   {
	  var  texture:String = Path.withoutDirectory(readstring());
	//  trace('Texture name:'+texture);
	  textures.push(texture);
	  file.readInt();//flags
	  file.readInt();//blend
	  file.readFloat();//x
	  file.readFloat();//y
	  file.readFloat();//scalex
	  file.readFloat();//sclaey
	  file.readFloat();//rotation
  }

  
  }
  private function readBRUS():Void
  {
	  var count = file.readInt();//num textures
	//  trace('num textures in brush:' + count);

  while (getChunkSize()!=0) 
  {
	  var brush:Brush = new Brush(0);
	  if (count == 2)
	  {
	  brush.materialType = 1;
	  }

	  
	     readstring();
	     brush.DiffuseColor.r= file.readFloat();//r
	     brush.DiffuseColor.g= file.readFloat();//g
		 brush.DiffuseColor.b=file.readFloat();//b
		 brush.alpha= file.readFloat();//a
		 
		 file.readFloat();//shiness
		var blend:Int= file.readInt();//blend
		var fx:Int = file.readInt();//fx
	//	trace(blend + ',' + fx);
		 
		 for (i in 0...count)
		 {
			var textid = file.readInt();//texid
			
			if (Assets.exists(texturepath+textures[textid]))
			{
				if (i == 0)
				{
				brush.setTexture(Gdx.Instance().getTexture(texturepath + textures[textid], true));
				} else
				{
				brush.setDetail(Gdx.Instance().getTexture(texturepath + textures[textid], true));
					
				}
				
			} else
			{
				trace("ERROR: Texture ("+texturepath+textures[textid]+") dont find..");
			}
			
		 }
		 

	brushes.push(brush);
  }
  }
    private function readKEYS(bone:B3DBone):Void
   {
	   var Flags:Int = file.readInt();
	   var Size:Int = 4;
	   if (Flags & 1 > 0) Size += 12;
	   
       if (Flags & 2 > 0) Size += 12;
	   
       if (Flags & 4 > 0) Size += 16;
	
	
	
	      
	   
	   while (getChunkSize()!=0) 
      {
	         var frame:Int=file.readInt();
	  	 
	   	    if ((Flags & 1)>0)//position
            {
				var x:Float = file.readFloat();
				var y:Float = file.readFloat();
				var z:Float = file.readFloat();
			//	trace(x+','+y+','+z);
			   bone.Pos.push( new PosKeyFrame(frame,new Vector3(x, y, z)));
				
			}
	        if ((Flags & 2)>0)//scale
            {
				var x:Float = file.readFloat();
				var y:Float = file.readFloat();
				var z:Float = file.readFloat();
			//		trace(x+','+y+','+z);
			//	bone.Scl.push( new PosKeyFrame(frame,new Vector3(x, y, z)));
				
			}
			 if ((Flags & 4)>0)//rotation
            {
				var w:Float = file.readFloat();
				var x:Float = file.readFloat();
				var y:Float = file.readFloat();
				var z:Float = file.readFloat();
			    bone.Rot.push(new RotKeyFrame( frame,new Quaternion(x, y, z, -w)));
				 
				
			}
	
			
	  }
	  
   }
  private function readNODE(parent:SceneNode):SceneNode
  {
     var n:String = readstring();
	 var child:SceneNode = null;

	var lastBone = new B3DBone(scene, parent, id + Bones.length, n);
	
		 
	lastBone.position.x=  file.readFloat();//x
	lastBone.position.y=  file.readFloat();//y
	lastBone.position.z = file.readFloat();//z

	  
	
	lastBone.scaling.x=  file.readFloat();//sx
	lastBone.scaling.y=  file.readFloat();//sy
	lastBone.scaling.z =  file.readFloat();//sz
	  
	 var rw:Float=file.readFloat();//rx
	 var rx:Float=file.readFloat();//ry
	 var ry:Float=file.readFloat();//rz
	 var rz:Float =file.readFloat();//rw
	 lastBone.rotationQuaternion = new Quaternion(rx, ry, rz, -rw);
	 lastBone.UpdateAbsoluteTransformation();
	 lastBone.initialize();
	 lastBone.index = Bones.length;

		
	 Bones.push(lastBone);
	 
while (getChunkSize() != 0)
{
	  var ChunkName = ReadChunk();
	 if(ChunkName=='MESH') 
     {
	 readMESH();
     } else  
	 if(ChunkName=='BONE') 
     {
	 readBone(lastBone);
     } 
	 if(ChunkName=='ANIM') 
     {
	  readANIM();
	
     }  else  
     if(ChunkName=='KEYS') 
     {
	readKEYS(lastBone); 
     } else
    if(ChunkName=='NODE') 
     {
	 child = readNODE(lastBone);
	}
	breakChunk();
}
lastBone.numKeys = lastBone.Pos.length;



  	 
  return lastBone;
}
  private function  readMESH():Void
  {
	
  var brushID:Int=file.readInt();//brushID
	while (getChunkSize() != 0)
    {
	   var ChunkName = ReadChunk();
	   if(ChunkName=='VRTS') 
       {
	   readVTS();
      } else  
      if(ChunkName=='TRIS') 
       {
    	readTRIS();
     } 
	 breakChunk();
	}  
	 
  }
  private function readVTS():Void
  {
	  listVertex = [];
		

        var flags = file.readInt();
		var tex_coord = file.readInt();
		var texsize = file.readInt();
		
		var Size:Int = 12 + tex_coord * texsize * 4;
		if (flags & 1 == 1) Size += 12;
	    if (flags & 2 == 2) Size += 16;
		
			  
	  var VertexCount:Int = Std.int(getChunkSize() / Size);
	  
	   
	//	trace('Num Vextex:'+ VertexCount +' flags:'+ flags + ', numUVC:' + tex_coord);
		
		while (getChunkSize() > 0)
		{
			var vertex:B3DVertex = new B3DVertex();
			vertex.Pos.x=file.readFloat();//x
            vertex.Pos.y=file.readFloat();//y
            vertex.Pos.z=file.readFloat();//z
			 if ((flags & 1)>0)
            {
            vertex.Normal.x=file.readFloat();// nx
            vertex.Normal.y=file.readFloat();//ny
            vertex.Normal.z=file.readFloat();//nz
			//trace(vertex.Normal.toString());
            }
		    if ((flags & 2)>0)
            {
            vertex.Color.r=file.readFloat();//r
            vertex.Color.g=file.readFloat();//g
            vertex.Color.b=file.readFloat();//b
			vertex.Color.a = file.readFloat();//a
			//trace(vertex.Color.toString());
			}
		
			if (tex_coord == 1)
			{
			    if (texsize == 2)
			   {
               vertex.TCoords0.x=file.readFloat();//u
               vertex.TCoords0.y = file.readFloat();//v
			   } else
			   {
			    vertex.TCoords0.x =file.readFloat();//u
                vertex.TCoords0.y = file.readFloat();//v
			    file.readFloat();//w
		     	}
			} else
			{
				 if (texsize == 2)
			   {
               vertex.TCoords0.x=file.readFloat();//u
               vertex.TCoords0.y=file.readFloat();//v
			   vertex.TCoords1.x=file.readFloat();//u
               vertex.TCoords1.y=file.readFloat();//v
			   } else
			   {
			    vertex.TCoords0.x =file.readFloat();//u
                vertex.TCoords0.y = file.readFloat();//v
			    file.readFloat();//w
		        vertex.TCoords1.x =file.readFloat();//u
                vertex.TCoords1.y = file.readFloat();//v
			    file.readFloat();//w
		     	}
			}
			
			listVertex.push(vertex);
		}
		
	
		
	//	trace('Num vertex:' + listVertex.length);

  }


  public function readTRIS():Void
  {
	   var brushid = file.readInt();
	   var TriangleCount:Int = Std.int(getChunkSize() / 12);
	   var surf = new Surface(scene.shader);
	   var listIndices:Array<Int>=[];
	   while (getChunkSize() != 0)
		{
			var v0 = file.readInt();
			var v1 = file.readInt();
			var v2 = file.readInt();
			surf.AddTriangle(v0, v1, v2);
		}
		for (i in 0...listVertex.length)// Std.int(TriangleCount *3))
	    {
			var vertex = listVertex[i];
			surf.AddFullVertexColorVector(vertex.Pos, vertex.Normal, vertex.TCoords0, vertex.TCoords1,vertex.Color);
	    }

		surf.brush.clone(brushes[brushid]);
	    surf.updateBounding();
	
		surfaces.push(surf);
	  	trace('create suface '+surf.CountVertices() +','+Std.int(surf.CountTriangles()));
	 

  }

  private function OnAnimate(timeMs:Int):Void
  {
	  if (LastTimeMs==0)	// first frame
	{
		LastTimeMs = timeMs;
	}
	
	buildFrameNr(timeMs - LastTimeMs);
	
	
	 for (i in 0... Bones.length)
		{
			var bone:B3DBone = Bones[i];
			bone.UpdateAbsoluteTransformation();
			bone.animateJoints(CurrentFrameNr);
		}

		
		for ( s in 0...surfaces.length)
		{
		
		var surf:Surface = surfaces[s];
		
		for (i in 0...listVertex.length)
		{
		   var vertex:B3DVertex = this.listVertex[i];
		   
		var x:Float = 0;
		var y:Float = 0;
		var z:Float = 0;
		var ovx:Float = 0;
		var ovy:Float = 0;
		var ovz:Float = 0;
		
		   if (vertex.bones[0].boneId != -1)
		   {
			  var pos:Vector3 = vertex.Pos;
			  
			  var tform_mat:Matrix4 =Matrix4.multiplyWith( Bones[vertex.bones[0].boneId].AbsoluteTransformation,Bones[vertex.bones[0].boneId].offMatrix);
			  
			  var w:Float = vertex.bones[0].Wight;
		
		      
			  ovx=pos.x;
              ovy=pos.y;
              ovz=pos.z;
            
			   x = ( tform_mat.m[0] * ovx + tform_mat.m[4] * ovy + tform_mat.m[8] * ovz  + tform_mat.m[12] ) * w;
			   y = ( tform_mat.m[1] * ovx + tform_mat.m[5] * ovy + tform_mat.m[9] * ovz  + tform_mat.m[13] ) * w;
		 	   z = ( tform_mat.m[2] * ovx + tform_mat.m[6] * ovy + tform_mat.m[10] * ovz + tform_mat.m[14] ) * w;
		
			  if (vertex.bones[1].boneId != -1)
		      {
			    var tform_mat:Matrix4 =Matrix4.multiplyWith( Bones[vertex.bones[1].boneId].AbsoluteTransformation,Bones[vertex.bones[1].boneId].offMatrix);
			
			   var w:Float = vertex.bones[1].Wight;
		       x =x+ ( tform_mat.m[0] * ovx + tform_mat.m[4] * ovy + tform_mat.m[8] * ovz  + tform_mat.m[12] ) * w;
			   y =y+ ( tform_mat.m[1] * ovx + tform_mat.m[5] * ovy + tform_mat.m[9] * ovz  + tform_mat.m[13] ) * w;
		 	   z =z+ ( tform_mat.m[2] * ovx + tform_mat.m[6] * ovy + tform_mat.m[10] * ovz + tform_mat.m[14] ) * w;
		
			   
			  if (vertex.bones[2].boneId != -1)
		      {
		    	var tform_mat:Matrix4 =Matrix4.multiplyWith( Bones[vertex.bones[2].boneId].AbsoluteTransformation,Bones[vertex.bones[2].boneId].offMatrix);
			
			    var w:Float = vertex.bones[2].Wight;
		       x =x+ ( tform_mat.m[0] * ovx + tform_mat.m[4] * ovy + tform_mat.m[8] * ovz  + tform_mat.m[12] ) * w;
			   y =y+ ( tform_mat.m[1] * ovx + tform_mat.m[5] * ovy + tform_mat.m[9] * ovz  + tform_mat.m[13] ) * w;
		 	   z =z+ ( tform_mat.m[2] * ovx + tform_mat.m[6] * ovy + tform_mat.m[10] * ovz + tform_mat.m[14] ) * w;
		
			   
			   if (vertex.bones[3].boneId != -1)
		      {
		   	  var tform_mat:Matrix4 =Matrix4.multiplyWith( Bones[vertex.bones[3].boneId].AbsoluteTransformation,Bones[vertex.bones[3].boneId].offMatrix);
			   var w:Float = vertex.bones[3].Wight;
		       x =x+ ( tform_mat.m[0] * ovx + tform_mat.m[4] * ovy + tform_mat.m[8] * ovz  + tform_mat.m[12] ) * w;
			   y =y+ ( tform_mat.m[1] * ovx + tform_mat.m[5] * ovy + tform_mat.m[9] * ovz  + tform_mat.m[13] ) * w;
		 	   z =z+ ( tform_mat.m[2] * ovx + tform_mat.m[6] * ovy + tform_mat.m[10] * ovz + tform_mat.m[14] ) * w;
		
		      }
		      }
			 
		     }
		    }
		  
			
	
				

		surf.VertexCoords(i, x, y, z);
		}
		}
	
	
	LastTimeMs = timeMs;
  }
  
  public function setCurrentFrame( frame:Float):Void
{
	// if you pass an out of range value, we just clamp it
	CurrentFrameNr =Util.clamp( frame, StartFrame, EndFrame );

}

public function setFrameLoop( begin:Int, end:Int, loop:Bool = true ):Void
{
	Looping = loop;
	
	if (end < begin)
	{
		StartFrame = Util.iclamp(end, 0, NumFrames);
		EndFrame = Util.iclamp(begin, StartFrame, NumFrames);
	}
	else
	{
		StartFrame = Util.iclamp(begin, 0, NumFrames);
		EndFrame = Util.iclamp(end, StartFrame, NumFrames);
	}
	if (FramesPerSecond < 0)
		setCurrentFrame(EndFrame);
	else
		setCurrentFrame(StartFrame);

	
}


//! sets the speed with witch the animation is played
public function setAnimationSpeed( framesPerSecond:Float):Void
{
	FramesPerSecond = framesPerSecond * 0.001;
}

private function   buildFrameNr( timeMs:Int)
{
	



	if ((StartFrame==EndFrame))
	{
		CurrentFrameNr = StartFrame; //Support for non animated meshes
	}
	else if (Looping)
	{
		// play animation looped
		CurrentFrameNr += timeMs * FramesPerSecond;

		// We have no interpolation between EndFrame and StartFrame,
		// the last frame must be identical to first one with our current solution.
		if (FramesPerSecond > 0.0) //forwards...
		{
			if (CurrentFrameNr > EndFrame)
			{
				CurrentFrameNr = StartFrame + Util.fMod( CurrentFrameNr - StartFrame , (EndFrame-StartFrame));
			}
		}
		else //backwards...
		{
			if (CurrentFrameNr < StartFrame)
				CurrentFrameNr = EndFrame - Util.fMod(EndFrame - CurrentFrameNr , (EndFrame-StartFrame));
				
		}
	}
	else
	{
		// play animation non looped

		CurrentFrameNr += timeMs * FramesPerSecond;
		if (FramesPerSecond > 0.0) //forwards...
		{
			if (CurrentFrameNr > EndFrame)
			{
				CurrentFrameNr = EndFrame;
				
			}
		}
		else //backwards...
		{
			if (CurrentFrameNr < StartFrame)
			{
				CurrentFrameNr = StartFrame;
				
			}
		}
	}
}

  

override public function render(camera:Camera) 
	{

		if (!Visible) return;
	    var meshTrasform:Matrix4 = getAbsoluteTransformation();
		
	
	
    	var scaleFactor:Float = Math.max(scaling.x, scaling.y);
             scaleFactor = Math.max(scaleFactor,scaling.z);
		Gdx.Instance().numMesh++;
	     scene.shader.setWorldMatrix(meshTrasform);
	
	  
	  	
		   

    	for (i in 0... surfaces.length)
		{
			
			  scene.setMaterial(surfaces[i].brush);
		///	  surfaces[i].primitiveType = GL.LINE_LOOP;
		     surfaces[i].render();
			  
		}
		

	}
	
    override public function update():Void
	{
		super.update();
     if(isAnimated)  OnAnimate(Gdx.Instance().getTimer());
	}
}