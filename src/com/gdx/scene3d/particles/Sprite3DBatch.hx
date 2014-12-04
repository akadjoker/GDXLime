package com.gdx.scene3d.particles ;

import com.gdx.Clip;
import com.gdx.color.Color3;
import com.gdx.gl.shaders.Brush;
import com.gdx.gl.Texture;
import com.gdx.math.Matrix4;
import com.gdx.math.Vector3;
import com.gdx.scene3d.buffer.ArrayBuffer;
import com.gdx.scene3d.buffer.IndexSingleBuffer;
import com.gdx.scene3d.buffer.VertexBuffer;
import com.gdx.scene3d.SceneNode;
import com.gdx.Util;
import haxe.xml.Fast;
import lime.Assets;
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
class Sprite3DBatch  extends SceneNode
{

	
	private var vertexStrideSize:Int;

	
	private	var vertex:Float32Array;
	private var currentBatchSize:Int;
    private  var texture :Texture;
	private var buffer:IndexSingleBuffer;
	private var clip:Array<Clip>;
	private var MaxSprites:Int;
	public var brush:Brush;
	private var horizontal:Vector3 = Vector3.Zero();
	private var vertical:Vector3 = Vector3.Zero();
	private var invTexWidth:Float = 0;
    private var invTexHeight:Float = 0;	
    public var numSprites (default, null) :Int = 0;

  
    public function new (maxSprites:Int,scene:Scene,Parent:SceneNode = null , id:Int = 0) 
    {
        super(scene, Parent, id, "Sprite3DBatch");
		
		 clip = [];
	 	brush = new Brush(0);
		brush.CullingFace = false;
		brush.DepthMask = false;
		brush.DepthTest = true;
		brush.BlendType = 0;
		brush.BlendFace = true;
		numSprites = 0;
		sprites=[];
		MaxSprites = maxSprites;
		
		InitWithTotal(MaxSprites);
		
    }


	public function setTexture(tex:Texture,frameWidth:Int=0, frameHeight:Int=0)
	{
			texture = tex;
		
			 var frame:Clip = new Clip (0,0,tex.width,tex.height, 0, 0);
			clip.push(frame);
		
		invTexWidth  = 1.0 / texture.width;
        invTexHeight = 1.0 / texture.height;
	}
public function addFrames(frameWidth:Int=0, frameHeight:Int=0)
	{
		if (frameWidth != 0 && frameHeight != 0)
		{
		var row:Int = Math.floor(texture.width / frameWidth);
		var column:Int = Math.floor(texture.height / frameHeight);
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
		}
	}
		public function LoadFrames(filename:String)
	{

		var xml:Xml = Xml.parse (Assets.getText(filename));
		var spriteSheetNode = xml.firstElement();
		var initFrameX = 0;
		var initFrameY = 0;
		var offsetFrameX = 0;
		var offsetFrameY = 0;
		var name:String="";
		var i = 0;

		for (frameNode in spriteSheetNode.elements()) 
		{
			
			var frameNodeFast = new Fast(frameNode);
		
			
			  if (frameNodeFast.has.frameX)
				{
					initFrameX = Std.parseInt ( frameNodeFast.att.frameX );
					offsetFrameX = Std.parseInt (frameNodeFast.att.frameX) - initFrameX;
				}
				if (frameNodeFast.has.frameY)
				{
					initFrameY = Std.parseInt ( frameNodeFast.att.frameY );
					offsetFrameY = Std.parseInt (frameNodeFast.att.frameY) - initFrameY;
				}
	
	
				name = frameNodeFast.att.name;
			   var frame:Clip = new Clip (
			   Std.parseInt (frameNodeFast.att.x),
			   Std.parseInt (frameNodeFast.att.y),
			   Std.parseInt (frameNodeFast.att.width),
			   Std.parseInt (frameNodeFast.att.height),
			   -offsetFrameX,
			   -offsetFrameY);
			   frame.name = name;
			    clip.push(frame);
			//	trace(frame.toString());
			
		}
		
		

	}
  
	public function getSpritePool(id:Int):Sprite3D
	{
		for (sprite in sprites)
		{
			if (sprite.Id != id) continue;
			if (sprite.active) continue;
			return sprite;			
		}
		return null;
	}
	
	public function addSprite(spr:Sprite3D):Void
	{
		sprites.push(spr);
	}
	public function createSprite(p:Vector3,size:Float,frame:Int,orientation:Int,id:Int=0):Sprite3D
	{
		var spr:Sprite3D=new Sprite3D(id);
		spr.active = true;
		spr.type = orientation;
		spr.position.copyFrom(p );
	    spr.alpha = 1;
		spr.life = 1;
		spr.size = size;
		spr.frame = frame;
		addSprite(spr);
		return spr;
	}
	public function createSpriteDecale(p:Vector3,n:Vector3,life:Float,size:Float,frame:Int,id:Int=0):Decale
	{
		var spr:Decale=new Decale(id);
		spr.active = true;
		spr.type = 4;
		spr.setPoint(p, n,size);
	    addSprite(spr);
		return spr;
	}	
	private function InitWithTotal(numberOf:Int)
	{
		currentBatchSize = 0;
		
    	  var indices:Array<Int> = [];
        var index = 0;
		var oldvertices:Int = 0;
        for (count in 0...Std.int(numberOf * 6)) {
            indices.push(index);
            indices.push(index + 2);
            indices.push(index + 1);
            indices.push(index );
            indices.push(index + 3);
            indices.push(index + 2);
            index += 4;
        }
		
		   
		
		buffer = new IndexSingleBuffer(scene.quadshader, true, false, true, false);
		buffer.uploadIndices(indices);
		vertexStrideSize =  (3+2+4) *4 ; 
	    vertex    = new Float32Array(numberOf*vertexStrideSize) ; 
		
			   
		
	
		
		
	}
	
   	public function drawAxisXBillboard(ii:Int,xsize:Float,zsize:Float,particle:Sprite3D):Void
	{
		    		 
			var index:Int = currentBatchSize *  vertexStrideSize;
			     	
 var u:Float = clip[particle.frame].x * invTexWidth;
 var v:Float = (clip[particle.frame].y + clip[particle.frame].height) * invTexHeight;
 var u2:Float = (clip[particle.frame].x + clip[particle.frame].width) * invTexWidth;
 var v2:Float = clip[particle.frame].y * invTexHeight;

			
	           var alpha:Float =  particle.alpha;
			   var color:Color3 = particle.color;
			   var P:Vector3 = particle.position;
			   
	  
			vertex[index++] = P.x; 
			vertex[index++] = P.y + xsize; 
			vertex[index++] = P.z + zsize;
	        vertex[index++] = u; vertex [index++] = v;
		    vertex[index++] =  color.r;
			vertex[index++] =  color.g;
			vertex[index++] =  color.b;
			vertex[index++] =  alpha;
		
			
			vertex[index++] = P.x; 
			vertex[index++] = P.y + xsize; 
			vertex[index++] = P.z - zsize;
	        vertex [index++] = u; vertex [index++] = v2;
			vertex[index++] =  color.r;
			vertex[index++] =  color.g;
			vertex[index++] =  color.b;
			vertex[index++] =  alpha;
	  
			vertex[index++] = P.x; 
			vertex[index++] = P.y - xsize; 
			vertex[index++] = P.z - zsize; 
		    vertex [index++] = u2; vertex [index++] = v2;
			vertex[index++] =  color.r;
			vertex[index++] =  color.g;
			vertex[index++] =  color.b;
			vertex[index++] =  alpha;
		  
			vertex[index++]  = P.x;
			vertex[index++] = P.y - xsize; 
			vertex[index++] = P.z + zsize; 
		    vertex [index++] = u2; vertex [index++] = v;	
		    vertex[index++] =  color.r;
			vertex[index++] =  color.g;
			vertex[index++] =  color.b;
			vertex[index++] =  alpha;
				
		this.currentBatchSize++;
		
		 
   	
	}

		public function drawAxisOrientedBillboard(ii:Int,xsize:Float,zsize:Float,particle:Decale):Void
	{
		    		 
			var index:Int = currentBatchSize *  vertexStrideSize;
			     	
 var u:Float = clip[particle.frame].x * invTexWidth;
 var v:Float = (clip[particle.frame].y + clip[particle.frame].height) * invTexHeight;
 var u2:Float = (clip[particle.frame].x + clip[particle.frame].width) * invTexWidth;
 var v2:Float = clip[particle.frame].y * invTexHeight;

			
	           var alpha:Float =  particle.alpha;
			   var color:Color3 = particle.color;
			   var P:Vector3 = particle.position;
			   
	  
			vertex[index++] = particle.position.x + ((-particle.right.x - particle.up.x) * particle.size);
			vertex[index++] = particle.position.y + ((-particle.right.y - particle.up.y) * particle.size);
			vertex[index++] = particle.position.z + ((-particle.right.z - particle.up.z) * particle.size);
	        vertex[index++] = u; vertex [index++] = v;
		    vertex[index++] =  color.r;
			vertex[index++] =  color.g;
			vertex[index++] =  color.b;
			vertex[index++] =  alpha;
		
			
			vertex[index++] = particle.position.x + ((particle.right.x - particle.up.x) * particle.size);
			vertex[index++] = particle.position.y + ((particle.right.y - particle.up.y) * particle.size);
			vertex[index++] = particle.position.z + ((particle.right.z - particle.up.z) * particle.size);
	        vertex [index++] = u; vertex [index++] = v2;
			vertex[index++] =  color.r;
			vertex[index++] =  color.g;
			vertex[index++] =  color.b;
			vertex[index++] =  alpha;
	  
			vertex[index++] = particle.position.x + ((particle.right.x + particle.up.x) * particle.size);
			vertex[index++] = particle.position.y + ((particle.right.y + particle.up.y) * particle.size);
			vertex[index++] = particle.position.z + ((particle.right.z + particle.up.z) * particle.size);
		    vertex [index++] = u2; vertex [index++] = v2;
			vertex[index++] =  color.r;
			vertex[index++] =  color.g;
			vertex[index++] =  color.b;
			vertex[index++] =  alpha;
		  
			vertex[index++]  = particle.position.x + ((-particle.right.x + particle.up.x) * particle.size);
			vertex[index++] = particle.position.y + ((-particle.right.y + particle.up.y) * particle.size);
			vertex[index++] = particle.position.z + ((-particle.right.z + particle.up.z) * particle.size);
		    vertex [index++] = u2; vertex [index++] = v;	
		    vertex[index++] =  color.r;
			vertex[index++] =  color.g;
			vertex[index++] =  color.b;
			vertex[index++] =  alpha;
				
		this.currentBatchSize++;
		
		 
   	
	}
	public function drawAxisYBillboard(ii:Int,xsize:Float,zsize:Float,particle:Sprite3D):Void
	{
	
	  		
			
				
	     	
  		 
			var index:Int = currentBatchSize *  vertexStrideSize;
			     	
 var u:Float = clip[particle.frame].x * invTexWidth;
 var v:Float = (clip[particle.frame].y + clip[particle.frame].height) * invTexHeight;
 var u2:Float = (clip[particle.frame].x + clip[particle.frame].width) * invTexWidth;
 var v2:Float = clip[particle.frame].y * invTexHeight;

			
	           var alpha:Float =  particle.alpha;
			   var color:Color3 = particle.color;
			   var P:Vector3 = particle.position;
			   
	  
			vertex[index++] = P.x - xsize; 
			vertex[index++] = P.y ; 
			vertex[index++] = P.z - zsize;
	        vertex[index++] = u; vertex [index++] = v;
		    vertex[index++] =  color.r;
			vertex[index++] =  color.g;
			vertex[index++] =  color.b;
			vertex[index++] =  alpha;
		
			
		
			
			vertex[index++] = P.x+xsize; 
			vertex[index++] = P.y ; 
			vertex[index++] = P.z - zsize;
	        vertex [index++] = u; vertex [index++] = v2;
			vertex[index++] =  color.r;
			vertex[index++] =  color.g;
			vertex[index++] =  color.b;
			vertex[index++] =  alpha;
			
			
	  
			vertex[index++] = P.x+xsize; 
			vertex[index++] = P.y ; 
			vertex[index++] = P.z + zsize; 
		    vertex [index++] = u2; vertex [index++] = v2;
			vertex[index++] =  color.r;
			vertex[index++] =  color.g;
			vertex[index++] =  color.b;
			vertex[index++] =  alpha;
			
				
		
		  
			vertex[index++]  = P.x-xsize;
			vertex[index++] = P.y ; 
			vertex[index++] = P.z + zsize; 
		    vertex [index++] = u2; vertex [index++] = v;	
		    vertex[index++] =  color.r;
			vertex[index++] =  color.g;
			vertex[index++] =  color.b;
			vertex[index++] =  alpha;
				
	
				this.currentBatchSize++;
		
		 
   	
	}
	
	
	public function drawAxisZBillboard(ii:Int,xsize:Float,ysize:Float,particle:Sprite3D):Void
	{
		    		 
		var index:Int = currentBatchSize *  vertexStrideSize;
			     	
 var u:Float = clip[particle.frame].x * invTexWidth;
 var v:Float = (clip[particle.frame].y + clip[particle.frame].height) * invTexHeight;
 var u2:Float = (clip[particle.frame].x + clip[particle.frame].width) * invTexWidth;
 var v2:Float = clip[particle.frame].y * invTexHeight;

			
	           var alpha:Float =  particle.alpha;
			   var color:Color3 = particle.color;
			   var P:Vector3 = particle.position;

	  
			
		 
			vertex[index++] = P.x - xsize; 
			vertex[index++] = P.y + ysize; 
			vertex[index++] = P.z ;
	        vertex[index++] = u; vertex [index++] = v;
		    vertex[index++] =  color.r;
			vertex[index++] =  color.g;
			vertex[index++] =  color.b;
			vertex[index++] =  alpha;
		
			
		
			
			vertex[index++] = P.x+xsize; 
			vertex[index++] = P.y+ysize; 
			vertex[index++] = P.z;
	        vertex [index++] = u; vertex [index++] = v2;
			vertex[index++] =  color.r;
			vertex[index++] =  color.g;
			vertex[index++] =  color.b;
			vertex[index++] =  alpha;
			
			
	  
			vertex[index++] = P.x+xsize; 
			vertex[index++] = P.y-ysize ; 
			vertex[index++] = P.z; 
		    vertex [index++] = u2; vertex [index++] = v2;
			vertex[index++] =  color.r;
			vertex[index++] =  color.g;
			vertex[index++] =  color.b;
			vertex[index++] =  alpha;
			
				
		
		  
			vertex[index++] = P.x-xsize;
			vertex[index++] = P.y-ysize; 
			vertex[index++] = P.z ; 
		    vertex [index++] = u2; vertex [index++] = v;	
		    vertex[index++] =  color.r;
			vertex[index++] =  color.g;
			vertex[index++] =  color.b;
			vertex[index++] =  alpha;
		
		
		 
   			this.currentBatchSize++;
		
	}


	 public function drawBillboard(ii:Int,horizontal:Vector3,vertical:Vector3,particle:Sprite3D):Void
	{
		    		 
			
	      
		   
			
			
	var index:Int = currentBatchSize *  vertexStrideSize;
			     	
 var u:Float = clip[particle.frame].x * invTexWidth;
 var v:Float = (clip[particle.frame].y + clip[particle.frame].height) * invTexHeight;
 var u2:Float = (clip[particle.frame].x + clip[particle.frame].width) * invTexWidth;
 var v2:Float = clip[particle.frame].y * invTexHeight;

			
	           var alpha:Float =  particle.alpha;
			   var color:Color3 = particle.color;
			   var P:Vector3 = particle.position;

	  
			
		 
			vertex[index++] = particle.position.x + horizontal.x + vertical.x;//baixo direita
			vertex[index++] = particle.position.y + horizontal.y + vertical.y;
			vertex[index++] = particle.position.z + horizontal.z + vertical.z;
	        vertex[index++] = u; vertex [index++] = v;
		    vertex[index++] =  color.r;
			vertex[index++] =  color.g;
			vertex[index++] =  color.b;
			vertex[index++] =  alpha;
		
			
		
			
			vertex[index++] = particle.position.x + horizontal.x - vertical.x;//cima direita
			vertex[index++] = particle.position.y + horizontal.y - vertical.y;
			vertex[index++] = particle.position.z + horizontal.z - vertical.z;
	        vertex [index++] = u; vertex [index++] = v2;
			vertex[index++] =  color.r;
			vertex[index++] =  color.g;
			vertex[index++] =  color.b;
			vertex[index++] =  alpha;
			
			
	  
			vertex[index++] =particle.position.x - horizontal.x - vertical.x;//cima esquerda
			vertex[index++] =particle.position.y - horizontal.y - vertical.y;
			vertex[index++] =particle.position.z - horizontal.z - vertical.z;
	        vertex [index++] = u2; vertex [index++] = v2;
			vertex[index++] =  color.r;
			vertex[index++] =  color.g;
			vertex[index++] =  color.b;
			vertex[index++] =  alpha;
			
				
		
			vertex[index++] = particle.position.x - horizontal.x + vertical.x;
			vertex[index++] = particle.position.y - horizontal.y + vertical.y;
			vertex[index++] = particle.position.z - horizontal.z + vertical.z;
		    vertex [index++] = u2; vertex [index++] = v;	
		    vertex[index++] =  color.r;
			vertex[index++] =  color.g;
			vertex[index++] =  color.b;
			vertex[index++] =  alpha;
		
		
		 
   			this.currentBatchSize++;
		
		
		 
   	
	}


	
	

	 override public function render(camera:Camera)
	{
		 var transform:Matrix4 = AbsoluteTransformation;
	     scene.quadshader.setWorldMatrix(transform);
	     var m:Matrix4 = camera.viewMatrix;		
	    currentBatchSize = 0;
		numSprites = 0;

    for (ii in 0...sprites.length)
    {
	         var particle:Sprite3D = sprites[ii];
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
						  case 4:
						 {
							 drawAxisOrientedBillboard(ii, particle.size, particle.size,cast particle);
						 }
			 }
			 numSprites++;
		   }
	 }
		
		if (currentBatchSize <= 0)		return;
			
		if (texture != null)
		{
        scene.quadshader.setTexture0(texture);
		}
	
		

	  brush.Applay();	
	  buffer.uploadDataBuffer(vertex);
      buffer.render(GL.TRIANGLES, currentBatchSize * 6);

		Gdx.Instance().numVertex     += currentBatchSize *4 ;
		Gdx.Instance().numTris += currentBatchSize *2 ;
  	}

	
	 override public function update()
	{
		super.update();
	  
       var dt:Float = Gdx.Instance().deltaTime;		
	   
	   var ii = 0;
        while (ii < sprites.length) 
		{
            var particle = sprites[ii];
                if (!particle.remove ) 
			    {
					particle.move(dt);
         	       ++ii;
                }
			else 
			{
                  sprites.remove(particle);
				  particle = null;
	        }
        }

   
	}
    

    private var sprites :Array<Sprite3D>;
   
	
}

