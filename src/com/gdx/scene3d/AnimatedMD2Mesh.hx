package com.gdx.scene3d ;


import com.gdx.gl.shaders.Brush;
import com.gdx.gl.Texture;
import com.gdx.math.BoundingInfo;
import com.gdx.math.Face;
import com.gdx.math.Matrix4;
import com.gdx.math.Vector2;
import com.gdx.math.Vector3;
import com.gdx.scene3d.buffer.ArrayBuffer;
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
 * djoker
 *  teste teste / create surfaces from all frames more memory 
 */
class AnimatedMD2Mesh extends Mesh
{
	private var animations:Array<Anim>;
	private var animation:Anim;

	
	private var lastTime:Float;
	public var brush:Brush;
		
	private var vtxTrasform:Vector3;
	private var vtxPoint:Vector3;

	public var currentFrame:Int;
	public var nextFrame:Int;
	private var lastanimation:Int;
	private var currentAnimation:Int;
	private var rollto_anim:Int;
	private var RollOver:Bool;
	
	 
	
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
		 super(scene, parent, id, name);
	    lastTime = 0;
		brush = new Brush(0);
		brush.DiffuseColor.set(1, 1, 1);
	
		surfaces = [];
		
	animations = new  Array<Anim>();
	lastanimation = -1;
	currentAnimation = 0;
	rollto_anim = 0;
	RollOver=false;
		
		vtxTrasform = Vector3.zero;
	vtxPoint = Vector3.zero;
	 		
		 faces = [];
	     vertex = [];
		 tfaces = [];
		 uvCoords = [];
		 
	
	
	
	 animations.push(new Anim("stand", 0, 39, 9));
	 animations.push(new Anim("run", 40, 45, 10));
	 animations.push(new Anim("attack", 46, 53, 10));
	 animations.push(new Anim("pain_a", 54, 57, 7));
	 animations.push(new Anim("pain_b", 58, 61, 7));
	 animations.push(new Anim("pain_c", 62, 65, 7));
	 animations.push(new Anim("jump", 66, 71, 7));
	 animations.push(new Anim("flip", 72, 83, 7));
	 animations.push(new Anim("salute", 84, 94, 7));
	 animations.push(new Anim("fallback", 95, 111, 10));
	 animations.push(new Anim("wave", 112, 122, 7));
	 animations.push(new Anim("point", 123, 134, 6));
	 animations.push(new Anim("crouch_stand", 135, 153, 10));
	 animations.push(new Anim("crouch_walk", 154, 159, 7));
	 animations.push(new Anim("crouch_attack", 160, 168, 10));
	 animations.push(new Anim("crouch_pain", 169, 172, 7));
	 animations.push(new Anim("crouch_death", 173, 177, 5));
	 animations.push(new Anim("death_fallback", 178, 183, 7));
	 animations.push(new Anim("death_fallbackforward", 184, 189, 7));
	 animations.push(new Anim("death_fallbackslow", 190, 197, 7));
	 animations.push(new Anim("boom", 198, 198, 5));
	 animations.push(new Anim("all", 0, 198, 15));
		
	 currentFrame=0;
	 nextFrame = 1;
	
     setAnimation(0);
			
	}
	
	public function clone(Parent:SceneNode = null , id:Int = 0, name:String="MD2MeshClone"):AnimatedMD2Mesh
	{
		 var mesh:AnimatedMD2Mesh = new AnimatedMD2Mesh(scene, Parent, id, name);
		 scene.addChild(mesh);
		
		 mesh.frames_Count = frames_Count;
		 mesh.face_Count = face_Count;
		 
		 
		for (s1 in 0...CountSurfaces())
		{
			var surf1:Surface = getSurface(s1);
			
			if (surf1.CountVertices() == 0 && surf1.CountFaces() == 0 ) continue;
			
				var surf:Surface = mesh.createSurface();
				//add vertices
		
					for (v in 0...surf1.CountVertices())
					{
					var vx=surf1.VertexX(v);
					var vy=surf1.VertexY(v);
					var vz=surf1.VertexZ(v);
					
					var vnx=surf1.VertexNX(v);
					var vny=surf1.VertexNY(v);
					var vnz=surf1.VertexNZ(v);
					var vu0=surf1.VertexU(v,0);
					var vv0=surf1.VertexV(v,0);
					var vu1=surf1.VertexU(v,1);
					var vv1=surf1.VertexV(v,1);
		

					var v2=surf.AddVertex(vx,vy,vz);
					surf.VertexColor(v2,255,255,255,1);
					surf.VertexNormal(v2,vnx,vny,vnz);
					surf.VertexTexCoords(v2,vu0,vv0,0,0);
					surf.VertexTexCoords(v2,vu1,vv1,0,1);
					}
					
					for (t in 0...surf1.CountTriangles())
				  {
					var v0=surf1.TriangleVertex(t,0);
					var v1=surf1.TriangleVertex(t,1);
					var v2=surf1.TriangleVertex(t,2);

					surf.AddTriangle(v0,v1,v2);
				}
				if (surf1.brush != null)
				{
					surf.brush.clone(surf1.brush);
				}
				surf.reset_vbo = -1;
				surf.UpdateVBO();
				surf.updateBounding();
			}
		
		mesh.UpdateBoundingBox();
	
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
		
		   
//	animVertex = [[]];
	
	for (i in 0...NumFrames)
	{
		var scale:Vector3 = new Vector3(0, 0, 0);
		var Translate:Vector3 = new Vector3(0, 0, 0);
		
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
	
	trace(faces.length);
	trace(tfaces.length);
	
	trace(vertex.length);
	trace(uvCoords.length);
	
	for (f in 0...NumFrames)
	{
	//	trace("cerate surface "+f);
		var surface = createSurface();
	   for (i in 0 ... this.faces.length)
	   {
	    var v1:Vector3 = vertex[f * vertex_Count + faces[i].v0];
	    var v2:Vector3 = vertex[f * vertex_Count + faces[i].v1];
	    var v3:Vector3 = vertex[f * vertex_Count + faces[i].v2];
        var uv1:Vector2 = uvCoords[0 * uv_count + tfaces[i].v0];
	    var uv2:Vector2 = uvCoords[0 * uv_count + tfaces[i].v1];
	    var uv3:Vector2 = uvCoords[0 * uv_count + tfaces[i].v2];
		
            Bounding.addInternalVector(v1);
	        Bounding.addInternalVector(v2);
	        Bounding.addInternalVector(v3);
		
		surface.brush = brush;
		surface.addFace(v3, v2, v1, uv3, uv2, uv1);
        	
	  }
	 
	  surface.updateBounding();
	  UpdateNormals();
	  surface.UpdateVBO();
	  //surface.Optimize();
	}
	
	//trace("update normal");
      //   UpdateNormals();
         faces = [];
	     vertex = [];
		 tfaces = [];
		 uvCoords = [];
}
	

	public function addAnimation(name:String, startFrame:Int, endFrame:Int, fps:Int):Int
	{
		animations.push(new Anim(name, startFrame, endFrame, fps));
		return (animations.length - 1);
		
	}
	
	override public function getBrush(index:Int=0):Brush
	{
			
			
			return brush;
		
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

	
	override public function update():Void 
	{
		
			var time:Float = Gdx.Instance().getTimer();
        var elapsedTime:Float = time - lastTime;
	    var t:Float = elapsedTime / (1000.0 / animation.fps);
		
		nextFrame = (currentFrame+1);
		if (nextFrame > animation.frameEnd)
		{
			nextFrame = animation.frameStart;
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
		
		super.update();
		
	}
    override public function render(camera:Camera) 
	{
		
        var meshTrasform:Matrix4 = AbsoluteTransformation;
		
		
		var scaleFactor:Float = Math.max(scaling.x, scaling.y);
             scaleFactor =  Math.max(scaleFactor, scaling.z);
			
		Bounding.update(meshTrasform, scaleFactor);
		if (!Bounding.isInFrustrum(camera.frustumPlanes)) return;
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


		
		
		 var s:Surface = surfaces[currentFrame];
		 if (s != null) s.render(true);
				
    

		
		
	}

	 public function getVertexPoint( index:Int):Vector3
	{
		 var s:Surface = surfaces[currentFrame];
		 
		vtxPoint.copyFrom(s.getVertex(index));
		return vtxPoint;
		
	}
	 public function getVertexPointTrasform( index:Int):Vector3
	{
	
	var s:Surface = surfaces[currentFrame];
		 
		vtxPoint.copyFrom(s.getVertex(index));
		Vector3.TransformCoordinatesToRef(vtxPoint, AbsoluteTransformation, vtxTrasform);
		return  vtxTrasform;
		
	}
}