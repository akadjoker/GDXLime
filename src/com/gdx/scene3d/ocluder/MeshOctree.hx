package com.gdx.scene3d.ocluder;

import com.gdx.math.BoundingBox;
import com.gdx.math.BoundingInfo;
import com.gdx.math.Plane;
import com.gdx.math.Ray;
import com.gdx.math.Vector3;
import com.gdx.scene3d.buffer.Imidiatemode;

/**
 * ...
 * @author Luis Santos AKA DJOKER
 */
class MeshOctree 
{
    public static var numNodes:Int = 0;
	public static var numSurfaces:Int = 0;
	public static var numaAddSurfaces:Int = 0;
	
	public var blocks:Array<MeshBlock>;
	public var _maxBlockCapacity:Int;
	public var _selection:Array<MeshBlock>;
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
	     MeshOctree.numNodes = 0;
		 MeshOctree.numSurfaces = 0;
		 MeshOctree.numNodes = 0;
		 MeshOctree.numaAddSurfaces = 0;
	}


	
	public function Build(worldMin:Vector3, worldMax:Vector3, entries:Array<Mesh>) 
	{
		this._minPoint = worldMin;
		this._maxPoint = worldMax;
		Bounding = new BoundingInfo(worldMin, worldMax);
	//	trace(worldMin.toString());
	//	trace(worldMax.toString());
        MeshOctree.CreateBlocks(worldMin, worldMax, entries, this._maxBlockCapacity, 0, this._maxDepth, this);
		
    }

	
	public function select(frustumPlanes:Array<Plane>):Array<MeshBlock> 
	{ 

        for (index in 0...this.blocks.length) {
            var block:MeshBlock = this.blocks[index];
            block.select(frustumPlanes, this._selection);
        }

        return this._selection;
    }
	
	public static function CreateBlocks(worldMin:Vector3, worldMax:Vector3, meshes:Array<Mesh>, maxBlockCapacity:Int,currentDepth:Int, maxDepth:Int, target:Dynamic) 
	{
        target.blocks = [];
        var blockSize = new Vector3((worldMax.x - worldMin.x) / 2, (worldMax.y - worldMin.y) / 2, (worldMax.z - worldMin.z) / 2);

        // Segmenting space
        for (x in 0...2) {
            for (y in 0...2) {
                for (z in 0...2) {
                    var localMin:Vector3 = worldMin.add(blockSize.multiplyByFloats(x, y, z));
                    var localMax:Vector3 = worldMin.add(blockSize.multiplyByFloats(x + 1, y + 1, z + 1));

                    var block:MeshBlock = new MeshBlock(localMin, localMax, maxBlockCapacity, currentDepth + 1, maxDepth);
					block.parent = target;
                    block.addEntries(meshes);
                    target.blocks.push(block);
                }
            }
        }
    }
	
		public function renderLines(lines:Imidiatemode):Void
	{
		 for (index in 0...this.blocks.length) 
		{
            var block:MeshBlock = this.blocks[index];
           block.renderLines(lines);
        }
	}
	public function cullNodes(camera:Camera, lines:Imidiatemode):Void
	{
	
	    for (index in 0...this.blocks.length) 
		{
            var block:MeshBlock = this.blocks[index];
            block.cullNodes(camera,lines);
        }
	}
	public function renderNodes(camera:Camera,lines:Imidiatemode):Void
	{
		  for (index in 0...this.blocks.length) 
		{
            var block:MeshBlock = this.blocks[index];
            block.renderNodes(camera,lines);
        }
	}
	public function intersectsRay(camera:Camera,ray:Ray,lines:Imidiatemode):Void
	{
	
	this.Bounding.boundingBox.renderColor(lines, 1, 1, 1);
		
		
	    for (index in 0...this.blocks.length) 
		{
            var block:MeshBlock = this.blocks[index];
            block.intersectsRay(camera,ray,lines);
        }
	}
}

class MeshBlock
{

	public var entries:Array<Mesh>;
	public var _capacity:Int;
	public var _depth:Int;
	public var _maxDepth:Int;
	public var _minPoint:Vector3;
	public var _maxPoint:Vector3;
	public var abb:BoundingInfo;
	public var _boundingVectors:Array<Vector3>;
	public var parent:MeshOctree;
	
	public var blocks:Array<MeshBlock>;	
	

	public function new(minPoint:Vector3, maxPoint:Vector3, capacity, depth:Int, maxDepth:Int) 
	{
		MeshOctree.numNodes++;
		
		abb = new BoundingInfo(minPoint, maxPoint);
		
        this.entries = [];
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
	
	public function addEntry(entry:Mesh)
	{
		if (entry.tag3 == 100) return;

		entry.UpdateBoundingBox();
		
		if (this.blocks != null)
		{
			for (i in 0...this.blocks.length)
			{
				var block = this.blocks[i];
				block.addEntry(entry);
			}
			return;
		}
       
		if (entry.Bounding.boundingBox.intersectsMinMax(this._minPoint,this._maxPoint)) 
		{
       		 entries.push(entry);
			 entry.tag3 = 100;
		     MeshOctree.numaAddSurfaces++;
			
         }
			

		     if (this.entries.length > this._capacity && this._depth < this._maxDepth) 
		    {
                this.createInnerBlocks();
	        }
    }
	
	public function addEntries(meshes:Array<Mesh>)
	{
        for (index in 0...meshes.length)
		{
            var mesh = meshes[index];
            this.addEntry(mesh);
        }       
    }
	
	
	
	public function select(frustumPlanes:Array<Plane>, selection:Array<MeshBlock>) {
        if (this.blocks != null && this.blocks.length > 0) {
            for (index in 0...this.blocks.length) {
                var block:MeshBlock = this.blocks[index];
                block.select(frustumPlanes, selection);
            }
        } else if (BoundingBox.IsInFrustum(this._boundingVectors, frustumPlanes)) {
            selection.push(this);
        }
    }
	
	public function renderLines(lines:Imidiatemode):Void
	{
        if (this.blocks != null && this.blocks.length > 0)
		{
            for (index in 0...this.blocks.length) 
			{
                var block:MeshBlock = this.blocks[index];
			    block.renderLines(lines);
            }
        } else 
		{
			this.abb.boundingBox.render(lines);
        }
    }
	
	public function createInnerBlocks():Void
	{
	MeshOctree.CreateBlocks(this._minPoint, this._maxPoint, this.entries, this._capacity, this._depth, this._maxDepth, this);
	}

	
	public function cullNodes(camera:Camera,lines:Imidiatemode):Void
	{
		
		if (this.blocks != null && this.blocks.length > 0)
		{
            for (index in 0...this.blocks.length) 
			{
                var block:MeshBlock = this.blocks[index];
			    block.cullNodes(camera,lines);
            }
        } else 
		{
			
			if (this.abb.isInFrustrum(camera.frustumPlanes))
			{
				for (i in 0 ... this.entries.length)
				{
					var m:Mesh = this.entries[i];
					m.Visible = true;
				}
			} else
			{
				for (i in 0 ... this.entries.length)
				{
					var m:Mesh = this.entries[i];
					m.Visible = false;
				}
			}
			
        }
			
	
	}
	
	public function renderNodes(camera:Camera,lines:Imidiatemode):Void
	{
		
		if (this.blocks != null && this.blocks.length > 0)
		{
            for (index in 0...this.blocks.length) 
			{
                var block:MeshBlock = this.blocks[index];
			    block.renderNodes(camera,lines);
            }
        } else 
		{
			
			if (this.abb.isInFrustrum(camera.frustumPlanes))
			{
				for (i in 0 ... this.entries.length)
				{
					var m:Mesh = this.entries[i];
					m.update();
					m.render(camera);
				}
			} 
			
        }
			
	
	}
	public function intersectsRay(camera:Camera,ray:Ray,lines:Imidiatemode):Void
	{
		
		if (this.blocks != null && this.blocks.length > 0)
		{
            for (index in 0...this.blocks.length) 
			{
                var block:MeshBlock = this.blocks[index];
			    block.intersectsRay(camera,ray,lines);
            }
        } else 
		{
			
			if (ray.intersectsBoxMinMax(this._minPoint, this._maxPoint))
		    {
				
				this.abb.boundingBox.renderColor(lines, 0, 1, 1);
				
				for (i in 0 ... this.entries.length)
				{
					var m:Mesh = this.entries[i];
				
					// if (ray.intersectsBox(m.Bounding.boundingBox))
					if (ray.intersectsTransformedBox(m.Bounding.boundingBox))
					// if (ray.intersectsSphere(m.Bounding.boundingSphere))
					 {
						 m.Bounding.boundingBox.renderAlignedColor(lines, 0, 1, 0);
						 break;
					 }
					 
					
				}
				
				
		     } 
        }
			
	
	}
    
	
}