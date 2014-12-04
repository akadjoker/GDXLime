package com.gdx.collision;

import com.gdx.math.BoundingInfo;
import com.gdx.math.Vector3;
import com.gdx.scene3d.buffer.Imidiatemode;

/**
 * ...
 * @author Luis Santos AKA DJOKER
 */
class QuadTree
{

	public  static var numNodes:Int = 0;
	
	private   var g_CurrentSubdivision:Int = 0;
	private   var g_MaxTriangles:Int;

// The maximum amount of subdivisions allow (Levels of subdivision)
	private   var g_MaxSubdivisions:Int;

// The amount of end nodes created in the octree (That hold vertices)
	private   var g_EndNodeCount:Int=0;




	   public static inline  var LEFT_FRONT:Int = 0;
	   public static inline   var LEFT_BACK:Int = 1;
	   public static inline  var RIGHT_BACK:Int = 2;
	   public static inline   var RIGHT_FRONT:Int = 3;

	public var m_bSubDivided:Bool;

	// This is the size of the cube for this current node
	public var m_Width:Float;

	// This holds the amount of triangles stored in this node
	public var m_TriangleCount:Int;

	// This is the center (X, Y, Z) point in this node
	public var m_vCenter:Vector3;
	
	public var bounding:BoundingInfo;
	
	public var m_pVertices:Array<Vector3>;
	
	public var m_pOctreeNodes:Array<QuadTree>;
	
	
	public function new(MaxTriangles:Int,MaxSubdivisions:Int) 
	{
		g_MaxSubdivisions = MaxSubdivisions;
		g_MaxTriangles = MaxTriangles;
		m_pVertices = [];
		m_pOctreeNodes = [];
		m_bSubDivided = false;

	// Set the dimensions of the box to false
	m_Width = 0; 

	// Initialize the triangle count
	m_TriangleCount = 0;

	// Initialize the center of the box to the 0
	m_vCenter = Vector3.zero;
	g_CurrentSubdivision = 0;

	}
	public function build(pVertices:Array<Vector3>):Void
	{
	var beginTime:Float = Gdx.Instance().getTimer();
		
		GetSceneDimensions(pVertices);
		CreateNode(pVertices, pVertices.length, m_vCenter, m_Width);
		
		var endTime:Float = Gdx.Instance().getTimer();
		var timepass:Float = endTime - beginTime;
		
		trace( "Needed " + timepass + ":ms to create Quadtree .(" + QuadTree.numNodes + " nodes.");	
	}
	public function GetSceneDimensions(pVertices:Array<Vector3>):Void
{
	
	// Initialize some temporary variables to hold the max dimensions found
	var maxWidth:Float = 0; 
	var maxHeight:Float = 0;
	var maxDepth :Float = 0;

	
	
	var numberOfVerts:Int = pVertices.length;
	
	// Go through all of the vertices and add them up to eventually find the center
	for(i in 0 ... numberOfVerts )
	{
		// Add the current vertex to the center variable (Using operator overloading)
		m_vCenter.x = m_vCenter.x + pVertices[i].x;
		m_vCenter.y = m_vCenter.y + pVertices[i].y;
		m_vCenter.z = m_vCenter.z + pVertices[i].z;
	}

	// Divide the total by the number of vertices to get the center point.
	// We could have overloaded the / symbol but I chose not to because we rarely use it.
	m_vCenter.x /= numberOfVerts;
	m_vCenter.y /= numberOfVerts;	
	m_vCenter.z /= numberOfVerts;


	// Go through all of the vertices and find the max dimensions
	for(i in 0 ... numberOfVerts)
	{
		// Get the current dimensions for this vertex.  We use the fabsf() function
		// to get the floating point absolute value because it might return a negative number.
		var currentWidth:Float  = Math.abs(pVertices[i].x - m_vCenter.x);	
		var currentHeight:Float = Math.abs(pVertices[i].y - m_vCenter.y);		
		var currentDepth:Float  = Math.abs(pVertices[i].z - m_vCenter.z);	

		// Check if the current width value is greater than the max width stored.
		if(currentWidth  > maxWidth)	maxWidth  = currentWidth;

		// Check if the current height value is greater than the max height stored.
		if(currentHeight > maxHeight)	maxHeight = currentHeight;

		// Check if the current depth value is greater than the max depth stored.
		if(currentDepth > maxDepth)		maxDepth  = currentDepth;
	}

	// Set the member variable dimensions to the max ones found.
	// We multiply the max dimensions by 2 because this will give us the
	// full width, height and depth.  Otherwise, we just have half the size
	// because we are calculating from the center of the scene.
	maxWidth *= 2;		maxHeight *= 2;		maxDepth *= 2;

	// Check if the width is the highest value and assign that for the cube dimension
	if(maxWidth > maxHeight && maxWidth > maxDepth)
		m_Width = maxWidth;

	// Check if the height is the heighest value and assign that for the cube dimension
	else if(maxHeight > maxWidth && maxHeight > maxDepth)
		m_Width = maxHeight;

	// Else it must be the depth or it's the same value as some of the other ones
	else
		m_Width = maxDepth;
		
		
	//trace(this.m_vCenter.toString()+" + " + m_Width);
 }

 
 public function GetNewNodeCenter( vCenter:Vector3,  width:Float, nodeID:Int):Vector3
{
		// Initialize the new node center
	var vNodeCenter:Vector3 = Vector3.zero;

	// Create a dummy variable to cut down the code size
	 var vCtr:Vector3 = vCenter;
	 var height:Float = 0;

	// Switch on the ID to see which subdivided node we are finding the center
	switch nodeID 
	{
		case QuadTree.LEFT_FRONT:
			vNodeCenter = new Vector3(vCtr.x - width/4, 0 , vCtr.z + width/4);


		case QuadTree.LEFT_BACK:
			vNodeCenter = new Vector3(vCtr.x - width/4, 0 , vCtr.z - width/4);


		case QuadTree.RIGHT_BACK:
			vNodeCenter = new Vector3(vCtr.x + width/4,0 , vCtr.z - width/4);


		case QuadTree.RIGHT_FRONT:
			vNodeCenter = new Vector3(vCtr.x + width/4, 0 , vCtr.z + width/4);
	

		

	}

	// Return the new node center
	return vNodeCenter;
}
/////	This allocates memory for the vertices to assign to the current end node

public function AssignVerticesToNode(pVertices:Array<Vector3>,  numberOfVerts:Int):Void
{
	// Since we did not subdivide this node we want to set our flag to false
	m_bSubDivided = false;

	// Initialize the triangle count of this end node (total verts / 3 = total triangles)
	m_TriangleCount = Std.int(numberOfVerts / 3);


	m_pVertices = [];// new CVector3 [numberOfVerts];


	for (i in 0 ... numberOfVerts)
	{
		m_pVertices.push(pVertices[i]);
		
	}

	QuadTree.numNodes++;
	g_EndNodeCount++;
}



public function CreateNewNode(pVertices:Array<Vector3>,pList:Array<Bool>,numberOfVerts:Int, vCenter:Vector3 ,width:Float,  triangleCount:Int,nodeID:Int ):Void
{
	
		// Allocate memory for the triangles found in this node (tri's * 3 for vertices)
		var pNodeVertices:Array<Vector3> =  [];

		// Create an counter to count the current index of the new node vertices
		var index:Int = 0;

		// Go through all the vertices and assign the vertices to the node's list
		for(i in 0 ... pVertices.length )
		{
			// If this current triangle is in the node, assign it's vertices to it
			if(pList[Std.int(i / 3)])	
			{
				pNodeVertices[index] = pVertices[i];
				index++;
			}
		}

	
		// Allocate a new node for this octree
		m_pOctreeNodes[nodeID] = new QuadTree(g_MaxTriangles,g_MaxSubdivisions);

		// Get the new node's center point depending on the nodexIndex (which of the 8 subdivided cubes).
		var vNodeCenter:Vector3 = GetNewNodeCenter(vCenter, width, nodeID);
		
		// Below, before and after we recurse further down into the tree, we keep track
		// of the level of subdivision that we are in.  This way we can restrict it.

		// Increase the current level of subdivision
		g_CurrentSubdivision++;
		//trace(Octree.g_CurrentSubdivision);

		// Recurse through this node and subdivide it if necessary
		m_pOctreeNodes[nodeID].CreateNode(pNodeVertices, triangleCount * 3, vNodeCenter, width / 2);

		// Decrease the current level of subdivision
		g_CurrentSubdivision--;

		// Free the allocated vertices for the triangles found in this node
	  pNodeVertices = null;
	}
	/////	This is our recursive function that goes through and subdivides our nodes
/////
///////////////////////////////// CREATE NODE \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*

	public function CreateNode(pVertices:Array<Vector3>, numberOfVerts:Int,  vCenter:Vector3, width:Float):Void
{
	
	// Create a variable to hold the number of triangles
	var numberOfTriangles = Std.int(numberOfVerts / 3);

	// Initialize this node's center point.  Now we know the center of this node.
	m_vCenter = vCenter;

	// Initialize this nodes cube width.  Now we know the width of this current node.
	m_Width = width;
	 
	    var min:Vector3 = new Vector3(m_vCenter.x - m_Width / 2,  m_vCenter.y- m_Width / 2, m_vCenter.z - m_Width / 2);
		var max:Vector3 = new Vector3(m_vCenter.x + m_Width / 2,  m_vCenter.y+ m_Width / 2, m_vCenter.z + m_Width / 2);
		
		bounding = new BoundingInfo(min, max);
	
	

	if( (numberOfTriangles > g_MaxTriangles) && (g_CurrentSubdivision < g_MaxSubdivisions) )
	{
			m_bSubDivided = true;

			var  pList1:Array<Bool> = [];		
		var  pList2:Array<Bool> = [];		
		var  pList3:Array<Bool> = [];		
		var  pList4:Array<Bool> = [];		
	
		var vCtr:Vector3 = vCenter;

		for(i in 0... numberOfVerts)
		{
			// Create some variables to cut down the thickness of the code (easier to read)
			var vPoint:Vector3 = pVertices[i];

			// Check if the point lines within the  LEFT FRONT node
			if( (vPoint.x <= vCtr.x) &&   (vPoint.z >= vCtr.z) ) 
				pList1[Std.int(i / 3)] = true;

			// Check if the point lines within the  LEFT BACK node
			if( (vPoint.x <= vCtr.x) &&  (vPoint.z <= vCtr.z) ) 
				pList2[Std.int(i / 3)] = true;

			// Check if the point lines within the  RIGHT BACK node
			if( (vPoint.x >= vCtr.x) &&  (vPoint.z <= vCtr.z) ) 
				pList3[Std.int(i / 3)] = true;

			// Check if the point lines within the  RIGHT FRONT node
			if( (vPoint.x >= vCtr.x) &&  (vPoint.z >= vCtr.z) ) 
				pList4[Std.int(i / 3)] = true;
	

		



		}	

		var triCount1:Int = 0;	var triCount2:Int = 0;	var triCount3:Int = 0;	var triCount4:Int = 0;
		
		// Go through each of the lists and increase the triangle count for each node.
		for(i in 0... numberOfTriangles)  
		{
			// Increase the triangle count for each node that has a "true" for the index i.
			if(pList1[i])	triCount1++;	if(pList2[i])	triCount2++;
			if(pList3[i])	triCount3++;	if(pList4[i])	triCount4++;
	
		}
	
		CreateNewNode(pVertices, pList1, numberOfVerts, vCenter, width, triCount1, QuadTree.LEFT_FRONT);
		CreateNewNode(pVertices, pList2, numberOfVerts, vCenter, width, triCount2, QuadTree.LEFT_BACK);
		CreateNewNode(pVertices, pList3, numberOfVerts, vCenter, width, triCount3, QuadTree.RIGHT_BACK);
		CreateNewNode(pVertices, pList4, numberOfVerts, vCenter, width, triCount4, QuadTree.RIGHT_FRONT);

	}
	else
	{
			AssignVerticesToNode(pVertices, numberOfVerts);
	}
}

public function DrawOctree(pNode:QuadTree,lines:Imidiatemode):Void
{
	bounding.boundingBox.render(lines);
	if(pNode==null) return;
	if(pNode.m_bSubDivided)
	{
		DrawOctree(pNode.m_pOctreeNodes[ QuadTree.LEFT_FRONT],lines);
		DrawOctree(pNode.m_pOctreeNodes[ QuadTree.LEFT_BACK],lines);
		DrawOctree(pNode.m_pOctreeNodes[ QuadTree.RIGHT_BACK],lines);
		DrawOctree(pNode.m_pOctreeNodes[ QuadTree.RIGHT_FRONT],lines);
    }
	else
	{
     pNode.bounding.boundingBox.render(lines);
	}
}

}

