package com.gdx.math;
import com.gdx.scene3d.buffer.Imidiatemode;

/**
 * ...
 * @author Luis Santos AKA DJOKER
 */
class Aabbox3d
{
public var MinEdge:Vector3;
public var MaxEdge:Vector3;




	public function new() 
	{
		MinEdge = new Vector3( 99999999, 99999999, 99999999);
		MaxEdge = new Vector3( -99999999, -99999999, -99999999);
/*
		edges = [];
		  var middle = getCenter();
			     var diag =  Vector3.Sub( middle , MaxEdge);
					 
			edges.push(new Vector3(middle.x + diag.x, middle.y + diag.y, middle.z + diag.z));
			edges.push(new Vector3(middle.x + diag.x, middle.y - diag.y, middle.z + diag.z));
			edges.push(new Vector3(middle.x + diag.x, middle.y + diag.y, middle.z - diag.z));
			edges.push(new Vector3(middle.x + diag.x, middle.y - diag.y, middle.z - diag.z));
			edges.push(new Vector3(middle.x - diag.x, middle.y + diag.y, middle.z + diag.z));
			edges.push(new Vector3(middle.x - diag.x, middle.y - diag.y, middle.z + diag.z));
			edges.push(new Vector3(middle.x - diag.x, middle.y + diag.y, middle.z - diag.z));
			edges.push(new Vector3(middle.x - diag.x, middle.y - diag.y, middle.z - diag.z));
		*/
	}
    public function set(min:Vector3,max:Vector3) 
	{
		MinEdge.copyFrom(min);
		MaxEdge.copyFrom(max);
		}
	public function getEdges (edges:Array<Vector3>):Void
	{
		
		// var edges:Array<Vector3> = [];
	
	             var middle = getCenter();
			     var diag =  Vector3.Sub( middle , MaxEdge);
					 
	        edges.push(new Vector3(middle.x + diag.x, middle.y + diag.y, middle.z + diag.z));
	        edges.push(new Vector3(middle.x + diag.x, middle.y - diag.y, middle.z + diag.z));
			edges.push(new Vector3(middle.x + diag.x, middle.y + diag.y, middle.z - diag.z));
			edges.push(new Vector3(middle.x + diag.x, middle.y - diag.y, middle.z - diag.z));
			edges.push(new Vector3(middle.x - diag.x, middle.y + diag.y, middle.z + diag.z));
			edges.push(new Vector3(middle.x - diag.x, middle.y - diag.y, middle.z + diag.z));
			edges.push(new Vector3(middle.x - diag.x, middle.y + diag.y, middle.z - diag.z));
			edges.push(new Vector3(middle.x - diag.x, middle.y - diag.y, middle.z - diag.z));
			
			//	return edges;
			
	}
	public function render(l:Imidiatemode,r:Float=1,g:Float=0,b:Float=1):Void
	{
		var edges:Array<Vector3> = [];
		getEdges(edges);
		
	l.lineVector(edges[5], edges[1], r,g,b,1);
	l.lineVector(edges[1], edges[3], r,g,b,1);
	l.lineVector(edges[3], edges[7],  r,g,b,1);
	l.lineVector(edges[7], edges[5],  r,g,b,1);
	l.lineVector(edges[0], edges[2],  r,g,b,1);
	l.lineVector(edges[2], edges[6],  r,g,b,1);
	l.lineVector(edges[6], edges[4], r,g,b,1);
	l.lineVector(edges[4], edges[0],  r,g,b,1);
	l.lineVector(edges[1], edges[0],  r,g,b,1);
	l.lineVector(edges[3], edges[2], r,g,b,1);
	l.lineVector(edges[7], edges[6],  r,g,b,1);
	l.lineVector(edges[5], edges[4],  r,g,b,1);
		
	}
    public function reset(v:Vector3) 
	{
		
		MaxEdge.copy(v);
		MinEdge.copy(v);
		
	}

	public function addInternalPoint(x:Float, y:Float,z:Float):Void
	{
		        if(x>MaxEdge.x) MaxEdge.x = x;
				if(y>MaxEdge.y) MaxEdge.y = y;
				if(z>MaxEdge.z) MaxEdge.z = z;

				if(x<MinEdge.x) MinEdge.x = x;
				if(y<MinEdge.y) MinEdge.y = y;
				if(z<MinEdge.z) MinEdge.z = z;
			
	
	}
	public function addInternalVector(v:Vector3):Void
	{
		 addInternalPoint(v.x, v.y, v.z);
	}
	
	public function addInternalBox(b:Aabbox3d):Void
	{
	addInternalVector(b.MaxEdge);
	addInternalVector(b.MinEdge);
	}
	public function getExtent():Vector3
	{
		return Vector3.Add(MaxEdge, MinEdge);
	}
	public function getCenter():Vector3
	{
		var Center:Vector3 = Vector3.zero;
		Center.x = (MinEdge.x + MaxEdge.x) / 2;
		Center.y = (MinEdge.y + MaxEdge.y) / 2;
		Center.z = (MinEdge.z + MaxEdge.z) / 2;

		return Center;
	}
	public function isEmpty():Bool
	{
		return MinEdge.equals(MaxEdge);
	}
	public function repair():Void
	{
		var t:Float = 0;

			if (MinEdge.x > MaxEdge.x)
				{ t=MinEdge.x; MinEdge.x = MaxEdge.x; MaxEdge.x=t; }
			if (MinEdge.y > MaxEdge.y)
				{ t=MinEdge.y; MinEdge.y = MaxEdge.y; MaxEdge.y=t; }
			if (MinEdge.z > MaxEdge.z)
			{ t=MinEdge.z; MinEdge.z = MaxEdge.z; MaxEdge.z=t; }
	}
		public function isPointInside(p:Vector3) :Bool
	{
			return (	p.x >= MinEdge.x && p.x <= MaxEdge.x &&
							p.y >= MinEdge.y && p.y <= MaxEdge.y &&
							p.z >= MinEdge.z && p.z <= MaxEdge.z);
			
	}
	public function isPointTotalInside(p:Vector3) :Bool
	{
			return (	p.x > MinEdge.x && p.x < MaxEdge.x &&
							p.y > MinEdge.y && p.y < MaxEdge.y &&
							p.z > MinEdge.z && p.z < MaxEdge.z);
	}
	public function isFullInside(other:Aabbox3d) :Bool
	{
				return (MinEdge.x >= other.MinEdge.x && MinEdge.y >= other.MinEdge.y && MinEdge.z >= other.MinEdge.z &&
				MaxEdge.x <= other.MaxEdge.x && MaxEdge.y <= other.MaxEdge.y && MaxEdge.z <= other.MaxEdge.z);
	
	}
	public function intersectsWithBox(other:Aabbox3d) :Bool
	{
				
			return (MinEdge.x <= other.MaxEdge.x && MinEdge.y <= other.MaxEdge.y && MinEdge.z <= other.MaxEdge.z &&
				MaxEdge.x >= other.MinEdge.x && MaxEdge.y >= other.MinEdge.y && MaxEdge.z >= other.MinEdge.z);
	
	
	}
}