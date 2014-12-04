package com.gdx.math;

/**
 * ...
 * @author djoekr
 */
class Triangle
{
  public var a:Vector3=Vector3.zero;
  public var b:Vector3=Vector3.zero;
  public var c:Vector3=Vector3.zero;
  public var normal:Vector3=Vector3.zero;
  
	public function new(v1:Vector3,v2:Vector3,v3:Vector3,vnormal:Vector3) 
	{
		a.copy(v1);
		b.copy(v2);
		c.copy(v3);
		normal.copy(vnormal);
		
	}
	
	public function  isTotalInsideBox( box:BoundingBox) :Bool
		{
			return (box.isPointInside(a) &&
				box.isPointInside(b) &&
				box.isPointInside(c));
		}
	public function toString():String
	{
		return a.toString() + "," + b.toString() + "," + c.toString()+ " :Normal:"+normal.toString();
	}
	public  function IsInFrustum( frustumPlanes:Array<Plane>):Bool 
	{
		
		var boundingVectors:Array<Vector3> = [];
		boundingVectors.push(a);
		boundingVectors.push(b);
		boundingVectors.push(c);
		
        for (p in 0...6) 
		{
            var inCount:Int = 8;

            for (i in 0...3) 
			{
                if (frustumPlanes[p].dotCoordinate(boundingVectors[i]) < 0) 
				{
                    --inCount;
                } else {
                    break;
                }
            }
            if (inCount == 0)
                return false;
        }
        return true;
    }
	
	public static function InFrontOf(p1:Triangle, p2:Triangle):Int
	{
		var  pos:Int;
		var neg:Int;
        var plane: Plane;
        var d:Float;
		
		plane = Plane.FromPoints(p2.a, p2.b, p2.c);
        pos = 0;
        neg = 0;

	 
  d = plane.DistanceTo(p1.a);
	  if (d < 0) { neg++; }    else { pos++; }
  d = plane.DistanceTo(p1.b);
	  if (d < 0) { neg++; }    else { pos++; }
  d = plane.DistanceTo(p1.c);
	  if (d < 0) { neg++; }    else { pos++; }
  
  if (pos == 3 ) return 1;
  else if (neg == 3) return -1;
  else return 0;
	}
}