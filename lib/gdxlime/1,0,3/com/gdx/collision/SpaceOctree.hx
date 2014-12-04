package com.gdx.collision;
import com.gdx.math.BoundingBox;
import com.gdx.math.BoundingInfo;
import com.gdx.math.Plane;
import com.gdx.math.Ray;
import com.gdx.math.Vector3;
import com.gdx.scene3d.buffer.Imidiatemode;
import com.gdx.scene3d.Node;

/**
 * ...
 * @author Luis Santos AKA DJOKER
 */
class SpaceOctree 
{
    public static var numNodes:Int = 0;
	public static var numSurfaces:Int = 100;
	public static var numaAddSurfaces:Int = 0;
	
	public var blocks:Array<SpaceBlock>;
	public var _maxBlockCapacity:Int;
	public var _selection:Array<SpaceBlock>;
	public var _maxDepth:Int;
	public var _minPoint:Vector3;
	public var _maxPoint:Vector3;		
	public var Bounding:BoundingInfo;
	
	
	

	public function new(maxBlockCapacity:Int = 64,maxDepth:Int=2) 
	{

		this.blocks = [];
		this._maxDepth = maxDepth;
        this._maxBlockCapacity = maxBlockCapacity;
        this._selection = [];// 
	     SpaceOctree.numNodes = 0;
		 SpaceOctree.numSurfaces = 0;
		 SpaceOctree.numNodes = 0;
		 SpaceOctree.numaAddSurfaces = 0;
	}


	
	public function Build(worldMin:Vector3, worldMax:Vector3) 
	{
		this._minPoint = worldMin;
		this._maxPoint = worldMax;
		Bounding = new BoundingInfo(worldMin, worldMax);
        SpaceOctree.CreateBlocks(worldMin, worldMax,  this._maxBlockCapacity, 0, this._maxDepth, this);
		
    }

	
	public function select(frustumPlanes:Array<Plane>):Array<SpaceBlock> 
	{ 

        for (index in 0...this.blocks.length) {
            var block:SpaceBlock = this.blocks[index];
          //  block.select(frustumPlanes, this._selection);
        }

        return this._selection;
    }
	
	public static function CreateBlocks(worldMin:Vector3, worldMax:Vector3,maxBlockCapacity:Int,currentDepth:Int, maxDepth:Int, target:Dynamic) 
	{
        target.blocks = [];
        var blockSize = new Vector3((worldMax.x - worldMin.x) / 2, (worldMax.y - worldMin.y) / 2, (worldMax.z - worldMin.z) / 2);

        // Segmenting space
        for (x in 0...2) {
            for (y in 0...2) {
                for (z in 0...2) {
                    var localMin:Vector3 = worldMin.add(blockSize.multiplyByFloats(x, y, z));
                    var localMax:Vector3 = worldMin.add(blockSize.multiplyByFloats(x + 1, y + 1, z + 1));

                    var block:SpaceBlock = new SpaceBlock(localMin, localMax, maxBlockCapacity, currentDepth + 1, maxDepth);
					block.createInner();
                    target.blocks.push(block);
                }
            }
        }
    }
	
		public function renderLines(lines:Imidiatemode):Void
	{
		this.Bounding.boundingBox.renderColor(lines, 1, 1, 0);
		 for (index in 0...this.blocks.length) 
		{
            var block:SpaceBlock = this.blocks[index];
          block.renderLines(lines);
        }
	}
	
	
	
}

class SpaceBlock
{

	public var _capacity:Int;
	public var _depth:Int;
	public var _maxDepth:Int;
	public var _minPoint:Vector3;
	public var _maxPoint:Vector3;
	public var abb:BoundingInfo;
	public var _boundingVectors:Array<Vector3>;
	private var entries:Int = 0;
//	public var entries:Array<Node>;
	
	public var blocks:Array<SpaceBlock>;	
	

	public function new(minPoint:Vector3, maxPoint:Vector3, capacity:Int, depth:Int, maxDepth:Int) 
	{
		trace(SpaceOctree.numNodes);
		SpaceOctree.numNodes++;
		
		abb = new BoundingInfo(minPoint, maxPoint);
		
    //    this.entries = [];
        this._capacity = capacity;
		this._maxDepth = maxDepth;
		this._depth = depth;
		


        this._minPoint = minPoint;
        this._maxPoint = maxPoint;
        
        this._boundingVectors = [];

        this._boundingVectors.push(minPoint.clone());
        this._boundingVectors.push(maxPoint.clone());

        this._boundingVectors.push(minPoint.clone());
        this._boundingVectors[2].x = maxPoint.x;

        this._boundingVectors.push(minPoint.clone());
        this._boundingVectors[3].y = maxPoint.y;

        this._boundingVectors.push(minPoint.clone());
        this._boundingVectors[4].z = maxPoint.z;

        this._boundingVectors.push(maxPoint.clone());
        this._boundingVectors[5].z = minPoint.z;

        this._boundingVectors.push(maxPoint.clone());
        this._boundingVectors[6].x = minPoint.x;

        this._boundingVectors.push(maxPoint.clone());
        this._boundingVectors[7].y = minPoint.y;
	}
	
	public function addEntry(entry:Node)
	{
		
     
		   //  if (this.entries.length > this._capacity && this._depth < this._maxDepth) 
		     if (this._depth < this._maxDepth) 
		    {
                this.createInnerBlocks();
	        }
		
    }
	
	public function createInner()
	{
	
		entries++;
	//	trace(SpaceOctree.numaAddSurfaces);
		SpaceOctree.numaAddSurfaces++;

		   //  if (this.entries.length > this._capacity && this._depth < this._maxDepth) 
		  //   if (entries> this._capacity && this._depth < this._maxDepth) 
		     if ( this._depth < this._maxDepth) 
			//if (SpaceOctree.numaAddSurfaces < 8)
		    {
				//SpaceOctree.numaAddSurfaces = 0;
                this.createInnerBlocks();
	        }
		
    }
	
	
	
	public function renderLines(lines:Imidiatemode):Void
	{
        if (this.blocks != null && this.blocks.length > 0)
		{
            for (index in 0...this.blocks.length) 
			{
                var block:SpaceBlock = this.blocks[index];
			    block.renderLines(lines);
            }
        } else 
		{
			this.abb.boundingBox.render(lines);
        }
    }
	
	
	public function createInnerBlocks():Void
	{		
		SpaceOctree.CreateBlocks(this._minPoint, this._maxPoint, this._capacity, this._depth, this._maxDepth, this);
	}

	
	
    
	
}