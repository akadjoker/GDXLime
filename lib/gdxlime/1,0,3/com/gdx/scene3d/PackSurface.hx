package com.gdx.scene3d ;



import com.gdx.color.Color4;
import com.gdx.gl.shaders.Brush;
import com.gdx.gl.shaders.Flat;
import com.gdx.gl.shaders.Shader;
import com.gdx.math.BoundingInfo;
import com.gdx.math.Matrix4;
import com.gdx.math.Plane;
import com.gdx.math.Quaternion;
import com.gdx.math.Ray;
import com.gdx.math.Triangle;
import com.gdx.math.Vector2;
import com.gdx.math.Vector3;
import com.gdx.scene3d.buffer.Imidiatemode;
import com.gdx.scene3d.buffer.IndexSingleBuffer;
import com.gdx.scene3d.buffer.VertexBuffer;
import com.gdx.scene3d.buffer.VertexVBO;
import com.gdx.Util;
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
class PackSurface 
{
	
    public var   vert_coords:Array<Float>;
	public var   vert_norm:Array<Float>;
	public var   vert_tex_coords0:Array<Float>;
	public var   vert_tex_coords1:Array<Float>;
	public var   vert_col:Array<Float>;
   
    public var vertexbuffer:VertexVBO;
   
	
	public var shader:Shader;
    public var  no_verts:Int;


	public var  reset_vbo:Int;

		
	
	
	public function new(lightshader:Shader,texture0:Bool,texture1:Bool,colors:Bool,normals:Bool) 
	{
	 	no_verts = 0;
 
		reset_vbo = -1;
		vert_coords = new Array<Float>();
		vert_norm = new Array<Float>();
		vert_tex_coords0 = new Array<Float>();
     	vert_tex_coords1 = new Array<Float>();
		vert_col = new Array<Float>();
		this.shader = lightshader;
		 vertexbuffer = new VertexVBO(this.shader, texture0,texture1,colors,normals);
	}
	
		
	public function AddVertex(x:Float, y:Float, z:Float, u:Float=0.0, v:Float=0.0):Int
	{
	
	no_verts++;
	vert_coords.push(x);
	vert_coords.push(y);
	vert_coords.push(z); 
	
	vert_norm.push(0.0);
	vert_norm.push(0.0);
	vert_norm.push(0.0);
	
	vert_col.push(1.0);
	vert_col.push(1.0);
	vert_col.push(1.0);
	vert_col.push(1.0);
	
	vert_tex_coords0.push(u);
	vert_tex_coords0.push(v);
    vert_tex_coords1.push(u);
    vert_tex_coords1.push(v);
		
	return no_verts-1;

}

	public function AddFullVertex(x:Float, y:Float, z:Float,nx:Float,ny:Float,nz:Float, u:Float=0.0, v:Float=0.0,u2:Float=0.0, v2:Float=0.0):Int
	{
	
	no_verts++;
	
	vert_coords.push(x);
	vert_coords.push(y);
	vert_coords.push(z); 
	
	vert_norm.push(nx);
	vert_norm.push(ny);
	vert_norm.push(nz);
	

	
	vert_col.push(1.0);
	vert_col.push(1.0);
	vert_col.push(1.0);
	vert_col.push(1.0);
	
	vert_tex_coords0.push(u);
	vert_tex_coords0.push(v);
    vert_tex_coords1.push(u2);
    vert_tex_coords1.push(v2);
		
	return no_verts-1;

}
	public function AddFullVertexColor(x:Float, y:Float, z:Float,nx:Float,ny:Float,nz:Float, u:Float=0.0, v:Float=0.0,u2:Float=0.0, v2:Float=0.0,r:Float=1,g:Float=1,b:Float=1,a:Float=1):Int
	{
	no_verts++;
	
	vert_coords.push(x);
	vert_coords.push(y);
	vert_coords.push(z); 
	
	vert_norm.push(nx);
	vert_norm.push(ny);
	vert_norm.push(nz);
	

	
	vert_col.push(r);
	vert_col.push(g);
	vert_col.push(b);
	vert_col.push(a);
	
	vert_tex_coords0.push(u);
	vert_tex_coords0.push(v);
    vert_tex_coords1.push(u2);
    vert_tex_coords1.push(v2);
		
	return no_verts-1;

}
public function AddFullVertexColorVector(Pos:Vector3,Nor:Vector3,uv0:Vector2,uv1:Vector2,color:Color4):Int
	{
	no_verts++;
	/*
	vert_coords.push(Pos.x);
	vert_coords.push(Pos.y);
	vert_coords.push(Pos.z); 
	
	vert_norm.push(Nor.x);
	vert_norm.push(Nor.y);
	vert_norm.push(Nor.z);
	

	
	vert_col.push(color.r);
	vert_col.push(color.g);
	vert_col.push(color.b);
	vert_col.push(color.a);
	
	vert_tex_coords0.push(uv0.x);
	vert_tex_coords0.push(uv0.y);
    vert_tex_coords1.push(uv1.x);
    vert_tex_coords1.push(uv1.y);
		*/
	return no_verts-1;

}
public function Vertex(vid:Int):Vector3
{
	return new Vector3(VertexX(vid), VertexY(vid), VertexZ(vid));
}

public function VertexX(vid:Int):Float
{
	return vert_coords[vid * 3];
}
public function VertexY(vid:Int):Float
{
	return vert_coords[(vid * 3) + 1];
}
public function VertexZ(vid:Int):Float
{
	return vert_coords[(vid * 3) + 2];
}
public function VertexRed(vid:Int):Int
{
	return Std.int( vert_col[vid * 4]*255);
}
public function VertexGreen(vid:Int):Int
{
		return Std.int(vert_col[(vid*4)+1]*255);
}
public function VertexBlue(vid:Int):Int
{
		return Std.int(vert_col[(vid*4)+2]*255);
}
public function VertexAlpha(vid:Int):Float
{
		return vert_col[(vid*4)+3];
}

public function VertexColorIndex(vid:Int,index:Int):Float
{
		return vert_col[(vid*4)+index];
}


public function VertexNX(vid:Int):Float
{
	return vert_norm[vid * 3];
}
public function VertexNY(vid:Int):Float
{
	return vert_norm[(vid * 3) + 1];
}
public function VertexNZ(vid:Int):Float
{
	return vert_norm[(vid * 3) + 2];
}


public function VertexU(vid:Int, coord_set:Int):Float
{

	if(coord_set==0){
		return vert_tex_coords0[vid*2];
	}else if(coord_set==1){
		return vert_tex_coords1[vid*2];
	}else{
		return vert_tex_coords1[vid*3];
	}

}
public function VertexV(vid:Int, coord_set:Int):Float
{

		if(coord_set==0){
		return vert_tex_coords0[(vid*2)+1];
	}else if(coord_set==1){
		return vert_tex_coords1[(vid*2)+1];
	}else{
		return vert_tex_coords1[(vid*3)+1];
	}

}


	
public function VertexCoords(vid:Int , x:Float, y:Float, z:Float):Void
{
	
	vid=vid*3;
	vert_coords[vid]=x;
	vert_coords[vid+1]=y;
	vert_coords[vid+2]=z; 

	reset_vbo=reset_vbo|1;
	
}
	

	public function UpdateVBO():Void
	{
	
	 if(reset_vbo==-1) reset_vbo=1|2|4|8;

	
        if (reset_vbo&1==1)
		{		
			if(vert_coords.length>0)vertexbuffer.uploadVertex(vert_coords);
		}
		
	
	
	
		if (reset_vbo&2==2)
		{
		
			if (vert_tex_coords0.length>0)vertexbuffer.uploadUVCoord0(vert_tex_coords0);
			if (vert_tex_coords1.length>0)vertexbuffer.uploadUVCoord1(vert_tex_coords1);
			
	      
	
		
		}
		
	
		if (reset_vbo&4==4)
		{
			if(vert_norm.length>0)		vertexbuffer.uploadNormals(vert_norm);
	 	}
	
        if (reset_vbo&8==8)
		{
	     if (vert_col.length>0)vertexbuffer.uploadColors(vert_col);
		}
	

	   
	
		
		
		reset_vbo = 0;
	
	
		
	}
	public function bind():Void
	{
     if (no_verts <= 0) return ; // ????? 
       UpdateVBO();
	  vertexbuffer.bind();
	}
      
 
	 public function dispose()
	{
		if (vertexbuffer != null) 
		{
			vertexbuffer.dispose();
			vertexbuffer = null;
		}
		
	}
}