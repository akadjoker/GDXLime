package com.gdx.scene3d.particles;
import com.gdx.math.Vector3;

/**
 * ...
 * @author Luis Santos AKA DJOKER
 */
class Decale extends Sprite3D
{
    public var right:Vector3;
	public var up:Vector3;
	 public function new (Id:Int) 
	{
	    super(Id);
		active = false;
		frame = 16;
		type = 4;
		
		
	}
	override public function reset () 
	{
	 active = true;	
	 alpha = 1;
	 life = 5;
	 
	}
	public function setPoint(n:Vector3,p:Vector3,size:Float):Void 
	{
		reset();
	//	trace(n.toString());
		var factor:Float = 0.02;
		p.x += n.x * factor;
		p.y += n.y * factor;
		p.z += n.z * factor;
		
		this.size = size;
		this.right = new Vector3(0, 0, 0);
		
		var axis:Array<Vector3> = [];
		axis.push(new Vector3(1, 0, 0));
		axis.push(new Vector3(0, 1, 0));
		axis.push(new Vector3(0, 0, 1));
		
		 var poly_normal:Vector3=new Vector3(Math.abs(n.x), Math.abs(n.y),Math.abs(n.z));
         poly_normal.normalize();
	
   var temp:Vector3 = Vector3.zero;
    var major:Int;

    if (poly_normal.x > poly_normal.y && poly_normal.x > poly_normal.z)
        major = 0;
    else if (poly_normal.y > poly_normal.x && poly_normal.y > poly_normal.z)
        major = 1;
    else
        major = 2;

    // build right vector by hand
    if (poly_normal.x == 1.0 || poly_normal.y == 1.0 || poly_normal.z == 1.0)
    {
        if ((major == 0 && n.x > 0.0) || major == 1)
            right.set(0.0, 0.0, -1.0);
        else if (major == 0)
            right.set(0.0, 0.0, 1.0);
        else
            right.set(1.0 * n.z, 0.0, 0.0);
    }
    else
    {
		axis[major] = Vector3.Cross(axis[major], n);
		right.copyFrom(axis[major]);
       
    }

    temp.x = -n.x;
    temp.y = -n.y;
    temp.z = -n.z;
    up=Vector3.Cross(temp,right);
    up.normalize();
    right.normalize();		
    this.position.set(p.x, p.y, p.z);
	}
	override public function move (dt:Float) 
	{
		if (!active) return;
		life-=  dt;
		if (life <= 0) active = false;
	
		
	}
	
}