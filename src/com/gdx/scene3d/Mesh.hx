package com.gdx.scene3d ;


import com.gdx.collision.Coldet;
import com.gdx.color.Color4;
import com.gdx.gl.shaders.Brush;
import com.gdx.gl.Texture;
import com.gdx.math.BoundingInfo;
import com.gdx.math.Matrix4;
import com.gdx.math.Ray;
import com.gdx.math.Vector2;
import com.gdx.math.Vector3;
import com.gdx.scene3d.buffer.Imidiatemode;
import com.gdx.scene3d.Surface;
import lime.Assets;
import lime.graphics.Image;
import lime.system.System;
import lime.utils.ByteArray;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLShader;
import lime.graphics.opengl.GLUniformLocation;
import lime.graphics.opengl.GLTexture;
import lime.graphics.RenderContext;
import lime.utils.Float32Array;
import lime.utils.Int16Array;
import com.gdx.scene3d.importer.Max3DSParser;
import com.gdx.scene3d.importer.AC3DParser;
import haxe.io.Path;

#if neko
import sys.io.File;
import sys.io.FileOutput;
#end



/**
 * djoker
 */
class Mesh extends SceneNode
{

	
	public var useNormals (default, default) :Bool = true;
	public var useColors (default, default) :Bool = true;
	public var useTCoords0 (default, default) :Bool = true;
	public var useTCoords1 (default, default) :Bool = true;

	public var maxWidth:Float = 0; 
	public var maxHeight:Float = 0;
	public var maxDepth :Float = 0;
	public var Size :Float = 0;
	public var Center :Vector3 = Vector3.zero;

	
	public  var  surfaces:Array<Surface>;


	public function new(scene:Scene,Parent:SceneNode = null , id:Int = 0, name:String="SceneNode") 
	{
		 super(scene,Parent, id, name); 
		 surfaces = new Array<Surface>();
         renderType = 0;
	  
	}
	
	
		
public function GetSceneDimensions():Void
{
	
	var numberOfVerts:Int = 0;
	
	for (i in 0...CountSurfaces())
	{
     var s:Surface = this.surfaces[i];
		
	 numberOfVerts+= s.CountVertices();
	for(v in 0 ... s.CountVertices() )
	{
		
		Center.x = Center.x + s.VertexX(v);
		Center.y = Center.y + s.VertexY(v);
		Center.z = Center.z + s.VertexZ(v);
	}
	}
	
	Center.x /= numberOfVerts;
	Center.y /= numberOfVerts;	
	Center.z /= numberOfVerts;

	for (i in 0...CountSurfaces())
	{
     var s:Surface = this.surfaces[i];
		
	 
	for(v in 0 ... s.CountVertices() )
	{
		var currentWidth:Float  = Math.abs( s.VertexX(v) - Center.x);	
		var currentHeight:Float = Math.abs( s.VertexY(v) - Center.y);		
		var currentDepth:Float  = Math.abs( s.VertexZ(v) - Center.z);	
    	if(currentWidth  > maxWidth)	maxWidth  = currentWidth;
    	if(currentHeight > maxHeight)	maxHeight = currentHeight;
		if(currentDepth > maxDepth)		maxDepth  = currentDepth;
	}
	}

	maxWidth *= 2;		maxHeight *= 2;		maxDepth *= 2;
	if(maxWidth > maxHeight && maxWidth > maxDepth)
		Size = maxWidth;
	else if(maxHeight > maxWidth && maxHeight > maxDepth)
		Size = maxHeight;
	else
		Size = maxDepth;
		

 
  trace(this.Center.toString()+" , " + Size+','+maxWidth+','+maxHeight+','+maxDepth);
}
	override public function render(camera:Camera) 
	{
	
		if (!Visible) return;
	    var meshTrasform:Matrix4 = AbsoluteTransformation;
		
    	var scaleFactor:Float = Math.max(scaling.x, scaling.y);
             scaleFactor = Math.max(scaleFactor,scaling.z);
		Bounding.update(meshTrasform, scaleFactor);
	
		if(EnableCull)if (!Bounding.isInFrustrum(camera.frustumPlanes)) return;
		if (showBoundingBoxes) Bounding.boundingBox.renderAligned(scene.lines);
		Gdx.Instance().numMesh++;
	     scene.shader.setWorldMatrix(meshTrasform);
	
	
		  		
		   

    	for (i in 0... surfaces.length)
		{
			if ( surfaces[i].Visible)
			{
			  surfaces[i].Bounding.update(meshTrasform, scaleFactor);
			  
				
			if (EnableCull)  if (!surfaces[i].Bounding.isInFrustrum(camera.frustumPlanes)) continue;
			if (showSubBoundingBoxes) surfaces[i].Bounding.boundingBox.renderAligned(scene.lines);
			if (showNormals) 			surfaces[i].debugNormals(meshTrasform,scene.lines, debugNormalLineSize);
			
			  scene.setMaterial(surfaces[i].brush);
		      surfaces[i].render();
			  
			}
		}
		
		super.render(camera);
	}
	public function UpdateNormals():Void
	{
		for (i in 0... surfaces.length)
		{
		 	surfaces[i].ComputeNormal();
			
		}
	}
	public function UpdateNormalsFlat():Void
	{
		for (i in 0... surfaces.length)
		{
		 	surfaces[i].ComputeNormalFlat();
			
		}
	}
		public function UpdateNormalsSmooth():Void
	{
		for (i in 0... surfaces.length)
		{
		 	surfaces[i].ComputeNormalSmooth();
			
		}
	}
	public function makePlanarMapping(resolution:Float=0.002)
	{
		for (i in 0... surfaces.length)
		{
		 	surfaces[i].makePlanarMapping(resolution);
			
		}
	}
	
	public function UpdateBoundingBox():Void
	{
			var scaleFactor:Float = Math.max(scaling.x, scaling.y);
             scaleFactor = Math.max(scaleFactor,scaling.z);
	
			 
	      var minimum:Vector3 = new Vector3(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY);
          var maximum:Vector3 = new Vector3(Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY);

		for (i in 0... surfaces.length)
		{
		      surfaces[i].Bounding.update(getAbsoluteTransformation(),scaleFactor);
			  minimum = Vector3.Minimize(surfaces[i].Bounding.boundingBox.minimum,minimum);
              maximum = Vector3.Maximize(surfaces[i].Bounding.boundingBox.maximum, maximum);
		}
			this.Bounding = new BoundingInfo(minimum, maximum);
			this.Bounding.update(getAbsoluteTransformation(),scaleFactor);
	}
	public function sortMaterial():Void
	{
	surfaces.sort(materialIndex);
	}
	
	function materialIndex(a:Surface, b:Surface):Int
    {

    if (a.materialIndex < b.materialIndex) return -1;
    if (a.materialIndex > b.materialIndex) return 1;
    return 0;
    } 

	public function CountVertices():Int
	{
		var count:Int = 0;
		
		for (i in 0...surfaces.length)
		{
			count += surfaces[i].no_verts;
		}
		
		return count;
	}
	public function CountSurfaces():Int
	{
		return surfaces.length;
	}
	public  function createSurface():Surface
	{
		var surf:Surface = new  Surface(scene.shader);
		surfaces.push(surf);
		return surf;
	}
	
	
	public function addSurface(surf:Surface):Void
	{
		if ( (surf.CountTriangles() == 0) || (surf.CountVertices() == 0)) return;
		
					
			var new_surf:Bool = true;
			
			for (s2 in 0...CountSurfaces())
			{
					var surf2:Surface = getSurface(s2);
				    var no_verts2:Int = surf2.CountVertices();
				
				
				//if (Brush.CompareBrushes(surf2.brush, surf.brush) == true)
			//	if (Brush.CompareBrushesMaterial(surf2.brush,surf.brush)==true)
			   if(surf.materialIndex==surf2.materialIndex)
				{
				
					for (v in 0...surf.CountVertices())
					{
					var vx=surf.VertexX(v);
					var vy=surf.VertexY(v);
					var vz=surf.VertexZ(v);
					
					var vnx=surf.VertexNX(v);
					var vny=surf.VertexNY(v);
					var vnz=surf.VertexNZ(v);
					var vu0=surf.VertexU(v,0);
					var vv0=surf.VertexV(v,0);
					var vu1=surf.VertexU(v,1);
					var vv1=surf.VertexV(v,1);
		

					var v2 = surf2.AddVertex(vx, vy, vz);
		
					surf2.VertexColor(v2,255,255,255,1);
					surf2.VertexNormal(v2,vnx,vny,vnz);
					surf2.VertexTexCoords(v2,vu0,vv0,0,0);
					surf2.VertexTexCoords(v2,vu1,vv1,0,1);
					}
					
					for (t in 0...surf.CountTriangles())
				  {
					var v0=surf2.TriangleVertex(t,0)+no_verts2;
					var v1=surf2.TriangleVertex(t,1)+no_verts2;
					var v2=surf2.TriangleVertex(t,2)+no_verts2;

					surf2.AddTriangle(v0,v1,v2);
				}
				surf2.reset_vbo = -1;
				surf2.UpdateVBO();
				surf2.updateBounding();
				new_surf = false;
				break;
				
				}
				
			}
			if (new_surf == true)
			{
				var surf2:Surface = createSurface();
	
					for (v in 0...surf.CountVertices())
					{
					var vx=surf.VertexX(v);
					var vy=surf.VertexY(v);
					var vz=surf.VertexZ(v);
					
					var vnx=surf.VertexNX(v);
					var vny=surf.VertexNY(v);
					var vnz=surf.VertexNZ(v);
					var vu0=surf.VertexU(v,0);
					var vv0=surf.VertexV(v,0);
					var vu1=surf.VertexU(v,1);
					var vv1=surf.VertexV(v,1);
		

					var v2=surf2.AddVertex(vx,vy,vz);
					surf2.VertexColor(v2,255,255,255,1);
					surf2.VertexNormal(v2,vnx,vny,vnz);
					surf2.VertexTexCoords(v2,vu0,vv0,0,0);
					surf2.VertexTexCoords(v2,vu1,vv1,0,1);
					}
					
					for (t in 0...surf.CountTriangles())
				  {
					var v0=surf.TriangleVertex(t,0);
					var v1=surf.TriangleVertex(t,1);
					var v2=surf.TriangleVertex(t,2);

					surf2.AddTriangle(v0,v1,v2);
				}
			    surf2.brush.clone(surf.brush);
				surf2.materialIndex = surf.materialIndex;
				surf2.reset_vbo = -1;
				surf2.UpdateVBO();
				surf2.updateBounding();
			}
		
      //  sortMaterial();
		UpdateBoundingBox();
		
	}
	public function AddMesh(mesh2:Mesh):Void
	{
		for (s1 in 0...mesh2.CountSurfaces())
		{
			var surf1:Surface = mesh2.getSurface(s1);
			
			if (surf1.CountVertices() == 0 && surf1.CountFaces() == 0 ) continue;
			
			var new_surf:Bool = true;
			
			for (s2 in 0...CountSurfaces())
			{
				var surf2:Surface = getSurface(s2);
				var no_verts2:Int = surf2.CountVertices();
				
				if (Brush.CompareBrushes(surf1.brush, surf2.brush) == true)
				{
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
		

					var v2 = surf2.AddVertex(vx, vy, vz);
		
					surf2.VertexColor(v2,255,255,255,1);
					surf2.VertexNormal(v2,vnx,vny,vnz);
					surf2.VertexTexCoords(v2,vu0,vv0,0,0);
					surf2.VertexTexCoords(v2,vu1,vv1,0,1);
					}
					
					for (t in 0...surf1.CountTriangles())
				  {
					var v0=surf1.TriangleVertex(t,0)+no_verts2;
					var v1=surf1.TriangleVertex(t,1)+no_verts2;
					var v2=surf1.TriangleVertex(t,2)+no_verts2;

					surf2.AddTriangle(v0,v1,v2);
				}
				surf2.reset_vbo = -1;
				surf2.UpdateVBO();
				surf2.updateBounding();
				new_surf = false;
				break;
				
				}
				
			}
			if (new_surf == true)
			{
				var surf:Surface = createSurface();
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
		}
		sortMaterial();
		UpdateBoundingBox();
	}
	public function CopyMeshTo(mesh2:Mesh):Void
	{
		for (s1 in 0...CountSurfaces())
		{
			var surf1:Surface = getSurface(s1);
			
			if (surf1.CountVertices() == 0 && surf1.CountFaces() == 0 ) continue;
			
			var new_surf:Bool = true;
			
			for (s2 in 0...mesh2.CountSurfaces())
			{
				var surf2:Surface = mesh2.getSurface(s2);
				var no_verts2:Int = surf2.CountVertices();
				
				if (Brush.CompareBrushes(surf1.brush, surf2.brush) == true)
				{
					//add vertices
					trace("add vertices surf1");
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
		

					var v2 = surf2.AddVertex(vx, vy, vz);
		
					surf2.VertexColor(v2,255,255,255,1);
					surf2.VertexNormal(v2,vnx,vny,vnz);
					surf2.VertexTexCoords(v2,vu0,vv0,0,0);
					surf2.VertexTexCoords(v2,vu1,vv1,0,1);
					}
					
					for (t in 0...surf1.CountTriangles())
				  {
					var v0=surf1.TriangleVertex(t,0)+no_verts2;
					var v1=surf1.TriangleVertex(t,1)+no_verts2;
					var v2=surf1.TriangleVertex(t,2)+no_verts2;

					surf2.AddTriangle(v0,v1,v2);
				}
				surf2.reset_vbo = -1;
				surf2.UpdateVBO();
				surf2.updateBounding();
				new_surf = false;
				break;
				
				}
				
			}
			if (new_surf == true)
			{
				var surf:Surface = mesh2.createSurface();
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
		}
		UpdateBoundingBox();
	}
	public  function createCube()
	{
	var surf:Surface = createSurface();
	surf.AddVertex(-1.0,-1.0,-1.0);
	surf.AddVertex(-1.0, 1.0,-1.0);
	surf.AddVertex( 1.0, 1.0,-1.0);
	surf.AddVertex( 1.0,-1.0,-1.0);
	
	surf.AddVertex(-1.0,-1.0, 1.0);
	surf.AddVertex(-1.0, 1.0, 1.0);
	surf.AddVertex( 1.0, 1.0, 1.0);
	surf.AddVertex( 1.0,-1.0, 1.0);
	
	surf.AddVertex(-1.0,-1.0, 1.0);
	surf.AddVertex(-1.0, 1.0, 1.0);
	surf.AddVertex( 1.0, 1.0, 1.0);
	surf.AddVertex( 1.0,-1.0, 1.0);
	
	surf.AddVertex(-1.0,-1.0,-1.0);
	surf.AddVertex(-1.0, 1.0,-1.0);
	surf.AddVertex( 1.0, 1.0,-1.0);
	surf.AddVertex( 1.0,-1.0,-1.0);
	
	surf.AddVertex(-1.0,-1.0, 1.0);
	surf.AddVertex(-1.0, 1.0, 1.0);
	surf.AddVertex( 1.0, 1.0, 1.0);
	surf.AddVertex( 1.0,-1.0, 1.0);
	
	surf.AddVertex(-1.0,-1.0,-1.0);
	surf.AddVertex(-1.0, 1.0,-1.0);
	surf.AddVertex( 1.0, 1.0,-1.0);
	surf.AddVertex( 1.0,-1.0,-1.0);
	
	surf.VertexNormal(0,0.0,0.0,-1.0);
	surf.VertexNormal(1,0.0,0.0,-1.0);
	surf.VertexNormal(2,0.0,0.0,-1.0);
	surf.VertexNormal(3,0.0,0.0,-1.0);
	
	surf.VertexNormal(4,0.0,0.0,1.0);
	surf.VertexNormal(5,0.0,0.0,1.0);
	surf.VertexNormal(6,0.0,0.0,1.0);
	surf.VertexNormal(7,0.0,0.0,1.0);
	
	surf.VertexNormal(8,0.0,-1.0,0.0);
	surf.VertexNormal(9,0.0,1.0,0.0);
	surf.VertexNormal(10,0.0,1.0,0.0);
	surf.VertexNormal(11,0.0,-1.0,0.0);
	
	surf.VertexNormal(12,0.0,-1.0,0.0);
	surf.VertexNormal(13,0.0,1.0,0.0);
	surf.VertexNormal(14,0.0,1.0,0.0);
	surf.VertexNormal(15,0.0,-1.0,0.0);
	
	surf.VertexNormal(16,-1.0,0.0,0.0);
	surf.VertexNormal(17,-1.0,0.0,0.0);
	surf.VertexNormal(18,1.0,0.0,0.0);
	surf.VertexNormal(19,1.0,0.0,0.0);
	
	surf.VertexNormal(20,-1.0,0.0,0.0);
	surf.VertexNormal(21,-1.0,0.0,0.0);
	surf.VertexNormal(22,1.0,0.0,0.0);
	surf.VertexNormal(23,1.0,0.0,0.0);
	
	surf.VertexTexCoords(0,0.0,1.0,0.0,0);
	surf.VertexTexCoords(1,0.0,0.0,0.0,0);
	surf.VertexTexCoords(2,1.0,0.0,0.0,0);
	surf.VertexTexCoords(3,1.0,1.0,0.0,0);
	
	surf.VertexTexCoords(4,1.0,1.0,0.0,0);
	surf.VertexTexCoords(5,1.0,0.0,0.0,0);
	surf.VertexTexCoords(6,0.0,0.0,0.0,0);
	surf.VertexTexCoords(7,0.0,1.0,0.0,0);
	
	surf.VertexTexCoords(8,0.0,1.0,0.0,0);
	surf.VertexTexCoords(9,0.0,0.0,0.0,0);
	surf.VertexTexCoords(10,1.0,0.0,0.0,0);
	surf.VertexTexCoords(11,1.0,1.0,0.0,0);
	
	surf.VertexTexCoords(12,0.0,0.0,0.0,0);
	surf.VertexTexCoords(13,0.0,1.0,0.0,0);
	surf.VertexTexCoords(14,1.0,1.0,0.0,0);
	surf.VertexTexCoords(15,1.0,0.0,0.0,0);
	
	surf.VertexTexCoords(16,0.0,1.0,0.0,0);
	surf.VertexTexCoords(17,0.0,0.0,0.0,0);
	surf.VertexTexCoords(18,1.0,0.0,0.0,0);
	surf.VertexTexCoords(19,1.0,1.0,0.0,0);
	
	surf.VertexTexCoords(20,1.0,1.0,0.0,0);
	surf.VertexTexCoords(21,1.0,0.0,0.0,0);
	surf.VertexTexCoords(22,0.0,0.0,0.0,0);
	surf.VertexTexCoords(23,0.0,1.0,0.0,0);
	
	surf.VertexTexCoords(0,0.0,1.0,0.0,1);
	surf.VertexTexCoords(1,0.0,0.0,0.0,1);
	surf.VertexTexCoords(2,1.0,0.0,0.0,1);
	surf.VertexTexCoords(3,1.0,1.0,0.0,1);
	
	surf.VertexTexCoords(4,1.0,1.0,0.0,1);
	surf.VertexTexCoords(5,1.0,0.0,0.0,1);
	surf.VertexTexCoords(6,0.0,0.0,0.0,1);
	surf.VertexTexCoords(7,0.0,1.0,0.0,1);
	
	surf.VertexTexCoords(8,0.0,1.0,0.0,1);
	surf.VertexTexCoords(9,0.0,0.0,0.0,1);
	surf.VertexTexCoords(10,1.0,0.0,0.0,1);
	surf.VertexTexCoords(11,1.0,1.0,0.0,1);
	
	surf.VertexTexCoords(12,0.0,0.0,0.0,1);
	surf.VertexTexCoords(13,0.0,1.0,0.0,1);
	surf.VertexTexCoords(14,1.0,1.0,0.0,1);
	surf.VertexTexCoords(15,1.0,0.0,0.0,1);
	
	surf.VertexTexCoords(16,0.0,1.0,0.0,1);
	surf.VertexTexCoords(17,0.0,0.0,0.0,1);
	surf.VertexTexCoords(18,1.0,0.0,0.0,1);
	surf.VertexTexCoords(19,1.0,1.0,0.0,1);
	
	surf.VertexTexCoords(20,1.0,1.0,0.0,1);
	surf.VertexTexCoords(21,1.0,0.0,0.0,1);
	surf.VertexTexCoords(22,0.0,0.0,0.0,1);
	surf.VertexTexCoords(23,0.0,1.0,0.0,1);
	
	surf.AddTriangle(0,1,2); // front
	surf.AddTriangle(0,2,3);
	surf.AddTriangle(6,5,4); // back
	surf.AddTriangle(7,6,4);
	surf.AddTriangle(6+8,5+8,1+8); // top
	surf.AddTriangle(2+8,6+8,1+8);
	surf.AddTriangle(0+8,4+8,7+8); // bottom
	surf.AddTriangle(0+8,7+8,3+8);
	surf.AddTriangle(6+16,2+16,3+16); // right
	surf.AddTriangle(7+16,6+16,3+16);
	surf.AddTriangle(0+16,1+16,5+16); // left
	surf.AddTriangle(0 + 16, 5 + 16, 4 + 16);
	
	surf.ComputeNormal();
	surf.updateBounding();
	surf.UpdateVBO();
	UpdateBoundingBox();
	}
	public  function createGrid(x_seg:Int,y_seg:Int, repeat_tex:Bool=false)
	{
		var surf:Surface = createSurface();
		
		var yhalf:Int = Std.int(y_seg * 0.5);
		var xhalf:Int = Std.int(x_seg * 0.5);
		var txstep = 1.0 / x_seg;
		var tystep = -1.0 / y_seg;
		
		var texx:Float = 0.0;
		var texy:Float = 1.0;
		var  v0, v1, v2, v3:Int = 0;
		v0 = 0;
		v1 = 0;
		v2 = 0;
		v3 = 0;
		
		var pv2:Array<Int> = new Array<Int>();
		var qv2:Array<Int> = new Array<Int>();
		if (!repeat_tex)
		{
			for ( y in  -yhalf ... yhalf  )
			{
				v0 = surf.AddVertex( -xhalf - 0.5, 0.0, y - 0.5);
				v1 = surf.AddVertex( -xhalf - 0.5, 0.0, y + 0.5);	

				for ( x in  -xhalf ... xhalf  )
				{
					
					if (x != -xhalf)  
					{
					v1 = v2; 
					v0 = v3;
					}
					if (y == -yhalf)
					{
						
						v3 = surf.AddVertex( x + 0.5, 0.0, y - 0.5);
	
					} else
					{
						v3 = pv2[xhalf + x];
										
					}
					
					v2 = surf.AddVertex( x + 0.5, 0.0, y + 0.5);
					qv2[xhalf + x] = v2;
					
				
					surf.VertexNormal(v0, 0.0, 1.0, 0.0);
					surf.VertexNormal(v1, 0.0, 1.0, 0.0);
					surf.VertexNormal(v2, 0.0, 1.0, 0.0);
					surf.VertexNormal(v3, 0.0, 1.0, 0.0);
					surf.VertexTexCoords(v0, texx, texy);
					surf.VertexTexCoords(v1, texx, texy + tystep);
					surf.VertexTexCoords(v2, texx + txstep, texy + tystep);
					surf.VertexTexCoords(v3, texx + txstep, texy);
					
					surf.VertexTexCoords(v0, texx, texy,0,1);
					surf.VertexTexCoords(v1, texx, texy + tystep,0,1);
					surf.VertexTexCoords(v2, texx + txstep, texy + tystep,0,1);
					surf.VertexTexCoords(v3, texx + txstep, texy,0,1);		
					
					surf.AddTriangle(v0, v1, v2);
					surf.AddTriangle(v0, v2, v3);
					
				trace( "tx " + texx + " " + texy + " " + (texx + txstep) + " " + (texy + tystep) + " :: " + txstep + " " + tystep			);
		
					texx += txstep;
					
					if (texx > 1.0)  texx = 0.0;
		
				}
				
				for (i in 0... x_seg)
				{
					pv2[i]  = qv2[i];
				}
				//qv2 = New Int[x_seg+1]
				
				texx = 0.0;
				texy += tystep;
				
				if (texy < 0.0)  texy = 1.0;


			}

			
		} else
		{
			for ( y in  -yhalf ... yhalf )
			{
			
				for ( x in  -xhalf ... xhalf  )
				{
								
					v0 = surf.AddVertex( x - 0.5, 0.0, y - 0.5);
					v1 = surf.AddVertex( x - 0.5, 0.0, y + 0.5);
					v2 = surf.AddVertex( x + 0.5, 0.0, y + 0.5);
					v3 = surf.AddVertex( x + 0.5, 0.0, y - 0.5);
					surf.VertexNormal(v0, 0.0, 1.0, 0.0);
					surf.VertexNormal(v1, 0.0, 1.0, 0.0);
					surf.VertexNormal(v2, 0.0, 1.0, 0.0);
					surf.VertexNormal(v3, 0.0, 1.0, 0.0);
					surf.VertexTexCoords(v0, 0.0, 0.0);
					surf.VertexTexCoords(v1, 0.0, 1.0);
					surf.VertexTexCoords(v2, 1.0, 1.0);
					surf.VertexTexCoords(v3, 1.0, 0.0);
					surf.VertexTexCoords(v0, 0.0, 0.0,0,1);
					surf.VertexTexCoords(v1, 0.0, 1.0,0,1);
					surf.VertexTexCoords(v2, 1.0, 1.0,0,1);
					surf.VertexTexCoords(v3, 1.0, 0.0,0,1);
					surf.AddTriangle(v0, v1, v2);
					surf.AddTriangle(v0, v2, v3);

				}
			}
		}

		     surf.updateBounding();
			surf.UpdateVBO();

		UpdateBoundingBox();
	}
	
	public function CreateSphere(segments:Int = 8)
	{

	if(segments<3 || segments>100) return ;

	var thissurf:Surface = createSurface();
		
	
	var div:Float=360.0/(segments*2);
	var height:Float=1.0;
	var upos:Float=1.0;
	var udiv:Float=1.0/(segments*2);
	var vdiv:Float=1.0/segments;
	var RotAngle:Float=90;

	if(segments<3){ // diamond shape - no center strips

		for ( i in 1 ... segments * 2)
		{
			var np:Int=thissurf.AddVertex(0.0,height,0.0,upos-(udiv/2.0),0);//northpole
			var sp:Int=thissurf.AddVertex(0.0,-height,0.0,upos-(udiv/2.0),1);//southpole
			var XPos:Float=-Util.cosdeg(RotAngle);
			var ZPos:Float=Util.sindeg(RotAngle);
			var v0:Int=thissurf.AddVertex(XPos,0,ZPos,upos,0.5);
			RotAngle=RotAngle+div;
			if(RotAngle>=360.0) RotAngle=RotAngle-360.0;
			XPos=-Util.cosdeg(RotAngle);
			ZPos=Util.sindeg(RotAngle);
			upos=upos-udiv;
			var v1:Int=thissurf.AddVertex(XPos,0,ZPos,upos,0.5);
			thissurf.AddTriangle(np,v0,v1);
			thissurf.AddTriangle(v1,v0,sp);
		}

	}

	if (segments > 2)
	{

		// poles first
		for ( i in 1 ... (segments) * 2+1)
		{
			//trace(i);

			var np:Int=thissurf.AddVertex(0.0,height,0.0,upos-(udiv/2.0),0);//northpole
			var sp:Int=thissurf.AddVertex(0.0,-height,0.0,upos-(udiv/2.0),1);//southpole

			var YPos:Float=Util.cosdeg(div);

			var XPos:Float=-Util.cosdeg(RotAngle)*(Util.sindeg(div));
			var ZPos:Float=Util.sindeg(RotAngle)*(Util.sindeg(div));

			var v0t:Int=thissurf.AddVertex(XPos,YPos,ZPos,upos,vdiv);
			var v0b:Int=thissurf.AddVertex(XPos,-YPos,ZPos,upos,1-vdiv);

			RotAngle=RotAngle+div;

			XPos=-Util.cosdeg(RotAngle)*(Util.sindeg(div));
			ZPos=Util.sindeg(RotAngle)*(Util.sindeg(div));

			upos=upos-udiv;

			var v1t:Int=thissurf.AddVertex(XPos,YPos,ZPos,upos,vdiv);
			var v1b:Int=thissurf.AddVertex(XPos,-YPos,ZPos,upos,1-vdiv);

			thissurf.AddTriangle(np,v0t,v1t);
			thissurf.AddTriangle(v1b,v0b,sp);

		}

		// then center strips

		upos=1.0;
		RotAngle=90;
		for ( i in 1 ... segments * 2 +1 )
		{

		//	trace(i);
			
			var mult:Float=1;
			var YPos:Float=Util.cosdeg(div*(mult));
			var YPos2:Float=Util.cosdeg(div*(mult+1.0));
			var Thisvdiv:Float=vdiv;

				for ( j in 1 ... segments-1 )
		{

		
				var XPos:Float=-Util.cosdeg(RotAngle)*(Util.sindeg(div*(mult)));
				var ZPos:Float=Util.sindeg(RotAngle)*(Util.sindeg(div*(mult)));

				var XPos2:Float=-Util.cosdeg(RotAngle)*(Util.sindeg(div*(mult+1.0)));
				var ZPos2:Float=Util.sindeg(RotAngle)*(Util.sindeg(div*(mult+1.0)));

				var v0t:Int=thissurf.AddVertex(XPos,YPos,ZPos,upos,Thisvdiv);
				var v0b:Int=thissurf.AddVertex(XPos2,YPos2,ZPos2,upos,Thisvdiv+vdiv);

				// 2nd tex coord set
				thissurf.VertexTexCoords(v0t,upos,Thisvdiv,0.0,1);
				thissurf.VertexTexCoords(v0b,upos,Thisvdiv+vdiv,0.0,1);

				var tempRotAngle:Float=RotAngle+div;

				XPos=-Util.cosdeg(tempRotAngle)*(Util.sindeg(div*(mult)));
				ZPos=Util.sindeg(tempRotAngle)*(Util.sindeg(div*(mult)));

				XPos2=-Util.cosdeg(tempRotAngle)*(Util.sindeg(div*(mult+1.0)));
				ZPos2=Util.sindeg(tempRotAngle)*(Util.sindeg(div*(mult+1.0)));

				var temp_upos=upos-udiv;

				var v1t:Int=thissurf.AddVertex(XPos,YPos,ZPos,temp_upos,Thisvdiv);
				var v1b:Int=thissurf.AddVertex(XPos2,YPos2,ZPos2,temp_upos,Thisvdiv+vdiv);

				// 2nd tex coord set
				thissurf.VertexTexCoords(v1t,temp_upos,Thisvdiv,0.0,1);
				thissurf.VertexTexCoords(v1b,temp_upos,Thisvdiv+vdiv,0.0,1);

				thissurf.AddTriangle(v1t,v0t,v0b);
				thissurf.AddTriangle(v1b,v1t,v0b);

				Thisvdiv=Thisvdiv+vdiv;
				mult=mult+1;

				YPos=Util.cosdeg(div*(mult));
				YPos2=Util.cosdeg(div*(mult+1.0));

			}

			upos=upos-udiv;
			RotAngle=RotAngle+div;

		}

	}

	    thissurf.ComputeNormal();
	    thissurf.updateBounding();
		thissurf.UpdateVBO();
		UpdateBoundingBox();

}
public function CreateCylinder(verticalsegments:Int = 8, solid:Bool=true)
{
	

	var ringsegments:Int=0; // default?

	var tr:Int = 0;
	var tl:Int = 0;
	var br:Int = 0;
	var bl:Int = 0;// 		side of cylinder
	var ts0:Int = 0;
	var ts1:Int = 0;
	var newts:Int = 0;// 	top side vertexs
	var bs0:Int = 0;
	var bs1 :Int= 0;
	var newbs:Int = 0;// 	bottom side vertexs
	
	if (verticalsegments<3 || verticalsegments>100) return ;
	if (ringsegments<0 || ringsegments>100) return ;

	var thissurf:Surface = createSurface();

	
	
	var div:Float =  (360.0 / verticalsegments);

	var height:Float=1.0;
	var ringSegmentHeight:Float=(height*2.0)/(ringsegments+1);
	var upos:Float=1.0;
	var udiv:Float=1.0/(verticalsegments);
	var vdiv:Float = 1.0 / (ringsegments + 1);
	
//	trace (div + "," + udiv + "," + vdiv);

	var SideRotAngle:Float=90.0;

	// re-diminsion arrays to hold needed memory.
	// this is used just for helping to build the ring segments...

	var tRing:Array<Int> = new Array<Int>();
	var bRing:Array<Int> = new Array<Int>();

	// render end caps if solid
	if (solid )
	{

     	var thissidesurf:Surface = createSurface();
 
		var XPos:Float=-Util.cosdeg(SideRotAngle);
		var ZPos:Float=Util.sindeg(SideRotAngle);

		 ts0=thissidesurf.AddVertex(XPos,height,ZPos,XPos/2.0+0.5,ZPos/2.0+0.5);
		 bs0=thissidesurf.AddVertex(XPos,-height,ZPos,XPos/2.0+0.5,ZPos/2.0+0.5);

		// 2nd tex coord set
		thissidesurf.VertexTexCoords(ts0,XPos/2.0+0.5,ZPos/2.0+0.5,0.0,1);
		thissidesurf.VertexTexCoords(bs0,XPos/2.0+0.5,ZPos/2.0+0.5,0.0,1);

		SideRotAngle=SideRotAngle+div;

		XPos=-Util.cosdeg(SideRotAngle);
		ZPos=Util.sindeg(SideRotAngle);

		ts1=thissidesurf.AddVertex(XPos,height,ZPos,XPos/2.0+0.5,ZPos/2.0+0.5);
		bs1=thissidesurf.AddVertex(XPos,-height,ZPos,XPos/2.0+0.5,ZPos/2.0+0.5);

		// 2nd tex coord set
		thissidesurf.VertexTexCoords(ts1,XPos/2.0+0.5,ZPos/2.0+0.5,0.0,1);
		thissidesurf.VertexTexCoords(bs1,XPos/2.0+0.5,ZPos/2.0+0.5,0.0,1);

		for ( i in 1...verticalsegments-1 )
		{
		
			SideRotAngle=SideRotAngle+div;

			XPos=-Util.cosdeg(SideRotAngle);
			ZPos=Util.sindeg(SideRotAngle);

			newts=thissidesurf.AddVertex(XPos,height,ZPos,XPos/2.0+0.5,ZPos/2.0+0.5);
			newbs=thissidesurf.AddVertex(XPos,-height,ZPos,XPos/2.0+0.5,ZPos/2.0+0.5);

			// 2nd tex coord set
			thissidesurf.VertexTexCoords(newts,XPos/2.0+0.5,ZPos/2.0+0.5,0.0,1);
			thissidesurf.VertexTexCoords(newbs,XPos/2.0+0.5,ZPos/2.0+0.5,0.0,1);

			thissidesurf.AddTriangle(ts0,ts1,newts);
			thissidesurf.AddTriangle(newbs,bs1,bs0);

			if (i < (verticalsegments-2 ))
			{
				ts1=newts;
				bs1 = newbs;
		
			}

		}
		      thissidesurf.ComputeNormal();
		      thissidesurf.updateBounding();
			  thissidesurf.UpdateVBO();
			
	}

	// -----------------------
	// middle part of cylinder
	var thisHeight:Float=height;

	// top ring first
	SideRotAngle=90.0;
	var XPos:Float=-Util.cosdeg(SideRotAngle);
	var ZPos:Float=Util.sindeg(SideRotAngle);
	var thisUPos:Float=upos;
	var thisVPos:Float=0.0;
	tRing[0]=thissurf.AddVertex(XPos,thisHeight,ZPos,thisUPos,thisVPos);
	thissurf.VertexTexCoords(tRing[0],thisUPos,thisVPos,0.0,1); // 2nd tex coord set
	for ( i in 0 ... verticalsegments)
	{
		SideRotAngle=SideRotAngle+div;
		XPos=-Util.cosdeg(SideRotAngle);
		ZPos=Util.sindeg(SideRotAngle);
		thisUPos=thisUPos-udiv;
		tRing[i+1]=thissurf.AddVertex(XPos,thisHeight,ZPos,thisUPos,thisVPos);
		thissurf.VertexTexCoords(tRing[i + 1], thisUPos, thisVPos, 0.0, 1); // 2nd tex coord set
    //   trace(i);
	}

	for ( ring in 0 ... Std.int(ringsegments + 1))
	{
		
  
		// decrement vertical segment
		thisHeight=thisHeight-ringSegmentHeight;

		// now bottom ring
		SideRotAngle=90;
		XPos=-Util.cosdeg(SideRotAngle);
		ZPos=Util.sindeg(SideRotAngle);
		thisUPos=upos;
		thisVPos=thisVPos+vdiv;
		bRing[0]=thissurf.AddVertex(XPos,thisHeight,ZPos,thisUPos,thisVPos);
		thissurf.VertexTexCoords(bRing[0],thisUPos,thisVPos,0.0,1); // 2nd tex coord set
		for ( i in 0 ... verticalsegments)
		{
			SideRotAngle=SideRotAngle+div;
			XPos=-Util.cosdeg(SideRotAngle);
			ZPos=Util.sindeg(SideRotAngle);
			thisUPos=thisUPos-udiv;
			bRing[i+1]=thissurf.AddVertex(XPos,thisHeight,ZPos,thisUPos,thisVPos);
			thissurf.VertexTexCoords(bRing[i + 1], thisUPos, thisVPos, 0.0, 1); // 2nd tex coord set
		//	trace(i);
		}

		// Fill in ring segment sides with triangles
		for (v in 1 ... verticalsegments+1)
		{
			tl=tRing[v];
			tr=tRing[v-1];
			bl=bRing[v];
			br=bRing[v-1];

				
			thissurf.AddTriangle(tl,tr,br);
			thissurf.AddTriangle(bl, tl, br);
		
		}

		// make bottom ring segment the top ring segment for the next loop.
		for ( v in 0 ... verticalsegments+1)
		{
			tRing[v] = bRing[v];
		}
	}

	 tRing = [];
	 bRing = [];
	 thissurf.ComputeNormal();
	 thissurf.updateBounding();
	 
    thissurf.UpdateVBO();
    UpdateBoundingBox();
}

public function CreateCone( segments:Int=8, solid:Bool=true)
{


	var top=0,br=0,bl=0; // side of cone
	var bs0=0,bs1=0,newbs=0; // bottom side vertices

	if(segments<3 || segments>100) return ;
	
	var thissurf:Surface = createSurface();
	var thissidesurf:Surface = null;

		
	if (solid )
	{
		thissidesurf = createSurface();
	}
	var div:Float=(360.0/segments);

	var height:Float=1.0;
	var upos:Float=1.0;
	var udiv:Float=(1.0/(segments));
	var RotAngle:Float=90.0;

	// first side
	var XPos:Float=-Util.cosdeg(RotAngle);
	var ZPos:Float=Util.sindeg(RotAngle);

	top=thissurf.AddVertex(0.0,height,0.0,upos-(udiv/2.0),0);
	br=thissurf.AddVertex(XPos,-height,ZPos,upos,1);

	// 2nd tex coord set
	thissurf.VertexTexCoords(top,upos-(udiv/2.0),0,0.0,1);
	thissurf.VertexTexCoords(br,upos,1,0.0,1);

	if(solid) bs0=thissidesurf.AddVertex(XPos,-height,ZPos,XPos/2.0+0.5,ZPos/2.0+0.5);
	if(solid) thissidesurf.VertexTexCoords(bs0,XPos/2.0+0.5,ZPos/2.0+0.5,0.0,1); // 2nd tex coord set

	RotAngle=RotAngle+div;

	XPos=-Util.cosdeg(RotAngle);
	ZPos=Util.sindeg(RotAngle);

	bl=thissurf.AddVertex(XPos,-height,ZPos,upos-udiv,1);
	thissurf.VertexTexCoords(bl,upos-udiv,1,0.0,1); // 2nd tex coord set

	if(solid) bs1=thissidesurf.AddVertex(XPos,-height,ZPos,XPos/2.0+0.5,ZPos/2.0+0.5);
	if(solid) thissidesurf.VertexTexCoords(bs1,XPos/2.0+0.5,ZPos/2.0+0.5,0.0,1); // 2nd tex coord set

	thissurf.AddTriangle(bl,top,br);

	// rest of sides
	for (i in 1 ... segments)
	{
		//trace(i);
		br=bl;
		upos=upos-udiv;
		top=thissurf.AddVertex(0.0,height,0.0,upos-(udiv/2.0),0);
		thissurf.VertexTexCoords(top,upos-(udiv/2.0),0,0.0,1); // 2nd tex coord set

		RotAngle=RotAngle+div;

		XPos=-Util.cosdeg(RotAngle);
		ZPos=Util.sindeg(RotAngle);

		bl=thissurf.AddVertex(XPos,-height,ZPos,upos-udiv,1);
		thissurf.VertexTexCoords(bl,upos-udiv,1,0.0,1); // 2nd tex coord set

		if(solid) newbs=thissidesurf.AddVertex(XPos,-height,ZPos,XPos/2.0+0.5,ZPos/2.0+0.5);
		if(solid) thissidesurf.VertexTexCoords(newbs,XPos/2.0+0.5,ZPos/2.0+0.5,0.0,1); // 2nd tex coord set

		thissurf.AddTriangle(bl,top,br);

		if (solid)
		{
			thissidesurf.AddTriangle(newbs,bs1,bs0);

			if(i<(segments-1)){
				bs1=newbs;
			}

		}
	}
	
	if (solid)
		{
		//	thissidesurf.ComputeNormal();
			thissidesurf.updateBounding();
			thissidesurf.UpdateVBO();
		}
	//thissurf.ComputeNormal();	
    thissurf.updateBounding();
	thissurf.UpdateVBO();
    UpdateBoundingBox();
}

		
 
	public  function createPlane(y:Float,w:Float=1000,d:Float=1000)
	{
		var surf:Surface = createSurface();
	
	surf.AddVertex(-w,y,-d);
	surf.AddVertex(-w,y, d);
	surf.AddVertex( w,y, d);
	surf.AddVertex( w,y,-d);


	surf.VertexNormal(0,0.0,0.0,-1.0);
	surf.VertexNormal(1,0.0,0.0,-1.0);
	surf.VertexNormal(2,0.0,0.0,-1.0);
	surf.VertexNormal(3,0.0,0.0,-1.0);
	
	surf.VertexTexCoords(0,0.0,1.0,0.0,0);
	surf.VertexTexCoords(1,0.0,0.0,0.0,0);
	surf.VertexTexCoords(2,1.0,0.0,0.0,0);
	surf.VertexTexCoords(3,1.0,1.0,0.0,0);

		
	surf.VertexTexCoords(0,0.0,1.0,0.0,1);
	surf.VertexTexCoords(1,0.0,0.0,0.0,1);
	surf.VertexTexCoords(2,1.0,0.0,0.0,1);
	surf.VertexTexCoords(3,1.0, 1.0, 0.0, 1);
	
	surf.AddTriangle(0,1,2); // front
	surf.AddTriangle(0, 2, 3);
	surf.updateBounding();
	surf.UpdateVBO();
	UpdateBoundingBox();
	}
	public  function createQuad(w:Float=1,h:Float=1)
	{
		var surf:Surface = createSurface();
	
    surf.AddVertex(-w,-h,0.0);
	surf.AddVertex(-w, h,0.0);
	surf.AddVertex( w, h,0.0);
	surf.AddVertex( w,-h,0.0);

	surf.VertexNormal(0,0.0,0.0,-1.0);
	surf.VertexNormal(1,0.0,0.0,-1.0);
	surf.VertexNormal(2,0.0,0.0,-1.0);
	surf.VertexNormal(3,0.0,0.0,-1.0);
	
	surf.VertexTexCoords(0,0.0,1.0,0.0,0);
	surf.VertexTexCoords(1,0.0,0.0,0.0,0);
	surf.VertexTexCoords(2,1.0,0.0,0.0,0);
	surf.VertexTexCoords(3,1.0,1.0,0.0,0);

	surf.AddTriangle(0,1,2); // front
	surf.AddTriangle(0, 2, 3);
	surf.updateBounding();
	surf.UpdateVBO();
	UpdateBoundingBox();
		
	}
	
	public  function CreateCylinderEx( height:Float, diameterTop:Float, diameterBottom:Float, tessellation:Int=1)
	{
		var radiusTop:Float = diameterTop / 2;
        var radiusBottom:Float = diameterBottom / 2;
        
		var indices:Array<Int> = [];
        var positions:Array<Float> = [];
        var normals:Array<Float> = [];
        var uvs:Array<Float> = [];
		
     
        function getCircleVector(i:Int):Vector3
		{
            var angle = (i * 2 * Math.PI / tessellation);
            var dx = Math.sin(angle);
            var dz = Math.cos(angle);

            return new Vector3(dx, 0, dz);
        }

        function createCylinderCap(isTop:Bool)
		{
            var radius:Float = isTop ? radiusTop : radiusBottom;
            
            if (radius == 0) {
                return;
            }

            // Create cap indices.
            for (i in 0...tessellation - 2)
			{
                var i1 = (i + 1) % tessellation;
                var i2 = (i + 2) % tessellation;

                if (!isTop) {
                    var tmp = i1;
                    var i1 = i2;
                    i2 = tmp;
                }

                var vbase = Std.int(positions.length / 3);
                indices.push(vbase);
                indices.push(vbase + i1);
                indices.push(vbase + i2);
            }


            // Which end of the cylinder is this?
            var normal = new Vector3(0, -1, 0);
            var textureScale = new Vector2(-0.5, -0.5);

            if (!isTop) {
                normal = normal.scale(-1);
                textureScale.x = -textureScale.x;
            }

            // Create cap vertices.
            for (i in 0...tessellation) 
			{
                var circleVector = getCircleVector(i);
                var position = circleVector.scale(radius).add(normal.scale(height));
                var textureCoordinate = new Vector2(circleVector.x * textureScale.x + 0.5, circleVector.z * textureScale.y + 0.5);

	
				
                positions.push(position.x);
				positions.push(position.y);
				positions.push(position.z);
                normals.push(normal.x);
				normals.push(normal.y);
				normals.push(normal.z);
                uvs.push(textureCoordinate.x);
				uvs.push(textureCoordinate.y);
            }
        }

        height /= 2;

        var topOffset:Vector3 = new Vector3(0, 1, 0).scale(height);

        var stride = tessellation + 1;

        // Create a ring of triangles around the outside of the cylinder.
        for (i in 0...tessellation+1) {
            var normal = getCircleVector(i);
            var sideOffsetBottom = normal.scale(radiusBottom);
            var sideOffsetTop = normal.scale(radiusTop);
            var textureCoordinate = new Vector2(i / tessellation, 0);

            var position = sideOffsetBottom.add(topOffset);
            positions.push(position.x);
			positions.push(position.y);
			positions.push(position.z);
            normals.push(normal.x);
			normals.push(normal.y);
			normals.push(normal.z);
            uvs.push(-textureCoordinate.x);
			uvs.push(textureCoordinate.y);

            position = sideOffsetTop.subtract(topOffset);
            textureCoordinate.y += 1;
            positions.push(position.x);
			positions.push(position.y);
			positions.push(position.z);
            normals.push(normal.x);
			normals.push(normal.y);
			normals.push(normal.z);
            uvs.push(-textureCoordinate.x);
			uvs.push(textureCoordinate.y);

            indices.push(i * 2);
            indices.push((i * 2 + 2) % (stride * 2));
            indices.push(i * 2 + 1);

            indices.push(i * 2 + 1);
            indices.push((i * 2 + 2) % (stride * 2));
            indices.push((i * 2 + 3) % (stride * 2));
        }

        // Create flat triangle fan caps to seal the top and bottom.
        createCylinderCap(true);
        createCylinderCap(false);
		
		var surf:Surface = createSurface();
		surf.setVerticesData(positions);
		surf.setIndices(indices);
		surf.setNormals(normals);
		surf.setTexCoords(uvs, 2);
		surf.ComputeNormal();
		surf.updateBounding();
		surf.UpdateVBO();
		UpdateBoundingBox();
	}
	public  function CreateTorus( diameter:Float=5, thickness:Float=1.0, tessellation:Int=10)
	{
	
        var indices:Array<Int> = [];
        var positions:Array<Float> = [];
        var normals:Array<Float> = [];
        var uvs:Array<Float> = [];

        var stride = tessellation + 1;

        for (i in 0...tessellation+1) {
            var u:Float = i / tessellation;

            var outerAngle:Float = i * Math.PI * 2.0 / tessellation - Math.PI / 2.0;

            var transform = Matrix4.Translation(diameter / 2.0, 0, 0).multiply(Matrix4.RotationY(outerAngle));

            for (j in 0...tessellation+1) {
                var v = 1 - j / tessellation;

                var innerAngle = j * Math.PI * 2.0 / tessellation + Math.PI;
                var dx = Math.cos(innerAngle);
                var dy = Math.sin(innerAngle);

                // Create a vertex.
                var normal = new Vector3(dx, dy, 0);
                var position:Vector3 = normal.scale(thickness / 2);
                var textureCoordinate = new Vector2(u, v);

                position = Vector3.TransformCoordinates(position, transform);
                normal = Vector3.TransformNormal(normal, transform);

                positions.push(position.x);
				positions.push(position.y);
				positions.push(position.z);
                normals.push(normal.x);
				normals.push(normal.y);
				normals.push(normal.z);
                uvs.push(-textureCoordinate.x);
				uvs.push(textureCoordinate.y);

                // And create indices for two triangles.
                var nextI = (i + 1) % stride;
                var nextJ = (j + 1) % stride;

                indices.push(i * stride + j);
                indices.push(i * stride + nextJ);
                indices.push(nextI * stride + j);

                indices.push(i * stride + nextJ);
                indices.push(nextI * stride + nextJ);
                indices.push(nextI * stride + j);
            }
        }

      
		var surf:Surface = createSurface();
		surf.setVerticesData(positions);
		surf.setIndices(indices);
		surf.setNormals(normals);
		surf.setTexCoords(uvs, 2);
		surf.ComputeNormal();
		surf.updateBounding();
		surf.UpdateVBO();
		UpdateBoundingBox();
	}
	public  function CreateGround( width:Float=6, height:Float=6, subdivisions:Int=2)
	{
	var surf:Surface = createSurface();
	//surf.primitiveType = GL.LINES;
       



        for (row in 0 ... subdivisions  ) 
	   
		{
            for (col in 0 ... subdivisions  )
	
			{
				
                var position = new Vector3((col * width) / subdivisions - (width / 2.0), 0.0, ((subdivisions - row) * height) / subdivisions - (height / 2.0));
                var normal = new Vector3(0.0, 1.0, 0.0);

				surf.AddFullVertex(
				position.x, position.y, position.z,
				normal.x, normal.y, normal.z,
				col / subdivisions,row / subdivisions);

            }
			
     }
   
	   

	
		


        for (row in 0 ... subdivisions ) 
	   
		{
            for (col in 0 ... subdivisions  )
	
			{
				
				
				surf.AddTriangle(
				col + 1 + (row + 1) * (subdivisions + 1),
				col + 1 + row * (subdivisions + 1),
				col + row * (subdivisions + 1));
				
				surf.AddTriangle(
		    	col + (row + 1) * (subdivisions + 1),
                col + 1 + (row + 1) * (subdivisions + 1),
                col + row * (subdivisions + 1));
			
         
				
            }
			
			
		
     }
     

        surf.ComputeNormal();
	    surf.updateBounding();
		surf.UpdateVBO();
		UpdateBoundingBox();
	}

	
		public  function CreateGroundPlane( width:Float, height:Float, subdivisions:Int)
	{
	
		
		   
  
           	
		var surf:Surface = createSurface();
	

					
            // Vertices
            for (row in 0... Math.round(subdivisions) ) 
			{
                for (col in 0... Math.round(subdivisions) ) 
				{
                    var position = new Vector3((col * width) / subdivisions - (width / 2.0), 0, ((subdivisions - row) * height) / subdivisions - (height / 2.0));

                   		surf.AddFullVertex(position.x, position.y, position.z, 0, 1, 0, col / subdivisions, row / subdivisions);
			
                }
            }
var v:Int = 0;
            // Indices
          for (row in 0... Math.round(subdivisions)-1 ) 
			{
                for (col in 0... Math.round(subdivisions)-1 ) 
				{
					
					  v  = Std.int(row *  subdivisions + col);
					  
		  
		  surf.AddTriangle(
		  Std.int(v + subdivisions),
		  v,
		  v + 1);
		 
		  surf.AddTriangle(
		   Std.int(v + subdivisions + 1),
		  Std.int(v + subdivisions),
		  v + 1);
		  
            				
			
                }
            }

			   
		surf.ComputeNormal();
		surf.updateBounding();
		surf.UpdateVBO();
UpdateBoundingBox();
       
	}
	
	public  function CreateTerrainHeightMap( url:String, Precision:Float,YFactor:Float,
		 PositionX:Float ,PositionZ:Float,
		 SrcPosX:Float , SrcPosY:Float ,
		 SingWidth:Float , SingHeight:Float,
		 ScaleXDetail:Float=2,ScaleYDetail:Float=2)
	{
	var w:Int = 0;
	var h:Int = 0;
	var MinY:Float = 0;
	var v:Int=0;
	var xl:Int = 0;
	var yl:Int = 0;
	
	
		
		    var img:Image = null; 
        
			if (Assets.exists(url)) 
			{
			 img = Assets.getImage(url);
		
		} else 
		{
			trace("Error: Image '" + url + "' doesn't exist !");
			return;
		}
	     
            // Getting height map data
            w =  img.width;
            h =  img.height;
			
				var Width:Float  =Math.round( w / Precision+1);
                var Height:Float = Math.round( h / Precision + 1);
				
			//	trace(Width + " x " + Height);

         
				var surf:Surface = createSurface();
	
					
            // Vertices
            for (y in 0... Math.round(Height)) 
			{
                for (x in 0... Math.round(Width)) 
				{
                 
                    v  = Std.int(y *  Width + x);
					
					
					
					
				    xl = Math.round(x / (Width-1) * w * SingWidth + SrcPosX * w)  ;
		            yl = Math.round(y / (Height - 1) * h * SingHeight + SrcPosY * h);
					
					var color:Int = img.getPixel(xl,yl);
					var r = Util.getRed(color)  / 255;
		            var g = Util.getGreen(color) / 255;
		            var b = Util.getBlue(color) / 255;
		           var gradient = r * 0.3 + g * 0.59 + b * 0.11;
			
					 

				  var pos:Vector3 = new Vector3((x * Precision)+PositionX,gradient*YFactor, (y * Precision)+PositionZ);
				   
				   surf.AddFullVertex(pos.x,pos.y,pos.z,
				   0.0, 1.0, 0.0,
				   (x / (Width - 1)),
				   (y / (Height - 1)),
				   (x / (Width - 1)  * ScaleXDetail * 0.995 + 0.0025 ),
				   (y / (Height - 1) * ScaleYDetail* 0.995 + 0.0025 ));
				  
				   
				   

                }
            }

			
            // Indices

          for (y in 0... Math.round(Height)-1) 
			{
                for (x in 0... Math.round(Width)-1) 
				{
                 
                   
          v  = Std.int(y *  Width + x);
					  
		  
		  surf.AddTriangle(
		  v + 1,
		  v,
		  Std.int(v + Width));
		 
		  surf.AddTriangle(
		  v + 1,
		  Std.int(v + Width),
		  Std.int(v + Width+1));
		  
		  
			
                }
            }

		surf.ComputeNormal();
		surf.brush.materialType = 2;
		surf.updateBounding();
		surf.UpdateVBO();
		UpdateBoundingBox();
	
       
	}
	
	/*
	 * 
	public  function CreateTerrainHeightMap( url:String, Precision:Float,YFactor:Float,
		 PositionX:Float ,PositionZ:Float,
		 SrcPosX:Float , SrcPosY:Float ,
		 SingWidth:Float , SingHeight:Float)
	{
	var w:Int = 0;
	var h:Int = 0;
	var MinY:Float = 0;
	var v:Int;
	var xl:Int = 0;
	var yl:Int = 0;
	
	
		
		    var img:BitmapData = null; 
        
			if (Assets.exists(url)) 
			{
			 img = Assets.getBitmapData(url);
		
		} else 
		{
			trace("Error: Image '" + url + "' doesn't exist !");
			return;
		}
		
            var indices:Array<Int> = [];
            var positions:Array<Float> = [];
            var normals:Array<Float> = [];
            var uvs:Array<Float> = [];
            
            // Getting height map data
            w =  img.width;
            h =  img.height;
			
				var Width:Float = w / Precision+1;
               var Height:Float = h / Precision+1;

            
            #if html5
			var buffer = img.getPixels(img.rect).byteView;
			#else
			var buffer = BitmapData.getRGBAPixels(img);
			#end
			
				var surf:Surface = createSurface();
	
					
            // Vertices
            for (y in 0...Std.int(Height)+1) 
			{
                for (x in 0...Std.int(Width)) 
				{
                 
                    v  = Std.int(y *  Width + x);
				    xl = Std.int(x / (Width-1) * w * SingWidth + SrcPosX * w)  ;
		            yl = Std.int(y / (Height - 1) * h * SingHeight + SrcPosY * h);
					
					  var color:Int = img.getPixel32(xl,yl);
				      var hi:Float=Util.getColorValue(Util.getRed(color));

				var pos:Vector3 = new Vector3((x * Precision)+PositionX,hi*YFactor, (y * Precision)+PositionZ);
				   
				   surf.AddFullVertex(pos.x,pos.y,pos.z,
				   0.0, 1.0, 0.0,
				   x / (Width - 1),
				   y / (Height - 1));
				  
				   
				   

                }
            }

            // Indices

            for (y in 0...Std.int(Height)-1) 
			{
                for (x in 0...Std.int(Width)) 
				{
          v  = Std.int(y *  Width + x);
					  
		  
		  surf.AddTriangle(
		  v + 1,
		  v,
		  Std.int(v + Width));
		 
		  surf.AddTriangle(
		  v + 1,
		  Std.int(v + Width),
		  Std.int(v + Width+1));
		  
		  
			
                }
            }

		
            // Normals
       // Util.ComputeNormal(positions, normals, indices);
		   
		//surf.primitiveType = GL.LINES;
	//	surf.setVerticesData(positions);
		//surf.setIndices(indices);
		//surf.setNormals(normals);
		//surf.setTexCoords(uvs, 2);
		
		surf.UpdateVBO();
			
		//	trace(positions.length);
		//	trace(indices.length);
       
	}
	 */
	
	public  function loadAC3D(filename:String,path:String,build:Bool=true,loadtexture:Bool=true):Void
	{
		var parcer:AC3DParser = new AC3DParser(filename, path, this);
	}
	
	
		public  function load3DS(filename:String,path:String,build:Bool=true,loadtexture:Bool=true):Void
	{
		var parser:Max3DSParser = new Max3DSParser(filename);

		for (i in 0... parser.objList.length)
		{
			
			
			
			var surface =	createSurface();
	
			var material:MaterialVO =	parser._materials.get(parser.objList[i].materials[0]);
			
			
			
			var texturename:String = material.colorMap;
		     var r:Float = Util.getRed(	material.diffuseColor) / 255.0;
			 var g:Float = Util.getGreen(material.diffuseColor) / 255.0;
			 var b:Float = Util.getBlue(material.diffuseColor) / 255.0;
			
			surface.brush.DiffuseColor.set(r,g,b);
			
		
			if (loadtexture)
			{
			if (Assets.exists(path + "/" + texturename))
			{
			     surface.brush.setTexture(Gdx.Instance().getTexture(path + "/" + texturename));
			} else
			{
				if (parser.objList[i].uvs != null)
				{
				trace("INFO: Replase :" + path + "/" + texturename+", with dummy");
				surface.brush.setTexture(Gdx.Instance().getTexture("dummy"));
				}
			}
			}
		
			
			for ( x in 0 ... Std.int(parser.objList[i].indices.length / 3))
			{
		
				var v0:Int = parser.objList[i].indices[x * 3 + 0];
				var v1:Int = parser.objList[i].indices[x * 3 + 1];
				var v2:Int = parser.objList[i].indices[x * 3 + 2];
				
				surface.AddTriangle(v0, v1, v2);
				
				
				
			}
			//surface.setVerticesData(parser.objList[i].verts);
			//surface.setTexCoords(parser.objList[i].uvs);
		
			for ( x in 0 ... Std.int(parser.objList[i].verts.length/3))
			{
		
				var px:Float = parser.objList[i].verts[x * 3 + 0];
				var py:Float = parser.objList[i].verts[x * 3 + 1];
				var pz:Float = parser.objList[i].verts[x * 3 + 2];
				var u:Float = 0.0;
				var v:Float = 0.0;
				if (parser.objList[i].uvs != null)
				{
				 u = parser.objList[i].uvs[x * 2 + 0];
				 v = parser.objList[i].uvs[x * 2 + 1];
				} 
				surface.AddVertex(px, py, pz, u, v);
				
				
				
				
				
			}
			
			
			surface.ComputeNormal();
			surface.updateBounding();
		if(build)	surface.UpdateVBO();
			
		}
		this.sortMaterial();
		
	}
	
		public function Optimize():Void
		{
			sortMaterial();
			for (i in 0...CountSurfaces())
			{
				surfaces[i].Optimize();
			}
		}
		

	public  function loadH3D(filename:String,path:String,build:Bool=true,loadtexture:Bool=true,scale:Float=1):Void
	{
		 if (!Assets.exists(filename))
			{
				trace("ERROR:Model " + filename+"dont exists..");
				return;
			}
			
		var file:ByteArray =	Assets.getBytes(filename);
	    	file.endian = "littleEndian";
        if (file.bytesAvailable <= 0) return;
	    file.position = 0;
		
		var  hSize:Int = file.readInt();
		var header:String = file.readUTFBytes(hSize);
		var id:Int = file.readInt();
		
		var numMaterials:Int = file.readInt();
		
		var brushes:Map<Int,Brush> = new Map<Int,Brush>();
		
		trace("Num materials :" + numMaterials);
		
		for (i in 0 ... numMaterials)
		{
			
			var  flags:Int = file.readInt();//
		    //trace('flags : ' + flags);
			var brush:Brush = new Brush(0);
			
			var r = file.readFloat();
			var g = file.readFloat();
			var b = file.readFloat();
			var alpha = file.readFloat();
			brush.DiffuseColor.set(r, g, b);
			brush.alpha = alpha;
			brush.materialId = i;
		//	trace('Color :' + brush.DiffuseColor.toString()+' alpha:'+alpha);
			
			var  nameSize:Int = file.readInt();
			if (nameSize >= 255) 
			{
				trace("ERROR:file dont match -"+nameSize+" color texture");
				return null;
			}
			var filename:String = file.readUTFBytes(nameSize);
			
			var  texture:String = Path.withoutDirectory(filename);
			if (Path.extension(texture) == 'bmp')
			{
				texture = Path.withoutExtension(texture);
				texture+= '.jpg';
			}else
			if (Path.extension(texture) == 'tga')
			{
				texture = Path.withoutExtension(texture);
				texture+= '.png';
			}
			
			if (Assets.exists(path  + texture))
			{
				
			if(loadtexture)  brush.setTexture( Gdx.Instance().getTexture(path  + texture, true));
			} else
			{
				trace("ERROR : dont find "+path  + texture+" color texture");
				
			}
			
			//****************
			
			//detail texture
			var  useDetail:Int = file.readInt();
			if (useDetail >= 1)
			{
			  var  nameSize:Int = file.readInt();
		  	var filename:String=file.readUTFBytes(nameSize);
			var  texture:String = Path.withoutDirectory(filename);
		    if (Path.extension(texture) == 'bmp')
			{
				texture = Path.withoutExtension(texture);
				texture+= '.jpg';
			}else
			if (Path.extension(texture) == 'tga')
			{
				texture = Path.withoutExtension(texture);
				texture+= '.png';
			}
			
				  
		     if (Assets.exists(path  + texture))
			{
			if(loadtexture)  brush.setDetail( Gdx.Instance().getTexture(path  + texture, true));
			} else
			{
				trace("ERROR : dont find"+path  + texture+" detail texture");
				
			}
			}
			
		
			brushes.set(i, brush);
	    }
		        var pos:Vector3 = new Vector3(0,0,0);
				var nor:Vector3 = new Vector3(0,0,0);
				var uv:Vector2 = new Vector2(0,0);
				var uv2:Vector2 = new Vector2(0,0);
				
				
				
		var  countMeshs:Int = file.readInt();
		trace("INFO:numsub surfaces:"+countMeshs);

	    for (i in 0 ... countMeshs)
		{

			var  flags:Int = file.readInt();//
			var surf:Surface = createSurface();
			surf.materialIndex = file.readInt();
			var numVertices:Int=file.readInt();
			var numFaces:Int=file.readInt();
			var numUVCoords:Int = file.readInt();
	
		
			
			surf.brush.clone(brushes.get(surf.materialIndex));
			if (numUVCoords == 1)
			{
			surf.brush.setMaterialType(0);
			} else
			{
				surf.brush.setMaterialType(1);
			}
			 
			//
			
		//	trace("Mesh ["+i+"] , num Vertices["+numVertices+"],  num Faces["+numFaces+"],  num UVCoords["+numUVCoords+"], Material:["+surf.materialIndex+']' );
			
			
			for (x in 0...numVertices)
			{
			
				
				pos.x = file.readFloat()*scale;
				pos.y = file.readFloat()*scale;
				pos.z = file.readFloat()*scale;
				
				nor.x = file.readFloat();
				nor.y = file.readFloat();
				nor.y = file.readFloat();
			//	trace(nor.toString());
				uv.x = file.readFloat();
				uv.y = file.readFloat();
				
		

			
			if (numUVCoords == 2)
			{
				   
					uv2.x = file.readFloat();
				    uv2.y = file.readFloat();
					surf.AddFullVertex(pos.x, pos.y, pos.z, nor.x, nor.y, nor.z, uv.x, uv.y, uv2.x, uv2.y);
					//trace(uv.toString());
					//trace(uv2.toString());
			} else
			{
				//trace(uv.toString());
				surf.AddFullVertex(pos.x, pos.y, pos.z, nor.x, nor.y, nor.z, uv.x, uv.y, uv.x, uv.y);
			}
			
		//	trace(pos.toString());
			
		}
		
			
			for (x in 0...numFaces)
			{
				var v0:Int = file.readInt();
				var v1:Int = file.readInt();
				var v2:Int = file.readInt();
	    		surf.AddTriangle(v0, v1, v2);
			}
		//if(loadtexture) surf.brush.setTexture(textures.get(surf.materialIndex));	
		 surf.updateBounding();	
         if(build)surf.UpdateVBO();
		//trace("Mesh ["+i+"] , num Vertices["+numVertices+"],  num Faces["+numFaces+"],  num UVCoords["+numUVCoords+"] , numColor["+numColors+"]" );
		}
		
		
		UpdateBoundingBox();
		
		sortMaterial();
	}

	public  function loadH3DOptimize(filename:String,path:String,build:Bool=true,loadtexture:Bool=true,scale:Float=1):Void
	{
		 if (!Assets.exists(filename))
			{
				trace("ERROR:Model " + filename+"dont exists..");
				return;
			}

		
		var file:ByteArray =	Assets.getBytes(filename);
	    	file.endian = "littleEndian";
        if (file.bytesAvailable <= 0) return;
	    file.position = 0;
		
		var  hSize:Int = file.readInt();
		var header:String = file.readUTFBytes(hSize);
		var id:Int = file.readInt();
		
		var numMaterials:Int = file.readInt();
		
		var brushes:Map<Int,Brush> = new Map<Int,Brush>();
		
	//	trace("Num materials :" + numMaterials);
		
		for (i in 0 ... numMaterials)
		{
			
			var  flags:Int = file.readInt();//
	//	trace('flags : ' + flags);
			var brush:Brush = new Brush(0);
			
			var r = file.readFloat();
			var g = file.readFloat();
			var b = file.readFloat();
			var alpha = file.readFloat();
			brush.DiffuseColor.set(r, g, b);
			brush.alpha = alpha;
			brush.materialId = i;
			//trace('Color :' + brush.DiffuseColor.toString()+' alpha:'+alpha);
			
			var  nameSize:Int = file.readInt();
			if (nameSize >= 255) 
			{
				trace("ERROR:file dont match -"+nameSize+" color texture");
				return null;
			}
			var  texture:String = Path.withoutDirectory(file.readUTFBytes(nameSize));
	
			if (Path.extension(texture) == 'bmp')
			{
				texture = Path.withoutExtension(texture);
				texture+= '.jpg';
			}else
			if (Path.extension(texture) == 'tga')
			{
				texture = Path.withoutExtension(texture);
				texture+= '.png';
			}
			
			
			
			
			if (Assets.exists(path  + texture))
			{
			if(loadtexture)  brush.setTexture( Gdx.Instance().getTexture(path  + texture, true));
			} else
			{
				trace("ERROR : dont find "+path  + texture+" color texture");
				
			}
			
			//****************
			
			//detail texture
			var  useDetail:Int = file.readInt();
			if (useDetail >= 1)
			{
			  var  nameSize:Int = file.readInt();
		      var  texture:String = Path.withoutDirectory(file.readUTFBytes(nameSize));
			  if (Path.extension(texture) == 'bmp')
			{
				texture = Path.withoutExtension(texture);
				texture+= '.jpg';
			}else
			if (Path.extension(texture) == 'tga')
			{
				texture = Path.withoutExtension(texture);
				texture+= '.png';
			}
			
				  
		     if (Assets.exists(path  + texture))
			{
			if(loadtexture)  brush.setDetail( Gdx.Instance().getTexture(path  + texture, true));
			} else
			{
				trace("ERROR : dont find"+path  + texture+" detail texture");
				
			}
			}
			
		
			brushes.set(i, brush);
	    }
		        var pos:Vector3 = new Vector3(0,0,0);
				var nor:Vector3 = new Vector3(0,0,0);
				var uv:Vector2 = new Vector2(0,0);
				var uv2:Vector2 = new Vector2(0,0);
				
				
				
		var  countMeshs:Int = file.readInt();
		trace("INFO:numsub surfaces:" + countMeshs);
		
		var surfs:Array<Surface> = [];

	    for (i in 0 ... countMeshs)
		{

			var  flags:Int = file.readInt();//
			var surf:Surface = new Surface(scene.shader);
			surf.materialIndex = file.readInt();
			var numVertices:Int=file.readInt();
			var numFaces:Int=file.readInt();
			var numUVCoords:Int = file.readInt();
			
		
			
			surf.brush.clone(brushes.get(surf.materialIndex));
		
			if (numUVCoords == 1)
			{
			surf.brush.setMaterialType(0);
			} else
			{
			surf.brush.setMaterialType(1);
			}
			 
			//
			
		//	trace("Mesh ["+i+"] , num Vertices["+numVertices+"],  num Faces["+numFaces+"],  num UVCoords["+numUVCoords+"], Material:["+surf.materialIndex+']' );
			
			
			for (x in 0...numVertices)
			{
			
				
				pos.x = file.readFloat()*scale;
				pos.y = file.readFloat()*scale;
				pos.z = file.readFloat()*scale;
				
				nor.x = file.readFloat();
				nor.y = file.readFloat();
				nor.y = file.readFloat();
				uv.x = file.readFloat();
				uv.y = file.readFloat();
	

			
			if (numUVCoords == 2)
			{
				   
					uv2.x = file.readFloat();
				    uv2.y = file.readFloat();
					surf.AddFullVertex(pos.x, pos.y, pos.z, nor.x, nor.y, nor.z, uv.x, uv.y, uv2.x, uv2.y);
			} else
			{
				surf.AddFullVertex(pos.x, pos.y, pos.z, nor.x, nor.y, nor.z, uv.x, uv.y, uv.x, uv.y);
			}
			
			
		}
		
			
			for (x in 0...numFaces)
			{
				var v0:Int = file.readInt();
				var v1:Int = file.readInt();
				var v2:Int = file.readInt();
	    		surf.AddTriangle(v0, v1, v2);
			}
			surfs.push(surf);
		//trace("Mesh ["+i+"] , num Vertices["+numVertices+"],  num Faces["+numFaces+"],  num UVCoords["+numUVCoords+"] , numColor["+numColors+"]" );
		}

		var saveCount:Int = surfs.length;
		surfs.sort(materialIndex);
		var lastMaterial:Int = -1;
		var surf2:Surface = createSurface();
		for (i in 0... surfs.length)
		{
			     var surf1:Surface = surfs[i];
				 var no_verts2:Int = surf2.CountVertices();
				 
	    		if (surf1.materialIndex != lastMaterial)
				{
				   lastMaterial = surf1.materialIndex;
				   surf2 = createSurface();
				   surf2.brush.clone(surf1.brush);
				   surf2.materialIndex = lastMaterial;
			    }
				
				
				
				
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
		

					var v2=surf2.AddVertex(vx,vy,vz);
					surf2.VertexColor(v2,255,255,255,1);
					surf2.VertexNormal(v2,vnx,vny,vnz);
					surf2.VertexTexCoords(v2,vu0,vv0,0,0);
					surf2.VertexTexCoords(v2,vu1,vv1,0,1);
				}
				for (t in 0...surf1.CountTriangles())
				{
					var v0=surf1.TriangleVertex(t,0)+no_verts2;
					var v1=surf1.TriangleVertex(t,1)+no_verts2;
					var v2=surf1.TriangleVertex(t,2)+no_verts2;

					surf2.AddTriangle(v0,v1,v2);
				}
				
				surf2.UpdateVBO();
				surf2.updateBounding();
			
			
		}

		trace("INFO:Remove surfaces:" + Std.int(Math.abs(CountSurfaces()-saveCount))+" surfaces");
		
		surfs = null;
		brushes = null;
		file = null;
		
		UpdateBoundingBox();
		UpdateNormals();
		Optimize();
		sortMaterial();
		
	}
	public  function getSurface(index:Int):Surface
	{
		return surfaces[index];
		
	}
	public function setTexture(tex:Texture)
	{
		for (i in 0... surfaces.length)
		{
			var surf = surfaces[i];
			
			surf.brush.setTexture(tex);
		}
	}
	public function setDetail(tex:Texture)
	{
		for (i in 0... surfaces.length)
		{
			var surf = surfaces[i];
			
			surf.brush.setDetail(tex);
		}
	}
	public function getBrush(index:Int=0):Brush
	{
			var surf = surfaces[index];
			
			return surf.brush;
		
	}
	public function setMaterialType(type:Int):Void
	{
	    for (i in 0... surfaces.length)
		{
			var surf = surfaces[i];
			
			surf.brush.setMaterialType(type);
		}
 	}
	
		public function setBlend(type:Bool):Void
	{
		renderType = 1;
	    for (i in 0... surfaces.length)
		{
			var surf = surfaces[i];
			
			surf.brush.BlendFace = type;
		}
 	}
	public function setBlendType(type:Int):Void
	{
		renderType = 1;
	    for (i in 0... surfaces.length)
		{
			var surf = surfaces[i];
			
			surf.brush.BlendType = type;
		}
 	}
	public function debugNormals(lines:Imidiatemode,length:Float)
	{
		for (i in 0... surfaces.length)
		{
			var surf = surfaces[i];
			
			surf.debugNormals(AbsoluteTransformation,lines,length);
		}
	}
	public function debugBoundingBoxes(lines:Imidiatemode)
	{
		
		for (i in 0... surfaces.length)
		{
			var surf = surfaces[i];
			
			surf.Bounding.boundingBox.renderAligned(lines);
		}
	}		

	inline public function intersects(ray:Ray, fastCheck:Bool = false):Float
    {
		for (i in 0... surfaces.length)
		{
			var surf = surfaces[i];
			if (surf.BoxIntersects(ray))
			{
				return surf.intersects(ray, fastCheck);
				break;
			}
			return -1;
		}
		return -1;
    }
	
	
	override public function dispose()
	{
		for (i in 0... surfaces.length)
		{
			var surf = surfaces[i];
			
			surf.dispose();
		}

		super.dispose();
	}
	
	public function transformPoint(v:Vector3):Vector3
	{
		return Vector3.TransformCoordinates(v, AbsoluteTransformation);
	}
	 public function MeshTranslate( x:Float,y:Float,z:Float):Void
   {
	   for (i in 0... surfaces.length)
		{
			var surf = surfaces[i];
			
			surf.translate(x,y, z);
		}
		UpdateBoundingBox();
   }
   public function MeshScale( x:Float,y:Float,z:Float):Void
   {
	   for (i in 0... surfaces.length)
		{
			var surf = surfaces[i];
			
			surf.scale(x, y, z);
		}
		UpdateBoundingBox();
   }
   public function MeshRotate( y:Float,p:Float,r:Float):Void
   {
	   for (i in 0... surfaces.length)
		{
			var surf = surfaces[i];
			
			surf.rotate(y,p,r);
		}
		UpdateBoundingBox();
   } 
  public function MeshTransform( m:Matrix4):Void
  {
	   for (i in 0... surfaces.length)
		{
			var surf = surfaces[i];
			
			surf.transform(m);
		}
		UpdateBoundingBox();
  }
  
  public function isObscure(point:Vector3,fastCheck:Bool=false ):Bool 
	{
	    var direction:Vector3 =point.subtract(position);
        var distance:Float = direction.length();
	    direction.normalize();
	    var ray:Ray = new Ray(position, direction);
        var pickInfo = scene.collider.RayPick(ray, fastCheck);
    	return (pickInfo && scene.inpactDistance < distance);
	
	}
	
    public function rayTrace(ray:Ray,fastCheck:Bool):Bool
   {
	   
	   
	   if (ray.intersectsTransformedBox(Bounding.boundingBox))
	   {
		   if (fastCheck)
		   {
			   return true;
		   } else
		   {
	      		 for (s in 0...CountSurfaces())
	              {
	               var surf:Surface = getSurface(s);
		           for (f in 0... surf.CountTriangles())
		           {
			        var p0 = surf.getFace(f, 0);
			        var p1 = surf.getFace(f, 1);
			        var p2 = surf.getFace(f, 2);
			    	var a = Vector3.TransformCoordinates(p0, getAbsoluteTransformation());
					var b = Vector3.TransformCoordinates(p1, getAbsoluteTransformation());
					var c = Vector3.TransformCoordinates(p2, getAbsoluteTransformation());
		   
					
			scene.inpactDistance = ray.intersectsTriangle(a,b,c);
			if(scene.inpactDistance>0)
			{
		    scene.inpactTriangle.a.copyFrom(a);
			scene.inpactTriangle.b.copyFrom(b);
			scene.inpactTriangle.c.copyFrom(c);
			scene.inpactTriangle.normal.copyFrom(surf.getFaceNormal(f, 0));
	        scene.inpactNormal.x = scene.inpactTriangle.normal.x;
			scene.inpactNormal.y = scene.inpactTriangle.normal.y;
			scene.inpactNormal.z = scene.inpactTriangle.normal.z;
			scene.inpactPoint.x = ray.origin.x + (ray.direction.x * scene.inpactDistance);
			scene.inpactPoint.y = ray.origin.y + (ray.direction.y * scene.inpactDistance);
			scene.inpactPoint.z = ray.origin.z + (ray.direction.z * scene.inpactDistance);
			
			
		
			return  true;
			}
					
					
				   }
				  }
		   }
	   }
				
	   
	   return false;
   }
  
}