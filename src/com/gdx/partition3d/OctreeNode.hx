package com.gdx.partition3d;
import com.gdx.math.BoundingInfo;
import com.gdx.math.Matrix4;
import com.gdx.math.Ray;
import com.gdx.math.Vector3;
import com.gdx.scene3d.buffer.Imidiatemode;
import com.gdx.scene3d.Surface;




class OctreeNode extends NodeBase {

    private var _centerX:Float;
    private var _centerY:Float;
    private var _centerZ:Float;
    private var _minX:Float;
    private var _minY:Float;
    private var _minZ:Float;
    private var _maxX:Float;
    private var _maxY:Float;
    private var _maxZ:Float;
    private var _quadSize:Float;
    private var _depth:Float;

    private var _rightTopFar:OctreeNode;
    private var _leftTopFar:OctreeNode;
    private var _rightBottomFar:OctreeNode;
    private var _leftBottomFar:OctreeNode;
    private var _rightTopNear:OctreeNode;
    private var _leftTopNear:OctreeNode;
    private var _rightBottomNear:OctreeNode;
    private var _leftBottomNear:OctreeNode;
	
    private var _halfExtent:Float;

    public function new(maxDepth:Int = 5, size:Float = 10000, centerX:Float = 0, centerY:Float = 0, centerZ:Float = 0, depth:Int = 0) {
		super();
        init(size, centerX, centerY, centerZ, depth, maxDepth);
   
    }

    private function init(size:Float, centerX:Float, centerY:Float, centerZ:Float, depth:Int, maxDepth:Int):Void {
        _halfExtent = size * .5;
        _centerX = centerX;
        _centerY = centerY;
        _centerZ = centerZ;
        _quadSize = size;
        _depth = depth;
        _minX = centerX - _halfExtent;
        _minY = centerY - _halfExtent;
        _minZ = centerZ - _halfExtent;
        _maxX = centerX + _halfExtent;
        _maxY = centerY + _halfExtent;
        _maxZ = centerZ + _halfExtent;
		bounding = new BoundingInfo(new Vector3(_minX, _minY, _minZ), new Vector3(_maxX, _maxY, _maxZ));
		bounding.calculate();
	      leaf = depth == maxDepth;
        if (!leaf) 
		{
            var hhs:Float = _halfExtent * .5;
			
			
            addNode(_leftTopNear = new OctreeNode(maxDepth, _halfExtent, centerX - hhs, centerY + hhs, centerZ - hhs, depth + 1));
            addNode(_rightTopNear = new OctreeNode(maxDepth, _halfExtent, centerX + hhs, centerY + hhs, centerZ - hhs, depth + 1));
            addNode(_leftBottomNear = new OctreeNode(maxDepth, _halfExtent, centerX - hhs, centerY - hhs, centerZ - hhs, depth + 1));
            addNode(_rightBottomNear = new OctreeNode(maxDepth, _halfExtent, centerX + hhs, centerY - hhs, centerZ - hhs, depth + 1));
            addNode(_leftTopFar = new OctreeNode(maxDepth, _halfExtent, centerX - hhs, centerY + hhs, centerZ + hhs, depth + 1));
            addNode(_rightTopFar = new OctreeNode(maxDepth, _halfExtent, centerX + hhs, centerY + hhs, centerZ + hhs, depth + 1));
            addNode(_leftBottomFar = new OctreeNode(maxDepth, _halfExtent, centerX - hhs, centerY - hhs, centerZ + hhs, depth + 1));
            addNode(_rightBottomFar = new OctreeNode(maxDepth, _halfExtent, centerX + hhs, centerY - hhs, centerZ + hhs, depth + 1));
			
        }
    }

 


// TODO: this can be done quicker through inversion

	public function findSurfaceForBounds(s:Surface):OctreeNode
	
	{
		  var min:Vector3 = s.Bounding.boundingBox.minimum;
          var max:Vector3 = s.Bounding.boundingBox.maximum;
	     return findPartitionForBounds(min.x, min.y, min.z, max.x, max.y, max.z);
		 
		
	}

    private function findPartitionForBounds(minX:Float, minY:Float, minZ:Float, maxX:Float, maxY:Float, maxZ:Float):OctreeNode
	{
        var left:Bool;
        var right:Bool;
        var far:Bool;
        var near:Bool;
        var top:Bool;
        var bottom:Bool;
        if (leaf) return this;
        right = maxX > _centerX;
        left = minX < _centerX;
        top = maxY > _centerY;
        bottom = minY < _centerY;
        far = maxZ > _centerZ;
        near = minZ < _centerZ;
        if ((left && right) || (far && near)) return this;
        if (top) {
            if (bottom) return this;
            if (near) {
                if (left) return _leftTopNear.findPartitionForBounds(minX, minY, minZ, maxX, maxY, maxZ)
                else return _rightTopNear.findPartitionForBounds(minX, minY, minZ, maxX, maxY, maxZ);
            }

            else {
                if (left) return _leftTopFar.findPartitionForBounds(minX, minY, minZ, maxX, maxY, maxZ)
                else return _rightTopFar.findPartitionForBounds(minX, minY, minZ, maxX, maxY, maxZ);
            }

        }

        else {
            if (near) {
                if (left) return _leftBottomNear.findPartitionForBounds(minX, minY, minZ, maxX, maxY, maxZ)
                else return _rightBottomNear.findPartitionForBounds(minX, minY, minZ, maxX, maxY, maxZ);
            }

            else {
                if (left) return _leftBottomFar.findPartitionForBounds(minX, minY, minZ, maxX, maxY, maxZ)
                else return _rightBottomFar.findPartitionForBounds(minX, minY, minZ, maxX, maxY, maxZ);
            }

        }

    }
}

