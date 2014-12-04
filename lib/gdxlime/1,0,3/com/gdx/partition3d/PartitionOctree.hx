package com.gdx.partition3d;
import com.gdx.math.Vector3;


class PartitionOctree extends Partition3D 
{
	
	 public function new(maxDepth:Int, size:Float,center:Vector3) 
	 {
        super(new OctreeNode(maxDepth, size,center.x,center.y,center.z));
    }
}

