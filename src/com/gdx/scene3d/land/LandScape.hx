package com.gdx.scene3d.land;
import com.gdx.gl.shaders.Brush;
import com.gdx.math.BoundingInfo;
import com.gdx.math.Matrix4;
import com.gdx.math.Vector3;
import com.gdx.scene3d.buffer.IndexSingleBuffer;
import com.gdx.scene3d.SceneNode;
import com.gdx.scene3d.Surface;
import com.gdx.util.HeightMap;
import lime.Assets;
import lime.graphics.Image;

/**
 * ...
 * @author Luis Santos AKA DJOKER
 */
class Chunck
{
	public var vertexbuffer:IndexSingleBuffer;
	public var land:LandScape;
	public var Position:Vector3;
	public var bound:BoundingInfo;
	public var Vert:Array<Float>;
	public var Indices:Array<Int>;
	public var surface:Surface;
	public var width:Float;
	public var height:Float;
	public function new(land:LandScape)
	{
		this.land = land;
		//vertexbuffer = new IndexSingleBuffer(land.scene.shader, true, true, true, true);
		//Vert = [];
		//Indices = [];
		//bound = new BoundingInfo(new Vector3(99999, 99999, 99999), new Vector3( -99999, -99999 - 99999));
		Position = Vector3.zero;
		surface = new Surface(land.scene.shader);
	}
}
 
class LandScape extends SceneNode
{
  public var heighMap:Image;
  public var Terrain:Array<Chunck>;
  private var yFactor:Float;
  private var precision:Float;
  public var brush:Brush;
  


	public function new(heigh:String,Precision:Float = 2,YFactor:Float=1,scene:Scene,Parent:SceneNode = null , id:Int = 0, name:String="LandsCape")  
	{
    	 super(scene, Parent, id, name);
		 
	if (Assets.exists(heigh))
	{
	 heighMap =  Assets.getImage(heigh);
	} else
	{
	heighMap = new Image(null, 0, 0, 128, 128);
	trace('ERROR:image ' + heigh + 'dont exit');
	}
		
	     brush = new Brush(3);
		 Terrain = [];
		 precision = Precision;
		 yFactor = YFactor;
	}
	public function  Optimize( ):Void
	{
		for (land in Terrain)
		{
			land.surface.Optimize();
		}
		
	}
	public function  GenerateHugeTerrain( 
	width:Int,
	height:Int,
	PosX:Float, 
	PosZ:Float):Void
	{
		for (x in 0...width)
		{
			for (y in 0...height)
			{
				
				GenerateTerrainEx(PosX + x * heighMap.width, PosZ + y * heighMap.height, x / width, y / height, 1 / width, 1 / height);
			}
		}

	}
	public function  GenerateTerrainEx( 
	PositionX:Float, 
	PositionZ :Float,
	SrcPosX :Float, 
	SrcPosY:Float, SingWidth :Float,
	SingHeight:Float,
	NoHeight:Bool = false):Void
	{
		
	var w:Int = this.heighMap.width;
	var h:Int = this.heighMap.height;

	var v:Int=0;
	var xl:Int = 0;
	var yl:Int = 0;
	var vy:Array < Float>=[];
	
		
		var chunk:Chunck = new Chunck(this);
		chunk.width  = heighMap.width / precision+1;
		chunk.height = heighMap.height/ precision+1;
		chunk.Position.set(PositionX, 0, PositionZ);
		chunk.surface.brush = brush;
		
		 for (y in 0... Math.round(chunk.height)) 
			{
                for (x in 0... Math.round(chunk.width)) 
				{
                 
                    v  = Std.int(y *  chunk.width + x);
					
				
					var gradient:Float = 0;
					if (!NoHeight)
					{
				    xl = Math.round(x / (chunk.width -  1) * w * SingWidth  + SrcPosX * w)  ;
		            yl = Math.round(y / (chunk.height - 1) * h * SingHeight + SrcPosY * h);
					var color:Int = heighMap.getPixel(xl,yl);
					var r = Util.getRed(color)  / 255;
		            var g = Util.getGreen(color)/255;
		            var b = Util.getBlue(color) / 255;
					gradient = (r * 0.3 + g * 0.59 + b * 0.11) * (yFactor*255) ;
					}
				  
				  
				   chunk.surface.AddFullVertex((x * precision) + PositionX,gradient ,(y * precision) + PositionZ,
				   0.0, 1.0, 0.0,
				   (x / (chunk.width - 1)),
				   (y / (chunk.height - 1)),
				   (x / (chunk.width - 1) ),
				   (y / (chunk.height - 1) ));
                }
            }

			
		
			
            // Indices

          for (y in 0... Math.round(chunk.height)-1) 
			{
                for (x in 0... Math.round(chunk.width)-1) 
				{
                 
                   
          v  = Std.int(y *  chunk.width + x);
					  
			  chunk.surface.AddTriangle(
		  v + 1,
		  v,
		  Std.int(v + chunk.width));
		 
		  chunk.surface.AddTriangle(
		  v + 1,
		  Std.int(v + chunk.width),
		  Std.int(v + chunk.width+1));
		  }
		  
			
                
            }


		
		chunk.surface.brush.materialType = 2;
		chunk.surface.updateBounding();
		//chunk.surface.UpdateVBO();
		chunk.surface.ComputeNormal();
		//chunk.surface.Optimize;
		Terrain.push(chunk);			
	}
	
	public function  ExpandTexture( TerrainMinX:Int, TerrainMinZ:Int,TerrainMaxX:Int, TerrainMaxZ:Int ):Void
  {
  var ScaleX:Float = 1 / (TerrainMaxX - TerrainMinX);
  var ScaleY:Float = 1 / (TerrainMaxZ - TerrainMinZ);
   var Tile:Int = 512;
   
   
   for (X in TerrainMinX ... TerrainMaxX)
   {
    for (Y in  TerrainMinZ ... TerrainMaxZ)
	{
      var DecalX:Float = (X - TerrainMinX) * ScaleX;
      var DecalY:Float = (Y - TerrainMinZ) * ScaleY;
       for (count in 0...Terrain.length)
	   {

		 if ((Terrain[count].Position.x/heighMap.width)==X && (Terrain[count].Position.z/heighMap.height)==Y)
		 {
			   for (cx in 0 ... Std.int(Terrain[count].width))
			   {
				   for ( cy in 0 ... Std.int(Terrain[count].height))
				   {
		             var V:Int = Std.int(Terrain[count].width * cy + cx);
					 
					 var ux:Float = cx / (Terrain[count].width - 1) * ScaleX * 0.995 + 0.0025 + DecalX;
					 var vy:Float = cy / (Terrain[count].height - 1) * ScaleY * 0.995 + 0.0025 + DecalY;
					 
					 
					 
					  
					  Terrain[count].surface.VertexTexCoords(V, ux, vy);
 
     			   }
		
		   }
			      
		 }
	   }
	}
   }
	}

	public function smoothTerrain(smoothFactor:Int):Void
	{
		for (land in Terrain)
		{
			_smoothTerrain(land.surface, Std.int(land.width), smoothFactor);
		}
	}
	
	
	
	private function _smoothTerrain(surf:Surface,Size:Int,smoothFactor:Int):Void
	{
		for (run in 0...smoothFactor)
		{
			var yd:Int = Size;
			for (y in 1...Size-1)
			{
				for (x in  1...Size-1)
				{
					surf.YVertex(x + yd,
					(surf.VertexY(x - 1 + yd) +//left
					surf.VertexY (x + 1 + yd) +//rigth
					surf.VertexY (x  + yd - Size) +//above
					surf.VertexY (x  + yd + Size)) * 0.25); //below
	
						
				}
				
					yd += Size;
			}
		}
		
		
	}
	
	override public function render(camera:Camera) 
	{
		if (!Visible) return;
	    var meshTrasform:Matrix4 = AbsoluteTransformation;
		
    	var scaleFactor:Float = Math.max(scaling.x, scaling.y);
             scaleFactor = Math.max(scaleFactor,scaling.z);
	
		Gdx.Instance().numMesh++;
	   scene.shader.setWorldMatrix(meshTrasform);
	
				
	   scene.setMaterial(brush);	
		   

    	for (i in 0... Terrain.length)
		{
			  Terrain[i].surface.Bounding.update(meshTrasform, scaleFactor);
			 if (EnableCull)  if (!Terrain[i].surface.Bounding.isInFrustrum(camera.frustumPlanes)) continue;
			 if (showSubBoundingBoxes) Terrain[i].surface.Bounding.boundingBox.renderAligned(scene.lines);
			 if (showNormals) 			Terrain[i].surface.debugNormals(meshTrasform, scene.lines, debugNormalLineSize);	
			
			 
		      Terrain[i].surface.render();
		}
	}
	 
}