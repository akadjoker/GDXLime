package com.gdx.scene2d;

import com.gdx.math.Matrix2D;
import com.gdx.math.Matrix4;
import com.gdx.math.Transform;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLShader;
import lime.graphics.opengl.GLUniformLocation;
import lime.graphics.opengl.GLTexture;
import lime.graphics.RenderContext;
import lime.utils.Float32Array;
import lime.utils.Int16Array;

/**
 * ...
 * @author djoekr
 */
class CameraOrtho extends Transform
{
	
	 // private var proj:Float32Array = new Float32Array(16);
	//  private var view:Float32Array = new Float32Array(16);
	  private var view:Matrix4;
	  private var proj:Matrix4;
	  
	  public var width:Float;
	  public var height:Float;

		
	
	public function new(width:Float , height:Float ) 
	{
		super();
		 this.width  = width;
		 this.height = height;
	
		 view =new Matrix4();
		 proj =new  Matrix4();
		 
		// view = [ 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0 ];
		 rescale(width, height);
		 update();
		
		
		 
	}
	public function centerRotation(move:Bool = true)
	{
		pivotX = (width / 2);
		pivotY = (height / 2);
		if (move)
		{
		 x = width / 2;
		 y = height / 2;
		}
	}
	public function setViewPort(x:Float,y:Float,w:Float,h:Float):Void
	{
		GL.viewport(Std.int(x) , Std.int(y), Std.int(w), Std.int(h));
	}
	public function rescale(Width:Float , Height:Float ) 
	{

		//setViewPort(0,0,width, height);
		setOrtho (0, width, height, 0, 1000, -1000);
	
	
	}

	public function update( )
	{
	

		
		 var m:Matrix2D=getTransformationMatrix();
		 view.m[0] = m.a;
         view.m[1] = m.b;
         view.m[4] = m.c;
         view.m[5] = m.d;
         view.m[12] = m.tx;
         view.m[13] = m.ty;
		
	}
	
	public function getView():Matrix4
	{
		return view;
	}
	public function getProj():Matrix4
	{
		return proj;
	}
	private  function set2D (x:Float, y:Float, scale:Float = 1, rotation:Float = 0) 
	{
		
		var theta = rotation * Math.PI / 180.0;
		var c = Math.cos (theta);
		var s = Math.sin (theta);
		
		view.set(
		
			c*scale,  -s*scale, 0,  0,
			s*scale,  c*scale, 0,  0,
			0,        0,        1,  0,
			x,        y,        0,  1
		);
		
	}
	
	private function setOrtho (x0:Float, x1:Float,  y0:Float, y1:Float, zNear:Float, zFar:Float) 
	{
		//proj.setOrthoOffCenterLH(x0, x1, y0, y1, zNear, zFar);
		
		var sx = 1.0 / (x1 - x0);
		var sy = 1.0 / (y1 - y0);
		var sz = 1.0 / (zFar - zNear);
		
		proj.set(
			2.0 * sx,     0,          0,                 0,
			0,            2.0 * sy,   0,                 0,
			0,            0,          -2.0 * sz,         0,
			- (x0 + x1) * sx, - (y0 + y1) * sy, - (zNear + zFar) * sz,  1
		);
		
	}
	public function dipose():Void 
	{
	      proj = null;
	      view = null;
	}
	
}