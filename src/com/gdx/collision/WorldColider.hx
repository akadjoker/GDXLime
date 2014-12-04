package com.gdx.collision;
import com.gdx.math.Aabbox3d;
import com.gdx.math.BoundingBox;
import com.gdx.math.Ray;
import com.gdx.math.Triangle;
import com.gdx.math.Vector3;
import com.gdx.scene3d.buffer.Imidiatemode;
import com.gdx.scene3d.Camera;
import com.gdx.scene3d.Mesh;
import com.gdx.scene3d.Scene;
import com.gdx.scene3d.SceneNode;

/**
 * ...
 * @author Luis Santos AKA DJOKER
 */
class WorldColider
{
	     private var _previousPosition:Vector3 = Vector3.Zero();
         private  var _collisionVelocity:Vector3 = Vector3.Zero();
         private  var _newPosition:Vector3 = Vector3.Zero();
		 private var FallingVelocity:Vector3 = Vector3.Zero();
		 private var Falling:Bool = false;
		 private var IsColide:Bool = false;
		 private var Gravity:Vector3= Vector3.Zero();
		 

	     private var _scaledVelocity:Vector3=Vector3.zero;
	     private var _scaledPosition:Vector3=Vector3.zero;
	      public  var ellipsoid:Vector3 = new Vector3(1, 1, 1);
          public  var ellipsoidOffset:Vector3 = new Vector3(0, 0, 0);
          private  var _oldPositionForCollisions:Vector3 = new Vector3(0, 0, 0);
          private  var _diffPositionForCollisions:Vector3 = new Vector3(0, 0, 0);
          private  var _newPositionForCollisions:Vector3 = new Vector3(0, 0, 0);
		  private  var collisionsEpsilon:Float = 0.05;//0.001;
          public var collider:Collider;
		  private var scene:Scene;
		  private var meshList:Array<Mesh>;
		  private var polys:Int;

	public function new(scene:Scene,minimalPolysPerNode:Int) 
	{
		    this.scene = scene;
			meshList = [];
			polys = minimalPolysPerNode;
			
		
	}
	public function addModel(mesh:Mesh):Void
	{
		collider.addModel(mesh);
	}
	public function addStaticMesh(mesh:Mesh):Void
	{
		meshList.push(mesh);
	}
	public function build():Void
	{
		 collider = new Collider(scene,meshList, polys) ;
	}
	
	public function getInpactPoint():Vector3
	{
		return scene.inpactPoint;
	}
	public function getInpactNormal():Vector3
	{
		return scene.inpactNormal;
	}
	public function rayHit( ray:Ray  ):Bool
	{
		if (collider == null) 
		{
			trace("INFO:add mesh and build");
			return false;
		}
		return collider.rayHit(ray);
		
	}
	inline public function moveAndStop(node:SceneNode ,box:BoundingBox) 
	{
		if (collider == null) 
		{
			trace("INFO:add mesh and build");
			return;
		}
               collider.radius = ellipsoid;
               node.position.subtractToRef(this._previousPosition, this._collisionVelocity);
               traceBoxNewPosition(node,box,this._previousPosition, this._collisionVelocity,  3, this._newPosition);
                if (!this._newPosition.equalsWithEpsilon( node.position))
				{
                     node.position.copyFrom(this._previousPosition);
				}
		
    }
	inline public function moveAndSlide(node:SceneNode, box:BoundingBox,velocity:Vector3) 
	{
		if (collider == null) 
		{
			trace("INFO:add mesh and build");
			return;
		}
			var collisionsEpsilon:Float = 0.001;
	         var globalPosition:Vector3 =	node.position;
            globalPosition.subtractFromFloatsToRef(0, 0, 0, this._oldPositionForCollisions);
            this._oldPositionForCollisions.addInPlace(this.ellipsoidOffset);
            collider.radius = this.ellipsoid;
            traceBoxNewPosition(node,box,this._oldPositionForCollisions, velocity,  3, this._newPositionForCollisions);
            this._newPositionForCollisions.subtractToRef(this._oldPositionForCollisions, this._diffPositionForCollisions);

            if (this._diffPositionForCollisions.length() > collisionsEpsilon)
			{
                node.position.addInPlace(this._diffPositionForCollisions);
			}
    }

	inline public function moveCameraAndSlide(node:Camera,box:BoundingBox, velocity:Vector3,ellipsoid:Vector3,slide:Float=0.005) 
	{
		
		if (collider == null) 
		{
			trace("INFO:add mesh and build");
			return;
		}
		    var globalPosition:Vector3 =	node.position;
            globalPosition.subtractFromFloatsToRef(0, 0, 0, this._oldPositionForCollisions);
            this._oldPositionForCollisions.addInPlace(this.ellipsoidOffset);
            collider.radius = ellipsoid;
			
				// Set this to match application scale..
      //  var unitsPerMeter:Float = 100.0;
      //  var unitScale:Float = unitsPerMeter / 100.0;
      //  var veryCloseDistance:Float = 0.005 * unitScale;
	    var veryCloseDistance:Float = 0.001 *10;
		
		
			
            traceBoxNewPosition(node,box,this._oldPositionForCollisions, velocity,  3, this._newPositionForCollisions,veryCloseDistance);
            this._newPositionForCollisions.subtractToRef(this._oldPositionForCollisions, this._diffPositionForCollisions);
			
			IsColide = (collider.triangleHits == 0);

			if (collider.Falling)
			{
				Falling = true;
			} else
			{
				Falling = false;
					
			}
			
            if (this._diffPositionForCollisions.length() > collisionsEpsilon)
			{
                node.position.addInPlace(this._diffPositionForCollisions);
				node.LookAt.addInPlace(this._diffPositionForCollisions);
			}
    }
	
	 public function moveCameraAndSlideWithGravity(node:Camera,box:BoundingBox, velocity:Vector3,gravity:Vector3,ellipsoid:Vector3,slide:Float=0.005) :Bool
	{
		
		if (collider == null) 
		{
			trace("INFO:add mesh and build");
			return false;
		}
		
		node.position.subtractFromFloatsToRef(0, 0, 0, this._oldPositionForCollisions);
		collider.radius.copyFrom(ellipsoid);
	    this._oldPositionForCollisions.addInPlace(this.ellipsoidOffset);
		
		Gravity.copyFrom(gravity);
		Gravity.normalize();
		
		
		
		
		FallingVelocity.x +=  gravity.x * Gdx.Instance().deltaTime * 0.03;
		FallingVelocity.y +=  gravity.y * Gdx.Instance().deltaTime * 0.03;
		FallingVelocity.z +=  gravity.z * Gdx.Instance().deltaTime * 0.03;
		
			
			traceBoxNewPositionGravity( box, this._oldPositionForCollisions, velocity,FallingVelocity ,_newPositionForCollisions,slide);
			if (collider.Falling)
			{
				Falling = true;
			} else
			{
				Falling = false;
				FallingVelocity.set(0, 0, 0);
				
			}
			
			IsColide = (collider.triangleHits == 0);
	
            this._newPositionForCollisions.subtractToRef(this._oldPositionForCollisions, this._diffPositionForCollisions);

           if (this._diffPositionForCollisions.length() > collisionsEpsilon)
			{
                node.position.addInPlace(this._diffPositionForCollisions);
		        node.LookAt.addInPlace(this._diffPositionForCollisions);
			}
			return collider.collisionFound;
    }

	 private function traceBoxNewPositionGravity(box:BoundingBox,position:Vector3, velocity:Vector3,gravity:Vector3,   finalPosition:Vector3,slide:Float)
	 {
		 
		if (collider == null) 
		{
			trace("INFO:add mesh and build");
			return;
		}
		
		
		
		{
		position.divideToRef(collider.radius, this._scaledPosition);
        velocity.divideToRef(collider.radius, this._scaledVelocity);
        collider.retry = 0;
    	collider.triangleHits = 0;
        BoxCollideWithWorld(box,this._scaledPosition, this._scaledVelocity,  3, finalPosition,slide);
      
		}
		
		{	
	    collider.Falling = false;
	    gravity.divideToRef(collider.radius, this._scaledVelocity);
		collider.retry = 0;
    	collider.triangleHits = 0;
	    BoxCollideWithWorld(box,finalPosition, _scaledVelocity,  2, finalPosition,slide);
        collider.Falling = (collider.triangleHits == 0);
		}
	    finalPosition.multiplyInPlace(collider.radius);
	}
	
	 private function traceBoxNewPosition(node:SceneNode, box:BoundingBox, position:Vector3, velocity:Vector3,  maximumRetry:Int, finalPosition:Vector3, slide:Float = 0.005 )
	 {
		 
		if (collider == null) 
		{
			trace("INFO:add mesh and build");
			return;
		}
		position.divideToRef(collider.radius, this._scaledPosition);
        velocity.divideToRef(collider.radius, this._scaledVelocity);
        collider.retry = 0;
    	collider.triangleHits = 0;
		collider.Falling = false;
        BoxCollideWithWorld(box,this._scaledPosition, this._scaledVelocity,  maximumRetry, finalPosition,slide);
	    finalPosition.multiplyInPlace(collider.radius);
	    collider.Falling = (collider.triangleHits == 0);
		IsColide = (collider.triangleHits == 0);
				
		
	}
    public function RayPickBoundingBoxes(ray:Ray ) :Bool
    {
		return collider.RayPickBoundingBoxes(ray);
    }
	public function RayPick(ray:Ray,fastCheck:Bool=true ) :Bool
    {
		return collider.RayPick(ray,fastCheck);
    }
	inline private function BoxCollideWithWorld(box:BoundingBox,position:Vector3, velocity:Vector3,  maximumRetry:Int, finalPosition:Vector3,slide:Float):Void 
	{
		
		if (collider == null) 
		{
			trace("INFO:add mesh and build");
			return;
		}
	
		var closeDistance = slide;

        if (collider.retry >= maximumRetry) 
		{
            finalPosition.copy(position);
	        return;
        } 
		

			collider.initialize(position, velocity, closeDistance);
			collider.TraceBox(box);
		
		
			if (!collider.collisionFound) 
			{
				position.addToRef(velocity, finalPosition);
				return;
			}
			
				
				if (velocity.x != 0 || velocity.y != 0 || velocity.z != 0) 
				{
					collider.getResponse(position, velocity);
				}
			

				if (velocity.length() <= closeDistance) 
				{
					finalPosition.copy(position);				
			       return;
				}  
				
				
				
					collider.retry++;
					BoxCollideWithWorld(box,position, velocity,  maximumRetry, finalPosition,slide);
					
	}
	
	
	
	 public function CameraCollideEllipsoidSimple(node:Camera,box:BoundingBox,ellipsoid:Vector3,velocity:Vector3,slideSpeed:Float=0.0005) :Bool
	{
		var triangles:Array<Triangle> = [];
	    collider.selector.traceBoundigBox( triangles,  box, scene.lines);
		
		node.position.subtractFromFloatsToRef(0, 0, 0, this._oldPositionForCollisions);
        this._oldPositionForCollisions.addInPlace(this.ellipsoidOffset);
        var  colData:CollisionData = Coldet.collideEllipsoidWithTrianglesSimple(triangles, this._oldPositionForCollisions, ellipsoid, velocity, slideSpeed, scene.lines);
		this._newPositionForCollisions.copyFrom(colData.finalPosition);
		this._newPositionForCollisions.subtractToRef(this._oldPositionForCollisions, this._diffPositionForCollisions);

            if (this._diffPositionForCollisions.length() > collisionsEpsilon)
			{
                node.position.addInPlace(this._diffPositionForCollisions);
				node.LookAt.addInPlace(this._diffPositionForCollisions);
			}
		return colData.foundCollision;
	}
	public function CameraCollideEllipsoidWithGravity(node:Camera,box:BoundingBox,ellipsoid:Vector3,velocity:Vector3,gravity:Vector3,slideSpeed:Float=0.0005) :Bool
	{
		
		var triangles:Array<Triangle> = [];
	    collider.selector.traceBoundigBox( triangles,  box, scene.lines);
		
		node.position.subtractFromFloatsToRef(0, 0, 0, this._oldPositionForCollisions);
        this._oldPositionForCollisions.addInPlace(this.ellipsoidOffset);
		Gravity.copyFrom(gravity);
		Gravity.normalize();
		
		FallingVelocity.x += gravity.x * Gdx.Instance().deltaTime * 0.03;
		FallingVelocity.y += gravity.y * Gdx.Instance().deltaTime * 0.03;
		FallingVelocity.z += gravity.z * Gdx.Instance().deltaTime * 0.03;

		
		
     	var  colData:CollisionData = Coldet.collideEllipsoidWithTriangles(triangles, _oldPositionForCollisions, ellipsoid, velocity, FallingVelocity, slideSpeed, scene.lines);
		if (colData.Falling)
		{
			Falling = true;
		} else
		{
			Falling = false;
			FallingVelocity.set(0, 0, 0);
		}
		
		
	
		this._newPositionForCollisions.copyFrom(colData.finalPosition);
		this._newPositionForCollisions.subtractToRef(this._oldPositionForCollisions, this._diffPositionForCollisions);

            if (this._diffPositionForCollisions.length() > collisionsEpsilon)
			{
                node.position.addInPlace(this._diffPositionForCollisions);
				node.LookAt.addInPlace(this._diffPositionForCollisions);
			}
		return colData.foundCollision;
	}

	public function jump(jumpSpeed:Float=0.5) :Void
	{
		 FallingVelocity.y -=  Gravity.y * jumpSpeed;
		 Falling = true;
	}
	public function isFalling():Bool
	{
		return Falling;
	}
	
	
}