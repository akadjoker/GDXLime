package com.gdx.collision;
import com.gdx.math.Aabbox3d;
import com.gdx.math.BoundingBox;
import com.gdx.math.Triangle;
import com.gdx.math.Vector3;
import com.gdx.scene3d.buffer.Imidiatemode;

/**
 * ...
 * @author Luis Santos AKA DJOKER
 */

class OctreeTriangleSelector
{
     public var  Root:SOctreeNode;
	 public var NodeCount:Int;
	 public var MinimalPolysPerNode:Int;
	
	public function new(minimalPolysPerNode:Int) 
	{
		this.MinimalPolysPerNode = minimalPolysPerNode;
		this.NodeCount = 0;
		Root = new SOctreeNode();
		
	}
	public function AddTriangle(a:Vector3, b:Vector3, c:Vector3,n:Vector3):Void
	{
		Root.Triangles.push( new Triangle(a,b,c,n));
	}
	
	public function Build():Void
	{
		var maxTriangles:Int = Root.Triangles.length;
		var beginTime:Float = Gdx.Instance().getTimer();
		
	
		constructOctree(Root);
	
		
		var endTime:Float = Gdx.Instance().getTimer();
		var timepass:Float = endTime - beginTime;
		
		trace( "Needed " + timepass + ":ms to create OctTree .(" + NodeCount+ " nodes, "+maxTriangles+" polys)" );
	
	
	}
	
	private function constructOctree(node:SOctreeNode):Void
{
	++NodeCount;

	node.Box.reset(node.Triangles[0].a);

	// get bounding box
	var cnt:Int = node.Triangles.length;
	for( i in 0... cnt)
	{
		node.Box.addInternalVector(node.Triangles[i].a);
		node.Box.addInternalVector(node.Triangles[i].b);
		node.Box.addInternalVector(node.Triangles[i].c);
	}

	
	var middle:Vector3 = node.Box.getCenter();
	
	
	var edges:Array<Vector3> = [];
	 node.Box.getEdges(edges);
	 
	

	var box:BoundingBox = new BoundingBox(Vector3.zero,Vector3.zero);
	
	//var keepTriangles:Array<Triangle> = [];


	// calculate children

	if (!node.Box.isEmpty() && Std.int(node.Triangles.length) > MinimalPolysPerNode)
	for (ch in 0 ...8)
	{
	
		box.reset(middle);
		box.addInternalVector(edges[ch]);
		node.Child[ch] = new SOctreeNode();
 	  var i = 0;
        while (i < node.Triangles.length) 
		{
			
			 if (node.Triangles[i].isTotalInsideBox(box))
			{
				node.Child[ch].Triangles.push(node.Triangles[i]);
				node.Triangles.splice(i,1);
				//node.Triangles.remove(node.Triangles[i]);
						
				--i;
			} 
			++i;
		}

		if (node.Child[ch].Triangles.length<=0)
		{
			node.Child[ch].Triangles = null;
			node.Child[ch] = null;
		}
		else
			constructOctree(node.Child[ch]);
			
			
	}
	
}

public function traceSphere(triangles:Array<Triangle>,center:Vector3,radius:Float ):Bool
	{
		
		if (this.Root == null) return false;
	    var trianglesWritten:Int = 0;
	    return getTrianglesFromOctreeSphere(this.Root,triangles,trianglesWritten,center,radius);
	}
public function traceBoundigBox(triangles:Array<Triangle>,b:BoundingBox, lines:Imidiatemode ):Bool
	{
		
		if (this.Root == null) return false;
	    var trianglesWritten:Int = 0;
	    return getTrianglesFromOctreeBB(this.Root,triangles,trianglesWritten,b,lines);
	}
private function getTrianglesFromOctreeSphere(node:SOctreeNode,triangles:Array<Triangle>,trianglesWritten:Int,center:Vector3,radius:Float ):Bool
	{
		 var bResult:Bool = false;
		 if (node == null) return bResult;
		if(! BoundingBox.colideABBWithSphere(node.Box,center,radius))return bResult;
		 
	   for (i in 0 ... node.Triangles.length)
	   {
	     triangles[trianglesWritten] = node.Triangles[i];
		 ++trianglesWritten;
	   }

	for (i in 0...8)
	{
		if (node.Child[i] != null)
		{
			if (getTrianglesFromOctreeSphere(node.Child[i], triangles, trianglesWritten,center,radius)) bResult = true;
		}
	}
		
		
	
	return bResult;

	}	
private function getTrianglesFromOctreeBB(node:SOctreeNode,triangles:Array<Triangle>,trianglesWritten:Int,b:BoundingBox, lines:Imidiatemode ):Bool
	{
		 var bResult:Bool = false;
		 if (node == null) return bResult;
	     if (!b.intersectsWithBox(node.Box)) return bResult;
		 
	   for (i in 0 ... node.Triangles.length)
	   {
	     triangles[trianglesWritten] = node.Triangles[i];
		 ++trianglesWritten;
	   }

	for (i in 0...8)
	{
		if (node.Child[i] != null)
		{
			if (getTrianglesFromOctreeBB(node.Child[i], triangles, trianglesWritten, b,lines)) bResult = true;
		}
	}
		
		
	
	return bResult;

	}
private function traceBoxDebug(b:BoundingBox,node:SOctreeNode,l:Imidiatemode):Void
{
	if (node == null) return;
	if (!b.intersectsWithBox(node.Box)) return;
	
	for (i in 0 ... node.Triangles.length)
	{
		var t:Triangle = node.Triangles[i];
		l.drawTriangle(t.a, t.b, t.c, 0, 1, 0, 1);
		
	}
	
	//node.Box.calculate();
	node.Box.render(l);
	
	for (i in 0...8)
	{
		if (node.Child[i] != null)
		{
			traceBoxDebug(b,node.Child[i],l);
		}
	}
}
public function Debug(b:BoundingBox,l:Imidiatemode):Void
{
	if (this.Root == null) return;
	traceBoxDebug(b,this.Root, l);
}
	
}

class SOctreeNode
{
	
	public var Child:Array<SOctreeNode>;
	public var Box:BoundingBox;
	public var Triangles:Array<Triangle>;
	public function new() 
	{
		Child = [];
		Triangles = [];
		Box = new BoundingBox(new Vector3(999999,999999,999999),new Vector3(-999999,-999999,-999999));
	}
	
}