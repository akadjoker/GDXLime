package com.gdx.scene3d ;


import com.gdx.collision.OctreeTriangleSelector;
import com.gdx.collision.WorldColider;
import com.gdx.color.Color4;
import com.gdx.gl.shaders.Brush;
import com.gdx.gl.Texture;
import com.gdx.math.BoundingInfo;
import com.gdx.math.Face;
import com.gdx.math.Matrix4;
import com.gdx.math.Quaternion;
import com.gdx.math.Vector2;
import com.gdx.math.Vector3;
import com.gdx.scene3d.buffer.ArrayBuffer;
import com.gdx.scene3d.buffer.ArraySingleBuffer;
import com.gdx.scene3d.buffer.PackBuffer;
import com.gdx.scene3d.buffer.PackIndexBuffer;
import com.gdx.scene3d.irr.S3DVertex;
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

#if neko
import sys.io.File;
import sys.io.FileOutput;
#end





class AnimMeshTransform extends SceneNode
{
	private var animations:Array<Anim>;
	private var animation:Anim;
	private var lastTime:Float;
	public var currentFrame:Int;
	public var nextFrame:Int;
	private var lastanimation:Int;
	private var currentAnimation:Int;
	private var rollto_anim:Int;
	private var RollOver:Bool;
	public var vertex_Count:Int;
	public var face_Count:Int;
	public var frames_Count:Int;
	public var submeshs:Array<SubMesh>;
	public var brush:Brush;
    private var NumMesh:Int;
	private var NumFrames:Int;
	private var FPS:Int;
	 
	
	public function new(scene:Scene,Parent:SceneNode = null , id:Int = 0, name:String="MD2Mesh")  
	{
	super(scene, Parent, id, name);
	lastTime = 0;
	animations = new  Array<Anim>();
	lastanimation = -1;
	currentAnimation = 0;
	rollto_anim = 0;
	RollOver=false;	
 	brush = new Brush(0);
	}
	
	public function addAnimation(name:String, startFrame:Int, endFrame:Int, fps:Int):Int
	{
		animations.push(new Anim(name, startFrame, endFrame, fps));
		return (animations.length - 1);
		
	}
	
	

	
	
	public function load(f:String):Void
	{
	 var file:ByteArray =	Assets.getBytes(f);
	 file.endian = "littleEndian";

	 var headersize:Int = file.readInt();
	 var headername:String = file.readUTFBytes(headersize);
	 var headerId:Int = file.readInt();
	 
	  NumMesh = file.readInt();
	  NumFrames = file.readInt();
	  FPS = file.readInt();

	 animations.push(new Anim("all", 0, NumFrames, FPS));
     setAnimation(0);
	 
	 submeshs = [];
	 trace(NumMesh + ',' + NumFrames + ',' + FPS);
	 for (i in 0...NumMesh)
	 {
		 
		 var numFrames = NumFrames;
		 var numFaces  = file.readInt();
		 var numVertex = file.readInt();
		 var mesh:SubMesh = new SubMesh(scene, numVertex, id + i, this);
		 mesh.numFaces = numFaces;
		 mesh.numFrames = numFrames;
		 mesh.numVertex = numVertex;
		 
		 for (v in 0...mesh.numFaces) 
		 {
			 var v0:Int = file.readInt();
			 var v1:Int = file.readInt();
			 var v2:Int = file.readInt();
			 mesh.addFace(v0, v1, v2);
		 }
		 
		 for (v in 0...mesh.numVertex) 
		 {
			 var x:Float = file.readFloat();
			 var y:Float = file.readFloat();
			 var z:Float = file.readFloat();
			 var nx:Float = file.readFloat();
			 var ny:Float = file.readFloat();
			 var nz:Float = file.readFloat();
			 var u:Float = file.readFloat();
			 var v:Float = file.readFloat();
			 mesh.addVertex(x, y, z, nx, ny, nz, u, v);
		 }
	
		  
		  for (v in 0...mesh.numFrames) 
		 {
			 var x:Float = file.readFloat();
			 var y:Float = file.readFloat();
			 var z:Float = file.readFloat();
			 var rx:Float = file.readFloat();
			 var ry:Float = file.readFloat();
			 var rz:Float = file.readFloat();
			 var rw:Float = file.readFloat();
			 var frame:MeshFrame = new MeshFrame();
			 frame.Pos = new Vector3(x, y, z);
			 trace(frame.Pos.toString());
			 frame.Rot = new Quaternion(rx, ry, rz, rw);
			 mesh.frames.push(frame);
		  }
		  mesh.build();		 
		 submeshs.push(mesh);
	 }

	 Bounding.calculate();
   }
	
	
	
	
	public function numAnimations():Int
	{
		return animations.length;
	}
	
	public function BackAnimation():Void
	{
		currentAnimation = (currentAnimation - 1) %  (numAnimations());
		if (currentAnimation < 0) currentAnimation = numAnimations();
	    setAnimation(currentAnimation);
	}
	public function NextAnimation():Void
	{
		currentAnimation = (currentAnimation +1) %  (numAnimations());
		if (currentAnimation >numAnimations()) currentAnimation = 0;
	    setAnimation(currentAnimation);
	}
	public function setAnimation(num:Int):Void
	{
	 if (num == lastanimation) return;
	 if (num > animations.length) return;
		
	 currentAnimation = num;	
	 animation = animations[currentAnimation];
	 currentFrame = animations[currentAnimation].frameStart;
	 lastanimation = currentAnimation;
	}
	public function setAnimationByName(name:String):Void
	{
	 
		for (i in 0 ... animations.length)
		{
			
			if (animations[i].name == name)
			{
				setAnimation(i);
				break;
			}
			
		}
		
	}
	public function SetAnimationRollOver(num:Int,next:Int):Void
	{
		if (num == lastanimation) return;
		if (num > animations.length) return;
		
	 currentAnimation = num;	
	 animation = animations[currentAnimation];
	 currentFrame = animations[currentAnimation].frameStart;
	 lastanimation = currentAnimation;
	 RollOver = true;
	 rollto_anim = next;
	}
	
	
	private function  updateframes()
	{

	//	var matrix:Matrix4 = Matrix4.Zero();
		var time:Float = Gdx.Instance().getTimer();
        var elapsedTime:Float = time - lastTime;
	    var t:Float = elapsedTime / (1000.0 / animation.fps);
		
		nextFrame = (currentFrame+1);
		if (nextFrame > animation.frameEnd)
		{
			nextFrame = animation.frameStart;
		}
		
		if (nextFrame >= 199)
		{
			//i'm fuck 
			nextFrame = 0;
		}
		if (RollOver)
		{
			if (currentFrame >= animation.frameEnd)
			{
				setAnimation(rollto_anim);
				RollOver = false;
			}
		}
		
		if (elapsedTime >= (1000.0 / animation.fps) )
	    {		
	    currentFrame = nextFrame;
		lastTime = time;	
	    }
    
		for (m in 0...submeshs.length)
		{
			var mesh:SubMesh = submeshs[m];
			mesh.lerp(currentFrame, nextFrame, t);
			mesh.update();
		}

		

}
	
	override public function update():Void 
	{
		
		updateframes();
		super.update();
		
	}
    override public function render(camera:Camera) 
	{

		
        var meshTrasform:Matrix4 = AbsoluteTransformation;
		var scaleFactor:Float = Math.max(scaling.x, scaling.y);
             scaleFactor =  Math.max(scaleFactor, scaling.z);
			
		Bounding.update(meshTrasform, scaleFactor);
		Bounding.boundingBox.renderAlignedColor(scene.lines, 1, 0, 1);
     	Gdx.Instance().numMesh++;
		scene.shader.setMaterialType(brush.materialType);
		scene.shader.setColor(brush.DiffuseColor.r, brush.DiffuseColor.g, brush.DiffuseColor.b, brush.alpha);
		brush.Applay();	
		if (brush.useTextures)
		{
				scene.shader.enableTexture(true);
			    scene.shader.setTexture0(brush.texture0);
		} else
		{
				scene.shader.enableTexture(false);
		}


		//5 cabeç 14 mao

	for (m in 0...submeshs.length)
	
	{
	 var mesh:SubMesh = submeshs[m];
     mesh.render(camera);	
   }
  

		super.render(camera);
		
	}

	public function getBrush():Brush
	{
		return this.brush;
	}


}

class MeshFrame
{
	public var Pos:Vector3;
	public var Rot:Quaternion;
	public function new()
	{
		Pos = null;
		Rot = null;
	}
	
}



class SubMesh extends SceneNode
{
	private var vbo:PackIndexBuffer;
	
	public	var vertex:Array<S3DVertex> ;
	public var faces:Array<Face>;
	
	public var frames:Array<MeshFrame>;
	public var numFrames:Int;
	public var numVertex:Int;
	public var numFaces:Int;
	public var matrix:Matrix4;
	private var v1:Vector3;
	private var v2:Vector3;
	private var v3:Vector3;
	
		public function new(scene:Scene,capacity:Int,id:Int,Parent:SceneNode) 
	{
		super(scene,Parent,id,"SubMesh_"+id);
		vertex = [];
		faces = [];
		frames = [];
		matrix = Matrix4.Identity();
		vbo= new PackIndexBuffer(scene.shader,capacity,capacity*6);
	    
	 
	}
	public function addVertex(x:Float,y:Float,z:Float,nx:Float,ny:Float,nz:Float,u:Float,v:Float):Void
	{
		var vtx = new S3DVertex();
		vtx.Pos.set(x, y, z);
		vtx.Normal.set(nx, ny, nz);
		vtx.TCoords.set(u, v);
		vertex.push(vtx);
		vbo.addVertex(vtx.Pos, vtx.Normal, vtx.TCoords, vtx.Color);
	}
	public function addFace(i0:Int,i1:Int, i2:Int):Void
	{
		faces.push(new Face(i0, i1, i2));
		vbo.addIndex(i0);
		vbo.addIndex(i1);
		vbo.addIndex(i2);
	}
	public function build():Void 
	{
		
	
	
	}
	public function lerp(start:Int, end:Int, t:Float):Void
	{
			var r:Quaternion = Quaternion.Slerp( frames[start].Rot, frames[end].Rot, t);
			position.copyFrom(Vector3.Lerp(frames[start].Pos, frames[end].Pos, t));
		    rotate(r);
	}
	

	 override public function render(camera:Camera) 
	{
	 scene.shader.setWorldMatrix(AbsoluteTransformation);
     vbo.render(GL.TRIANGLES,  numFaces * 3  );
     Gdx.Instance().numTris   += numFaces;
	 Gdx.Instance().numVertex += numVertex;
	 super.render(camera);
   }
	
}