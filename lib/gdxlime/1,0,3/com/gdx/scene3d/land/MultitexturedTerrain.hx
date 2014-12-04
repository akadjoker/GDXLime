package com.gdx.scene3d.land;

import com.gdx.gl.shaders.Brush;
import com.gdx.gl.shaders.Material;
import com.gdx.gl.shaders.TerrainShader;
import com.gdx.gl.Texture;
import com.gdx.math.Matrix4;
import com.gdx.math.Plane;
import com.gdx.math.Vector3;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLShader;
import lime.graphics.opengl.GLUniformLocation;
import lime.graphics.RenderContext;
import lime.utils.Float32Array;
import lime.utils.Int16Array;

import lime.graphics.Image;
import lime.graphics.ImageBuffer;
import lime.system.System;



import lime.Assets;

/**
 * ...
 * @author Luis Santos AKA DJOKER
 */
class MultitexturedTerrain extends SceneNode
{
	public var vertexBuffer:GLBuffer;
	public var indexBuffer:GLBuffer;
	public var pipeline:TerrainShader;
	public var vertex:Float32Array;
	public var indices:Int16Array;
	private var vertexStrideSize:Int;
	private var vertexStride:Int;
	private var numTriangles:Int;
		
	private var texture0:Texture;
	private var texture1:Texture;
	private var texture2:Texture;
	private var texture3:Texture;
	private var texture4:Texture;
	private var heightmap:Texture;
	 
	public var material:Material;

	
	public function new(HeightMap:String,highScale:Float,Precision:Float = 2,blockScale:Float = 2.0,scene:Scene,Parent:SceneNode = null , id:Int = 0, name:String="MultitexturedTerrain")  
	{
    	 super(scene, Parent, id, name);
	 	 pipeline = new TerrainShader();
		 
		material = new Material();
		
		
		 
		 
		 
		    var img:Image =  Assets.getImage(HeightMap);
		    heightmap  = Gdx.Instance().getTextureEx(img, false);
		    pipeline.setBumpScale(highScale);
		 

		 	var width:Int  = Math.round( img.width  / Precision);
            var height:Int = Math.round( img.height / Precision);
			
	
				
			 var numVerts:Int = width * height + 1;
		 vertexStrideSize = (3 + 3+ 2 ) * 4;
		 vertexStride = (3 + 3+ 2 );
	
	
	
		 var terrainWidth:Float = ( width - 1 )  * blockScale  ;
         var terrainHeight:Float = ( height - 1 ) * blockScale ;
         var halfTerrainWidth:Float  = terrainWidth * 0.5;
         var halfTerrainHeight:Float = terrainHeight * 0.5;
		 
		 var vtx:Array < Float>=[];
	 

	
	for (j in 0...height)
	{
		for (i in 0...width)
		{
			var index:Int = ( j * width ) + i;
			var S = ( i / (width - 1) );
            var T = ( j / (height - 1) ); var xl = Math.round(i / (width-1  ) * img.width  )  ;
		            var yl = Math.round(j / (height-1 ) * img.height );
					
				/*	var color:Int = img.getPixel(xl,yl);
					var r = Util.getRed(color)  / 255;
		            var g = Util.getGreen(color) / 255;
		            var b = Util.getBlue(color) / 255;
		           var gradient = r * 0.3 + g * 0.59 + b * 0.11;
*/
			       
				   

            var X = ( S * terrainWidth ) - halfTerrainWidth;
            var Y = 0;//  gradient * highScale;
            var Z = ( T * terrainHeight ) - halfTerrainHeight;
			Bounding.addInternalPoint(X, Y, Z);
			
			vtx.push(X); vtx.push(Y); vtx.push(Z);
			vtx.push(0); vtx.push(0); vtx.push(0);
			vtx.push(S); vtx.push(T);
			
		}
	}
		
	
	
	
	 numTriangles = ( width - 1 ) * ( height - 1 ) * 2;

	
	var faces:Array < Int>=[];
	
	var index:Int = 0;
	  for (j in 0... (height-1 ))
    {
        for (i in 0... (width-1 ) )
        {
            var vertexIndex:Int = ( j * width ) + i;
			
		
				//top
			faces.push(vertexIndex);          //v0
			faces.push(vertexIndex + 1);      //v1
		    faces.push(vertexIndex+width+1);  //v3
 			
				//bottom
			faces.push(vertexIndex);          //v0
			faces.push(vertexIndex+ width+1); //v3
            faces.push(vertexIndex+ width) ;  //v2
 			
		}
	}
	
	for ( i in 0... Std.int(faces.length / 3))
	{
		var i0:Int = faces[i * 3 + 0];
		var i1:Int = faces[i * 3 + 1];
		var i2:Int = faces[i * 3 + 2];
		
		var p0:Vector3 = new Vector3(vtx[i0 * 8 + 0], vtx[i0 * 8 + 1], vtx[i0 * 8 + 2]);
		var p1:Vector3 = new Vector3(vtx[i1 * 8 + 0], vtx[i1 * 8 + 1], vtx[i1 * 8 + 2]);
		var p2:Vector3 = new Vector3(vtx[i2 * 8 + 0], vtx[i2 * 8 + 1], vtx[i2 * 8 + 2]);

		    var p1p2 = p0.subtract(p1);
            var p3p2 = p2.subtract(p1);

         var normal:Vector3 = Vector3.Normalize(Vector3.Cross(p1p2, p3p2));
		 
	
	vtx[i0 * 8 + 3] = normal.x;
	vtx[i0 * 8 + 4] = normal.y;
	vtx[i0 * 8 + 5] = normal.z;
	vtx[i1 * 8 + 3] = normal.x;
	vtx[i1 * 8 + 4] = normal.y;
	vtx[i1 * 8 + 5] = normal.z;
	vtx[i2 * 8 + 3] = normal.x;
	vtx[i2 * 8 + 4] = normal.y;
	vtx[i2 * 8 + 5] = normal.z;
	
	
	
	
	
		
		
	}
	
	
	vertex = new Float32Array(vtx);
    indices = new Int16Array(faces); 
	
	 	vertexBuffer = GL.createBuffer();
		    GL.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer);
	        GL.bufferData(GL.ARRAY_BUFFER,  vertex, GL.STATIC_DRAW);
			GL.bindBuffer(GL.ARRAY_BUFFER, null);	
			
		 indexBuffer = GL.createBuffer();
		   GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indexBuffer);
           GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, indices, GL.STATIC_DRAW);
		   GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, null);
		   update();
	}

	public function scaleTextureLayer(value:Float, layer:Int):Void
	{
		pipeline.setLayerScale(value, layer);
	}
	public function loadTextures(water:String,sand:String,grass:String,rock:String,snow:String):Void
	{
		 texture0 = Gdx.Instance().getTexture(water, true);
		 texture1 = Gdx.Instance().getTexture(sand, true);
		 texture2 = Gdx.Instance().getTexture(grass, true);
		 texture3 = Gdx.Instance().getTexture(rock, true);
		 texture4 = Gdx.Instance().getTexture(snow, true);
	}
    override public function render(camera:Camera) 
	{

		
        var meshTrasform:Matrix4 = AbsoluteTransformation;
		
		
		var scaleFactor:Float = Math.max(scaling.x, scaling.y);
             scaleFactor =  Math.max(scaleFactor, scaling.z);
			
			 
	   
		
		
		          
		pipeline.Bind();
		pipeline.setWorldMatrix(meshTrasform);
		pipeline.setProjMatrix(camera.projMatrix);
		pipeline.setViewMatrix(camera.viewMatrix);
		pipeline.setAmbient(scene.AmbientColor.r, scene.AmbientColor.g, scene.AmbientColor.b, 1);
		pipeline.setLightPosition(scene.sunPosition.x, scene.sunPosition.y, scene.sunPosition.z);
	
		
		
    pipeline.setTexture(heightmap,0);	
	pipeline.setTexture(texture0, 1);
	pipeline.setTexture(texture1, 2);
	pipeline.setTexture(texture2, 3);
	pipeline.setTexture(texture3, 4);
	pipeline.setTexture(texture4, 5);
	
	    var offSet:Int = 0;
		GL.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer);
		GL.vertexAttribPointer(pipeline.vertexAttribute, 3, GL.FLOAT, false, vertexStrideSize, 0); 
    	GL.enableVertexAttribArray (pipeline.vertexAttribute);
		offSet += 3;

		GL.vertexAttribPointer(pipeline.normalAttribute, 3, GL.FLOAT, false, vertexStrideSize, offSet*4); 
	    GL.enableVertexAttribArray (pipeline.normalAttribute);
		offSet += 3;
		
		GL.vertexAttribPointer(pipeline.texCoord0Attribute, 2, GL.FLOAT, false, vertexStrideSize, offSet*4); 
	    GL.enableVertexAttribArray (pipeline.texCoord0Attribute);
		offSet += 2;

	     material.Applay();
	
        GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indexBuffer);
        GL.drawElements(GL.TRIANGLES, numTriangles*3, GL.UNSIGNED_SHORT, 0);
		Gdx.Instance().numTris   += numTriangles*3;
		Gdx.Instance().numVertex += Std.int(vertex.length / 13);
		Gdx.Instance().numMesh++;
	
 


		
	}

	override public function dispose()
	{
		
		GL.deleteBuffer(vertexBuffer);
		GL.deleteBuffer(indexBuffer );
	}
}