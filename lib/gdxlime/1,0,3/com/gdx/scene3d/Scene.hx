package com.gdx.scene3d;

import com.gdx.collision.Coldet;
import com.gdx.collision.CollisionInfo;
import com.gdx.collision.WorldColider;
import com.gdx.color.Color3;
import com.gdx.color.Color4;
import com.gdx.gl.shaders.AmbientLight;
import com.gdx.gl.shaders.Brush;
import com.gdx.gl.shaders.Fixed;
import com.gdx.gl.shaders.Flat;
import com.gdx.gl.shaders.QuadShader;
import com.gdx.gl.Texture;
import com.gdx.math.Plane;
import com.gdx.math.Ray;
import com.gdx.math.Triangle;
import com.gdx.math.Vector3;
import com.gdx.scene3d.buffer.Imidiatemode;
import com.gdx.scene3d.Camera;
import com.gdx.scene3d.importer.AC3DParser;
import com.gdx.scene3d.land.LandScape;
import com.gdx.scene3d.land.MultitexturedTerrain;
import com.gdx.scene3d.land.SplattingTerrain;
import com.gdx.scene3d.ocluder.MeshOctree;
import com.gdx.scene3d.ocluder.OctreeSurfaceSelector;
import com.gdx.scene3d.particles.Sprite3DBatch;



import com.gdx.scene3d.particles.BoxEmitter;
import com.gdx.scene3d.particles.BilboardBatch;
import com.gdx.scene3d.particles.CylinderEmitter;
import com.gdx.scene3d.particles.MeshEmitter;
import com.gdx.scene3d.particles.ParticleSystem;
import com.gdx.scene3d.particles.DecaleSystem;
import com.gdx.scene3d.particles.RingEmitter;
import com.gdx.scene3d.particles.SphereEmitter;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLShader;
import lime.graphics.opengl.GLUniformLocation;
import lime.graphics.opengl.GLTexture;
import lime.graphics.RenderContext;
import lime.utils.Float32Array;
import lime.utils.Int16Array;

/**
 * ...
 * @author djoekr
 */
class Scene 
{
	public static inline var NUMLINES =5000;
	public  var  shader:Flat;
    public var  quadshader:QuadShader;
	public var mainCamera:Camera;
	public var lines:Imidiatemode;
	public var root:Pivot;
	public var childs:Array<SceneNode>;
	public var deleteList:Array<SceneNode>;
	public var MeshShaders:Array<SceneNode>;
	public var bodyList:Array<Body>;
	public var blendNodes:Array<SceneNode>;
	public var skybox:SkyBox;
	private var colidecount:Int = 0;
	public var force:Vector3;
	public var masslessForce:Vector3;
	public var sceneOctree:MeshOctree;
	public var lastBrush:Brush;
	
	public var	inpactTriangle: Triangle;
	public var inpactPoint: Vector3;
	public var inpactNormal:Vector3;
	public var inpactPlane:Plane;
	public var inpactDistance:Float;
	
	
  // public var DiffuseColor:Color3;
   public var AmbientColor:Color3;
 //  public var SpecularColor:Color3;
   public var sunPosition:Vector3;
 //  public var Shininess:Float;
    public var collider:WorldColider;
		
	
		
	public function new()
	{
		
		root = new Pivot(this);
		childs = [];
		blendNodes = [];
		MeshShaders = [];
		deleteList = [];
		bodyList = [];
		collider = null;
		addChild(root);
		mainCamera = null;
		shader = new Flat();
		quadshader = new QuadShader();
		addCamera(new Vector3(0, 2, -10),new Vector3( 0, 0, 1000));
	    mainCamera.setPerspective(45,Gdx.Instance().width/Gdx.Instance().height, 0.1, 3000);
		lines = new Imidiatemode(NUMLINES);
		skybox = null;
		force = new Vector3(0,0,0);
		masslessForce = new Vector3(0, 0, 0);
		sceneOctree = null;
			inpactTriangle=new Triangle(Vector3.zero, Vector3.zero, Vector3.zero, Vector3.zero);
	inpactPoint = Vector3.zero;
	inpactNormal = Vector3.zero;
	inpactPlane = new Plane(0, 0, 0, 0);
	inpactDistance = 0;

		
	 lastBrush = null;
	// DiffuseColor = new Color3(1, 1, 1);
     AmbientColor= new Color3(0.8, 0.8, 0.8);
   //  SpecularColor= new Color3(1, 1, 1);
     sunPosition = new Vector3( 1000, 1000, 1000);
	// Shininess = 10;


	}
	public function setAmbientColor(r:Float,g:Float,b:Float):Void
	{
		AmbientColor.set(r, g, b);
		
	}
	/*
    public function setAmbientDiffuse(r:Float,g:Float,b:Float):Void
	{
		DiffuseColor.set(r, g, b);
		
	}
	public function setAmbientSpecular(r:Float,g:Float,b:Float):Void
	{
		SpecularColor.set(r, g, b);
		
	}
	public function setAmbientShiness(v:Float):Void
	{
	Shininess = v;
		
	}
	public function setLightDirection(x:Float,y:Float,z:Float):Void
	{
		lightdirection.set(x, y, z);
		
	}
	*/
	public function setLightPosition(x:Float,y:Float,z:Float):Void
	{
		sunPosition.set(x, y, z);
		
	}
		public function setLightPositionVector(v:Vector3):Void
	{
		sunPosition.set(v.x, v.y, v.z);
		
	}
	public function createOctree(maxBlockCapacity:Int = 64,maxDepth:Int=2):MeshOctree
	{
	     sceneOctree = new MeshOctree(maxBlockCapacity,maxDepth);
		 return sceneOctree;
	}
	
	public function addToDeletion(node:SceneNode):Void
	{
		deleteList.push(node);
	}
	 public function removeBlendNode(node:SceneNode)
	
	{
		blendNodes.remove(node);
	}
	 public function addBlendNode(node:SceneNode)
	{
		blendNodes.push(node);
	}
	
	 public function addChild(node:SceneNode)
	
	{
		//childs.push(node);
		if (Std.is(node, ShaderMesh))
		{
			MeshShaders.push(node);
			
		} else
		if (Std.is(node, MultitexturedTerrain))
		{
			MeshShaders.push(node);
			
		} else
			if (Std.is(node, SplattingTerrain))
		{
			MeshShaders.push(node);
			
		} else

		if (Std.is(node, ParticleSystem))
		{
		 this.blendNodes.push(node);
		} 
		if (Std.is(node, DecaleSystem))
		{
		 this.blendNodes.push(node);
		} 
		else
		if (Std.is(node, BilboardBatch))
		{
		 this.blendNodes.push(node);
		} 
		else
			if (Std.is(node, Sprite3DBatch))
		{
		 this.blendNodes.push(node);
		} 
		else
		if (Std.is(node, Pivot))
		{
		 childs.push(node);
		} else
		if (Std.is(node, MeshOctree))
		{
		 childs.push(node);
		}else
		if (Std.is(node, LandScape))
		{
		 childs.push(node);
		}else
		if (Std.is(node, OctreeSurfaceSelector))
		{
		 childs.push(node);
		}else
		if (Std.is(node, Mesh))
		{
		 childs.push(node);
		}else
			if (Std.is(node, SceneLevel))
		{
		 childs.push(node);
		}else
		if (Std.is(node, AnimatedMD2Mesh))
		{
		 childs.push(node);
		}else
			if (Std.is(node, AnimatedMD2Mesh))
		{
		 childs.push(node);
		}else
	
		if (Std.is(node, MD2Mesh))
		{
		 childs.push(node);
		}else
			if (Std.is(node, MD3Mesh))
		{
		 childs.push(node);
		}else
		if (Std.is(node, B3DMesh))
		{
		 childs.push(node);
		}else
	
		if (Std.is(node, BspMesh))
		{
		 childs.push(node);
		}

		sortSolidNodes();
		
	}
	public function removeChild(node:SceneNode, dispose:Bool = true )
	{
		node.scene = null;
	//	childs.remove(node);
		
		if (Std.is(node, ShaderMesh))
		{
			MeshShaders.remove(node);
			node.dispose();
			
		} else
		if (Std.is(node, ParticleSystem))
		{
		 this.blendNodes.remove(node);
		 node.dispose();
		} 
		else
		if (Std.is(node, Pivot))
		{
		childs.remove(node);
		} else
		if (Std.is(node, Mesh))
		{
		childs.remove(node);
		}
		 else
		if (Std.is(node, BspMesh))
		{
		childs.remove(node);
		}else
		if (Std.is(node, MeshOctree))
		{
		childs.remove(node);
		}
	
		
		
		
	}
	public function addFlyCamera():FlyCamera
	{
		var cam:FlyCamera = new FlyCamera(this);
		mainCamera = cam;
		return cam;
	}
	public function addFreeCamera(position:Vector3, LookAt:Vector3):FreeCamera
	{
		var cam:FreeCamera = new FreeCamera(this, position.x, position.y, position.z, LookAt.x, LookAt.y, LookAt.z);
		mainCamera = cam;
		return cam;
	}
	public function addOrbitCamera( offset:Vector3):OrbitCamera
	{
		var cam:OrbitCamera = new OrbitCamera(this,offset);
		mainCamera = cam;
		return cam;
	}
	public function addCamera(position:Vector3, LookAt:Vector3):Camera
	{
		mainCamera = new Camera(this);
		mainCamera.setLookAt(position, LookAt);
		return mainCamera;
	}
	/*
	public function addMeshOctree(MaxTriangles:Int,MaxSubdivisions:Int,parent:SceneNode=null,id:Int=0):MeshOctree
	{
		var pa:SceneNode = null;
		if (parent != null)
		{
			pa = parent;
		} else
		{
			pa = root;
		}
		var m:MeshOctree = new MeshOctree(MaxTriangles,MaxSubdivisions,this,pa, id, "MeshOctree");
		addChild(m);
		
		return m;
	}
	*/
	

	
		public function addMD2Animation(filename:String,parent:SceneNode=null,id:Int=0,name:String="MD2"):MD2Mesh
	{
		var pa:SceneNode = root;
		if (parent != null)
		{
			pa = parent;
		} 
		    var m = new MD2Mesh(this, pa, id, name);
			 m.setParent(pa);
	         m.load(filename);
	 		addChild(m);
	   	return m;
	}
	
	public function addMD3Animation(filename:String,parent:SceneNode=null,id:Int=0,name:String="MD3"):MD3Mesh
	{
		var pa:SceneNode = null;
		if (parent != null)
		{
			pa = parent;
		} else
		{
			pa = root;
		}
		
		    var m = new MD3Mesh(this, pa, id, name);
	         m.load(filename);
			 m.setParent(pa);
	 		addChild(m);
	   	    return m;
	}
	public function addCube(parent:SceneNode=null,id:Int=0):Mesh
	{
		var pa:SceneNode = null;
		if (parent != null)
		{
			pa = parent;
		} else
		{
			pa = root;
		}
		var m:Mesh = new Mesh(this,pa, id, "Cube");
		addChild(m);
		m.createCube();
		return m;
	}
	public function CreateMesh(parent:SceneNode=null,id:Int=0):Mesh
	{
		var pa:SceneNode = null;
		if (parent != null)
		{
			pa = parent;
		} else
		{
			pa = root;
		}
		var m:Mesh = new Mesh(this,pa, id, "Mesh");
		addChild(m);
		return m;
	}
	public function CloneMesh(mesh:Mesh,parent:SceneNode=null,id:Int=0):Mesh
	{
		
		var m:Mesh = CreateMesh(parent, id);
		m.AddMesh(mesh);
		addChild(m);
		return m;
	}
	public function addPlane(y:Float=0.0,w:Float=1000,d:Float=1000,parent:SceneNode=null,id:Int=0):Mesh
	{
		var pa:SceneNode = null;
		if (parent != null)
		{
			pa = parent;
		} else
		{
			pa = root;
		}
		var m:Mesh = new Mesh(this,pa, id, "Plane");
		addChild(m);
		m.createPlane(y, w, d);
		return m;
	}
	public function addGroundPlane( width:Float, height:Float, subdivisions:Int,parent:SceneNode=null,id:Int=0):Mesh
	{
		var pa:SceneNode = null;
		if (parent != null)
		{
			pa = parent;
		} else
		{
			pa = root;
		}
		var m:Mesh = new Mesh(this,pa, id, "GroundPlane");
		addChild(m);
		m.CreateGroundPlane(width, height, subdivisions);
		return m;
	}
	public function addSphere(parent:SceneNode=null,id:Int=0,segment:Int=8):Mesh
	{
		var pa:SceneNode = null;
		if (parent != null)
		{
			pa = parent;
		} else
		{
			pa = root;
		}
		var m:Mesh = new Mesh(this,pa, id, "Sphere");
		addChild(m);
		m.CreateSphere(segment);
    	return m;
	}
			public function addQuad(w:Float=1,h:Float=1,parent:SceneNode=null,id:Int=0,segment:Int=8):Mesh
	{
		var pa:SceneNode = null;
		if (parent != null)
		{
			pa = parent;
		} else
		{
			pa = root;
		}
		var m:Mesh = new Mesh(this,pa, id, "Quad");
		addChild(m);
		m.createQuad(w,h);
		return m;
	}
		public function addCone(parent:SceneNode=null,id:Int=0,segment:Int=8):Mesh
	{
		var pa:SceneNode = null;
		if (parent != null)
		{
			pa = parent;
		} else
		{
			pa = root;
		}
		var m:Mesh = new Mesh(this,pa, id, "Cone");
		addChild(m);
		m.CreateCone(segment, true);
		return m;
	}
		public function addCylinder(parent:SceneNode=null,id:Int=0,segment:Int=8):Mesh
	{
		var pa:SceneNode = null;
		if (parent != null)
		{
			pa = parent;
		} else
		{
			pa = root;
		}
		var m:Mesh = new Mesh(this,pa, id, "Cylinder");
		addChild(m);
		m.CreateCylinder(segment, true);
		return m;
	}
		public function addTorus(parent:SceneNode=null,id:Int=0,diameter:Float=5, thickness:Float=1.0, tessellation:Int=10):Mesh
	{
		var pa:SceneNode = null;
		if (parent != null)
		{
			pa = parent;
		} else
		{
			pa = root;
		}
		var m:Mesh = new Mesh(this,pa, id, "Torus");
		addChild(m);
		m.CreateTorus(diameter, thickness, tessellation);
		return m;
	}
	
	public function addStaticMesh(filename:String,Texturepath:String,build:Bool=true,loadtexture:Bool=true,scale:Float=1,parent:SceneNode=null,id:Int=0):Mesh
	{
		var beginTime:Float = Gdx.Instance().getTimer();
		
		var pa:SceneNode = null;
		if (parent != null)
		{
			pa = parent;
		} else
		{
			pa = root;
		}
		var m:Mesh = new Mesh(this,pa, id, "mesh");
		addChild(m);
		m.loadH3D(filename, Texturepath, build, loadtexture,scale);
		var endTime:Float = Gdx.Instance().getTimer();
		var timepass:Float = endTime - beginTime;
		trace( "Needed " + timepass + ":ms to load :"+filename);
		return m;
	}
		public function addStaticMeshOptimize(filename:String,Texturepath:String,build:Bool=true,loadtexture:Bool=true,scale:Float=1,parent:SceneNode=null,id:Int=0):Mesh
	{
		var beginTime:Float = Gdx.Instance().getTimer();
		
		var pa:SceneNode = null;
		if (parent != null)
		{
			pa = parent;
		} else
		{
			pa = root;
		}
		var m:Mesh = new Mesh(this,pa, id, "mesh");
		addChild(m);
		m.loadH3DOptimize(filename, Texturepath, build, loadtexture,scale);
		var endTime:Float = Gdx.Instance().getTimer();
		var timepass:Float = endTime - beginTime;
		trace( "Needed " + timepass + ":ms to load :"+filename);
		return m;
	}
	public function add3DSMesh(filename:String,Texturepath:String,build:Bool=true,loadtexture:Bool=true,parent:SceneNode=null,id:Int=0):Mesh
	{
		var beginTime:Float = Gdx.Instance().getTimer();
		
		
		
		
		var pa:SceneNode = null;
		if (parent != null)
		{
			pa = parent;
		} else
		{
			pa = root;
		}
		var m:Mesh = new Mesh(this,pa, id, "mesh");
		addChild(m);
		m.load3DS(filename, Texturepath,build, loadtexture);
		
		var endTime:Float = Gdx.Instance().getTimer();
		var timepass:Float = endTime - beginTime;
		trace( "Needed " + timepass + ":ms to load :"+filename);
		
		return m;
	}
	public function addAC3DMesh(filename:String,Texturepath:String,build:Bool=true,loadtexture:Bool=true,parent:SceneNode=null,id:Int=0):Mesh
	{
		var beginTime:Float = Gdx.Instance().getTimer();
		
		
		
		
		var pa:SceneNode = null;
		if (parent != null)
		{
			pa = parent;
		} else
		{
			pa = root;
		}
		var m:Mesh = new Mesh(this,pa, id, "mesh");
		
		m.loadAC3D(filename, Texturepath, build, loadtexture);
		
				addChild(m);
		
		var endTime:Float = Gdx.Instance().getTimer();
		var timepass:Float = endTime - beginTime;
		trace( "Needed " + timepass + ":ms to load :"+filename);
		
		return m;
	}
	
	public function cloneMesh(mesh:Mesh,parent:SceneNode=null,id:Int=0):Mesh
	{
		var pa:SceneNode = null;
		if (parent != null)
		{
			pa = parent;
		} else
		{
			pa = root;
		}
		var m:Mesh = new Mesh(this,pa, id, "mesh");
		addChild(m);
		
		var lastMaterial:Int = -1;
		
		var surf2:Surface = m.createSurface();
		
		for (i in 0... mesh.surfaces.length)
		{
			var surf1:Surface = mesh.surfaces[i];
				
		     
		//752 1356
				
				if (surf1.materialIndex != lastMaterial)
				{
				   lastMaterial = surf1.materialIndex;
				   surf2= m.createSurface();
		
				 // trace("create surface" + i);
				}
				
				
				surf2.brush = surf1.brush;
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
			
				//trace("createsurface:"+lastMaterial);
			
			
		}
		
		return m;
	}
		public function addTerrainHeightMap(url:String, Precision:Float,YFactor:Float,

		 ScaleXDetail:Float=2,ScaleYDetail:Float=2,parent:SceneNode=null,id:Int=0):Mesh
	{
		var pa:SceneNode = null;
		if (parent != null)
		{
			pa = parent;
		} else
		{
			pa = root;
		}
		var m:Mesh = new Mesh(this,pa, id, "Landscape");
		addChild(m);
		m.CreateTerrainHeightMap(url, Precision, YFactor, 0, 0, 0, 0, 1, 1, ScaleXDetail, ScaleYDetail);
		return m;
	}
		public function getNodeIndex(index:Int):SceneNode
	{
		
				return childs[index];
		
	}
	public function getNodeById(id:Int):SceneNode
	{
		
		for (i in 0...childs.length)
		{
			if (childs[i].id == id)
			{
				return childs[i];
			}
		}
		return null;
	}
	
		public function addForce(v:Vector3):Void 
		{
			force=Vector3.Add(force,v);
		}
		 
	
		public function addMasslessForce(v:Vector3):Void 
		{
			masslessForce=Vector3.Add(masslessForce,v);
		}
		
	 public function addBody(b:Body)
	 {
		bodyList.push(b);
		b.update();
		b.integrate(1);
	 }
	 public function step(dt:Float):Void 
	 {
		 
		
	   for (i in 0 ... this.bodyList.length)
		{
			this.bodyList[i].integrate(dt);
		}	
		
		for (j in 0...this.bodyList.length)
		{
			for (i in j + 1 ... this.bodyList.length)
			{
				var a:Body = bodyList[i];
				var b:Body = bodyList[j];
				a.isColliding = false;
				b.isColliding = false;
				if (a != b) 	
				{
					if (testMesh(a, b)) continue;
				}
				
				
			}
		}
		
	
	 }
	 
	
		


	 	private  function testMesh(ca:Body,cb:Body):Bool 
		{
			
		
			
			var mesh1:Mesh = cast(ca, Mesh);
			var mesh2:Mesh = cast(cb, Mesh);
			
	  if (!mesh1.Bounding.intersects(mesh2.Bounding, false)) return false;
	  
	  var r:Float = 1;//  mesh1.Bounding.boundingSphere.radiusWorld;
	
     for (s in 0...mesh2.CountSurfaces())
	 {
		 var surf:Surface = mesh2.getSurface(s);
		 for (f in 0... surf.CountTriangles())
		 {
			var f0 = surf.getFace(f, 0);
			var f1 = surf.getFace(f, 1);
			var f2 = surf.getFace(f, 2);
			
			var v0:Vector3 = Vector3.TransformCoordinates(f0, mesh2.AbsoluteTransformation);
			var v1:Vector3 = Vector3.TransformCoordinates(f1, mesh2.AbsoluteTransformation);
			var v2:Vector3 = Vector3.TransformCoordinates(f2, mesh2.AbsoluteTransformation);
			
			var vNormal = surf.getFaceNormal(f, 0);
				
			if (Coldet.SphereTriangleCollision(mesh1.position, new Triangle(v2, v1, v0, vNormal),r))
			{
				var p = Plane.FromPoints(v2, v1, v0);
				var d:Float = p.DistanceTo(mesh1.position);
				var collisionDepth = r - d;
			
           		  resolveParticleParticle(ca, cb, vNormal, collisionDepth);
				 return true;
				
				
			}
	  		
	    	
			
		 }
	 }
		
		 
			
		
			return false;
			/*

			  var positionOne:Vector3 = ca.position;
              var positionTwo:Vector3 = cb.position;
			  var midline:Vector3 = Vector3.Sub(positionOne,positionTwo);
			 
			  
			  
			  var size:Float = midline.length();

			   if (size <= 0.0 || size >= ca.Bounding.boundingSphere.radiusWorld+cb.Bounding.boundingSphere.radiusWorld)
               {
                 return false;
               }
			   
			   var normal:Vector3 = Vector3.Mult(midline, (1.0 / size));

		
			   var penetration:Float = ( ca.Bounding.boundingSphere.radiusWorld+cb.Bounding.boundingSphere.radiusWorld - size);
		
			   
				
			    resolveParticleParticle(ca, cb, normal, penetration);

			return true;
			*/
		}
		
		

	 function clamp(input:Float, min:Float, max:Float):Float {
        	if (input > max) return max;	
            if (input < min) return min;
            return input;
        } 
		public  function resolveParticleParticle(pa:Body, pb:Body, normal:Vector3, depth:Float):Void 
		{
				
			
			 var mtd:Vector3 = Vector3.Mult(normal,depth);
			 var te:Float = pa.elasticity + pb.elasticity;
			 var sumInvMass:Float = pa.invMass + pb.invMass;
			  
			// the total friction in a collision is combined but clamped to [0,1]
		   // the total friction in a collision is combined but clamped to [0,1]
            var tf:Float = clamp(1 - (pa.friction + pb.friction), 0, 1);
		
			// get the total mass, and assign giant mass to fixed particles
		
			
			
			// get the collision components, vn and vt
			var ca:CollisionInfo = pa.getComponents(normal);
			var cb:CollisionInfo = pb.getComponents(normal);
		 
		 	// calculate the coefficient of restitution based on the mass  
			var vnA:Vector3 = Vector3.divEquals(Vector3.Add(Vector3.Mult(cb.vn,(te + 1) * pa.invMass),  Vector3.Mult(ca.vn,pb.invMass - te * pa.invMass)),sumInvMass);	
			var vnB:Vector3 = Vector3.divEquals(Vector3.Add(Vector3.Mult(ca.vn, (te + 1) * pb.invMass), Vector3.Mult(cb.vn, pa.invMass - te * pb.invMass)), sumInvMass);	
			
			// apply friction to the tangental component
			ca.vt=Vector3.Mult(ca.vt,tf);
			cb.vt=Vector3.Mult(cb.vt,tf);
			
			// scale the mtd by the ratio of the masses. heavier particles move less
			var mtdA:Vector3 =Vector3.Mult(mtd,pa.invMass / sumInvMass);

			var mtdB:Vector3 =Vector3.Mult(mtd,-pb.invMass / sumInvMass);
			
			  // add the tangental component to the normal component for the new velocity 
            vnA=Vector3.Add(vnA,ca.vt);
            vnB=Vector3.Add(vnB,cb.vt);            
			
			if (!pa.isStatic) pa.resolveCollision(mtdA, vnA);
			if (!pb.isStatic) pb.resolveCollision(mtdB, vnB);
			//
			
		

		}
	
	

	public function addDecaleSystem(max:Int,   parent:SceneNode = null , id:Int = 0):DecaleSystem
	{
			var pa:SceneNode = null;
		if (parent != null)
		{
			pa = parent;
		} else
		{
			pa = root;
		}
		
		var b = new DecaleSystem(max, this, pa, id);
		addChild(b);
		return b;
	}
	public function addBilboadBatch(max:Int,   parent:SceneNode = null , id:Int = 0):BilboardBatch
	{
			var pa:SceneNode = null;
		if (parent != null)
		{
			pa = parent;
		} else
		{
			pa = root;
		}
		
		var b = new BilboardBatch(max, this, pa, id);
		addChild(b);
		return b;
	}
	public function addSprite3DBatch(max:Int,   parent:SceneNode = null , id:Int = 0):Sprite3DBatch
	{
			var pa:SceneNode = null;
		if (parent != null)
		{
			pa = parent;
		} else
		{
			pa = root;
		}
		
		var b = new Sprite3DBatch(max, this, pa, id);
		addChild(b);
		return b;
	}
	public function addMeshEmitter(node:Mesh, texture:Texture,  parent:SceneNode = null , id:Int = 0):MeshEmitter
	{
			var pa:SceneNode = null;
		if (parent != null)
		{
			pa = parent;
		} else
		{
			pa = root;
		}
		
		var b = new MeshEmitter(node, texture, this, pa, id);
		addChild(b);
		return b;
	}
	public function addBoxEmitter(boxMin:Vector3, boxMax:Vector3, texture:Texture,  parent:SceneNode = null , id:Int = 0):BoxEmitter
	{
			var pa:SceneNode = null;
		if (parent != null)
		{
			pa = parent;
		} else
		{
			pa = root;
		}
		
		var b = new BoxEmitter(boxMin, boxMax, texture, this, pa, id);
		addChild(b);
		return b;
	}
	public function addSphereEmitter(center:Vector3,radius:Float, texture:Texture,  parent:SceneNode = null , id:Int = 0):SphereEmitter
	{
			var pa:SceneNode = null;
		if (parent != null)
		{
			pa = parent;
		} else
		{
			pa = root;
		}
		
		var b = new SphereEmitter(center,radius, texture, this, pa, id);
		addChild(b);
		return b;
	}
	public function addRingEmitter(center:Vector3,radius:Float,ringThickness:Float, texture:Texture,  parent:SceneNode = null , id:Int = 0):RingEmitter
	{
			var pa:SceneNode = null;
		if (parent != null)
		{
			pa = parent;
		} else
		{
			pa = root;
		}
		
		var b = new RingEmitter(center,radius,ringThickness, texture, this, pa, id);
		addChild(b);
		return b;
	}	
		public function addCylinderEmitter(normal:Vector3,lenght:Float,center:Vector3,radius:Float,outlineOnly:Bool, texture:Texture,  parent:SceneNode = null , id:Int = 0):CylinderEmitter
	{
			var pa:SceneNode = null;
		if (parent != null)
		{
			pa = parent;
		} else
		{
			pa = root;
		}
		
		var b = new CylinderEmitter(normal,lenght,center,radius,outlineOnly, texture, this, pa, id);
		addChild(b);
		return b;
	}
	public function setSkyBox(file:String,size:Float=500):SkyBox
	{
		//
		this.skybox = new SkyBox(size, Gdx.Instance().getTextureCubemap(file));
		return this.skybox;
		
	}
	public function setCollider(minmPolys:Int):WorldColider
	{
		collider = new WorldColider(this,  minmPolys);
		return collider;
		
		
	}
	public function setMainCamera(cam:Camera):Void
	
	{
		this.mainCamera = cam;
		
	}
	 public function update():Void 
	
	{
		step(Gdx.Instance().fixedTime*3);
		if (mainCamera == null) return;
	     mainCamera.update();
		
		
		for (i in 0 ... this.childs.length)
		{
			this.childs[i].update();
		}
		
		
	for (i in 0 ... this.MeshShaders.length)
		{
			this.MeshShaders[i].update();
		}
		
		for (i in 0 ... this.blendNodes.length)
		{
			this.blendNodes[i].update();
		}
		
		
		
	}
	public function setMaterial(b:Brush):Void
	{
		if (!Brush.CompareBrushes(b, lastBrush))
		{
			  lastBrush = b;
			  shader.setMaterialType(lastBrush.materialType);
			  shader.setColor(lastBrush.DiffuseColor.r,lastBrush.DiffuseColor.g, lastBrush.DiffuseColor.b, lastBrush.alpha);
			  lastBrush.Applay();
		}
		
	}
	public function renderAll() 
	{
		//lastBrush = null;
		 
	
		
	  if (skybox != null)
			{
					
				skybox.render(mainCamera);
			}
		
      
				
		
		
		shader.Bind();
		shader.setProjMatrix(mainCamera.projMatrix);
		shader.setViewMatrix(mainCamera.viewMatrix);
		shader.setAmbient(this.AmbientColor.r, this.AmbientColor.g, this.AmbientColor.b, 1);
		shader.setLightPosition(sunPosition.x, sunPosition.y, sunPosition.z);
	
	 
	 
		if (sceneOctree != null)
		{
			sceneOctree.renderNodes(mainCamera,lines);
		}
		
		for (i in 0 ... this.childs.length)
		{
			this.childs[i].render(mainCamera);
		}
		shader.unBind();
		
		for (i in 0 ... this.MeshShaders.length)
		{
			this.MeshShaders[i].render(mainCamera);
		}
		
	



			

		
		quadshader.Bind();
		quadshader.setProjMatrix(mainCamera.projMatrix);
		quadshader.setViewMatrix(mainCamera.viewMatrix);
		
		for (i in 0 ... this.blendNodes.length)
		{
			
			this.blendNodes[i].render(mainCamera);
		}
		quadshader.unBind();

		
	
		
		lines.render(mainCamera);
	   lines.reset();
		
		 var ii = 0;
        while (ii < this.deleteList.length) 
		{
                var node =  this.deleteList[ii];
                if (node.Active) 
			    {
                ++ii;
                }
			else 
			{
				  removeChild(node);
                  deleteList.remove(node);
				  node = null;
	        }
        }

/*
	    Gdx.Instance().setDepthMask(true);
		Gdx.Instance().setDepthTest(true);
		Gdx.Instance().setCullFace(true);
		Gdx.Instance().setBlend(false);
	*/
		
	}
	public function sortSolidNodes():Void
	{
	childs.sort(renderType);
	}
	
	public function rayTrace(ray:Ray,fastCheck:Bool=true):SceneNode
	{
	 for (i in 0...childs.length)
	 {
		 var node:SceneNode = childs[i];
		 if  (Std.is(node, Mesh))
		 {
			 var mesh:Mesh = cast(node);
			 if (mesh.rayTrace(ray, fastCheck))
			 {
				 return node;
			 }
		 }
	 }
	return null;
	}
	function renderType(a:SceneNode, b:SceneNode):Int
    {

    if (a.renderType < b.renderType) return -1;
    if (a.renderType > b.renderType) return 1;
    return 0;
    } 
	public function dispose()
	{
		
	}
}