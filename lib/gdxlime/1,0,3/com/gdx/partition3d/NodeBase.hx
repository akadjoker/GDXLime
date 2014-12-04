package com.gdx.partition3d;
import com.gdx.math.BoundingInfo;
import com.gdx.math.Ray;
import com.gdx.math.Vector3;
import com.gdx.scene3d.buffer.Imidiatemode;
import com.gdx.scene3d.Camera;
import com.gdx.scene3d.Node;
import com.gdx.scene3d.Surface;

/**
 * ...
 * @author Luis Santos AKA DJOKER
 */
class NodeBase
{
    public var _parent:NodeBase;
    private var _childNodes:Array<NodeBase>;
    private var _numChildNodes:Int;
    public var bounding:BoundingInfo;
    private var _numEntities:Int;
    public var _collectionMark:Int;
	public var leaf:Bool;
	public var surfaces:Array <Surface>;
	public var nodes:Array <Node>;
		
	public function new() 
	{
		_childNodes = new Array<NodeBase>();
		_numEntities = 0;
		_collectionMark = 0;
		_numChildNodes = 0;
		surfaces = [];
		nodes=[];
		//bounding = new BoundingInfo(Vector3.zero,Vector3.zero);
	}
	 /**
	 * The parent node. Null if this node is the root.
	 */
    public function get_parent():NodeBase {
        return _parent;
    }

    public function addNode(node:NodeBase):Void {
	
        node._parent = this;
        _numEntities += node._numEntities;

        _childNodes[_numChildNodes++] = node;
        var numEntities:Int = node._numEntities;
        node = this;
        do {
            node._numEntities += numEntities;
        }
        while (((node = node._parent) != null));
	
    }

 


    private function removeNode(node:NodeBase):Void 
	{
        var index:Int = _childNodes.indexOf(node);
        _childNodes[index] = _childNodes[--_numChildNodes];
        _childNodes.pop();
        var numEntities:Int = node._numEntities;
        node = this;
        do {
            node._numEntities -= numEntities;
        }
        while (((node = node._parent) != null));
    }

    private function get_numEntities():Int
	{
        return _numEntities;
    }

    private function updateNumEntities(value:Int):Void 
	{
        var diff:Int = value - _numEntities;
        var node:NodeBase = this;
        do {
            node._numEntities += diff;
        }
        while (((node = node._parent) != null));
    }
	
	
	public function debug(lines:Imidiatemode):Void
	{
		
		if (leaf) 
		{
		 this.bounding.boundingBox.renderColor(lines, 1, 1, 1);		
		} 
		
		
		this.bounding.boundingBox.renderColor(lines, 0, 1, 1);
		
		
		
		var i:Int = 0;
        while (i < _numChildNodes) 
		{
            _childNodes[i].debug(lines);
            ++i;
        }
		
	}
	
	public function addSurface(s:Surface):Void
	{
		if (!leaf) 
		{
			
		} else
		{
		if (s.Bounding.boundingBox.isFullInside(this.bounding.boundingBox))
		{
		 surfaces.push(s);
         trace("add:"+Std.int(surfaces.length-1));
		 return;
		}
		}
		var i:Int = 0;
        while (i < _numChildNodes) 
		{
           _childNodes[i].addSurface(s);
            ++i;
        }
		
		
		
	}
	
	
	  public function RayHit(ray:Ray, lines:Imidiatemode):Bool
	{
		
		
		var result:Bool = false;
		
		if (!leaf) 
		{
		 this.bounding.boundingBox.renderColor(lines, 1, 1, 1);		
		} else
		{
		

		if (ray.intersectsBox(this.bounding.boundingBox))
		{
		  this.bounding.boundingBox.renderColor(lines, 1, 1, 0);	
		  result = true;
		}
		}
		
		
		
		var i:Int = 0;
        while (i < _numChildNodes) 
		{
           if ( _childNodes[i].RayHit(ray, lines)) result = true;
            ++i;
        }
		
		
		
		return result;
	}
	
	public function renderSurfaces(camera:Camera,lines:Imidiatemode):Void
	{
		
		if (leaf) 
		{
			
			if (this.bounding.isInFrustrum(camera.frustumPlanes))
			{
		this.bounding.boundingBox.renderColor(lines, 1, 1, 0);	
		for (i in 0... surfaces.length)
		{
			surfaces[i].render();
		}
			}
		
		} 

		
		
		var i:Int = 0;
        while (i < _numChildNodes) 
		{
          _childNodes[i].renderSurfaces(camera, lines);
            ++i;
        }
		
	}
}