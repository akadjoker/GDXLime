package com.gdx.scene3d;

import com.gdx.gl.Texture;
import com.gdx.math.BoundingInfo;
import com.gdx.math.Matrix4;
import com.gdx.math.Vector2;
import com.gdx.math.Vector3;
import lime.Assets;
import lime.graphics.Image;
import lime.utils.ByteArray;

/**
 * ...
 * @author Luis Santos AKA DJOKER
 */




// This is our BSP lump structure

 typedef BSPLump = { 

	  offset:Int,					// The offset into the file for the start of this lump
	  length:Int					// The length in bytes for this lump
};

// This is our BSP vertex structure
typedef BSPVertex=
{
     vPosition:Vector3,			// (x, y, z) position. 
     vTextureCoord:Vector2,		// (u, v) texture coordinate
     vLightmapCoord:Vector2,	// (u, v) lightmap coordinate
     vNormal:Vector3,			// (x, y, z) normal vector
     r:Int,				// RGBA color for the vertex 
	 g:Int,
	 b:Int,
	 a:Int
};

typedef BSPFace=
{
     textureID:Int,				// The index o the texture array 
     effect:Int,					// The index for the effects (or -1 = n/a) 
     type:Int,					// 1=polygon, 2=patch, 3=mesh, 4=billboard 
     startVertIndex:Int,			// The starting index o this face's first vertex 
     numOfVerts:Int,				// The number of vertices for this face 
     startIndex:Int,				// The starting index o the indices array for this face
     numOfIndices:Int,			// The number of indices for this face
     lightmapID:Int,				// The texture index for the lightmap 
     lMapCorner0:Int,			// The face's lightmap corner in the image 
	 lMapCorner1:Int,			// The face's lightmap corner in the image 
     lMapSize0:Int,			// The size of the lightmap section 
	 lMapSize1:Int,			// The size of the lightmap section 
     lMapPos:Vector3,			// The 3D origin of lightmap. 
     lMapVecs0:Vector3,		// The 3D space for s and t unit vectors. 
	 lMapVecs1:Vector3,		// The 3D space for s and t unit vectors. 
     vNormal:Vector3,			// The face normal. 
     size0:Int,				// The bezier patch dimensions.  
	 size1:Int				// The bezier patch dimensions.  
};



class BspMesh extends Mesh
{
	public static var   kEntities    = 0;            // Stores player/object positions, etc...
    public static var   kTextures    = 1;            // Stores texture information
    public static var   kPlanes      = 2;            // Stores the splitting planes
    public static var    kNodes       = 3;            // Stores the BSP nodes
    public static var kLeafs       = 4;            // Stores the leafs of the nodes
    public static var kLeafFaces   = 5;            // Stores the leaf's indices into the faces
    public static var kLeafBrushes = 6;            // Stores the leaf's indices into the brushes
    public static var kModels      = 7;            // Stores the info of world models
    public static var kBrushes     = 8;            // Stores the brushes info (for collision)
    public static var kBrushSides  = 9;            // Stores the brush surfaces info
    public static var kVertices    = 10;           // Stores the level vertices
    public static var  kIndices   = 11;           // Stores the model vertices offsets
    public static var kShaders     = 12;           // Stores the shader files (blending, anims..)
   public static var  kFaces       = 13;           // Stores the faces for the level
   public static var  kLightmaps   = 14;           // Stores the lightmaps for the level
   public static var  kLightVolumes= 15;           // Stores extra world lighting information
   public static var  kVisData     = 16;           // Stores PVS and cluster info (visibility)
   public static var  kMaxLumps    = 17;           // A constant to store the number of lumps

   
	public var    strID:String;				// This should always be 'IBSP'
    public var    version:Int;				// This should be 0x2e for Quake 3 files
	
	public var m_numOfVerts:Int;			// The number of verts in the model
	public var m_numOfFaces:Int;			// The number of faces in the model
	public var m_numOfIndices:Int;			// The number of indices for the model
	public var m_numOfTextures:Int;		// The number of texture maps
	public var m_numOfLightmaps:Int;		// The number of light maps
	public var m_numOfNodes:Int;			// The number of nodes in the BSP
	public var m_numOfLeafs:Int;			// The number of leafs
	public var m_numOfLeafFaces:Int;		// The number of faces
	public var m_numOfPlanes:Int;			// The number of planes in the BSP
	public var m_numOfBrushes:Int;			// The number of brushes in our world
	public var m_numOfBrushSides:Int;		// The number of brush sides in our world
	public var m_numOfLeafBrushes:Int;		// The number of leaf brushes

	public var lumps:Array<BSPLump> ;
	public var Vertex:Array<BSPVertex> ;
	public var Faces:Array<BSPFace>;
	public var Indices:Array<Int>;
	public var textures:Array<Texture>;
	public var lightmaps:Array<Texture>;
	private var path:String;
	//private var tree:SurfaceOctree;
	private var lmgamma:Float;
	var count:Int = 0;
		
	public function new(scene:Scene,Parent:SceneNode = null , id:Int = 0, name:String="BspMesh") 
	{
		 super(scene,Parent, id, name); 
		
	  Vertex = [];
	  lumps = [];
	  Faces = [];
	  Indices = [];
	  textures = [];
	  lightmaps = [];
	
	  
		
	}

	public function  loadMap(filename:String,path:String,gamma:Float,optimize:Bool=true):Void
	{
		lmgamma = gamma;
		this.path = path;
		var file:ByteArray =	Assets.getBytes(filename);
	    	file.endian = "littleEndian";
        if (file.bytesAvailable <= 0) return;
	    file.position = 0;
		
	
		
		
		 strID=file.readUTFBytes(4);
		 version = file.readInt();
		 trace("version:" + version);
		 
		 for (i in 0 ... kMaxLumps)
		 {
			 var lump:BSPLump = { offset:0, length:0 };
			 lump.offset=file.readInt();
			 lump.length = file.readInt();
				 lumps.push(lump);
		 }
		 
		 m_numOfVerts = Std.int(lumps[kVertices].length / (11*4) );
	//	 trace("Number of vertices:"+ m_numOfVerts);
		    
		  m_numOfFaces = Std.int(lumps[kFaces].length / (26*4));
		// trace("Number of faces:" + m_numOfFaces);
		 
		  m_numOfTextures = Std.int(lumps[kTextures].length / (64+2*4));
		// trace("Number of textures:" + m_numOfTextures);
		 
		  m_numOfLightmaps = Std.int(lumps[kLightmaps].length / (128*128*3));
		// trace("Number of Lightmaps:" + m_numOfLightmaps);
			 
		 
	
		  m_numOfIndices = Std.int(lumps[kIndices].length / 4);
	//	 trace("Number of Indices:" + m_numOfIndices);
		 
		 loadtexture(file);
		 loadLightmap(file);
		 loadVertex(file);
		 loadFaces(file);
		 loadIndex(file);
		 if (optimize)
		 {
		  buildBatchMesh();	 
		 }else
		 {
			buildMesh(); 
		 }
		// buildMesh();
		 
		
		
	}
	public function buildMesh():Void
	{
		
	

      
		
	
		for (i in 0 ... this.m_numOfFaces)
		{
			var face:BSPFace = Faces[i];
			if (face.type == 1)//polygon
			{
					var surf:Surface = createSurface();
					
					
				//	trace(face.startVertIndex + " , " + (face.startVertIndex+face.numOfVerts));
					
					for ( v in face.startVertIndex ... (face.startVertIndex+face.numOfVerts))
					{
						var pos:Vector3 = Vertex[v].vPosition;
						var normal:Vector3 = Vertex[v].vNormal;
						var uv:Vector2 = Vertex[v].vTextureCoord;
						var uv2:Vector2 = Vertex[v].vLightmapCoord;
						var r:Float = Vertex[v].r / 255.0;
						var g:Float = Vertex[v].g / 255.0;
						var b:Float = Vertex[v].b / 255.0;
						var a:Float = Vertex[v].a / 255.0;
						
					surf.AddFullVertexColor(pos.x, pos.y, pos.z, normal.x, normal.y, normal.z, uv.x, uv.y, uv2.x, uv2.y, r, g, b, a);
	
			  
					}
					//surf.Bounding.calculate();
		
			  
					//	trace(face.startIndex + " , " + Std.int((face.startIndex + face.numOfIndices)/3));
				
                    var index:Int = face.startIndex;					
					for (x in 0 ...  Std.int(face.numOfIndices/3))
					{
						
						var v0:Int = this.Indices[index];index++;
						var v1:Int = this.Indices[index];index++;
						var v2:Int = this.Indices[index];index++;
						
					//	trace(v0 + "," + v1 + " ," +v2);
						surf.AddTriangle(v0, v1, v2);
					}
				
				
					
		
					if (textures.length >= 1)
					{
				   if (face.textureID <= textures.length)
					{
						if (textures[face.textureID]!=null)	surf.brush.setTexture(	textures[face.textureID]);
					}
					}
					
					if (lightmaps.length >= 1)
					{
					if (face.lightmapID <= lightmaps.length)
					{
						if (lightmaps[face.lightmapID]!=null)	  surf.brush.setDetail(	lightmaps[face.lightmapID]);
					}
					}
				
					
					
						
					surf.materialIndex = face.textureID;
					surf.brush.setMaterialType(2);
				
				
				 surf.updateBounding();	
                 surf.UpdateVBO();
			}
		}
		
	
		
		sortMaterial();
		Bounding.calculate();
	//
	
		
	}
	public function buildBatchMesh():Void
	{
		
		
		var surfs:Array<Surface> = [];
	
		for (i in 0 ... this.m_numOfFaces)
		{
			var face:BSPFace = Faces[i];
			if (face.type == 1)//polygon
			{
					var  surf:Surface = new Surface(scene.shader);
			
					surf.materialIndex = face.textureID;
					surf.brush.setMaterialType(2);
					
				//	trace(face.startVertIndex + " , " + (face.startVertIndex+face.numOfVerts));
					
					for ( v in face.startVertIndex ... (face.startVertIndex+face.numOfVerts))
					{
						var pos:Vector3 = Vertex[v].vPosition;
						var normal:Vector3 = Vertex[v].vNormal;
						var uv:Vector2 = Vertex[v].vTextureCoord;
						var uv2:Vector2 = Vertex[v].vLightmapCoord;
						var r:Float = Vertex[v].r / 255.0;
						var g:Float = Vertex[v].g / 255.0;
						var b:Float = Vertex[v].b / 255.0;
						var a:Float = Vertex[v].a / 255.0;
			
						
						//swap z/y
					surf.AddFullVertexColor(pos.x, pos.y, pos.z, normal.x, normal.y, normal.z, uv.x, uv.y, uv2.x, uv2.y,r,g,b,a);
					}
					
					//	trace(face.startIndex + " , " + Std.int((face.startIndex + face.numOfIndices)/3));
				
                    var index:Int = face.startIndex;					
					for (x in 0 ...  Std.int(face.numOfIndices/3))
					{
						
						var v0:Int = this.Indices[index];index++;
						var v1:Int = this.Indices[index];index++;
						var v2:Int = this.Indices[index];index++;
						
					//	trace(v0 + "," + v1 + " ," +v2);
						surf.AddTriangle(v0, v1, v2);
					}
				
					if (textures.length >= 1)
					{
					if (face.textureID <= textures.length)
					{
						if (textures[face.textureID]!=null)	surf.brush.setTexture(	textures[face.textureID]);
					}
					}
					
					if (lightmaps.length >= 1)
					{
					if (face.lightmapID <= lightmaps.length)
					{
						if (lightmaps[face.lightmapID]!=null)	  surf.brush.setDetail(	lightmaps[face.lightmapID]);
					}
					}
					
              
							surfs.push(surf);
							surfs.sort(materialIndex);
			}
		}
		
		
		trace("create mesh with sort material");
	
		var lastMaterial:Int = -1;
		
		var surf2:Surface = createSurface();
		
		for (i in 0... surfs.length)
		{
			var surf1:Surface = surfs[i];
		
				if (surf1.materialIndex != lastMaterial)
				{
				   lastMaterial = surf1.materialIndex;
				   surf2= createSurface();
		
			//	  trace("create surface" + i);
				}
				
				
				surf2.brush.clone(surf1.brush);
				var no_verts2:Int = surf2.CountVertices();
				
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
					var vv1 = surf1.VertexV(v, 1);
					var r = surf1.VertexRed(v);
					var g = surf1.VertexGreen(v);
					var b = surf1.VertexBlue(v);
					var a = surf1.VertexAlpha(v);
		
					var v2=surf2.AddVertex(vx,vy,vz);
					surf2.VertexColor(v2,r,g,b,a);
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
		
		//trace("batch complete");
		sortMaterial();
		Bounding.calculate();

		for (i in 0... surfs.length)
		{
			surfs[i].dispose();
			surfs[i] = null;
		}
		surfs = null;
	}
	/*
	override public function render(camera:Camera) 
	{
		if (surfaces.length <= 0) return;
		var meshTrasform:Matrix4 = AbsoluteTransformation;
		Bounding.update(meshTrasform, 1);
		scene.shader.setWorldMatrix(meshTrasform);


		if (!Bounding.isInFrustrum(camera.frustumPlanes)) return;
		Gdx.Instance().numMesh++;
		

	
		  		
		   

    	for (i in 0... surfaces.length)
		{
			if ( surfaces[i].visible)
			{
			  surfaces[i].Bounding.update(meshTrasform, 1);
			
			  if (!surfaces[i].Bounding.isInFrustrum(camera.frustumPlanes)) continue;
			  		
			  scene.shader.setMaterialType(surfaces[i].brush.materialType);
			  scene.shader.setColor(surfaces[i].brush.DiffuseColor.r, surfaces[i].brush.DiffuseColor.g, surfaces[i].brush.DiffuseColor.b, surfaces[i].brush.alpha);
			  surfaces[i].brush.Applay();
		      surfaces[i].render();
			  
			}
		}
	
	}
	*/
	private function loadIndex(file:ByteArray):Void
	{
	   file.position = lumps[kIndices].offset;
	   for (i in 0...m_numOfIndices)
	   {
		   var indice:Int = file.readInt();
		   this.Indices.push(indice);
	   }
	}
	private function loadFaces(file:ByteArray):Void
	{
	   file.position = lumps[kFaces].offset;
	
	   
	   for ( i in 0...m_numOfFaces)
	   {
		   
		      var face:BSPFace =
	   {
     textureID:0,				// The index o the texture array 
     effect:0,					// The index for the effects (or -1 = n/a) 
     type:0,					// 1=polygon, 2=patch, 3=mesh, 4=billboard 
     startVertIndex:0,			// The starting index o this face's first vertex 
     numOfVerts:0,				// The number of vertices for this face 
     startIndex:0,				// The starting index o the indices array for this face
     numOfIndices:0,			// The number of indices for this face
     lightmapID:0,				// The texture index for the lightmap 
     lMapCorner0:0,			// The face's lightmap corner in the image 
	 lMapCorner1:0,			// The face's lightmap corner in the image 
     lMapSize0:0,			// The size of the lightmap section 
	 lMapSize1:0,			// The size of the lightmap section 
     lMapPos:Vector3.zero,			// The 3D origin of lightmap. 
     lMapVecs0:Vector3.zero,		// The 3D space for s and t unit vectors. 
	 lMapVecs1:Vector3.zero,		// The 3D space for s and t unit vectors. 
     vNormal:Vector3.zero,			// The face normal. 
     size0:0,				// The bezier patch dimensions.  
	 size1:0				// The bezier patch dimensions.
	   }
		        face.textureID             = file.readInt();
                face.effect                = file.readInt();
                face.type                  = file.readInt();
                face.startVertIndex           = file.readInt();
                face.numOfVerts            = file.readInt();
                face.startIndex         = file.readInt();
                face.numOfIndices          = file.readInt();
                face.lightmapID            = file.readInt();
                face.lMapCorner0       = file.readInt();
                face.lMapCorner1       = file.readInt();
                
                face.lMapSize0         = file.readInt();
                face.lMapSize1         = file.readInt();
                
		
                face.lMapPos.x          = file.readFloat();
                face.lMapPos.y          = file.readFloat();
                face.lMapPos.z          = file.readFloat();
    
                face.lMapVecs0.x = file.readFloat();
                face.lMapVecs0.y = file.readFloat();
                face.lMapVecs0.z = file.readFloat();
      
                face.lMapVecs1.x = file.readFloat();
                face.lMapVecs1.y = file.readFloat();
                face.lMapVecs1.z = file.readFloat();
                
          
                face.vNormal.x         = file.readFloat();
                face.vNormal.y          = file.readFloat();
                face.vNormal.z          = file.readFloat();
                
                face.size0             = file.readInt();
                face.size1             = file.readInt();
				//trace( "type=" + face.type + ", verts " + face.numOfVerts + ", " + face.numOfVerts );
				Faces.push(face);
				
	   }
	   

	}
	private function loadVertex(file:ByteArray):Void
	{
	   file.position = lumps[kVertices].offset;

		   
		   
		   
		   for (i in 0...m_numOfVerts)
		   {
			   
			   	   var vertex:BSPVertex =
	   {
      vPosition:Vector3.zero,			// (x, y, z) position. 
     vTextureCoord:Vector2.Zero(),		// (u, v) texture coordinate
     vLightmapCoord:Vector2.Zero(),	// (u, v) lightmap coordinate
     vNormal:Vector3.zero,			// (x, y, z) normal vector
     r:0,				// RGBA color for the vertex 
	 g:0,
	 b:0,
	 a:0
		   }
		 
			 vertex.vPosition.x =  file.readFloat();
			 vertex.vPosition.y=  file.readFloat();
			 vertex.vPosition.z =  file.readFloat();
			 
			 
			 var t:Float = vertex.vPosition.y;
			 vertex.vPosition.y = vertex.vPosition.z;
			 vertex.vPosition.z = t;
			
			 vertex.vTextureCoord.x =  file.readFloat();
			 vertex.vTextureCoord.y =  file.readFloat();
		
		
			 vertex.vLightmapCoord.x =  file.readFloat();
			 vertex.vLightmapCoord.y =  file.readFloat();
		      
			
			 vertex.vNormal.x =  file.readFloat();
			 vertex.vNormal.y=  file.readFloat();
			 vertex.vNormal.z =  file.readFloat();
		
			 var r:Int= file.readByte();
			 if (r < 0)
			 r = -r + 127;
			  var g:Int= file.readByte();
			 if (g < 0)
			 g = -g + 127;
			  var b:Int= file.readByte();
			 if (b < 0)
			 b = -b + 127;
			  var a:Int= file.readByte();
			 if (a < 0)
			 a = -a + 127;
			 
			 vertex.r = r;vertex.g = g;vertex.b = b;vertex.a = a;
			 this.Vertex.push(vertex);
			 
			// trace(vertex.vPosition.toString());
			// trace(vertex.vNormal.toString());
			// trace(vertex.vTextureCoord.toString());
			// trace(vertex.vLightmapCoord.toString());
			// trace(vertex.r+" , "+vertex.g+" , "+vertex.b+" , "+vertex.a);
		   }
		   
	
	}
	private function loadtexture(file:ByteArray):Void
	{
		 var strName:String=" ";			// The name of the texture w/o the extension 
         var flags:Int;					// The surface flags (unknown) 
         var textureType:Int;			// The type of texture (solid, water, slime, etc..) (type & 1) = 1 (solid)
		
			
		file.position = lumps[kTextures].offset;
		for (i in 0 ... this.m_numOfTextures)
		{
			strName = readTextureName(file);
			flags=file.readInt();
			textureType = file.readInt();			
			//trace( flags + " ," + textureType+", "+strName);
		if (Assets.exists(path+"/" + strName+".jpg"))
		{
			//trace("try load :" + path + "/" + strName+".jpg");
			
			
			textures.push(Gdx.Instance().getTexture(path + "/" + strName+".jpg", true));
			
		} else
		if (Assets.exists(path+"/" + strName+".png"))
		{
			//trace("try load :" + path + "/" + strName+".png");
			textures.push(Gdx.Instance().getTexture(path + "/" + strName+".png", true));
		} else	{
			trace("Textures :" + path + "/" + strName+" dont exits");
			textures.push(Gdx.Instance().getTexture("dummy"));
		}
		    
		}
		
		
		
	}
	private function loadLightmap(file:ByteArray):Void
	{
		 var strName:String=" ";			// The name of the texture w/o the extension 
         var flags:Int;					// The surface flags (unknown) 
         var textureType:Int;			// The type of texture (solid, water, slime, etc..) (type & 1) = 1 (solid)
		
	
				
		file.position = lumps[kLightmaps].offset;
		for (i in 0 ... this.m_numOfLightmaps)
		{
			/*
		    #if html5
			var data:ByteArray = new ByteArray();
			#else
			var data:ByteArray = new ByteArray(128 * 128 * 3);
			#end
			*/
			
			var data:Array<Int> = [];
			
	
		//file.readBytes(data, 0, 128 * 128 * 3);
		for (x in 0... (128 * 128))
		{
		 data.push(file.readByte());
		 data.push(file.readByte());
		 data.push(file.readByte());
		}
		
		
		// var lightData:ByteArray = new ByteArray(128 * 128 * 3);
		var lightData:Array<Int> = [];
	
		for (j in 0 ... Std.int(data.length/3))
		{
			var r, g, b:Int = 0;
			var rf, gf, bf:Float = 0;
			r = data[j * 3 + 2];
			g = data[j * 3 + 1];
			b = data[j * 3 + 0];
	
			
			rf = r * lmgamma / 255.0;
			gf = g * lmgamma / 255.0;
			bf = b * lmgamma / 255.0;
			
			var scale:Float = 1.0;
			var temp:Float = 0;
			
			    if (rf > 1.0 && (temp = (1.0 / rf)) < scale) scale = temp;
                if (gf > 1.0 && (temp = (1.0 / gf)) < scale) scale = temp;
                if (bf > 1.0 && (temp = (1.0 / bf)) < scale) scale = temp;

                scale *= 255.0;
                r = Std.int(rf * scale);
				g = Std.int(gf * scale);
				b = Std.int(bf * scale);
              
	
				
			//lightData[j] =(r << 0xff) | (0 << 8) | (0xff << 16)  | ((0xFF) << 24); // (r << 0) | (g << 8) | (b << 16)  | ((0xFF) << 24); 
			lightData.push(Util.getColorRGBA(r, g, b, 255));
			
		}

    var lm:Image = new Image(null,0,0,128, 128,  0xFF0000);
	for (y in 0 ... 128)
	{
	for (x in 0 ... 128)
	{
		lm.setPixel32(x, y, lightData[x + (y * 128)]);
	}
	}

	var tlm:Texture = new Texture();
	tlm.loadBitmap(lm, false);	
	this.lightmaps.push(tlm);
	
  }
		
		//Util.saveBitmapData(lm, "lightmap2.png");
	
	}
	
		private function readTextureName(byteData:ByteArray):String {
        var name:String = "";
        var k:Int = 0;
        for (j in 0...64) 
		{
            var ch:Int = byteData.readUnsignedByte();

			//trace(String.fromCharCode(ch) + "," + ch);
			
			 
			if (ch  == 47) 
			{
                name += String.fromCharCode(ch);
				continue;
            }
			
           if (ch > 48 && ch <= 122 && k == 0) 
			{
                name += String.fromCharCode(ch);
            }

          
        }
		
		
        return name;
    }

	

}