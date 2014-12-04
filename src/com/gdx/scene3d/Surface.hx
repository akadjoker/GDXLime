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
class Surface 
{
	public var Visible (default, default) :Bool = true;
	public var Bounding:BoundingInfo;
    public var   vert_coords:Array<Float>;
	public var   vert_norm:Array<Float>;
	public var   vert_tex_coords0:Array<Float>;
	public var   vert_tex_coords1:Array<Float>;
	public var   vert_col:Array<Float>;
   
	public var tag1:Int;
	public var tag2:Int;
	public var tag3:Int;
		
   public var vertexbuffer:VertexBuffer;
   public var singleBuffer:IndexSingleBuffer;
   public var isOptimize:Bool;
	
	
	public var shader:Shader;
	public var materialIndex:Int;

	public var brush:Brush;
	

	    private var justGeometry:Bool;
		public var  no_verts:Int;
	    public var  no_tris:Int;
		public var  tris:Array<Int>;

		public var  reset_vbo:Int;
		public var  primitiveType:Int;
		
	
	
	public function new(lightshader:Shader) 
	{
	    Bounding = new BoundingInfo(new Vector3(99999999,99999999,99999999), new Vector3(-99999999,-99999999,-99999999));
	
		
		brush = new Brush(0);
	
		
		no_verts = 0;
		no_tris = 0;
		tris = new Array<Int>();
        materialIndex = 0;
		reset_vbo = -1;



		vert_coords = new Array<Float>();
		vert_norm = new Array<Float>();
		vert_tex_coords0 = new Array<Float>();
     	vert_tex_coords1 = new Array<Float>();
		vert_col = new Array<Float>();
		justGeometry = true;
		if (lightshader != null)
		{
		 justGeometry = false;
		 this.shader = lightshader;
		 vertexbuffer = new VertexBuffer(this.shader, true, true, true, true);
		}
		
		primitiveType = GL.TRIANGLES;
		
		tag1 = 0;
		tag2 = 0;
		tag3 = 0;
		
		 singleBuffer = null;
         isOptimize = false;
	
	
		
	}
	public function Optimize():Void
	{
		if (justGeometry) return;
		if (no_verts <= 0) return;
		if(vertexbuffer!=null)vertexbuffer.dispose();
		vertexbuffer = null;
		isOptimize = true;
		singleBuffer = new IndexSingleBuffer(this.shader,  true, true, true, true);// (vert_tex_coords0.length > 0), (vert_tex_coords1.length > 0), (vert_col.length > 0), (vert_norm.length > 0));
		var data:Array < Float>=new Array<Float>();
		
		for (i in 0...this.no_verts)
		{
			data.push(this.VertexX(i));
			data.push(this.VertexY(i));
			data.push(this.VertexZ(i));
			
			data.push(this.VertexNX(i));
			data.push(this.VertexNY(i));
			data.push(this.VertexNZ(i));
			
			data.push(this.VertexU(i,0));
			data.push(this.VertexV(i,0));
			
			data.push(this.VertexU(i,1));
			data.push(this.VertexV(i, 1));
			
		
			data.push(this.VertexColorIndex(i, 0));
			data.push(this.VertexColorIndex(i, 1));
			data.push(this.VertexColorIndex(i, 2));
			data.push(this.VertexColorIndex(i, 3));
			
			
			
		}
		
		
		
		singleBuffer.uploadData(data);
		
       singleBuffer.uploadIndices(this.tris);

		data = null;
		
	}
	public function updateBounding():Void
	{
		 function checkExtends(v:Vector3, min:Vector3, max:Vector3) {
            if (v.x < min.x)
                min.x = v.x;
            if (v.y < min.y)
                min.y = v.y;
            if (v.z < min.z)
                min.z = v.z;

            if (v.x > max.x)
                max.x = v.x;
            if (v.y > max.y)
                max.y = v.y;
            if (v.z > max.z)
                max.z = v.z;
        }

        var min = new Vector3(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY);
        var max = new Vector3(Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY);

         for (index in 0...CountFaces()) 
		 {
			 for (i in 0...3)
			 {
              var v:Vector3 = this.getFace(index, i);
              checkExtends(v, min, max);
			 }
         
			
        }
		
		Bounding = new BoundingInfo(min,max);
		Bounding.calculate();
	}

	

	public function pushVertex(x:Float, y:Float, z:Float):Int
	{
	
	no_verts++;
	Bounding.addInternalPoint(x, y, z);
	vert_coords.push(x);
	vert_coords.push(y);
	vert_coords.push(z); 
	
	vert_norm.push(0.0);
	vert_norm.push(0.0);
	vert_norm.push(0.0);

		
	return no_verts-1;

}

	public function pushUV0(x:Float, y:Float):Void
	{
	vert_tex_coords0.push(x);
	vert_tex_coords0.push(y);
	}
	

	public function AddVertexVector(v:Vector3, uv:Vector2):Int
	
	{
	return AddVertex(v.x, v.y, v.z, uv.x, uv.y);
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
public function AddVertexUv(x:Float, y:Float, z:Float,nx:Float,ny:Float,nz:Float, u:Float=0.0, v:Float=0.0,u2:Float=0.0, v2:Float=0.0):Int
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
		
	return no_verts-1;

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
public function XVertex(vid:Int,value:Float):Void
{
	 vert_coords[vid * 3]=value;
}
public function YVertex(vid:Int,value:Float):Void
{
	 vert_coords[(vid * 3) + 1]=value;
}
public function ZVertex(vid:Int,value:Float):Void
{
	 vert_coords[(vid * 3) + 2]=value;
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

public function TriangleX(tri_no:Int,index:Int):Float
{
	 var v:Int=TriangleVertex(tri_no, index);
	 return VertexX(v);
}
public function TriangleY(tri_no:Int,index:Int):Float
{
	 var v:Int=TriangleVertex(tri_no, index);
	 return VertexY(v);
}
public function TriangleZ(tri_no:Int,index:Int):Float
{
	 var v:Int=TriangleVertex(tri_no, index);
	 return VertexZ(v);
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
public function TriangleVertex( tri_no:Int, corner:Int):Int
{

	var vid:Array<Int>=[];

	tri_no=(tri_no+1)*3;
	vid[0]=tris[tri_no-1];
	vid[1]=tris[tri_no-2];
	vid[2]=tris[tri_no-3];

	return vid[corner];

}


	
public function VertexCoords(vid:Int , x:Float, y:Float, z:Float):Void
{
	
	vid=vid*3;
	vert_coords[vid]=x;
	vert_coords[vid+1]=y;
	vert_coords[vid+2]=z; 
	

	reset_vbo=reset_vbo|1;
	
}
	

	public function VertexNormal(vid:Int , nx:Float, ny:Float, nz:Float):Void
	{
    vid=vid*3;
	vert_norm[vid]=nx;
	vert_norm[vid+1]=ny;
	vert_norm[vid+2]=nz; 
	reset_vbo=reset_vbo|4;
    }

public function VertexColor( vid:Int, r:Int , g:Int, b:Int, a:Float):Void
{

	vid=vid*4;
	vert_col[vid]=r/255.0;
	vert_col[vid+1]=g/255.0;
	vert_col[vid+2]=b/255.0;
	vert_col[vid+3]=a;
	
	reset_vbo=reset_vbo|8;

}
public function scaleVertexAlongNormal(  factorX:Float, factorY:Float, factorZ:Float):Void
{
	var normal:Vector3 = new Vector3(0, 0, 0);
	for (v in 0...no_verts)
	{
		
	  
	  normal.set(vert_norm[v * 3], vert_norm[(v * 3) + 1], vert_norm[(v * 3) + 2]);
	  vert_coords[v * 3]       += normal.x * factorX;
	  vert_coords[(v * 3) + 1] += normal.y * factorY;
	  vert_coords[(v * 3) + 2] += normal.z * factorZ;
	  
	 
		
		
			
   }
	reset_vbo=reset_vbo|1;
	
	
}
public function scaleVertex(  factorX:Float, factorY:Float, factorZ:Float):Void
{
	var normal:Vector3 = new Vector3(0, 0, 0);
	for (v in 0...no_verts)
	{
	  vert_coords[v * 3]       *=  factorX;
	  vert_coords[(v * 3) + 1] *=  factorY;
	  vert_coords[(v * 3) + 2] *=  factorZ;
   }
	reset_vbo=reset_vbo|1;
	
	
}
public function scaleTexCoords(  factorX:Float, factorY:Float, coords_set:Int):Void
{
	for (v in 0...no_verts)
	{
		var vx, vy:Float = 0;
		
		if (coords_set == 0)
		{
		
	     vert_tex_coords0[v * 2] *= factorX;
		 vert_tex_coords0[(v * 2) + 1] *= factorY; 
		
		
		} else
		{
     	 vert_tex_coords1[v * 2] *= factorX;
		 vert_tex_coords1[(v * 2) + 1] *= factorY; 
		
			
		}
		reset_vbo=reset_vbo|2;
	
	}
}

public function setVerticesData(data:Array < Float>)
{
	for (i in 0... data.length )
	{
	 vert_coords.push(data[i]);
	 vert_norm.push(0);
	 vert_col.push(1.0);
	 vert_col.push(1.0);
	 vert_col.push(1.0);
	 vert_col.push(1.0);
	}
		 no_verts= Std.int(data.length / 3);
		reset_vbo = reset_vbo | 1;
		reset_vbo = reset_vbo | 8;
		
}

public function addFace(v0:Vector3, v1:Vector3, v2:Vector3, uv0:Vector2, uv1:Vector2, uv2:Vector2):Int
{
	
	var v0=this.AddVertex(v0.x, v0.y, v0.z, uv0.x, uv0.y);
	var v1=this.AddVertex(v1.x, v1.y, v1.z, uv1.x, uv1.y);
	var v2=this.AddVertex(v2.x, v2.y, v2.z, uv2.x, uv2.y);
	return AddTriangle(v0, v1, v2);
	
	
}
public function addFullFace(v0:Vector3, v1:Vector3, v2:Vector3,nv0:Vector3, nv1:Vector3, nv2:Vector3, uv0:Vector2, uv1:Vector2, uv2:Vector2):Int
{
	
	var v0=this.AddFullVertex(v0.x, v0.y, v0.z,nv0.x, nv0.y, nv0.z, uv0.x, uv0.y);
	var v1=this.AddFullVertex(v1.x, v1.y, v1.z,nv1.x, nv1.y, nv1.z, uv1.x, uv1.y);
	var v2=this.AddFullVertex(v2.x, v2.y, v2.z,nv2.x, nv2.y, nv2.z, uv2.x, uv2.y);
	return AddTriangle(v0, v1, v2);
	
	
}
public function setTexCoords(data:Array < Float>,layer:Int=0)
{
	for (i in 0... data.length )
	{
		if (layer == 0)
		{
	    this.vert_tex_coords0.push( data[i]);
		} else
		if (layer == 1)
		{
	    this.vert_tex_coords1.push(data[i]);			
		} 
		else
		if (layer == 2)
		{
			    this.vert_tex_coords0.push(data[i]);
	            this.vert_tex_coords1.push(data[i]);			
		}
	 
	}
	reset_vbo=reset_vbo|2;
}
public function setNormals(data:Array < Float>)
{
	for (i in 0... data.length )
	{
	 this.vert_norm.push(data[i]);
	}
}
public function setIndices(data:Array < Int>)
{
	for (i in 0 ... data.length)
	{
	 this.tris.push(data[i]);
	}
	no_tris = Std.int(data.length / 3);
	reset_vbo=reset_vbo|1|2|16;
}
public function VertexTexCoords( vi:Int, u:Float, v:Float,w:Float=0, coords_set:Int=0):Void
{
	
	vi=vi*2;
	
	if(coords_set==0){
	
		vert_tex_coords0[vi]=u;
		vert_tex_coords0[vi+1]=v;
	
	}else{
		
		vert_tex_coords1[vi]=u;
		vert_tex_coords1[vi + 1] = v;
		
	
	}
	
	reset_vbo=reset_vbo|2;
	
}
	public function AddTriangle(v0:Int, v1:Int, v2:Int):Int
	{
	
	no_tris++;
	
	tris.push(v2);
	tris.push(v1);
	tris.push(v0);
	
	reset_vbo=reset_vbo|1|2|16;
	return no_tris;
    }
	public function UpdateVBO():Void
	{
	 if (justGeometry) return;	
	 if(reset_vbo==-1) reset_vbo=1|2|4|8|16;

	
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
	

	   
	
			
        if (reset_vbo&16==16)
		{		
	       if (tris.length>0)vertexbuffer.uploadIndices(tris );
		}
		
		reset_vbo = 0;
	
	
		
	}
	public function render(ignoreBrush:Bool = false)
	{
		if (justGeometry) return;
		if (no_verts <= 0) return ; // ????? 

		if (isOptimize)
		{
			
			if (!ignoreBrush)
			{
				
			
		if (brush.useTextures)
		{
			if (brush.texture0 != null)
			{
				shader.enableTexture(true);
			    shader.setTexture0(brush.texture0);
			}
			if (brush.isDetail)
			{
				if (brush.texture1 != null)
				{
				shader.setTexture1(brush.texture1);
				}
			} 
		
		} else
		{
				shader.enableTexture(false);
		}

		}//no brush
	
		singleBuffer.render(primitiveType, no_tris * 3);
		
		
		} else
		{
		UpdateVBO();
		
		if (!ignoreBrush)
		{
		if (brush.useTextures)
		{
			if (brush.texture0 != null)
			{
				shader.enableTexture(true);
			    shader.setTexture0(brush.texture0);
				vertexbuffer.useTexture = true;
			}
			if (brush.isDetail)
			{
				if (brush.texture1 != null)
				{
				shader.setTexture1(brush.texture1);
				vertexbuffer.useDetail = true;
				}
			} else
			{
				vertexbuffer.useDetail = false;
			}
		
		} else
		{
				shader.enableTexture(false);
				vertexbuffer.useTexture = false;
				vertexbuffer.useDetail = false;
		}
		}//ignore brush
	
		vertexbuffer.render(primitiveType, no_tris * 3);
		
		}
		
		Gdx.Instance().numSurfaces += 1 ;
		Gdx.Instance().numTris += no_tris ;
		Gdx.Instance().numVertex += no_verts ;
	}
      
   public function translate( x:Float,y:Float,z:Float):Void
   {
	   var m:Matrix4 = Matrix4.Translation(x, y, z);
	   for (i in 0...no_verts)
	   {
		   var v:Vector3 = getVertex(i);
		   v = m.transformVector(v);
		   var n:Vector3 = getNormal(i);
		   n = m.rotateVect(n);
		   setNormal(i, n);
		   setVertex(i, v);
	   }
	  	reset_vbo = reset_vbo | 1 | 4;
		updateBounding(); 
	   
   }
   public function scale( x:Float,y:Float,z:Float):Void
   {
	   var m:Matrix4 = Matrix4.Scaling(x, y, z);
	   transform(m);

   }
   public function rotate( y:Float,p:Float,r:Float):Void
   {
	   
	   var q:Quaternion = Quaternion.RotationYawPitchRoll(Util.deg2rad(y),Util.deg2rad(p),Util.deg2rad(r));
	   var m:Matrix4 = Matrix4.Identity();
	   q.toRotationMatrix(m);
	   transform(m);
   } 
  public function transform( m:Matrix4):Void
  {
	for (v in 0...no_verts)
	{
	var vx:Float =  vert_coords[v * 3];
	var vy:Float =  vert_coords[v * 3 + 1];
	var vz:Float =  vert_coords[v * 3 + 2];
	
	vert_coords[v * 3+0] = m.get00() * vx + m.get10() * vy + m.get20() * vz + m.get30();
	vert_coords[v * 3+1] = m.get01() * vx + m.get11() * vy + m.get21() * vz + m.get31();
	vert_coords[v * 3+2] = m.get02() * vx + m.get12() * vy + m.get22() * vz + m.get32();
	
	
	var nx:Float =  vert_norm[v * 3];
	var ny:Float =  vert_norm[v * 3 + 1];
	var nz:Float =  vert_norm[v * 3 + 2];
	
	vert_norm[v * 3 + 0] = m.get00() * nx + m.get10() * ny + m.get20() * nz ;
	vert_norm[v * 3 + 1] = m.get01() * nx + m.get11() * ny + m.get21() * nz;
	vert_norm[v * 3 + 2] = m.get02() * nx + m.get12() * ny + m.get22() * nz;
   }
	
		reset_vbo = reset_vbo | 1 | 4;
		updateBounding();
}

	public  function ComputeNormal() 
   {
		var positionVectors:Array<Vector3> = [];
        var facesOfVertices:Array<Array<Int>> = [];
		
        var index:Int = 0;

		while (index < vert_coords.length) 
		{
            var vector3 = new Vector3(vert_coords[index], vert_coords[index + 1], vert_coords[index + 2]);
            positionVectors.push(vector3);
            facesOfVertices.push([]);
			index += 3;
        }
		
        // Compute normals
        var facesNormals:Array<Vector3> = [];
        for (index in 0...Std.int(tris.length / 3)) {
            var i1 = tris[index * 3];
            var i2 = tris[index * 3 + 1];
            var i3 = tris[index * 3 + 2];

            var p1 = positionVectors[i1];
            var p2 = positionVectors[i2];
            var p3 = positionVectors[i3];

            var p1p2 = p1.subtract(p2);
            var p3p2 = p3.subtract(p2);

            facesNormals[index] = Vector3.Normalize(Vector3.Cross(p1p2, p3p2));
            facesOfVertices[i1].push(index);
            facesOfVertices[i2].push(index);
            facesOfVertices[i3].push(index);
        }

        for (index in 0...positionVectors.length) 
		{
            var faces:Array<Int> = facesOfVertices[index];

            var normal:Vector3 = Vector3.Zero();
            for (faceIndex in 0...faces.length) 
			{
                normal.addInPlace(facesNormals[faces[faceIndex]]);
            }

            normal = Vector3.Normalize(normal.scale(1.0 / faces.length));

            vert_norm[index * 3] = normal.x;
            vert_norm[index * 3 + 1] = normal.y;
            vert_norm[index * 3 + 2] = normal.z;
        }
		reset_vbo=reset_vbo|4;
	}
	public  function ComputeNormalFlat() 
   {
	
		
 
 
       for (index in 0...Std.int(tris.length / 3)) 
		{
            var p0 = getFace(index, 0);
			var p1 = getFace(index, 1);
			var p2 = getFace(index, 2);
         var p:Plane = Plane.FromPoints(p2, p1, p0);
			
			setFaceNormal(index,0, p.normal);
			setFaceNormal(index,1, p.normal);
			setFaceNormal(index,2, p.normal);
          }
		
		reset_vbo=reset_vbo|4;
	}
	public  function ComputeNormalSmooth() 
   {
     
       for (index in 0...Std.int(tris.length / 3)) 
		{
           
			
			setFaceNormal(index, 0, Vector3.zero);
			setFaceNormal(index, 1, Vector3.zero);
			setFaceNormal(index, 2, Vector3.zero);
			
		
			
          }
	
		for (index in 0...Std.int(tris.length / 3)) 
		{
        		
			var p0 = getFace(index, 0);
			var p1 = getFace(index, 1);
			var p2 = getFace(index, 2);
            var p:Plane = Plane.FromPoints(p2, p1, p0);
			
			var weight = Vector3.getAngleWeight(p2, p1, p0);
			
			var n:Vector3 = Vector3.Add(weight, p.normal);
			n.normalize();
			
			setFaceNormal(index,0,n);
			setFaceNormal(index,1,n);
			setFaceNormal(index,2,n);
          }
		reset_vbo=reset_vbo|4;
	


	}
	/*
	public function makePlanarMapping(resolution:Float):Void
	{
		

		
	
		for (index in  0... Std.int(tris.length / 3)) 
		{
            var p0 = getVertex(tris[index*3+0]);
			var p1 = getVertex(tris[index*3+1]);
			var p2 = getVertex(tris[index*3+2]);
			
			var p:Plane = Plane.FromPoints(p2, p1, p0);
			
		p.normal.x = Math.abs(p.normal.x);
		p.normal.y = Math.abs(p.normal.y);
		p.normal.z = Math.abs(p.normal.z);
	
		if(p.normal.x > p.normal.y && p.normal.x > p.normal.z)
		{
			
			for (i in 0 ... 3)
			{
				var Pos = getVertex(tris[index * 3 + i]);
				setUv0(tris[index * 3 + i],new Vector2(Pos.y * resolution, Pos.z * resolution));
				
			}
		 
		 
			
		}
		else if(p.normal.y > p.normal.x && p.normal.y > p.normal.z)
		{
		
		for (i in 0 ... 3)
			{
				var Pos = getVertex(tris[index * 3 + i]);
				setUv0(tris[index * 3 + i],new Vector2(Pos.x * resolution, Pos.z * resolution));
				
			}
		 
		
		}else
		{
	
		for (i in 0 ... 3)
			{
				var Pos = getVertex(tris[index * 3 + i]);
				setUv0(tris[index * 3 + i],new Vector2(Pos.x * resolution, Pos.y * resolution));
				
			}
		 
		 
		}
			
		
			//index += 3;
        }
		

			reset_vbo=reset_vbo|2;	
	}
*/
	public function makePlanarMapping(resolution:Float):Void
	{
	  var Pos:Vector3 = Vector3.zero;
        for (index in 0...Std.int(tris.length / 3)) 
		{
 
		
			var p0 = getFace(index,0);
			var p1 = getFace(index,1);
			var p2 = getFace(index,2);
			var p:Plane = Plane.FromPoints(p0, p1, p2);
		 	p.normal.normalize();
			
		
		p.normal.x = Math.abs(p.normal.x);
		p.normal.y = Math.abs(p.normal.y);
		p.normal.z = Math.abs(p.normal.z);
	
		//front  / sides
		if(p.normal.x > p.normal.y && p.normal.x > p.normal.z)
		{
			
			for (i in 0 ... 3)
			{
				Pos = getFace(index,i);
				setFaceUv0(index, i, new Vector2(Pos.y * resolution, Pos.z * resolution));
				setFaceUv1(index,i,new Vector2(Pos.y * resolution, Pos.z * resolution));
			}
		 
		 
			
		}
		else if(p.normal.y > p.normal.x && p.normal.y > p.normal.z)
		{
		
		for (i in 0 ... 3)
			{
				Pos = getFace(index,i);
				setFaceUv0(index, i, new Vector2(Pos.x * resolution, Pos.z * resolution));
				setFaceUv1(index,i,new Vector2(Pos.x * resolution, Pos.z * resolution));
			}
		
		}else
		{
	
		for (i in 0 ... 3)
			{
				Pos = getFace(index,i);
				setFaceUv0(index, i, new Vector2(Pos.x * resolution, Pos.y * resolution));
				setFaceUv1(index,i,new Vector2(Pos.x * resolution, Pos.y * resolution));
			}
		 
		}
		
	
		
			
		}
			reset_vbo=reset_vbo|2;	
	}


    public  function CountFaces():Int
   {
	   return Std.int(tris.length/3);
   }
    public  function CountTriangles():Int
   {
	   return no_tris;
   } 
    public  function CountVertices():Int
   {
	   return no_verts;
   }
   
    public  function getIndex(numface:Int):Int
   {
   
	return tris[numface];
   }
     public  function getIndice(numface:Int,index:Int):Int
   {
	   
	return tris[numface * 3 + index];
   }
    public  function getFace(numface:Int,index:Int):Vector3
   {
   
	return getVertex(tris[numface * 3 + index]);
   }
    public  function getFaceNormal(numface:Int,index:Int):Vector3
   {

	   
	return getNormal(tris[numface * 3 + index]);
   }
    
    public  function setFaceNormal(numface:Int,index:Int,v:Vector3):Void
   {

	   
	 setNormal(tris[numface * 3 + index],v);
   }
   public  function getFaceUv0(numface:Int,index:Int):Vector2
   {

	   
	return getUv0(tris[numface * 3 + index]);
   }
   public  function setFaceUv0(numface:Int,index:Int,v:Vector2):Void
   {
   
	setUv0(tris[numface * 3 + index],v);
   }
     public  function setFaceUv1(numface:Int,index:Int,v:Vector2):Void
   {
   
	setUv1(tris[numface * 3 + index],v);
   }
   public function getVertex(index:Int):Vector3
   {
	   return new Vector3(vert_coords[index*3+0], vert_coords[index *3+1], vert_coords[index *3+2]);
    }
	 public function getUv0(index:Int):Vector2
   {
	   return new Vector2(vert_tex_coords0[(index*2)+0], vert_tex_coords0[(index *2)+1]);
    }
	 public function setUv0(index:Int,v:Vector2):Void
   {
	   vert_tex_coords0[(index * 2) + 0] = v.x;
	   vert_tex_coords0[(index * 2) + 1] = v.y;
	   
	    
    }	
    public function getUv1(index:Int):Vector2
   {
	   return new Vector2(vert_tex_coords1[(index*2)+0], vert_tex_coords1[(index *2)+1]);
    }
	 public function setUv1(index:Int,v:Vector2):Void
   {
	   vert_tex_coords1[(index * 2) + 0] = v.x;
	   vert_tex_coords1[(index * 2) + 1] = v.y;
    }
	 public function setVertex(index:Int,v:Vector3):Void
   {
	   vert_coords[index * 3 + 0] = v.x;
	   vert_coords[index * 3 + 1] = v.y;
	   vert_coords[index * 3 + 2] = v.z;
   }  
	
	/*
	 * the normal vertex 
	 * 
	 */
	
   public function getNormal(index:Int):Vector3
   {
	   return new Vector3(vert_norm[index * 3 + 0], vert_norm[index * 3 + 1], vert_norm[index * 3 + 2]);
   }  
   public function setNormal(index:Int,v:Vector3):Void
   {
	   vert_norm[index * 3 + 0] = v.x;
	   vert_norm[index * 3 + 1] = v.y;
	   vert_norm[index * 3 + 2] = v.z;
   }  
   
	public  function getTriangles():Array<Triangle> 
   {
		var result:Array<Triangle> = [];
	    for (index in 0...Std.int(tris.length / 3)) 
		{
            var i1 = tris[index * 3];
            var i2 = tris[index * 3 + 1];
            var i3 = tris[index * 3 + 2];

			
            var p1 = getVertex(i1);
            var p2 = getVertex(i2);
            var p3 = getVertex(i3);
	        result.push(new Triangle(p1, p2, p3,getNormal(i1)));
       }
        return result;
      
	}	
	public  function getPlanes():Array<Plane> 
   {
	 var planes:Array<Plane>=[] ;

        for (index in 0...Std.int(tris.length / 3))
   {
            var i1 = tris[index * 3];
            var i2 = tris[index * 3 + 1];
            var i3 = tris[index * 3 + 2];
            var p1 = getVertex(i1);
            var p2 = getVertex(i2);
            var p3 = getVertex(i3);
			var plane:Plane = Plane.FromPoints(p3, p2, p1);
           planes.push(plane);
        }
        return planes;
      
	}	
	public function debugNormals(m:Matrix4,lines:Imidiatemode,length:Float)
	{
		
		for (i in 0... this.no_verts)
		{
			var v:Vector3 = getVertex(i);
			var n:Vector3 = Vector3.Mult( getNormal(i), length);
			
			v = m.transformVector(v);
			n = m.transformVector(n);
			
			
			lines.line3D(
			v.x, v.y, v.z, 
			v.x + n.x, v.y + n.y, v.z + n.z,
			1, 0, 0);
	//	trace(n.toString());
			
		}

		/*  for (index in 0...Std.int(tris.length / 3)) 
		  {
            var i1 = tris[index * 3];
            var i2 = tris[index * 3 + 1];
            var i3 = tris[index * 3 + 2];
			
			var v = getVertex(i1);
			var n = getNormal(i1);
		
		
			lines.line3D(v.x, v.y, v.z, v.x+(n.x*length), v.y+(n.y*length), v.z+(n.z*length),1,1,1,1);

		  }
*/

	}
	inline public function  BoxIntersects(ray:Ray):Bool 
	{
        return ray.intersectsBox(this.Bounding.boundingBox);
    }
	inline public function intersects(ray:Ray, fastCheck:Bool = false):Float
	{
        var distance = Math.POSITIVE_INFINITY;

        // Triangles test
		var index:Int = 0;
		while (index < this.CountTriangles())
		{
            var p0 = getVertex(tris[index]);
            var p1 = getVertex(tris[index + 1]);
            var p2 = getVertex(tris[index + 2]);

            var currentDistance = ray.intersectsTriangle(p2, p1, p0);

            if (currentDistance > 0) 
			{
                if (fastCheck || currentDistance < distance) 
				{
                    distance = currentDistance;

                    if (fastCheck) {
                        break;
                    }
                }
            }
			
			index += 3;
        }

        if (!(distance > 0 && distance < Math.POSITIVE_INFINITY)) {
            distance = 0;
		}

        return distance;
    }
	 public function dispose()
	{
		brush = null;
		if (vertexbuffer != null) 
		{
			vertexbuffer.dispose();
			vertexbuffer = null;
		}
		if (singleBuffer != null)
		{
			singleBuffer.dispose();
			singleBuffer = null;
			
		}
	}
}