package com.gdx.scene3d;

import com.gdx.gl.shaders.Brush;
import com.gdx.gl.Texture;
import com.gdx.math.Matrix4;
import com.gdx.math.Vector2;
import com.gdx.math.Vector3;
import com.gdx.scene3d.buffer.ArraySingleBuffer;
import com.gdx.scene3d.buffer.IndexSingleBuffer;
import haxe.xml.Fast;
import lime.Assets;
import lime.utils.Float32Array;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLShader;
import lime.graphics.opengl.GLUniformLocation;
import lime.graphics.opengl.GLTexture;

/**
 * ...
 * @author Luis Santos AKA DJOKER
 */
class MapMesh extends Mesh
{
	

	public function new(scene:Scene,Parent:SceneNode = null , id:Int = 0, name:String="MapMesh")  
	{
		 super(scene, Parent, id, name);
	  	
	}
	public function parse(filename:String,texturePath:String,scale:Float=1.0)
	{

		
		var xml:Xml = Xml.parse (Assets.getText(filename));
		var xmlNode = xml.firstElement();
		var min:Vector3 = Vector3.zero;
		var max:Vector3 = Vector3.zero;
		var pos:Vector3 = Vector3.zero;
		var normal:Vector3 = Vector3.zero;
		var uv:Vector2 = Vector2.zero;
  		var fast = new Fast(xmlNode);
		
				var textures:Map<Int,Texture> = new Map<Int,Texture>();
		var surfs:Array<Surface> = [];
		
		//trace("Num materials :" + numMaterials);
		
		
	    
		
    	 var list:List<Fast> = fast.node.resolve("Textures").nodes.resolve("Texture");
		 var index:Int = 0;
		 for (item in list)
		{
			var texture = item.att.name;
		
			if (Assets.exists(texturePath + "/" + texture))
			{
			textures.set(index, Gdx.Instance().getTexture(texturePath + "/" + texture, true));
			} else
			{
				trace("INFO: Replase "+texture+" with dummy");
				textures.set(index, Gdx.Instance().getTexture("dummy", true));
			}
			index++;
       }
		
	var lastTextureId:Int = -1;
	var textureId:Int = 0;
	
	var numMesh:Int = 0;
	var numSurfaces:Int = 0;
	var no_verts:Int = 0;
	
	var newsurface:Bool = false;
		var isModel:Bool = false;			  
	
	    var list:List<Fast> =  fast.nodes.resolve("Entitie");
		for (entitie in list)
		{
	
		isModel = false;
		
		
	
			 for (node in  entitie.elements)
			 {
				 if (node.name == "Attributes")
				 {
				 	for (att in node.elements)
			       {
				    if (att.has.Name)
				     {
					
				     }
			        }
				}
			//	if (isModel) continue;
				//******************
				 if (node.name == "Brush")
				 {
					   for (brush in node.elements)
				       {
					   if (brush.name == "Surface")
					   {
						var surf:Surface = createSurface();
					    	textureId = Std.parseInt(brush.att.TexID);
						    surf.materialIndex = textureId;
						    surf.brush.setTexture(textures.get(surf.materialIndex));
					    
						
			
						 
						 for ( n in brush.elements)
						 {
					    	 if (n.name == "Polys")
							 {
								
				              for (poly in n.elements)
				             {
					 var x = Std.parseFloat(poly.att.x);
					 var y = Std.parseFloat(poly.att.y);
					 var z = Std.parseFloat(poly.att.z);
					 var nx = Std.parseFloat(poly.att.nx);
					 var ny = Std.parseFloat(poly.att.ny);
					 var nz = Std.parseFloat(poly.att.nz);
					 var tu = Std.parseFloat(poly.att.tu);
					 var tv = Std.parseFloat(poly.att.tv);
					 surf.AddFullVertex(x*scale, y*scale, z*scale, nx, ny, nz, tu, tv);
			
				            }//vertex
							}
							
							
							  if (n.name == "Faces")
							 {
								for (face in n.elements)
				                {
	      			             var a = Std.parseInt(face.att.A);
					             var b = Std.parseInt(face.att.B);
					             var c = Std.parseInt(face.att.C);
								 surf.AddTriangle(a, b, c);
						
				              }//face 
							 }
						 }
						
						
						   surf.UpdateVBO();
						   surf.updateBounding();
						 
					  }// surface
			
					  
						   
				       }///brush elements
				 }
			 }
		}
			
	//	trace(numSurfaces);
    
		sortMaterial();
        UpdateBoundingBox();
	//	Optimize();
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
			
			if(EnableCull)  if (!surfaces[i].Bounding.isInFrustrum(camera.frustumPlanes)) continue;
			if (showSubBoundingBoxes) surfaces[i].Bounding.boundingBox.renderAligned(scene.lines);
			if (showNormals) 			surfaces[i].debugNormals(meshTrasform,scene.lines, 5.0);
				
			  scene.setMaterial(surfaces[i].brush);
		      surfaces[i].render();
			  
			}
		}



		//super.render(camera);
		
	}


	

	

}
