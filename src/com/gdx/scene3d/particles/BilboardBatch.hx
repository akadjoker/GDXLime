package com.gdx.scene3d.particles ;

import com.gdx.Clip;
import com.gdx.color.Color3;
import com.gdx.gl.shaders.Brush;
import com.gdx.gl.Texture;
import com.gdx.math.Matrix4;
import com.gdx.math.Vector3;
import com.gdx.scene3d.buffer.ArrayBuffer;
import com.gdx.scene3d.buffer.VertexBuffer;
import com.gdx.scene3d.SceneNode;
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
class BilboardBatch  extends SceneNode
{

	
	private var vertexStrideSize:Int;

	
	private	var vert_tex_coords:Float32Array;
	private var vert_col :Float32Array;
	private	var vert_coords:Float32Array;
	private var buffer:VertexBuffer;		
	private var currentBatchSize:Int;
    private  var texture :Texture;
	private var vertexbuffer:ArrayBuffer;
	private var clip:Array<Clip>;
	private var MaxDecales:Int;
	public var brush:Brush;
	private var horizontal:Vector3 = Vector3.Zero();
	private var vertical:Vector3 = Vector3.Zero();
	private var invTexWidth:Float = 0;
     private var invTexHeight:Float = 0;
	
	
  public var numParticles (default, null) :Int = 0;
  
    public function new (maxDecales:Int,scene:Scene,Parent:SceneNode = null , id:Int = 0) 
    {
        super(scene, Parent, id, "BilBoardBatch");
		
		 clip = [];
	 	brush = new Brush(0);
		brush.CullingFace = false;
		brush.DepthMask = false;
		brush.DepthTest = true;
		brush.BlendType = 0;
		brush.BlendFace = true;
		numParticles = 0;
		decales=[];
		MaxDecales = maxDecales;
		InitWithTotal(maxDecales);
		
    }

	public function addBillboard( pos:Vector3, size:Float,life:Float=10,frame:Int=0,type:Int=0):Void
	{
		 for (particle in decales)
	   {
		   if (particle.active==false)
		   {
			    particle.reset(pos, size, life,frame, type);
				break;
		   }
	   }
		
	}
	public function  count():Int
	{
		return this.decales.length;
	}
	public function setTexture(tex:Texture,frameWidth:Int=0, frameHeight:Int=0)
	{
			texture = tex;
		if (frameWidth != 0 && frameHeight != 0)
		{
		var row:Int = Math.floor(tex.width / frameWidth);
		var column:Int = Math.floor(tex.height / frameHeight);
		var index:Int = 0;
		for (i in 0 ... row)
		{
			for (j in 0 ... column)
			{
				    var frame:Clip = new Clip (i * frameWidth, j * frameHeight, frameWidth, frameHeight, 0, 0);
				    clip.push(frame);
					index++;
			}
		}
		} else
		{
			 var frame:Clip = new Clip (0,0,tex.width,tex.height, 0, 0);
			clip.push(frame);
		}
		invTexWidth  = 1.0 / texture.width;
        invTexHeight = 1.0 / texture.height;
	}

  
	private function InitWithTotal(numberOf:Int)
	{
    	  var indices:Array<Int> = [];
        var index = 0;
		var oldvertices:Int = 0;
        for (count in 0...Std.int(numberOf * 6)) {
            indices.push(index + 0);
            indices.push(index + 2);
            indices.push(index + 1);
            indices.push(index + 0);
            indices.push(index + 3);
            indices.push(index + 2);
            index += 4;
        }
		
		buffer = new VertexBuffer(scene.quadshader, true, false, true, false);
		buffer.uploadIndices(indices);
		

	    vert_coords    = new Float32Array(numberOf*3*4) ; 
		vert_tex_coords= new Float32Array(numberOf*2*4) ; 
     	vert_col =     new Float32Array(numberOf * 4 * 4) ; 
		
			   
		
	for (i in 0...numberOf)
	{
		decales.push(new BillSprite(Vector3.zero, 0, 0, 0));
	}
		
		
	}
	
   	public function drawAxisXBillboard(ii:Int,xsize:Float,zsize:Float,particle:BillSprite):Void
	{
		    		 
			
	           var alpha:Float =  particle.alpha;
			   var P:Vector3 = particle.position;
	  
			vert_coords[(ii * 12) + 0] = P.x; 
			vert_coords[(ii * 12) + 1] = P.y + xsize; 
			vert_coords[(ii * 12) + 2] = P.z + zsize;
			
			vert_coords[(ii * 12) + 3] =P.x; 
			vert_coords[(ii * 12) + 4] = P.y + xsize; 
			vert_coords[(ii * 12) + 5] = P.z - zsize;
			
			vert_coords[(ii * 12) + 6] = P.x; 
			vert_coords[(ii * 12) + 7] = P.y - xsize; 
			vert_coords[(ii * 12) + 8] = P.z - zsize; 
			
			vert_coords[(ii * 12) + 9]  = P.x;
			vert_coords[(ii * 12) + 10] = P.y - xsize; 
			vert_coords[(ii * 12) + 11] = P.z + zsize; 
			
	     	
 var u:Float = clip[particle.frame].x * invTexWidth;
 var v:Float = (clip[particle.frame].y + clip[particle.frame].height) * invTexHeight;
 var u2:Float = (clip[particle.frame].x + clip[particle.frame].width) * invTexWidth;
 var v2:Float = clip[particle.frame].y * invTexHeight;
			
	  vert_tex_coords [(ii * 8) + 0] = u; vert_tex_coords [(ii * 8) +1] = v2;
	  vert_tex_coords [(ii * 8) + 2] = u; vert_tex_coords [(ii * 8) +3] = v;
	  vert_tex_coords [(ii * 8) + 4] = u2; vert_tex_coords [(ii * 8) +5] = v;
	  vert_tex_coords [(ii * 8) + 6] = u2; vert_tex_coords [(ii * 8) +7] = v2;

	  
	  var alpha:Float =  particle.alpha;
	  

	  
	        vert_col[(ii * 16) + 0] =  1;
			vert_col[(ii * 16) + 1] =  1;
			vert_col[(ii * 16) + 2] =  1;
			vert_col[(ii * 16) + 3] =  alpha;
			
		    vert_col[(ii * 16) + 4] =  1;
			vert_col[(ii * 16) + 5] =  1;
			vert_col[(ii * 16) + 6] =  1;
			vert_col[(ii * 16) + 7] =  alpha;
			
			vert_col[(ii * 16) + 8] =  1;
			vert_col[(ii * 16) + 9] =  1;
			vert_col[(ii * 16) + 10] =  1;
			vert_col[(ii * 16) + 11] =  alpha;
			
		    vert_col[(ii * 16) + 12] =  1;
			vert_col[(ii * 16) + 13] =  1;
			vert_col[(ii * 16) + 14] =  1;
			vert_col[(ii * 16) + 15] =  alpha;

		
		
		 
   	
	}

	public function drawAxisYBillboard(ii:Int,xsize:Float,zsize:Float,particle:BillSprite):Void
	{
		    		 
			
	           var alpha:Float =  particle.alpha;
			   var P:Vector3 = particle.position;
	  
			vert_coords[(ii * 12) + 0] = P.x - xsize;
			vert_coords[(ii * 12) + 1] = P.y; 
			vert_coords[(ii * 12) + 2] = P.z - zsize;
			
			vert_coords[(ii * 12) + 3] = P.x + xsize; 
			vert_coords[(ii * 12) + 4] = P.y;
			vert_coords[(ii * 12) + 5] = P.z - zsize;
			
			vert_coords[(ii * 12) + 6] = P.x + xsize;
			vert_coords[(ii * 12) + 7] = P.y;
			vert_coords[(ii * 12) + 8] = P.z + zsize; 
			
			vert_coords[(ii * 12) + 9]  = P.x - xsize;
			vert_coords[(ii * 12) + 10] = P.y;
			vert_coords[(ii * 12) + 11] = P.z + zsize; 
			
	     	
		
 var u:Float = clip[particle.frame].x * invTexWidth;
 var v:Float = (clip[particle.frame].y + clip[particle.frame].height) * invTexHeight;
 var u2:Float = (clip[particle.frame].x + clip[particle.frame].width) * invTexWidth;
 var v2:Float = clip[particle.frame].y * invTexHeight;
	  vert_tex_coords [(ii * 8) + 0] = u; vert_tex_coords [(ii * 8) +1] = v2;
	  vert_tex_coords [(ii * 8) + 2] = u; vert_tex_coords [(ii * 8) +3] = v;
	  vert_tex_coords [(ii * 8) + 4] = u2; vert_tex_coords [(ii * 8) +5] = v;
	  vert_tex_coords [(ii * 8) + 6] = u2; vert_tex_coords [(ii * 8) +7] = v2;

	
	  var alpha:Float =  particle.alpha;
	  

	  
	        vert_col[(ii * 16) + 0] =  1;
			vert_col[(ii * 16) + 1] =  1;
			vert_col[(ii * 16) + 2] =  1;
			vert_col[(ii * 16) + 3] =  alpha;
			
		    vert_col[(ii * 16) + 4] =  1;
			vert_col[(ii * 16) + 5] =  1;
			vert_col[(ii * 16) + 6] =  1;
			vert_col[(ii * 16) + 7] =  alpha;
			
			vert_col[(ii * 16) + 8] =  1;
			vert_col[(ii * 16) + 9] =  1;
			vert_col[(ii * 16) + 10] =  1;
			vert_col[(ii * 16) + 11] =  alpha;
			
		    vert_col[(ii * 16) + 12] =  1;
			vert_col[(ii * 16) + 13] =  1;
			vert_col[(ii * 16) + 14] =  1;
			vert_col[(ii * 16) + 15] =  alpha;
		
		
		 
   	
	}
	
	
	public function drawAxisZBillboard(ii:Int,xsize:Float,ysize:Float,particle:BillSprite):Void
	{
		    		 

	           var alpha:Float =  particle.alpha;
			   var P:Vector3 = particle.position;
	  
			vert_coords[(ii * 12) + 0] = P.x - xsize;
			vert_coords[(ii * 12) + 1] = P.y + ysize;
			vert_coords[(ii * 12) + 2] = P.z;
			
			vert_coords[(ii * 12) + 3] = P.x + xsize; 
			vert_coords[(ii * 12) + 4] = P.y +ysize;
			vert_coords[(ii * 12) + 5] = P.z;
			
			vert_coords[(ii * 12) + 6] = P.x + xsize;
			vert_coords[(ii * 12) + 7] = P.y - ysize;
			vert_coords[(ii * 12) + 8] = P.z;
			
			vert_coords[(ii * 12) + 9]  = P.x - xsize;
			vert_coords[(ii * 12) + 10] = P.y - ysize;
			vert_coords[(ii * 12) + 11] = P.z;
			
	     	
		
			
 var u:Float = clip[particle.frame].x * invTexWidth;
 var v:Float = (clip[particle.frame].y + clip[particle.frame].height) * invTexHeight;
 var u2:Float = (clip[particle.frame].x + clip[particle.frame].width) * invTexWidth;
 var v2:Float = clip[particle.frame].y * invTexHeight;
	  vert_tex_coords [(ii * 8) + 0] = u; vert_tex_coords [(ii * 8) +1] = v2;
	  vert_tex_coords [(ii * 8) + 2] = u; vert_tex_coords [(ii * 8) +3] = v;
	  vert_tex_coords [(ii * 8) + 4] = u2; vert_tex_coords [(ii * 8) +5] = v;
	  vert_tex_coords [(ii * 8) + 6] = u2; vert_tex_coords [(ii * 8) +7] = v2;
	    var alpha:Float =  particle.alpha;
	  

	  
	        vert_col[(ii * 16) + 0] =  1;
			vert_col[(ii * 16) + 1] =  1;
			vert_col[(ii * 16) + 2] =  1;
			vert_col[(ii * 16) + 3] =  alpha;
			
		    vert_col[(ii * 16) + 4] =  1;
			vert_col[(ii * 16) + 5] =  1;
			vert_col[(ii * 16) + 6] =  1;
			vert_col[(ii * 16) + 7] =  alpha;
			
			vert_col[(ii * 16) + 8] =  1;
			vert_col[(ii * 16) + 9] =  1;
			vert_col[(ii * 16) + 10] =  1;
			vert_col[(ii * 16) + 11] =  alpha;
			
		    vert_col[(ii * 16) + 12] =  1;
			vert_col[(ii * 16) + 13] =  1;
			vert_col[(ii * 16) + 14] =  1;
			vert_col[(ii * 16) + 15] =  alpha;

		
		
		 
   	
	}


	 public function drawBillboard(ii:Int,horizontal:Vector3,vertical:Vector3,particle:BillSprite):Void
	{
		    		 
			
	      
		    vert_coords[(ii * 12) + 0] = particle.position.x + horizontal.x + vertical.x;//baixo direita
			vert_coords[(ii * 12) + 1] = particle.position.y + horizontal.y + vertical.y;
			vert_coords[(ii * 12) + 2] = particle.position.z + horizontal.z + vertical.z;
			
			vert_coords[(ii * 12) + 3] = particle.position.x + horizontal.x - vertical.x;//cima direita
			vert_coords[(ii * 12) + 4] = particle.position.y + horizontal.y - vertical.y;
			vert_coords[(ii * 12) + 5] = particle.position.z + horizontal.z - vertical.z;
			
			vert_coords[(ii * 12) + 6] = particle.position.x - horizontal.x - vertical.x;//cima esquerda
			vert_coords[(ii * 12) + 7] = particle.position.y - horizontal.y - vertical.y;
			vert_coords[(ii * 12) + 8] = particle.position.z - horizontal.z - vertical.z;
			
			vert_coords[(ii * 12) + 9]  = particle.position.x - horizontal.x + vertical.x;
			vert_coords[(ii * 12) + 10] = particle.position.y - horizontal.y + vertical.y;
			vert_coords[(ii * 12) + 11] = particle.position.z - horizontal.z + vertical.z;
			
			
			
		
			
 var u:Float = clip[particle.frame].x * invTexWidth;
 var v:Float = (clip[particle.frame].y + clip[particle.frame].height) * invTexHeight;
 var u2:Float = (clip[particle.frame].x + clip[particle.frame].width) * invTexWidth;
 var v2:Float = clip[particle.frame].y * invTexHeight;
			
	  vert_tex_coords [(ii * 8) + 0] = u; vert_tex_coords [(ii * 8) +1] = v2;
	  vert_tex_coords [(ii * 8) + 2] = u; vert_tex_coords [(ii * 8) +3] = v;
	  vert_tex_coords [(ii * 8) + 4] = u2; vert_tex_coords [(ii * 8) +5] = v;
	  vert_tex_coords [(ii * 8) + 6] = u2; vert_tex_coords [(ii * 8) +7] = v2;
	  
	  
	  
	  var alpha:Float =  particle.alpha;
	  

	  
	        vert_col[(ii * 16) + 0] =  1;
			vert_col[(ii * 16) + 1] =  1;
			vert_col[(ii * 16) + 2] =  1;
			vert_col[(ii * 16) + 3] =  alpha;
			
		    vert_col[(ii * 16) + 4] =  1;
			vert_col[(ii * 16) + 5] =  1;
			vert_col[(ii * 16) + 6] =  1;
			vert_col[(ii * 16) + 7] =  alpha;
			
			vert_col[(ii * 16) + 8] =  1;
			vert_col[(ii * 16) + 9] =  1;
			vert_col[(ii * 16) + 10] =  1;
			vert_col[(ii * 16) + 11] =  alpha;
			
		    vert_col[(ii * 16) + 12] =  1;
			vert_col[(ii * 16) + 13] =  1;
			vert_col[(ii * 16) + 14] =  1;
			vert_col[(ii * 16) + 15] =  alpha;

		
		
		 
   	
	}


	
	

	 override public function render(camera:Camera)
	{
		 var transform:Matrix4 = AbsoluteTransformation;
	     scene.quadshader.setWorldMatrix(transform);
	     var m:Matrix4 = camera.viewMatrix;		
	    numParticles = 0;

    for (ii in 0...decales.length)
    {
	         var particle = decales[ii];
			 if (!particle.active) continue;
	 	   if (particle.active)
		   {
			
			 switch (particle.type)
			 {
				 case 0:
					 {
						    
			          var   xOffset =   ( clip[particle.frame].width  / 2   * particle.size)/100;
                      var   yOffset =   ( clip[particle.frame].height / 2   * particle.size)/100;
			          horizontal.set(m.m[0] * xOffset, m.m[4] * xOffset, m.m[8] * xOffset);
			          vertical.set(m.m[1] * yOffset, m.m[5] * yOffset, m.m[9] * yOffset);
    	    	      drawBillboard(ii, horizontal, vertical, particle);
					 }
					 case 1:
						 {
							 drawAxisXBillboard(ii, particle.size, particle.size, particle);
						 }
						 case 2:
						 {
							 drawAxisYBillboard(ii, particle.size, particle.size, particle);
						 }
						 case 3:
						 {
							 drawAxisZBillboard(ii, particle.size, particle.size, particle);
						 }
			 }
			 numParticles++;
		   }
	 }
		
					
		if (texture != null)
		{
        scene.quadshader.setTexture0(texture);
		}
	
		

	  brush.Applay();	
     
	

		    

buffer.setVertex(vert_coords);
buffer.setUVCoord0(vert_tex_coords);
buffer.setColors(vert_col);
buffer.render(GL.TRIANGLES, numParticles * 6);

		Gdx.Instance().numVertex     += numParticles *4 ;
		Gdx.Instance().numTris += numParticles *2 ;
  	}

	
	 override public function update()
	{
		super.update();
	  
       var dt:Float = Gdx.Instance().deltaTime;		
	   
	   for (particle in decales)
	   {
		   if (particle.active)
		   {
			   
			     var alphaLerp:Float = (1 - particle.life) / particle.startlife * dt;
			     particle.life -= dt;// (1.0 * dt);
			   
			   //	particle.size =   Util.lerp(particle.size,  0.2 , alphaLerp);
				particle.alpha =  Util.lerp(particle.alpha , 0.01, alphaLerp);
		
				//trace(particle.size+" , " + particle.alpha+" , "+alphaLerp);
		
		//	particle.alpha = particle.alpha - (1.0 * dt);
		//	particle.size = particle.size - (1.0 * dt);
						
			    
				
				 if (particle.life <= 0.0)
				 {
					 particle.active = false;
				 }
		   }
	   }
	   
	  
	
		
		
	 
    }


   

    

    private var decales :Array<BillSprite>;
   
	
}

private class BillSprite
{
    public var position :Vector3;
	public var alpha :Float ;
    public var life :Float ;
	public var size :Float ;
	public var type:Int;
	public var active:Bool;
	public var frame:Int;
	public var startlife:Float;
	public var startsize:Float;
	
    public function new (p:Vector3,s:Float,life:Float,type:Int) 
	{
	    this.active = false;
		this.type = type;
		this.position = new Vector3(p.x, p.y, p.z);
	    this.alpha = 1;
		this.life = life;
		this.size = s;
	}
	public function reset (p:Vector3,s:Float,life:Float,frame:Int,type:Int) 
	{
		this.startlife = life;
		this.frame = frame;
	    this.active = true;
		this.type = type;
		this.position.set(p.x, p.y, p.z);
	    this.alpha = 1;
		this.life = life;
		this.size = s;
		this.startsize = s;
	}
}