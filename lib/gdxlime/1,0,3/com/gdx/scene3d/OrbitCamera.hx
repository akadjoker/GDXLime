package com.gdx.scene3d;
import com.gdx.math.Matrix4;
import com.gdx.math.Quaternion;
import com.gdx.math.Vector2;
import com.gdx.math.Vector3;

/**
 * ...
 * @author Luis Santos AKA DJOKER
 */
class OrbitCamera extends Camera
{
public var target:SceneNode;
public var offset:Vector3;
public var yaw:Float;
public var pitch:Float;

	public function new(scene:Scene,offset:Vector3, id:Int=0, name:String="Camera") 
	{
		
		super(scene, id, name);
		this.offset = offset;
		yaw = 0;
		pitch = 0;
	}

	public function setTarget( obj:SceneNode):Void
	{
		this.target = obj;
		viewMatrix   = Matrix4.LookAtLH(obj.position.add(offset), obj.position, up);
	}
	
	override public function update() 
	{
		if (target == null)
		{
			super.update();
		  return;
		}
		
		var mousePos:Vector2 = Gdx.Instance().GetMouseSpeed();
		mousePos.normalize();
			
		var yawSpeed:Float = 50;
		var pitchSpeed:Float = 100;
		
           yaw    = Util.CurveValue(mousePos.x , yaw  , 1 * Gdx.Instance().fixedTime) / yawSpeed;
           pitch =  Util.CurveValue(mousePos.y , pitch, 1 * Gdx.Instance().fixedTime) / pitchSpeed;

		   var quatYaw:Quaternion = Quaternion.CreateFromAngleAxis(yaw, new Vector3(0, 1, 0));
		    offset=Vector3.TransformByQuaternion(offset,quatYaw);
	        up = Vector3.TransformByQuaternion(up, quatYaw );
			var forward:Vector3 = new Vector3( -offset.x, -offset.y, -offset.z);
			forward.normalize();
			
			var left:Vector3 = Vector3.Cross(up, forward);
			left.normalize();
			
			var quatPitch:Quaternion = Quaternion.CreateFromAngleAxis(pitch, left);
		    offset=Vector3.TransformByQuaternion(offset,quatPitch);
	        up = Vector3.TransformByQuaternion(up, quatPitch );
			
	
			viewMatrix   = Matrix4.LookAtLH(target.position.add(offset), target.position, up);
		   
		super.update();
	}
	
}