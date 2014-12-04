package com.gdx.scene3d;
import com.gdx.math.BoundingBox;
import com.gdx.math.BoundingInfo;
import com.gdx.math.Frustum;
import com.gdx.math.Matrix3;
import com.gdx.math.Matrix4;
import com.gdx.math.Plane;
import com.gdx.math.Quaternion;
import com.gdx.math.Ray;
import com.gdx.math.Vector3;

/**
 * ...
 * @author djoker
 */
class Camera extends SceneNode
{

	public var LookAt:Vector3;
	public var toTarget:Vector3;
	public var horizontalAngle:Vector3;


	public var up:Vector3;
	public var viewMatrix:Matrix4;
	public var viewMatrixInvert:Matrix4;
	public var projMatrix:Matrix4;
    private var _worldMatrix:Matrix4;
	private var fov:Float;
	private var vmin:Float;
	private var vmax:Float;
	public var frustumPlanes:Array<Plane>;
	private var sprite3DMatrix:Matrix4;
	public var cameraRay:Ray;
	public var ellipse:Vector3 ;
	
	
	public function new(scene:Scene, id:Int = 0, name:String="Camera") 
	{
		LookAt = new Vector3(0,0,1);
		up = new Vector3(0, 1, 0);
		toTarget = Vector3.Zero();
		horizontalAngle = Vector3.Zero();
		super(scene, null, id, name);
		viewMatrix = new Matrix4();
		projMatrix = new Matrix4();
		_worldMatrix = new Matrix4();
		viewMatrixInvert = new Matrix4();
		viewMatrix.setLookAtLH(position, LookAt, up);//
		projMatrix.setPerspectiveFovLH(45, Gdx.Instance().width / Gdx.Instance().height, 0.1, 1000);
		this.Bounding.setFloats( -1.0, 1.0);
		sprite3DMatrix = Matrix4.Identity();
		ellipse= new Vector3(1, 1, 1);
		update();
	}
	public function getTarget():Vector3
	{
		return LookAt;
	}
	public function getDirection():Vector3
	{
		return toTarget;
	}
	public function getSpriteMatrix(level:Int):Matrix4
	{
		if (level <= 0) level = 0;
		if (level >= 3) level = 3;
		
		//sprite3DMatrix.setIdentity();

		switch (level)
		{
		case 0:
			{
	sprite3DMatrix.m[Matrix4.M00] = viewMatrixInvert.m[Matrix4.M00];
	sprite3DMatrix.m[Matrix4.M01] = viewMatrixInvert.m[Matrix4.M01];
	sprite3DMatrix.m[Matrix4.M02] = viewMatrixInvert.m[Matrix4.M02];
	sprite3DMatrix.m[Matrix4.M20] = viewMatrixInvert.m[Matrix4.M20];
	sprite3DMatrix.m[Matrix4.M21] = viewMatrixInvert.m[Matrix4.M21];
	sprite3DMatrix.m[Matrix4.M22] = viewMatrixInvert.m[Matrix4.M22];
	
			}
		case 1:
			{
	sprite3DMatrix.m[Matrix4.M10] = viewMatrixInvert.m[Matrix4.M10];
	sprite3DMatrix.m[Matrix4.M11] = viewMatrixInvert.m[Matrix4.M11];
	sprite3DMatrix.m[Matrix4.M12] = viewMatrixInvert.m[Matrix4.M12];
	sprite3DMatrix.m[Matrix4.M20] = viewMatrixInvert.m[Matrix4.M20];
	sprite3DMatrix.m[Matrix4.M21] = viewMatrixInvert.m[Matrix4.M21];
	sprite3DMatrix.m[Matrix4.M22] = viewMatrixInvert.m[Matrix4.M22];
			}
		case 2:
			{
	sprite3DMatrix.m[Matrix4.M00] = viewMatrixInvert.m[Matrix4.M00];
	sprite3DMatrix.m[Matrix4.M01] = viewMatrixInvert.m[Matrix4.M01];
	sprite3DMatrix.m[Matrix4.M02] = viewMatrixInvert.m[Matrix4.M02];
	sprite3DMatrix.m[Matrix4.M10] = viewMatrixInvert.m[Matrix4.M10];
	sprite3DMatrix.m[Matrix4.M11] = viewMatrixInvert.m[Matrix4.M11];
	sprite3DMatrix.m[Matrix4.M12] = viewMatrixInvert.m[Matrix4.M12];
	
			}
		case 3:
			{
	sprite3DMatrix.m[Matrix4.M00] = viewMatrixInvert.m[Matrix4.M00];
	sprite3DMatrix.m[Matrix4.M01] = viewMatrixInvert.m[Matrix4.M01];
	sprite3DMatrix.m[Matrix4.M02] = viewMatrixInvert.m[Matrix4.M02];
	sprite3DMatrix.m[Matrix4.M10] = viewMatrixInvert.m[Matrix4.M10];
	sprite3DMatrix.m[Matrix4.M11] = viewMatrixInvert.m[Matrix4.M11];
	sprite3DMatrix.m[Matrix4.M12] = viewMatrixInvert.m[Matrix4.M12];
	sprite3DMatrix.m[Matrix4.M20] = viewMatrixInvert.m[Matrix4.M20];
	sprite3DMatrix.m[Matrix4.M21] = viewMatrixInvert.m[Matrix4.M21];
	sprite3DMatrix.m[Matrix4.M22] = viewMatrixInvert.m[Matrix4.M22];	
			}
	}
	
	
		
			
	return sprite3DMatrix;	
	}
	public function setLookAt(pos:Vector3, view:Vector3)
	{
		this.position = pos;
		this.LookAt = view;
		viewMatrix.setLookAtLH(position, LookAt, up);//   = Matrix4.LookAtLH(position, LookAt, up);
	}

	
	public function setPerspective(fov:Float,aspect:Float,viewMin:Float,viewMax:Float) 
	{
		this.fov = fov;
		this.vmin = viewMin;
		this.vmax = viewMax;
		projMatrix.setPerspectiveFovLH(fov, aspect, viewMin, viewMax);
	}
	
	override public function getRelativeTransformation():Matrix4
	{
		toTarget.x = LookAt.x - position.x;
		toTarget.y = LookAt.y - position.y;
		toTarget.z = LookAt.z - position.z;
		toTarget.getHorizontalAngle(horizontalAngle);
		this.rotation.x = horizontalAngle.x;
		this.rotation.y = horizontalAngle.y;
		this.rotation.z = horizontalAngle.z;
		LocalWorld.setIdentity();
		LocalWorld.setRotationDegrees(this.rotation);
    	LocalWorld.m[12] = position.x;
		LocalWorld.m[13] = position.y;
		LocalWorld.m[14] = position.z;
     	return LocalWorld;
	}

	public  function BoundingBoxInFrustum(b:BoundingBox):Bool 
	{
		return MinMaxInFrustum(b.minimum, b.maximum);
	}
	public  function TransformBoundingBoxInFrustum(b:BoundingBox):Bool 
	{
		return MinMaxInFrustum(b.minimumWorld, b.maximumWorld);
	}
	public  function CubeInFrustum(x:Float,y:Float,z:Float,size:Float):Bool 
	{
	   for (p in 0...6) 
		{
			if (frustumPlanes[p].normal.x * (x-size) + frustumPlanes[p].normal.y * (y-size) + frustumPlanes[p].normal.z * (z-size) + frustumPlanes[p].d > 0) continue;
			if (frustumPlanes[p].normal.x * (x+size)+ frustumPlanes[p].normal.y * (y-size) + frustumPlanes[p].normal.z *  (z-size) + frustumPlanes[p].d > 0) continue;	
		
			if (frustumPlanes[p].normal.x * (x-size) + frustumPlanes[p].normal.y * (y+size) + frustumPlanes[p].normal.z * (z-size) + frustumPlanes[p].d > 0) continue;
			if (frustumPlanes[p].normal.x * (x+size) + frustumPlanes[p].normal.y * (y+size) + frustumPlanes[p].normal.z * (z-size) + frustumPlanes[p].d > 0) continue;	
			
			if (frustumPlanes[p].normal.x * (x-size) + frustumPlanes[p].normal.y * (y-size) + frustumPlanes[p].normal.z * (z+size) + frustumPlanes[p].d > 0) continue;
			if (frustumPlanes[p].normal.x * (x+size) + frustumPlanes[p].normal.y * (y-size) + frustumPlanes[p].normal.z * (z+size) + frustumPlanes[p].d > 0) continue;	
			
			if (frustumPlanes[p].normal.x * (x-size) + frustumPlanes[p].normal.y * (y+size) + frustumPlanes[p].normal.z * (z+size) + frustumPlanes[p].d > 0) continue;
			if (frustumPlanes[p].normal.x * (x+size) + frustumPlanes[p].normal.y * (y+size) + frustumPlanes[p].normal.z * (z+size) + frustumPlanes[p].d > 0) continue;	
			return false;
        }
        return true;
    }
	public  function MinMaxInFrustum(min:Vector3, max:Vector3):Bool 
	{
	   for (p in 0...6) 
		{
			if (frustumPlanes[p].normal.x * min.x + frustumPlanes[p].normal.y * min.y + frustumPlanes[p].normal.z * min.z + frustumPlanes[p].d > 0) continue;
			if (frustumPlanes[p].normal.x * max.x + frustumPlanes[p].normal.y * min.y + frustumPlanes[p].normal.z * min.z + frustumPlanes[p].d > 0) continue;	
		
			if (frustumPlanes[p].normal.x * min.x + frustumPlanes[p].normal.y * max.y + frustumPlanes[p].normal.z * min.z + frustumPlanes[p].d > 0) continue;
			if (frustumPlanes[p].normal.x * max.x + frustumPlanes[p].normal.y * max.y + frustumPlanes[p].normal.z * min.z + frustumPlanes[p].d > 0) continue;	
			
			if (frustumPlanes[p].normal.x * min.x + frustumPlanes[p].normal.y * min.y + frustumPlanes[p].normal.z * max.z + frustumPlanes[p].d > 0) continue;
			if (frustumPlanes[p].normal.x * max.x + frustumPlanes[p].normal.y * min.y + frustumPlanes[p].normal.z * max.z + frustumPlanes[p].d > 0) continue;	
			
			if (frustumPlanes[p].normal.x * min.x + frustumPlanes[p].normal.y * max.y + frustumPlanes[p].normal.z * max.z + frustumPlanes[p].d > 0) continue;
			if (frustumPlanes[p].normal.x * max.x + frustumPlanes[p].normal.y * max.y + frustumPlanes[p].normal.z * max.z + frustumPlanes[p].d > 0) continue;	
			return false;
        }
        return true;
    }
		public  function SphereInFrustum(center:Vector3, r:Float):Bool 
	{
	   for (p in 0...6) 
		{
			if (frustumPlanes[p].normal.x * center.x + frustumPlanes[p].normal.y * center.y + frustumPlanes[p].normal.z * center.z + frustumPlanes[p].d <= -r) return false;
			
        }
        return true;
    }
		public  function PointInFrustum(center:Vector3):Bool 
	{
	   for (p in 0...6) 
		{
			if (frustumPlanes[p].normal.x * center.x + frustumPlanes[p].normal.y * center.y + frustumPlanes[p].normal.z * center.z + frustumPlanes[p].d <= 0) return false;
			
        }
        return true;
    }
    override    public function update()
	{
		/*
		    Bounding.reset(position);
			Bounding.addInternalVector(Vector3.Add(position, velocity));
			Bounding.minimum.x -= ellipse.x;
			Bounding.minimum.y -= ellipse.y;
			Bounding.minimum.z -= ellipse.z;
			Bounding.maximum.x += ellipse.x;
			Bounding.maximum.y += ellipse.y;
			Bounding.maximum.z += ellipse.z;
			*/
		   UpdateAbsoluteTransformation();
		
	
		
		
		if (parent != null)
		{
			var parentInvert:Matrix4 = Matrix4.Zero();
			parent.getAbsoluteTransformation().invertToRef(parentInvert);
			viewMatrix.append(parentInvert);
		}
		
		viewMatrix.invertToRef(viewMatrixInvert);
		this.Bounding.update(viewMatrixInvert, 1);
		extractPlanes();
		this.cameraRay = getRay();
	}
	
	private function extractPlanes():Void
	{
		if (frustumPlanes == null) 
		{
            frustumPlanes = Frustum.GetPlanes(getProjViewMatrix());
        } else {
            frustumPlanes = Frustum.GetPlanesToRef(getProjViewMatrix(),frustumPlanes);
        }
   	}
	
	 inline public function getWorldMatrix():Matrix4 
	 {
       
	
        viewMatrix.invertToRef(_worldMatrix);

        return this._worldMatrix;
	}
	public function getProjViewMatrix():Matrix4
	{
			 var ViewProj:Matrix4 = new Matrix4();
		     viewMatrix.multiplyToRef(projMatrix, ViewProj);
			 return ViewProj;
	}
	
	public function getRay():Ray
	{
		return Ray.CreateNew(Gdx.Instance().width / 2, Gdx.Instance().height / 2, Gdx.Instance().width, Gdx.Instance().height,  this.viewMatrix, this.projMatrix);
	}
	public function rayPick(x:Float,y:Float):Ray
	{
		return Ray.CreateNew(x, y, Gdx.Instance().width, Gdx.Instance().height,  this.viewMatrix, this.projMatrix);
	}	
	public function screenToWorld(screenPos:Vector3):Vector3
    {
     var worldPos = screenPos;
	 var port = Gdx.Instance().viewPort;
   return Vector3.UnprojectVector(worldPos, port.width, port.height, this.viewMatrix, this.projMatrix);
   
   }

   public function worldToScreen(worldPos:Vector3):Vector3
{
    var screenPos = worldPos;
	var port = Gdx.Instance().viewPort;
	screenPos.copyFrom(Vector3.Project(screenPos, Matrix4.Identity(), getProjViewMatrix(), port));
    screenPos.x = ( screenPos.x + 1 ) * (port.width/2);
    screenPos.y = ( - screenPos.y + 1) * (port.height/2);
    return screenPos;
}
}