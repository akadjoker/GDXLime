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
class ParticleSystem  extends SceneNode
{

	
	private var vertexStrideSize:Int;

	
		var vert_tex_coords:Float32Array;
	    var vert_col :Float32Array;
		var vert_coords:Float32Array;
		private var buffer:VertexBuffer;		
		private var currentBatchSize:Int;

    public var texture :Texture;

    /** The current number of particles being shown. */
    public var numParticles (default, null) :Int = 0;

    public var maxParticles (get, set) :Int;

  
	public var alphaBlend:Bool;
    /** How long the emitter should remain enabled, or <= 0 to never expire. */
    public var duration :Float;

    /** Whether new particles are being actively emitted. */
    public var enabled :Bool = true;

    public var alphaStart (default, null) :Float;
    public var alphaStartVariance (default, null) :Float;

    public var alphaEnd (default, null) :Float;
    public var alphaEndVariance (default, null) :Float;



     public var EmitPosition:Vector3;

    public var lifespanVariance (default, null) :Float;
    public var lifespan (default, null) :Float;


    public var sizeStart (default, null) :Float;
    public var sizeStartVariance (default, null) :Float;
    public var sizeEnd (default, null) :Float;
 
	public var DirectionMin:Vector3;
	public var DirectionMax:Vector3;

	public var AccelerationMin :Vector3;
	public var AccelerationMax:Vector3;

	
	
	
	public var startColor:Color3 = new Color3();
	public var endColor:Color3 = new Color3();

	

	private var vertexbuffer:ArrayBuffer;

	
	
	private var clip:Clip;

	public var brush:Brush;


    public function new (texture:Texture,scene:Scene,Parent:SceneNode = null , id:Int = 0) 
    {
        super(scene, Parent, id, "ParticleSystem");
		
		alphaBlend = true;
		 clip = new Clip();
		 setTexture(texture, null);
		 _particles = new Array<Particle>();
	 	brush = new Brush(0);
		brush.CullingFace = false;
		brush.DepthMask = false;
		brush.DepthTest = false;
		brush.BlendType = 2;
		brush.BlendFace = true;
		EmitPosition=Vector3.zero;
		 createDefault(30);
    }

	public function setTexture(tex:Texture,?tex_clip:Clip=null)
	{
			texture = tex;
		
		if (tex_clip != null)
		{
			clip = tex_clip;
		} else
		{
		 clip.set(0, 0, texture.width, texture.height);
		}
	}
	public function createDefault(numberOfParticles:Int=255)
	{
	
		InitWithTotalParticles(numberOfParticles);

			setupEmitter(-1, 
			new Vector3( -0.2, 0.5, -0.2), new Vector3(0.2, 2, 0.2), 
			new Vector3(0, 0, 0), new Vector3(0,0,0),
		 1, 0.8, 0.2, 
		Color3.DARKORANGE, Color3.YELLOW, 
		1, 0.0, 
		1.5, 0.5);
	
	
  }
	public function createFire(numberOfParticles:Int=255)
	{
	
		InitWithTotalParticles(numberOfParticles);

			setupEmitter(-1, 
			new Vector3( -0.2, 1, -0.2), new Vector3(0.2, 2, 0.2), 
			new Vector3(-0.01, -0.2, -0.01), new Vector3(0.01, -0.5, 0.01),
		1, 0.8, 0.2, 
		new Color3(0,0,0), new Color3(0,1,0), 
		1, 0.1, 
		1, 0.8);
	
	
  }
  
	public function InitWithTotalParticles(numberOfParticles:Int)
	{
    	  var indices:Array<Int> = [];
        var index = 0;
		var oldvertices:Int = 0;
        for (count in 0...Std.int(numberOfParticles * 6)) {
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
		

	    vert_coords    = new Float32Array(numberOfParticles*3*4) ; 
		vert_tex_coords= new Float32Array(numberOfParticles*2*4) ; 
     	vert_col =     new Float32Array(numberOfParticles * 4 * 4) ; 
		
			   
		
	
	
        var ii = 0, ll = numberOfParticles;
		while (ii < ll) 
		{
	        _particles[ii] = new Particle();
            ++ii;
        }
		
		
		
	}
	
    public function restart ()
    {

        enabled = true;
        _totalElapsed = 0;
    }

	
	public function drawAxisXBillboard(ii:Int,xsize:Float,zsize:Float,particle:Particle):Void
	{
		    		 
			   var color:Color3 =  particle.color;
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
			
	     	
		
			
	  vert_tex_coords [(ii * 8) + 0] = 0.0; vert_tex_coords [(ii * 8) +1] = 0.0;
	  vert_tex_coords [(ii * 8) + 2] = 0.0; vert_tex_coords [(ii * 8) +3] = 1.0;
	  vert_tex_coords [(ii * 8) + 4] = 1.0; vert_tex_coords [(ii * 8) +5] = 1.0;
	  vert_tex_coords [(ii * 8) + 6] = 1.0; vert_tex_coords [(ii * 8) +7] = 0.0;

	  
	  var color:Color3 =  particle.color;
	  var alpha:Float =  particle.alpha;
	  

	  
	        vert_col[(ii * 16) + 0] =  color.r;
			vert_col[(ii * 16) + 1] =  color.g;
			vert_col[(ii * 16) + 2] =  color.b;
			vert_col[(ii * 16) + 3] =  alpha;
			
		    vert_col[(ii * 16) + 4] =  color.r;
			vert_col[(ii * 16) + 5] =  color.g;
			vert_col[(ii * 16) + 6] =  color.b;
			vert_col[(ii * 16) + 7] =  alpha;
			
			vert_col[(ii * 16) + 8] =  color.r;
			vert_col[(ii * 16) + 9] =  color.g;
			vert_col[(ii * 16) + 10] =  color.b;
			vert_col[(ii * 16) + 11] =  alpha;
			
		    vert_col[(ii * 16) + 12] =  color.r;
			vert_col[(ii * 16) + 13] =  color.g;
			vert_col[(ii * 16) + 14] =  color.b;
			vert_col[(ii * 16) + 15] =  alpha;

		
		
		 
   	
	}

	public function drawAxisYBillboard(ii:Int,xsize:Float,zsize:Float,particle:Particle):Void
	{
		    		 
			   var color:Color3 =  particle.color;
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
			
	     	
		
			
	  vert_tex_coords [(ii * 8) + 0] = 0.0; vert_tex_coords [(ii * 8) +1] = 0.0;
	  vert_tex_coords [(ii * 8) + 2] = 0.0; vert_tex_coords [(ii * 8) +3] = 1.0;
	  vert_tex_coords [(ii * 8) + 4] = 1.0; vert_tex_coords [(ii * 8) +5] = 1.0;
	  vert_tex_coords [(ii * 8) + 6] = 1.0; vert_tex_coords [(ii * 8) +7] = 0.0;

	  
	  var color:Color3 =  particle.color;
	  var alpha:Float =  particle.alpha;
	  

	  
	        vert_col[(ii * 16) + 0] =  color.r;
			vert_col[(ii * 16) + 1] =  color.g;
			vert_col[(ii * 16) + 2] =  color.b;
			vert_col[(ii * 16) + 3] =  alpha;
			
		    vert_col[(ii * 16) + 4] =  color.r;
			vert_col[(ii * 16) + 5] =  color.g;
			vert_col[(ii * 16) + 6] =  color.b;
			vert_col[(ii * 16) + 7] =  alpha;
			
			vert_col[(ii * 16) + 8] =  color.r;
			vert_col[(ii * 16) + 9] =  color.g;
			vert_col[(ii * 16) + 10] =  color.b;
			vert_col[(ii * 16) + 11] =  alpha;
			
		    vert_col[(ii * 16) + 12] =  color.r;
			vert_col[(ii * 16) + 13] =  color.g;
			vert_col[(ii * 16) + 14] =  color.b;
			vert_col[(ii * 16) + 15] =  alpha;

		
		
		 
   	
	}
	
	
	public function drawAxisZBillboard(ii:Int,xsize:Float,ysize:Float,particle:Particle):Void
	{
		    		 
			   var color:Color3 =  particle.color;
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
			
	     	
		
			
	  vert_tex_coords [(ii * 8) + 0] = 0.0; vert_tex_coords [(ii * 8) +1] = 0.0;
	  vert_tex_coords [(ii * 8) + 2] = 1.0; vert_tex_coords [(ii * 8) +3] = 0.0;
	  vert_tex_coords [(ii * 8) + 4] = 1.0; vert_tex_coords [(ii * 8) +5] = 1.0;
	  vert_tex_coords [(ii * 8) + 6] = 0.0; vert_tex_coords [(ii * 8) +7] = 1.0;

	  
	  var color:Color3 =  particle.color;
	  var alpha:Float =  particle.alpha;
	  

	  
	        vert_col[(ii * 16) + 0] =  color.r;
			vert_col[(ii * 16) + 1] =  color.g;
			vert_col[(ii * 16) + 2] =  color.b;
			vert_col[(ii * 16) + 3] =  alpha;
			
		    vert_col[(ii * 16) + 4] =  color.r;
			vert_col[(ii * 16) + 5] =  color.g;
			vert_col[(ii * 16) + 6] =  color.b;
			vert_col[(ii * 16) + 7] =  alpha;
			
			vert_col[(ii * 16) + 8] =  color.r;
			vert_col[(ii * 16) + 9] =  color.g;
			vert_col[(ii * 16) + 10] =  color.b;
			vert_col[(ii * 16) + 11] =  alpha;
			
		    vert_col[(ii * 16) + 12] =  color.r;
			vert_col[(ii * 16) + 13] =  color.g;
			vert_col[(ii * 16) + 14] =  color.b;
			vert_col[(ii * 16) + 15] =  alpha;

		
		
		 
   	
	}


	 public function drawBillboard(ii:Int,horizontal:Vector3,vertical:Vector3,particle:Particle):Void
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
			
			
			
		
			
	  vert_tex_coords [(ii * 8) + 0] = 0.0; vert_tex_coords [(ii * 8) +1] = 0.0;
	  vert_tex_coords [(ii * 8) + 2] = 0.0; vert_tex_coords [(ii * 8) +3] = 1.0;
	  vert_tex_coords [(ii * 8) + 4] = 1.0; vert_tex_coords [(ii * 8) +5] = 1.0;
	  vert_tex_coords [(ii * 8) + 6] = 1.0; vert_tex_coords [(ii * 8) +7] = 0.0;

	  
	  var color:Color3 =  particle.color;
	  var alpha:Float  =  particle.alpha;
	  

	  
	        vert_col[(ii * 16) + 0] =  color.r;
			vert_col[(ii * 16) + 1] =  color.g;
			vert_col[(ii * 16) + 2] =  color.b;
			vert_col[(ii * 16) + 3] =  alpha;
			
		    vert_col[(ii * 16) + 4] =  color.r;
			vert_col[(ii * 16) + 5] =  color.g;
			vert_col[(ii * 16) + 6] =  color.b;
			vert_col[(ii * 16) + 7] =  alpha;
			
			vert_col[(ii * 16) + 8] =  color.r;
			vert_col[(ii * 16) + 9] =  color.g;
			vert_col[(ii * 16) + 10] =  color.b;
			vert_col[(ii * 16) + 11] =  alpha;
			
		    vert_col[(ii * 16) + 12] =  color.r;
			vert_col[(ii * 16) + 13] =  color.g;
			vert_col[(ii * 16) + 14] =  color.b;
			vert_col[(ii * 16) + 15] =  alpha;

		
		
		 
   	
	}
	

	 override public function render(camera:Camera)
	{
		 var transform:Matrix4 = AbsoluteTransformation;
	     scene.quadshader.setWorldMatrix(transform);
		Bounding.boundingBox.reset(this.EmitPosition);
	
		
		
	
	    var m:Matrix4 = camera.viewMatrix;		
		
	

		
				
        

	var horizontal:Vector3 = Vector3.Zero();
	var vertical:Vector3 = Vector3.Zero();
	
	  

	
      

		
			
		

 var ii = 0;
 for (ii in 0...numParticles)

    {
	         var particle = _particles[ii];
			var   xOffset =   ( clip.width  / 2   * particle.scaleX)/100;
            var   yOffset =   ( clip.height / 2   * particle.scaleY)/100;
			
			    horizontal.set(m.m[0] * xOffset, m.m[4] * xOffset, m.m[8] * xOffset);
			    vertical.set(m.m[1] * yOffset, m.m[5] * yOffset, m.m[9] * yOffset);
    	    	drawBillboard(ii, horizontal, vertical, particle);
				//drawAxisZBillboard(ii, xOffset, yOffset, particle);
				Bounding.addInternalVector(particle.position);
			
	 }

	     Bounding.update(transform, 1);			
        if (numParticles <= 0) return;	 
       if (!Bounding.isInFrustrum(camera.frustumPlanes)) return;
	
		
		
					
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
	  this.getAbsoluteTransformation();
		
       var dt:Float = Gdx.Instance().deltaTime;
	   
        var ii = 0;
        while (ii < numParticles) 
		{
            var particle = _particles[ii];
                if (particle.life > 0) 
			    {
              
             var lerp:Float = (particle.startlife - particle.life) / particle.startlife * dt;
				
        
		particle.scaleX =   Util.lerp(particle.scaleX,  sizeEnd , lerp);
		particle.scaleY =   Util.lerp(particle.scaleY,  sizeEnd , lerp);
		particle.alpha =  Util.lerp(particle.alpha , alphaEnd, lerp);
	    particle.color = Color3.Lerp(particle.color, endColor, lerp);
			
				particle.position.x += particle.velocity.x * dt;
				particle.position.y += particle.velocity.y * dt;
				particle.position.z += particle.velocity.z * dt;
				
		    	
				
				particle.velocity.x +=particle.acceleration.x * dt;
				particle.velocity.y +=particle.acceleration.y * dt;
				particle.velocity.z +=particle.acceleration.z * dt;

				
				/*
					if (particle.position.y <= 0)
				{
					particle.position.y = 0;
					
						
					var normal:Vector3 = new Vector3(0, 1, 0);
					normal.normalize();
					var speed:Float = normal.DotProduct(particle.velocity);
	
					
					
					
					particle.velocity.x -= 2 * normal.x * speed;
					particle.velocity.y -= 2 * normal.y * speed;
					particle.velocity.z -= 2 * normal.z * speed;
					
					var bounce:Float = 1.0;
					
					particle.velocity.x *= bounce;
					particle.velocity.y *= bounce;
					particle.velocity.z *= bounce;
					
				}
				*/

                particle.life -=dt;
                ++ii;

            } else {
                   --numParticles;
                if (ii != numParticles) 
				{
                    _particles[ii] = _particles[numParticles];
                    _particles[numParticles] = particle;
	                }
            }
        }

        // Check whether we should continue to the emit step
        if (!enabled) 
		{
            return;
        }
        if (duration > 0)
		{
            _totalElapsed += dt;
            if (_totalElapsed >= duration) 
			{
                enabled = false;
                return;
            }
        }

	
		
        // Emit new particles
        var emitDelay =  lifespan / _particles.length;
        _emitElapsed += dt;
        while (_emitElapsed >= emitDelay)
		{
            if (numParticles < _particles.length) 
			{
                var particle = _particles[numParticles];
                if (initParticle(particle)) 
				{
					
                    ++numParticles;
                }
            }
            _emitElapsed -= emitDelay;
        }
		
			 super.update();
    }
 public function setupEmitter(
	duration:Float,
	minDirection:Vector3, maxDirection:Vector3,
	minAcceleration:Vector3, maxAcceleration:Vector3,
	startSize:Float, startVariance:Float, endSize:Float,
	ColorBegin:Color3, ColorEnd:Color3, 
	startAlpha:Float, endAlpha:Float,
	life:Float,lifeVariance:Float
	):Void
	{
	 DirectionMin = minDirection;
	 DirectionMax = maxDirection;
	 AccelerationMin = minAcceleration;
	 AccelerationMax = maxAcceleration;
	 this.duration = duration;
	 this.sizeStart = startSize;
	 this.sizeStartVariance = startVariance;
	 this.sizeEnd = endSize;
	 this.startColor = ColorBegin;
	 this.endColor = ColorEnd;
	 this.alphaStart = startAlpha;
	 this.alphaEnd = endAlpha;
	 this.lifespan = life;
	 this.lifespanVariance = lifeVariance;
	
	
	}
	
	public function setDirection(min:Vector3, max:Vector3):Void
	{
			 DirectionMin = min;
	 DirectionMax = max;
	}
 	public function getStartPosition():Vector3
	{
		
		return new Vector3(0,0,0);
	}

    private function initParticle (particle :Particle) :Bool
    {
        particle.startlife = random(lifespan, lifespanVariance);
     	particle.life = particle.startlife;
        particle.color = startColor;
	    particle.alpha = alphaStart;
		
		var size:Float = random(sizeStart, sizeStartVariance);
		
        particle.scaleX = size;
		particle.scaleY = size;


		particle.position = getStartPosition();
		
		
		//trace(_particles.length);


		
	    particle.acceleration.x = Util.randf(AccelerationMin.x, AccelerationMax.x);
		particle.acceleration.y = Util.randf(AccelerationMin.y, AccelerationMax.y);
		particle.acceleration.z = Util.randf(AccelerationMin.z, AccelerationMax.z);
		particle.velocity.x = Util.randf(DirectionMin.x, DirectionMax.x);
		particle.velocity.y = Util.randf(DirectionMin.y, DirectionMax.y);
		particle.velocity.z = Util.randf(DirectionMin.z, DirectionMax.z);
		
		
		
		
        return true;
    }

    inline private function get_maxParticles () :Int
    {
        return _particles.length;
    }

    private function set_maxParticles (maxParticles :Int) :Int
    {
        // Grow the pool
        var oldLength = _particles.length;
        while (oldLength < maxParticles) 
		{
            _particles[oldLength] = new Particle();
            ++oldLength;
        }

        if (numParticles > maxParticles) {
            numParticles = maxParticles;
        }

        return maxParticles;
    }

    private static function random (base :Float, variance :Float)
    {
        if (variance != 0) {
            base += variance * (2*Math.random()-1);
        }
        return base;
    }


    private var _particles :Array<Particle>;
    private var _emitElapsed :Float = 0;
    private var _totalElapsed :Float = 0;
}
private class Particle
{
    // Where the emitter was when the particle was spawned
    public var velocity :Vector3;
	public var position :Vector3;
	public var acceleration:Vector3;
	


    public var scaleX :Float = 0;
    public var scaleY :Float = 0;
  


    public var alpha :Float = 0;
   
    public var life :Float = 0;
	public var startlife:Float = 0;
	
	public var color:Color3;
	
    public function new () 
	{
		this.velocity = new Vector3(0, 0, 0);
		this.position = new Vector3(0, 0, 0);
		this.acceleration = new Vector3(0, 0, 0);
        this.startlife = 1;
		this.life = 1;
		color = new Color3();
			
		}
}
