package com.gdx.scene3d;
import com.gdx.math.Matrix4;
import com.gdx.math.Quaternion;
import com.gdx.math.Vector3;
import com.gdx.scene3d.animators.Animator;

/**
 * ...
 * @author djoekr
 */
class SceneNode extends Node
{
	public var Active (default, default) :Bool = true;
	public var EnableCull (default, default) :Bool = true;
	public var showNormals (default, default) :Bool = false;
	public var showBoundingBoxes (default, default) :Bool = false;
	public var debugNormalLineSize (default, default) :Float = 1;
	public var showSubBoundingBoxes (default, default) :Bool = false;
	public var  parent:SceneNode;
	public var  scene:Scene;
		

	private var newRotation:Bool;
	public var rotationQuaternion:Quaternion;
	public var localRotation:Matrix4;

	public var childs:Array<SceneNode>; //
	public var tag1:Int;
	public var tag2:Int;
	public var tag3:Int;
    private var ignoreTrasformation:Bool;
	private var newMatrix:Matrix4;
	
	private var WorldMatrix:Matrix4;
	private var LocalWorld:Matrix4;
	public  var AbsoluteTransformation:Matrix4;
	public var  AbsolutePosition:Vector3;
	
		
	public var orientation:Int;
	private var animators:Array<Animator>;
	
	public var renderType:Int;//trasparen blend etcetc
	
		
	
	public function new(scene:Scene,Parent:SceneNode = null , id:Int = 0, name:String="SceneNode") 
	{
		super(id, name);
		this.scene = scene;
		this.parent = Parent;
		orientation = 0;
		animators = [];
		renderType = 0;//solid
		AbsolutePosition=Vector3.zero;
		if (Parent != null)
		{
			setParent(Parent);
		} 
		childs = [];
		AbsoluteTransformation = Matrix4.Identity();

        LocalWorld = Matrix4.Zero();
		WorldMatrix= Matrix4.Zero();
	    localRotation = Matrix4.Zero();
		newMatrix= Matrix4.Identity();
		tag1 = 0;
		tag2 = 0;
		tag3 = 0;
		ignoreTrasformation = false;
		
	    this.rotationQuaternion = new Quaternion();
		newRotation = false;
     
		setScale(1, 1, 1, true);
		setRotation(0, 0, 0);
		setPosition(0, 0, 0);
		
		
		UpdateAbsoluteTransformation();

	}
	public function setMatrix(m:Matrix4)
	{
		if(m != null)
		{
	     ignoreTrasformation = true;
		 this.AbsoluteTransformation = m;
		} else
		{
		ignoreTrasformation = false;
		}
	}
		public function setName(n:String)
	{
		this.name = n;
	}
	public function setParent(node:SceneNode)
	{
		if ( (Std.is(node, Camera)) || (Std.is(node, FreeCamera)) || (Std.is(node, OrbitCamera)))
		{
			EnableCull = false;
		}
		this.parent = node;
	}
	public function addChild(node:SceneNode)
	{
		    node.parent = null;
			childs.push(node);
			node.parent = this;
	}
	public function removeChild(node:SceneNode)
	{
		node.setParent(null);
		childs.remove(node);
	}	
		public function setRotationVector(v:Vector3,deg:Bool=false,global:Bool=false):Void
	{
		setRotation(v.x, v.y, v.z, deg, global);
		
	}
	public function setRotation(x:Float, y:Float, z:Float,deg:Bool=false,global:Bool=false):Void
	{
		if (deg)
		{
		rotation.set(Util.deg2rad(x), Util.deg2rad(y),Util.deg2rad(z));	
		} else
		{
		rotation.set(x, y, z);
		}
		updateRotation(global);
		
	}
	public function addYaw(v:Float,global:Bool=false):Void
	{
		rotation.y += v;
		updateRotation(global);
	}
	public function addPitch(v:Float,global:Bool=false):Void
	{
		rotation.x += v;
		updateRotation(global);
	}
	public function addRoll(v:Float,global:Bool=false):Void
	{
		rotation.z += v;
		updateRotation(global);
	}
	public function setYaw(v:Float,deg:Bool=false,global:Bool=false):Void
	{
		if (deg)
		{
		rotation.y = Util.deg2rad(v)	;
		}else
		{
		rotation.y = v;	
		}
		
		updateRotation(global);
	}
	public function setPitch(v:Float,deg:Bool=false,global:Bool=false):Void
	{
		if (deg)
		{
		rotation.x = Util.deg2rad(v)	;
		}else
		{
		rotation.x = v;	
		}
			updateRotation(global);
	}
	public function setRoll(v:Float,deg:Bool=false,global:Bool=false):Void
	{
		if (deg)
		{
		rotation.z = Util.deg2rad(v)	;
		}else
		{
		rotation.z = v;	
		}
			updateRotation(global);
	}
	public function setPosition(x:Float, y:Float, z:Float,global:Bool=false):Void
	{
		position.set(x, y, z);
		if (global)
		{
			if (parent != null)
			{
		      var v:Vector3 = SceneNode.TFormPoint(new Vector3(x, y, z), null, parent	);
			  position.copyFrom(v);
	       }
		}
		
	}
	public function setPositionVector(p:Vector3, global:Bool=false):Void
	{
		position.copyFrom(p);
		
	if (global)
		{
			if (parent != null)
			{
		      var v:Vector3 = SceneNode.TFormPoint(p, null, parent	);
			  position.copyFrom(v);
			} 
		}	
	}

	private function updateRotation(global:Bool=false):Void
	{
		rotationQuaternion.RotationYawPitchRollTo(this.rotation.y, this.rotation.x, this.rotation.z);	
     	if (global)
		{
			if (parent != null)
			{
				var m2:Matrix4 = Matrix4.Zero();
				m2.copyFrom(parent.AbsoluteTransformation);
				m2.invert();
				m2.m[12] = 0;
				m2.m[13] = 0;
				m2.m[14] = 0;
				
				var q:Quaternion = Quaternion.CreateFromMatrix(m2);
				
			    rotationQuaternion.multLeft(q);
			}
		} 
 	}
	public function setScale(x:Float, y:Float, z:Float,global:Bool = false):Void
	{
		var tmp = scaling;
		
		if (global)
		{
		if (parent != null)
		{
			var esx = parent.ScaleX(true);
			var esy = parent.ScaleY(true);
			var esz = parent.ScaleZ(true);
			
		if (esx != 0.0) {x = x / esx; }
		if (esy != 0.0) {y = y / esy; }
		if (esz != 0.0) {z = z / esz; }
		}
		}
		
		scaling.set(x, y, z);
		
	}	
	public function UpdateAbsoluteTransformation():Void
	{
		    if (!ignoreTrasformation)
			{
		     AbsoluteTransformation = getRelativeTransformation();
			}
			
			AbsolutePosition.set(AbsoluteTransformation.m[12], AbsoluteTransformation.m[13], AbsoluteTransformation.m[14]);
			
	}

	public function getAbsolutePosition():Vector3
		{
			AbsolutePosition.set(AbsoluteTransformation.m[12], AbsoluteTransformation.m[13], AbsoluteTransformation.m[14]);
			return AbsolutePosition;
		}
	public function getAbsoluteTransformation():Matrix4
	{
			return AbsoluteTransformation;
	}
	
	public function rotate(q:Quaternion):Void
	{
		 rotationQuaternion.copyFrom(q);
	}
	
	public function getRelativeTransformation():Matrix4
	{
						 
	
		 switch (orientation)
		 {
			 case 0:
				 {
					 rotationQuaternion.toRotationMatrix(localRotation);
	                 LocalWorld.makeTransform(position, scaling, rotationQuaternion);
	                 if (this.parent != null)
				      {
					  LocalWorld.append(parent.AbsoluteTransformation);
					  }

				 }
			case 1:
				{
					LocalWorld.copyFrom(scene.mainCamera.getSpriteMatrix(0));
					LocalWorld.m[12] = position.x;
					LocalWorld.m[13] = position.y;
					LocalWorld.m[14] = position.z;
		           
				}
		 	case 2:
				{
					LocalWorld.copyFrom(scene.mainCamera.getSpriteMatrix(1));
					LocalWorld.m[12] = position.x;
					LocalWorld.m[13] = position.y;
					LocalWorld.m[14] = position.z;
		           
				}
		 	case 3:
				{
					LocalWorld.copyFrom(scene.mainCamera.getSpriteMatrix(2));
					LocalWorld.m[12] = position.x;
					LocalWorld.m[13] = position.y;
					LocalWorld.m[14] = position.z;
		       
		           
				}
		 	case 4:
				{
				
				
					 LocalWorld.copyFrom(scene.mainCamera.getSpriteMatrix(3));
					 LocalWorld.m[12] = position.x;
					 LocalWorld.m[13] = position.y;
					 LocalWorld.m[14] = position.z;
					 
					 
				
					 
					 var sx = LocalWorld.m[0];
					 var sy = LocalWorld.m[5];
					 var sz = LocalWorld.m[10];
					 
					// LocalWorld.m[0] =scaling.x  * sx;
				//	 LocalWorld.m[5] = scaling.y * sy;
			//
					 
					 
					 
		           
				}
		   }     
				
		
		
		
		           
	
		return LocalWorld;
	}

	
	static public function TFormVector(v:Vector3, src_ent:SceneNode, dest_ent:SceneNode):Vector3
	{

	var mat1:Matrix4 = Matrix4.Zero();
	var mat2:Matrix4 = Matrix4.Zero();
			
	if (src_ent != null)
	{	

	mat1.copyFrom(src_ent.getRelativeTransformation());
	mat1.m[12] = 0;
	mat1.m[13] = 0;
	mat1.m[14] = 0;
	}
	
	if (dest_ent != null)
	{
	dest_ent.getRelativeTransformation().invertToRef(mat2);
	mat2.m[12] = 0;
	mat2.m[13] = 0;
	mat2.m[14] = 0;	
	}
	
	var result:Vector3 = Vector3.zero;

	//transform point by matrix
	if (dest_ent != null)
	{
	result=mat2.TransformVec(v, 1);
	}
	if (src_ent != null)
	{
	result = mat1.TransformVec(v, 1);
	}
	
	mat1 = null;
	mat2 = null;
	
	
	return result;
	}
	
	static public function TFormPoint(v:Vector3, src_ent:SceneNode, dest_ent:SceneNode):Vector3
	{

	var mat1:Matrix4 = Matrix4.Zero();
	var mat2:Matrix4 = Matrix4.Zero();
			
	if (src_ent != null)
	{	
	mat1.copyFrom(src_ent.getRelativeTransformation());
	}
	
	if (dest_ent != null)
	{
	 dest_ent.getRelativeTransformation().invertToRef(mat2);
	}
	
	var result:Vector3 = Vector3.zero;

	//transform point by matrix
	if (dest_ent != null)
	{
	result=mat2.TransformVec(v, 1);
	}
	if (src_ent != null)
	{
	result = mat1.TransformVec(v, 1);
	}
	mat1 = null;
	mat2 = null;
	
	return result;
	}
	
	public function NodeX(global:Bool = false):Float
	{
		if (global)
		{
			return AbsoluteTransformation.m[12];
		}else
		{
			return position.x;
		}
	}
	public function NodeY(global:Bool = false):Float
	{
		if (global)
		{
			return AbsoluteTransformation.m[13];
		}else
		{
			return position.y;
		}
	}
	public function NodeZ(global:Bool = false):Float
	{
		if (global)
		{
			return AbsoluteTransformation.m[14];
		}else
		{
			return position.z;
		}
	}
	public function getPitch(global:Bool = false):Float
	{
		if (global)
		{
			return AbsoluteTransformation.GetPitch();
		}else
		{
			return rotation.x;
		}
	}
	public function getYaw(global:Bool = false):Float
	{
		if (global)
		{
			return AbsoluteTransformation.GetYaw();
		}else
		{
			return rotation.y;
		}
	}
	public function getRoll(global:Bool = false):Float
	{
		if (global)
		{
			return AbsoluteTransformation.GetRoll();
		}else
		{
			return rotation.z;
		}
	}
	public function ScaleX(global:Bool = false):Float
	{
		var x:Float = scaling.x;
		
		if (global)
		{
			if (parent != null)
			{
				x = x * parent.scaling.x;
				return x;
			} else
			{
				return x;
			}
		}else
		{
			return x;
		}
	}
	public function ScaleY(global:Bool = false):Float
	{
		var x:Float = scaling.y;
		
		if (global)
		{
			if (parent != null)
			{
				x = x * parent.scaling.y;
				return x;
			} else
			{
				return x;
			}
		}else
		{
			return x;
		}
	}
	public function ScaleZ(global:Bool = false):Float
	{
		var x:Float = scaling.z;
		
		if (global)
		{
			if (parent != null)
			{
				x = x * parent.scaling.z;
				return x;
			} else
			{
				return x;
			}
		}else
		{
			return x;
		}
	}
	public function Advance(v:Vector3):Void
	{
		var dst:Vector3 = Vector3.zero;
		dst=localRotation.TransformVec(v, 0);
		position.addInPlace(dst);
		
	}
    public function getLocalRotation():Vector3
	{
		
		return localRotation.TransformVec(rotation, 0);
		
		
	}
	public function Translate(v:Vector3):Void
	{
		var dst:Vector3 = Vector3.zero;
		dst = TFormVector(v, null, this);
		var to:Vector3 = Vector3.zero;
		to=localRotation.TransformVec(dst, 0);
		position.addInPlace(to);
		
	}	
	public function addAnimator(a:Animator):Void
	{
		animators.push(a);
	}
	public function update():Void
	{
		
		if (!Active) return;
		
		for (animator in animators)
		{
			animator.animate(this);
		}
		
		UpdateAbsoluteTransformation();
		
		
	
    }
	public function render(camera:Camera) 
	{
	//	if (!Visible) return;

	//	for (child in childs)
	//	{
	//		child.render(camera);
	//	}
	
	}
	public function dispose()
	{
		for (child in childs)
		{
			child.dispose();
			child = null;
		}
	
		childs=null;
	}
	
	
		
		
}