package com.gdx.scene3d ;


import com.gdx.collision.WorldColider;
import com.gdx.color.Color4;
import com.gdx.gl.shaders.Brush;
import com.gdx.gl.Texture;
import com.gdx.math.BoundingInfo;
import com.gdx.math.Face;
import com.gdx.math.Matrix4;
import com.gdx.math.Vector2;
import com.gdx.math.Vector3;
import com.gdx.scene3d.buffer.ArrayBuffer;
import com.gdx.scene3d.buffer.ArraySingleBuffer;
import com.gdx.scene3d.buffer.PackBuffer;
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
import lime.utils.ByteArray;




/**
 * ..com.gdx.3dscene.Mesh.Meshjoekr
 */
class MD2Mesh extends SceneNode
{
	


		private var vbo:PackBuffer;


	

	public var brush:Brush;
		

	private var animtedVertex:Vector3 = Vector3.zero;
	private var animtedVexterIndex:Int = 0;

	private var lastTime:Float;
    private var TicksPerSecond:Float;
	private var StartFrame:Int;
	private var EndFrame:Int;
	private var nextFrame:Int;
	private var currentFrame:Int;
	private var FramesPerSecond:Float;
	private var CurrentFrameNr:Float;
    private var LastTimeMs:Int;
	private	var Looping:Bool;
	private var CurrentTime:Float;
	
	
	private var vtxTrasform:Vector3;
	private var vtxPoint:Vector3;
	public var vertex_Count:Int;
	public var uv_count:Int;
	public var face_Count:Int;
	public var frames_Count:Int;
	var faces:Array<Face>;
	var tfaces:Array<Face>;
	var uvCoords:Array<Vector2>;
	var vertex:Array<Vector3>;
	
	public function new(scene:Scene,Parent:SceneNode = null , id:Int = 0, name:String="MD2Mesh")  
	{
		 super(scene, Parent, id, name);

		brush = new Brush(0);

	vtxTrasform = Vector3.zero;
	vtxPoint = Vector3.zero;
	
		
		 faces = [];
	     vertex = [];
		 tfaces = [];
		 uvCoords = [];
		 

	
	 
         FramesPerSecond = 0.025;
		 StartFrame = 0;
		 nextFrame = 0;
		 EndFrame = 0;
		 CurrentFrameNr = 0;
		 LastTimeMs = 0;
		 Looping = true;

		 lastTime = Gdx.Instance().getTimer();

			
	}
	
	
	
	public function clone(Parent:SceneNode = null , id:Int = 0, name:String="MD2MeshClone"):MD2Mesh
	{
		 var mesh:MD2Mesh = new MD2Mesh(scene, Parent, id, name);
		 scene.addChild(mesh);
		
		 mesh.brush.clone(brush);
		
		 mesh.frames_Count = frames_Count;
	     mesh.vertex_Count = vertex_Count; 
      	 mesh.face_Count = face_Count;
		 mesh.uv_count = uv_count;
		
	
	
		mesh.faces = [];
		mesh.vertex = [];
		mesh.tfaces = [];
		mesh.uvCoords = [];
		for ( i in 0...faces.length)
		{
			mesh.faces.push(this.faces[i].clone());
		}
		
		for ( i in 0...this.uvCoords.length)
		{
			mesh.uvCoords.push(this.uvCoords[i].clone());
		}
		for ( i in 0...this.tfaces.length)
		{
			mesh.tfaces.push(tfaces[i].clone());
		}
		for ( i in 0...vertex.length)
		{
			mesh.vertex.push(this.vertex[i].clone());
		}
		
	
		mesh.build();
		return mesh;
	}
	
	
	
	private function readFrameName(byteData:ByteArray):String {
        var name:String = "";
        var k:Int = 0;
        for (j in 0...16) {
            var ch:Int = byteData.readUnsignedByte();

            if (ch > 0x39 && ch <= 0x7A && k == 0) {
                name += String.fromCharCode(ch);
            }

            if (ch >= 0x30 && ch <= 0x39) {
                k++;
            }
        }
        return name;
    }
	
	public function load(f:String):Void
	{
	var file:ByteArray =	Assets.getBytes(f);
	file.endian = "littleEndian";
	
	
	
    var Magic:Int=file.readInt();
    var Version:Int=file.readInt();
    var SkinWidth:Int=file.readInt();
    var SkinHeight:Int=file.readInt();
    var FrameSize:Int=file.readInt();
    var NumSkins:Int=file.readInt();
    var NumVertices:Int=file.readInt();
    var NumTexCoords:Int=file.readInt();
    var NumTriangles:Int=file.readInt();
    var NumGlCommands:Int=file.readInt();
    var NumFrames:Int=file.readInt();
    var OffsetSkins:Int=file.readInt();
    var OffsetTexCoords:Int=file.readInt();
    var OffsetTriangles:Int=file.readInt();
    var OffsetFrames:Int=file.readInt();
    var OffsetGlCommands:Int=file.readInt();
    var OffsetEnd:Int = file.readInt();

    frames_Count = NumFrames;
	vertex_Count=NumVertices ;
	face_Count = NumTriangles;
	uv_count = NumTexCoords;
	trace("Num vertex:" + vertex_Count);
	trace("Num uvs:"+uv_count);
	trace("Num FRames:"+frames_Count);
	currentFrame=0;
	nextFrame=1;
	
	 setFrameLoop(0,frames_Count);
	 setAnimationSpeed(15.0);
	
	
  

	file.position = OffsetTriangles;
	for (i in 0...NumTriangles)
	{
		var v0, v1, v2:Int;
		v0=file.readUnsignedShort();
		v1=file.readUnsignedShort();
		v2=file.readUnsignedShort();
        var vt:Face = new Face(v0, v1, v2);
		faces.push(vt);
		
		v0=file.readUnsignedShort();
		v1=file.readUnsignedShort();
		v2=file.readUnsignedShort();
		var vc:Face = new Face(v0, v1, v2);
		tfaces.push(vc);
		
	}
	
		
	var  dmaxs:Float = 1.0/(SkinWidth);
    var  dmaxt:Float = 1.0/(SkinHeight);
  

		

	file.position = OffsetTexCoords;
	for (i in 0...NumTexCoords)
	{
		var u:Float = file.readShort()/SkinWidth;
		var v:Float = file.readShort()/SkinHeight;
		uvCoords.push(new Vector2(u,v));
	}
	file.position = OffsetFrames;
	var lastname:String = " ";
	var count:Int = 0;
	var endFrame:Int = 0;
		
		   

	
	for (i in 0...NumFrames)
	{
		var scale:Vector3 = Vector3.zero;
		var Translate:Vector3 = Vector3.zero;
		
		scale.x = file.readFloat();
		scale.y = file.readFloat();
		scale.z = file.readFloat();
		
		Translate.x = file.readFloat();
		Translate.y = file.readFloat();
		Translate.z = file.readFloat();
		
		var name:String = readFrameName(file);

	
		
		if (lastname != name)
		{
			lastname = name;
			endFrame = i;
			count = 0;
		}
		count++;
		

		for (j in 0...NumVertices) 
		{
			   var x:Int= file.readUnsignedByte() ;
			   var y:Int= file.readUnsignedByte() ;
			   var z:Int = file.readUnsignedByte() ;     
               var sx:Float = scale.x * x  + Translate.x;
			   var sy:Float = scale.z * z  + Translate.z;
			   var sz:Float = scale.y * y  + Translate.y;
			   vertex.push(new Vector3(sz, sy, sx));		
               file.position ++;				
		}
		
	}
	
	
	
    build();	
}
	
	private function build()
	
	{
	
  
	 vbo = new PackBuffer(scene.shader,this.faces.length*3+3, 0);
		
	 var count:Int = 0;
	    for (index in 0... this.faces.length)
		{
            var i1 = faces[index].v0;
            var i2 = faces[index].v1;
            var i3 = faces[index].v2;
  
            var p1 = vertex[i1];
            var p2 = vertex[i2];
            var p3 = vertex[i3];
			
	        Bounding.addInternalVector(p1);
	        Bounding.addInternalVector(p2);
	        Bounding.addInternalVector(p3);
	
            var p1p2 = p1.subtract(p2);
            var p3p2 = p3.subtract(p2);

            var normal = Vector3.Normalize(Vector3.Cross(p1p2, p3p2));
         	var t1:Vector2 = uvCoords[0* uv_count + tfaces[index].v0];
	        var t2:Vector2 = uvCoords[0* uv_count + tfaces[index].v1];
	        var t3:Vector2 = uvCoords[0* uv_count + tfaces[index].v2];

			vbo.addVertex(p1, normal, t1,  Color4.WHITE);
			vbo.addVertex(p2, normal, t2,  Color4.WHITE);
			vbo.addVertex(p3, normal, t3,  Color4.WHITE);
			count++;
			count++;
			count++;
	    }
		
			 
	
	

	 
	 
	}
	
	public function getBrush():Brush
	{
		return this.brush;
	}

	
	
	
	
	 private function OnAnimate(timeMs:Int):Void
  {
	  if (LastTimeMs==0)	// first frame
	{
		LastTimeMs = timeMs;
	}
	
	   buildFrameNr(timeMs - LastTimeMs);
       Bounding.setFloats(99999999, -99999999);
	   currentFrame = Std.int(CurrentFrameNr);
	   nextFrame = (currentFrame+1);
	   if (nextFrame > EndFrame)
	   {
		   nextFrame = currentFrame;
	   }
	   
		
    
	  var index = 0;
      for (i in 0 ... this.faces.length)
	  {
		var v1:Vector3 = Vector3.Lerp(vertex[currentFrame * vertex_Count + faces[i].v0], vertex[nextFrame * vertex_Count + faces[i].v0], 1);
		vbo.setPosition(index++, v1);
	    var v2:Vector3 = Vector3.Lerp(vertex[currentFrame * vertex_Count + faces[i].v1], vertex[nextFrame * vertex_Count + faces[i].v1], 1);
	   vbo.setPosition(index++, v2);
		var v3:Vector3 = Vector3.Lerp(vertex[currentFrame * vertex_Count + faces[i].v2], vertex[nextFrame * vertex_Count + faces[i].v2], 1);
		vbo.setPosition(index++, v3);
		Bounding.addInternalVector(v1);
		Bounding.addInternalVector(v2);
		Bounding.addInternalVector(v3);
      }
	
	  LastTimeMs = timeMs;
}
	
	override public function update():Void 
	{
		super.update();
    	 OnAnimate(Gdx.Instance().getTimer());
	}
    override public function render(camera:Camera) 
	{
		if (camera == null) return;
	

		
        var meshTrasform:Matrix4 = AbsoluteTransformation;
		
		
		var scaleFactor:Float = Math.max(scaling.x, scaling.y);
             scaleFactor =  Math.max(scaleFactor, scaling.z);
			
		Bounding.update(meshTrasform, scaleFactor);
		if (EnableCull)
		{
		if (!Bounding.isInFrustrum(camera.frustumPlanes)) return;
		}
		if (showBoundingBoxes) Bounding.boundingBox.renderAligned(scene.lines);
		
		Gdx.Instance().numMesh++;
		scene.shader.setWorldMatrix(meshTrasform);
		      
		scene.setMaterial(brush);
	
		
	
		
		if (brush.useTextures)
		{
				scene.shader.enableTexture(true);
			    scene.shader.setTexture0(brush.texture0);
		} else
		{
				scene.shader.enableTexture(false);
		}


		
	vbo.render(GL.TRIANGLES,  face_Count *3 );
		
	
		
	    Gdx.Instance().numTris   += face_Count;
		Gdx.Instance().numVertex += vertex_Count;
		Gdx.Instance().numSurfaces += 1;
}

	 public function getVertexPoint( index:Int):Vector3
	{
		
		vtxPoint.copyFrom(vbo.getPosition(index));
		return vtxPoint;
		
	}
	 public function getVertexPointTrasform( index:Int):Vector3
	{
	
		vtxPoint.copyFrom(vbo.getPosition(index));
		Vector3.TransformCoordinatesToRef(vtxPoint, AbsoluteTransformation, vtxTrasform);
		return  vtxTrasform;
		
	}

	public function getAnimationSpeed():Float
{
	return FramesPerSecond * 1000.0;
}
public function getFrameNr():Int
{
	return Std.int(CurrentFrameNr);
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
		StartFrame = Util.iclamp(end, 0, frames_Count);
		EndFrame = Util.iclamp(begin, StartFrame, frames_Count);
	}
	else
	{
		StartFrame = Util.iclamp(begin, 0, frames_Count);
		EndFrame = Util.iclamp(end, StartFrame, frames_Count);
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


}