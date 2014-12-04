package com.gdx.scene3d;
import com.gdx.math.Matrix4;
import com.gdx.math.Vector2;
import com.gdx.math.Vector3;
/**
 * ...
 * @author djoekr
 */
class FreeCamera extends Camera
{
	private var angleX:Float;
	private var angleY:Float;
	public var cross:Vector3;
	
	private var m_vStrafe:Vector3;
	private var mousePos:Vector2;
	private var lastMousePos:Vector2;
	
	
	
	public function new(scene:Scene,x:Float,y:Float,z:Float,lx:Float,ly:Float,lz:Float, id:Int = 0, name:String="Camera") 
	{
		super(scene,  id, name);
		angleX = 0;
		angleY = 0;
		cross = Vector3.Zero();
		m_vStrafe = Vector3.Zero();
		
		this.position.set(x, y, z);
		this.LookAt.set(lx, ly, lz);
		lastMousePos = Vector2.Zero();
		mousePos = Vector2.Zero();
	    update();
	}
	
	override public function update() 
	{
	    cross = Vector3.Cross(LookAt.subtract(position), up);
		m_vStrafe = Vector3.Normalize(cross);
		viewMatrix.setLookAtLH(position, LookAt, up); //   = Matrix4.LookAtLH(position, LookAt, up);
		super.update();
	}
	
    public function Strafe(speed:Float)
	{
	position.x += m_vStrafe.x * speed;
	position.z += m_vStrafe.z * speed;
 	LookAt.x += m_vStrafe.x * speed;
 	LookAt.z += m_vStrafe.z * speed;
	}
	  public function StrafeVelocity(speed:Float)
	{
	velocity.x += m_vStrafe.x * speed;
	velocity.z += m_vStrafe.z * speed;
 	LookAt.x += m_vStrafe.x * speed;
 	LookAt.z += m_vStrafe.z * speed;
	}
	public function Move( speed:Float, ignoreY:Bool = false )
	{

    var  vVector = LookAt.subtract(position);
	vVector = Vector3.Normalize(vVector);
	
	position.x += vVector.x * speed;
	position.z += vVector.z * speed;
	if(!ignoreY) position.y += vVector.y * speed;
	LookAt.x += vVector.x * speed;
 	LookAt.z += vVector.z * speed;
	if(!ignoreY) LookAt.y += vVector.y * speed;
	}
	public function MoveVelocity( speed:Float,ignoreY:Bool = false)
	{

    var  vVector = LookAt.subtract(position);
	vVector = Vector3.Normalize(vVector);
	
	velocity.x += vVector.x * speed;
	velocity.z += vVector.z * speed;
	if(!ignoreY) velocity.y += vVector.y * speed;
	LookAt.x += vVector.x * speed;
 	LookAt.z += vVector.z * speed;
	if(!ignoreY) LookAt.y += vVector.y * speed;
	}
	
	public function MouseLook(yawSpeed:Float=50,pitchSpeed:Float=100,smoth:Float=1)
	{
		var vAxis:Vector3 = Vector3.Zero();
		mousePos= Gdx.Instance().GetMouseSpeed();
		mousePos.normalize();
		
	
      angleX   = mousePos.x / yawSpeed * smoth;// Util.CurveValue(mousePos.x , angleX, smoth) / yawSpeed;
      angleY   = -mousePos.y / pitchSpeed * smoth;//  Util.CurveValue( -mousePos.y, angleY, smoth) / pitchSpeed;
	
	  angleX = Util.clamp(angleX, -1, 1);
	  angleY = Util.clamp(angleY, -1, 1);
	
	    vAxis= Vector3.Normalize(cross);
	    RotateView(angleY, vAxis.x, vAxis.y, vAxis.z);
		RotateView(angleX, 0, 1, 0);
		
	
		
	}
	public function Turn(yaw:Float,pitch:Float,roll:Float):Void
	{
		
	    
	    RotateView(Util.deg2rad(pitch),1,0,0);
		RotateView(Util.deg2rad(yaw), 0, 1, 0);
		RotateView(Util.deg2rad(roll), 0, 0, 1);
		
	
		
	}
	public function MouseLookLerp(yawSpeed:Float=50,pitchSpeed:Float=100,smoth:Float=1)
	{
		var vAxis:Vector3 = Vector3.Zero();
		mousePos= Gdx.Instance().GetMouseSpeed();
		mousePos.normalize();
		
	
      angleX   = Util.CurveValue(mousePos.x , angleX, smoth) / yawSpeed;
      angleY   =  Util.CurveValue( -mousePos.y, angleY, smoth) / pitchSpeed;
	
	//  angleX = Util.clamp(angleX, -1, 1);
	//  angleY = Util.clamp(angleY, -1, 1);
	
	    vAxis= Vector3.Normalize(cross);
	    RotateView(angleY, vAxis.x, vAxis.y, vAxis.z);
		RotateView(angleX, 0, 1, 0);
		
	
		
	}
	public function Rotate(yaw:Float,pitch:Float)
	{
		var vAxis:Vector3 = Vector3.Zero();
		
	  //angleX   = pitch;
      //angleY   = yaw;
	  angleX = Util.clamp(yaw, -1, 1);
	  angleY = Util.clamp(-pitch, -1, 1);
	
	    vAxis= Vector3.Normalize(cross);
	    RotateView(angleY, vAxis.x, vAxis.y, vAxis.z);
		RotateView(angleX, 0, 1, 0);
		
	
		
	}
	public function RotateView(angle:Float, x:Float, y:Float,  z:Float)
	{

	var vNewView:Vector3=Vector3.Zero();
	var vView:Vector3=Vector3.Zero();
    var cosTheta,sinTheta:Float=0;

    vView.x = LookAt.x - position.x;
	vView.y = LookAt.y - position.y;
	vView.z = LookAt.z - position.z;
	
	
	 cosTheta = Math.cos(angle);
 	 sinTheta = Math.sin(angle);
	
	vNewView.x = (cosTheta + (1 - cosTheta) * x * x)		* vView.x;
	vNewView.x = vNewView.x + ((1 - cosTheta) * x * y - z * sinTheta)	* vView.y;
	vNewView.x = vNewView.x + ((1 - cosTheta) * x * z + y * sinTheta)	* vView.z;
	
	vNewView.y = ((1 - cosTheta) * x * y + z * sinTheta)	* vView.x;
	vNewView.y =vNewView.y + (cosTheta + (1 - cosTheta) * y * y)		* vView.y;
	vNewView.y =vNewView.y + ((1 - cosTheta) * y * z - x * sinTheta)	* vView.z;
	
	vNewView.z = ((1 - cosTheta) * x * z - y * sinTheta)	* vView.x;
	vNewView.z =vNewView.z+ ((1 - cosTheta) * y * z + x * sinTheta)	* vView.y;
	vNewView.z =vNewView.z+ (cosTheta + (1 - cosTheta) * z * z)		* vView.z;
	
	LookAt.x = position.x + vNewView.x;
	LookAt.y = position.y + vNewView.y;
	LookAt.z = position.z + vNewView.z;
	rotation.set(LookAt.x, LookAt.y, LookAt.z);
	}
	
	
	
}