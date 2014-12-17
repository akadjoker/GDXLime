package com.gdx.scene3d ;

/*
 Copyright (C) 2013-2014 Luis Santos AKA DJOKER
 
 This file is part of GDXLime .
 
 TrenchBroom is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 TrenchBroom is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with GDXLime.  If not, see <http://www.gnu.org/licenses/>.
 */

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
import com.gdx.scene3d.buffer.Imidiatemode;
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
import haxe.xml.Fast;
import lime.Assets;





class MD3Mesh extends SceneNode
{
		
	private var animations:Array<Anim>;
	public var animation:Anim;

	
	private var lastTime:Float;

		

	private var animtedVertex:Vector3 = Vector3.zero;
	private var animtedVexterIndex:Int = 0;

	public var currentFrame:Int;
	public var nextFrame:Int;
	private var lastanimation:Int;
	private var currentAnimation:Int;
	private var rollto_anim:Int;
	private var RollOver:Bool;
	private var numBoneFrames:Int;
    private var numTags:Int;

	 
	public var frames_Count:Int;
	var animtionFPS:Int;
	
	public var tags:Array<Md3Tag>;
	public var subMesh:Array<MD3SubMesh>;
	public var bones:Array<SceneNode>;
	

	
	public function new(scene:Scene,Parent:SceneNode = null , id:Int = 0, name:String="MD3Mesh")  
	{
		super(scene, Parent, id, name);
	    lastTime = 0;
		
		tags = [];
		bones = [];
		subMesh = [];
		
		
	  
		
	   
	animations = new  Array<Anim>();

	lastanimation = -1;
	currentAnimation = 0;
	rollto_anim = 0;
	RollOver=false;

	}
	
	public function clone(Parent:SceneNode = null , id:Int = 0, name:String="MD3MeshClone"):MD3Mesh
	{
		 var mesh:MD3Mesh = new MD3Mesh(scene, Parent, id, name);
		 scene.addChild(mesh);
		
		 return mesh;
	}
	
	public function loadAnimation(filename:String):Void
	{
		

		var xml:Xml = Xml.parse (Assets.getText(filename));
		var node = xml.firstElement();
		for (frameNode in node.elements()) 
		{
			
			var frameNodeFast = new Fast(frameNode);
		
			        var name = frameNodeFast.att.name;
					var start = Std.parseInt ( frameNodeFast.att.start );
					var end = Std.parseInt ( frameNodeFast.att.end );
					var fps = Std.parseInt ( frameNodeFast.att.fps );
				
					
					animations.push(new Anim(name, start, end, fps));
					
				///	trace(name+" , start:" + start + " ," +end+" + end + " , " + fps);
			
		}
		
		

	
	}
	public function setBrushSkin(i:Int,texture:Texture)
	{
		if (texture == null) return;
		getBrush(i).setTexture(texture);
	}
	public function getBrush(index:Int):Brush
	{
		return subMesh[index].brush;
	}
	public function setSkin(texture:Texture)
	{
		if (texture == null) return;
		for (i in 0...subMesh.length)
		{
			subMesh[i].brush.setTexture(texture);
		}
	}
	
	
	public function getTag(Index:Int):SceneNode
	{
		return bones[Index % numTags];
	}
	
	
		private function readCreatorName(byteData:ByteArray):String {
        var name:String = "";
        var k:Int = 0;
        for (j in 0...16) {
            var ch:Int = byteData.readUnsignedByte();


            if (ch > 0x30 && ch <= 0x7A ) 
			{
                name += String.fromCharCode(ch);
            }

        }
        return name;
    }
	private function readMeshName(byteData:ByteArray):String {
        var name:String = "";
        var k:Int = 0;
        for (j in 0...68) {
            var ch:Int = byteData.readUnsignedByte();

		
            if (ch > 0x30 && ch <= 0x7A ) 
			{
                name += String.fromCharCode(ch);
            }

        }
        return name;
    }
	private function updateTags(currentFrame:Int, nexFrame:Int, pol:Float):Void
	{
		var frameOffsetA:Int = currentFrame * numTags;
	    var frameOffsetB :Int= nexFrame * numTags;
	
		
		for (i in 0...numTags)
		{
			bones[i].position.copyFrom(Vector3.Lerp(tags[frameOffsetA + i].position, tags[frameOffsetB + i].position, pol));
			var q = Quaternion.Slerp(tags[frameOffsetA + i].rotation, tags[frameOffsetB + i].rotation, pol);
			bones[i].rotate(q);// .rotation.set(angle.y, angle.x, angle.z);
	
		}
	}
	private function readTagName(byteData:ByteArray):String {
        var name:String = "";
        var k:Int = 0;
        for (j in 0...64) {
            var ch:Int = byteData.readUnsignedByte();

            if (ch > 65 && ch <= 122 ) 
			{
                name += String.fromCharCode(ch);
            }

         
        }
        return name;
    }
	public function load(f:String):Void
	{
	var file:ByteArray =	Assets.getBytes(f);
	file.endian = "littleEndian";
	
	
	
    var fileid:String=file.readUTFBytes(4);//4IDP3
    var Version:Int=file.readInt();//15
    var strFile:String = readMeshName(file);// file.readUTFBytes(68);//68
	
     numBoneFrames=file.readInt();//num keyframes
     numTags = file.readInt();//number tags per frame
	var numMeshes:Int = file.readInt();//number of mehs/skins
	var numMaxSkins:Int = file.readInt();////maximum number of unique skins used in md3 file.
	
	var frameStart:Int = file.readInt();//starting position of frame-structur
	
	var tagStart:Int = file.readInt();//starting position of tag-structures
	var tagEnd:Int = file.readInt();//ending position of tag-structures/starting position of mesh-structures
	
	var fileSize:Int = file.readInt();


	trace("INFO: Header Size: "+fileSize);
	trace("INFO: Num Bone Frames: "+numBoneFrames);
	trace("INFO: Num Tags: " + numTags);
	trace("INFO: Num Sub Meshs: "+numMeshes);
	trace("INFO: Num Max Skins: " + numMaxSkins);
	


		file.position = tagStart;
//		trace("INFO: start read tags: " + numTags);
		
	
		
		for (i in 0...(numBoneFrames*numTags))
		{
		 var tag:Md3Tag = new Md3Tag();
		 
		  tag.name = readTagName(file);

	//	 trace(tag.name);
		 tag.position.x = file.readFloat();
		 tag.position.z = file.readFloat();
		 tag.position.y = file.readFloat();
		 var f:Float = 0;
		 f = file.readFloat();
		 f = file.readFloat();
		 f = file.readFloat();
		 
		 f = file.readFloat();
		 f = file.readFloat();
		 f = file.readFloat();
		 
		 tag.axe.y = file.readFloat();
 		 tag.axe.x = file.readFloat();
 		 tag.axe.z = file.readFloat();
		 
	

 		 tag.UpdateRotation();
		 this.tags.push(tag); 
		 
		}
		
		for (i in 0...numTags)
		{
			var b:SceneNode = new SceneNode(scene, this,  id+i, tags[i].name);
			bones.push ( b);
			addChild(b);
		}
		
		var offset:Int =  tagEnd;
		
			
		trace("INFO: start read meshs ");
		
		for ( i in 0...numMeshes)
		{
			file.position = offset;
			var mesh:MD3SubMesh = new MD3SubMesh(this);
			mesh.load(file, offset);
			subMesh.push(mesh);
			offset += mesh.meshSize;
		}
		
	//	trace(file.position +"," + file.bytesAvailable);
	
	    for ( i in 0...numMeshes)
		{
			this.subMesh[i].build();
		}
		


	animtionFPS = 16;
    frames_Count = numBoneFrames;
	
	
	currentFrame=0;
	nextFrame=0;
	
	
	

	 animations.push(new Anim("all", 0, frames_Count, 15));
	
     setAnimation(0);
	


	
	
		
	

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

	
		var time:Float = Gdx.Instance().getTimer();
        var elapsedTime:Float = time - lastTime;
	    var t:Float = elapsedTime / (1000.0 / animation.fps);
		
		nextFrame = (currentFrame+1);
		if (nextFrame > animation.frameEnd)
		{
			nextFrame = animation.frameStart;
		}
		
		//this coun never hapand
		if (nextFrame >= frames_Count)
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
		
		
		 
		//trace(currentFrame+ " , " + nextFrame);
		if (elapsedTime >= (1000.0 / animation.fps) )
	    {
		 var dt:Float = 1000.0 / animation.fps ; 
		 currentFrame = nextFrame;
	 	 lastTime = time;	
	     }
 
		 updateTags(currentFrame, nextFrame, t); 
		 for (i in 0...subMesh.length)
		{
			 this.subMesh[i].update(currentFrame,nextFrame, t);
		}
		
	
		
		
}
	override public function update():Void 
	{
		
		super.update();
		updateframes();
		for (child in childs)
		{
		child.update();
		}
	}
	
    override public function render(camera:Camera) 
	{

		Bounding.setFloats(99999999, -99999999);
		var meshTrasform:Matrix4 = AbsoluteTransformation;
		var scaleFactor:Float = Math.max(scaling.x, scaling.y);
             scaleFactor =  Math.max(scaleFactor, scaling.z);
			
	
		
		for (i in 0...subMesh.length)
		{
        this.subMesh[i].Bounding.update(meshTrasform, scaleFactor);
	    this.Bounding.addInternalVector( this.subMesh[i].Bounding.boundingBox.minimum);
		this.Bounding.addInternalVector( this.subMesh[i].Bounding.boundingBox.maximum);
		}
		Bounding.update(meshTrasform, scaleFactor);
			
		
		if (!Bounding.isInFrustrum(camera.frustumPlanes)) return;
	   if (showBoundingBoxes) Bounding.boundingBox.renderAligned(scene.lines);
		Gdx.Instance().numMesh++;
    	scene.shader.setWorldMatrix(meshTrasform);
	

			
		
        for (i in 0...subMesh.length)
		{
    	if(showSubBoundingBoxes) this.subMesh[i].Bounding.boundingBox.renderAlignedColor(scene.lines, 0, 1, 1);	
		this.subMesh[i].render(); 
		}
		
		
		
	
     super.render(camera);
		
	}

	
	
	
}

class MD3SubMesh extends Node
{
	public var brush:Brush;
		
	private var    mesh_parent:MD3Mesh;
	public var 	    meshID:String;//4					// This stores the mesh ID (We don't care)
	public var      skin:String;//68;				// This stores the mesh name (We do care)
	public var 		numMeshFrames:Int;				// This stores the mesh aniamtion frame count
	public var    	numSkins:Int;					// This stores the mesh skin count
	public var      numVertices:Int;				// This stores the mesh vertex count
	public var 	    numTriangles:Int;				// This stores the mesh face count
	public var 		triStart:Int;					// This stores the starting offset for the triangles
	public var 		headerSize:Int;					// This stores the header size for the mesh
	public var      TexVectorStart:Int;					// This stores the starting offset for the UV coordinates
	public var 		vertexStart:Int;				// This stores the starting offset for the vertex indices
	public var 		meshSize:Int;					// This stores the total mesh size
	public var      triangles:Array < Face>;
    public var      vertex:Array < Vector3>;
	public var      TexCoord:Array < Vector2>;
	private var vbo:PackBuffer;


	
	public function new(mesh:MD3Mesh)
	{
		super(0, "subMD3Mesh");
		triangles = [];
		vertex = [];
		TexCoord = [];
		mesh_parent = mesh;
		brush = new Brush(0);
	}
	public function load(f:ByteArray,MeshOffset:Int)
	{
		
		
		
		
	 meshID = f.readUTFBytes(4);
	 skin = readFrameName(f);
	 trace("skin:"+skin);
	 numMeshFrames = f.readInt();
	 numSkins = f.readInt();
	 numVertices = f.readInt();
	 numTriangles = f.readInt();
	 triStart = f.readInt();
	 headerSize = f.readInt();
	 TexVectorStart = f.readInt();
	 vertexStart = f.readInt();
	 meshSize = f.readInt();
	 
	 vbo = new PackBuffer(mesh_parent.scene.shader, numTriangles, 1);
	 
	f.position = MeshOffset + triStart;
	for ( i in 0...numTriangles)
	{
		var v0:Int = f.readInt();
		var v1:Int = f.readInt();
		var v2:Int = f.readInt();
		triangles.push(new Face(v2,v1,v0));
		
	}
	 
	f.position = MeshOffset + TexVectorStart;
	for ( i in 0...numVertices)
	{
		
	     var uvx = f.readFloat();
		 var uvy = f.readFloat();
		 var v:Vector2=new Vector2(uvx, uvy);
		 TexCoord.push(v); 
	}
	 
	f.position = MeshOffset + vertexStart;
	for ( i in 0...numVertices*numMeshFrames)
	{
		
	     var x = f.readShort()/64;
		 var y = f.readShort()/64;
		 var z = f.readShort()/64;
		 var n1:Int = f.readUnsignedByte();
		 var n2:Int = f.readUnsignedByte();
		 var v:Vector3 = new Vector3(x, z, y);
		 vertex.push(v); 
	}
	
	}
	public function build()
	{
		
	//******************
	 var uv_count:Int = this.TexCoord.length;
	

	    for (index in 0... this.triangles.length)
		{
            var i1 = this.triangles[index].v0;
            var i2 = this.triangles[index].v1;
            var i3 = this.triangles[index].v2;

            var p1 = vertex[i1];
            var p2 = vertex[i2];
            var p3 = vertex[i3];
	
            var p1p2 = p1.subtract(p2);
            var p3p2 = p3.subtract(p2);

            var normal = Vector3.Normalize(Vector3.Cross(p1p2, p3p2));
			
					
	var t1:Vector2 = TexCoord[0 * uv_count + triangles[index].v0];
	var t2:Vector2 = TexCoord[0 * uv_count + triangles[index].v1];
	var t3:Vector2 = TexCoord[0 * uv_count + triangles[index].v2];
	
	        vbo.addVertex(p1, normal, t1,  Color4.WHITE);
			vbo.addVertex(p2, normal, t2,  Color4.WHITE);
			vbo.addVertex(p3, normal, t3,  Color4.WHITE);
       }

	
		 update(0, 0, 1);
	
	}
	

	public function update(currentFrame:Int, nexFrame:Int, pol:Float):Void
	{
		Bounding.setFloats(99999999, -99999999);
		
		var currentOffsetVertex:Int = currentFrame * numVertices;
		var nextCurrentOffsetVertex:Int = nexFrame * numVertices;
	
		  var index = 0;
		
		for (i in 0...numTriangles)
		{
			var v0:Int = triangles[i].v0;
			var v1:Int = triangles[i].v1;
			var v2:Int = triangles[i].v2;
			

	var vx1:Vector3 = Vector3.Lerp(vertex[currentOffsetVertex + v0], vertex[nextCurrentOffsetVertex + v0], pol);
	vbo.setPosition(index++, vx1);
	var vx2:Vector3 = Vector3.Lerp(vertex[currentOffsetVertex + v1], vertex[nextCurrentOffsetVertex + v1], pol);
	vbo.setPosition(index++, vx2);
	var vx3:Vector3 = Vector3.Lerp(vertex[currentOffsetVertex + v2], vertex[nextCurrentOffsetVertex + v2], pol);
	vbo.setPosition(index++, vx3);
	
	

	Bounding.addInternalPoint(vx1.x, vx1.z, vx1.y);
	Bounding.addInternalPoint(vx2.x, vx2.z, vx2.y);
	Bounding.addInternalPoint(vx3.x, vx3.z, vx3.y);
	
	}
	
	}
	
	
	 public function render():Void
	{
		
		mesh_parent.scene.shader.setMaterialType(brush.materialType);
		mesh_parent.scene.shader.setColor(brush.DiffuseColor.r, brush.DiffuseColor.g, brush.DiffuseColor.b, brush.alpha);
		brush.Applay();	
	
	
		
		if (brush.useTextures)
		{
				mesh_parent.scene.shader.enableTexture(true);
			    mesh_parent.scene.shader.setTexture0(brush.texture0);
		} else
		{
				mesh_parent.scene.shader.enableTexture(false);
		}

		
		vbo.render(GL.TRIANGLES,numTriangles *3 );
	    Gdx.Instance().numTris   += numTriangles;
		Gdx.Instance().numVertex += numVertices;
	}
	
	private function readFrameName(byteData:ByteArray):String 
	{
        var name:String = "";
        var k:Int = 0;
        for (j in 0...68) {
            var ch:Int = byteData.readUnsignedByte();
//48 122
            if (ch > 33 && ch <= 126 ) 
			{
                name += String.fromCharCode(ch);
            } 

        }
        return name;
    }

}



class Md3Tag 
{
	public var position:Vector3;
	public var name:String;
	public var axe:Vector3;
	public var rotation:Quaternion;
	
	public function new()  
	{
		
		position = Vector3.zero;
		axe =Vector3.zero;
		
		
		
	}
	
	public function UpdateRotation()
	{
		rotation = new Quaternion(
		axe.x,//rotationMatrix[7],
		0.0,
		-axe.y,//-rotationMatrix[6],
		1 + axe.z);//1 + rotationMatrix[8]);
		
		rotation.normalize();
		
		
		
	}

	
}


