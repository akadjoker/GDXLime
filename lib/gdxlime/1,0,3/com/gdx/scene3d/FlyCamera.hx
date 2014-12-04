package com.gdx.scene3d;
import com.gdx.math.Matrix4;
import com.gdx.math.Quaternion;
import com.gdx.math.Vector2;
import com.gdx.math.Vector3;

/**
 * ...
 * @author Luis Santos AKA DJOKER
 */
class FlyCamera extends Camera
{

	public function new(scene:Scene,id:Int=0, name:String="Camera") 
	{
		
		super(scene, id, name);
		UpdateAbsoluteTransformation();
		scaling.set(1, 1, 1);
		viewMatrix.copyFrom(AbsoluteTransformation);

		
	}

	
	override public function getRelativeTransformation():Matrix4
	{
					 rotationQuaternion.toRotationMatrix(localRotation);
	                 LocalWorld.makeTransform(position, scaling, rotationQuaternion);
	                 if (this.parent != null)
				      {
					  LocalWorld.append(parent.AbsoluteTransformation);
					  }
		return LocalWorld;
	}
	override public function update() 
	{
			scaling.set(1, 1, 1);
	       UpdateAbsoluteTransformation();
		
	
		
		
		if (parent != null)
		{
			var parentInvert:Matrix4 = Matrix4.Zero();
			parent.getAbsoluteTransformation().invertToRef(parentInvert);
			viewMatrix.append(parentInvert);
		}
		//viewMatrix.copyFrom(AbsoluteTransformation);
		AbsoluteTransformation.invertToRef(viewMatrix);
		viewMatrix.invertToRef(viewMatrixInvert);
		this.Bounding.update(viewMatrixInvert, 1);
		extractPlanes();
		this.cameraRay = getRay();
		
	
	   
	}
	
}