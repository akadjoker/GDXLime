package ;
import com.gdx.color.Color3;
import com.gdx.Gdx;
import com.gdx.gl.batch.SpriteBatch;
import com.gdx.input.Keys;
import com.gdx.math.Vector3;
import com.gdx.scene2d.CameraOrtho;
import com.gdx.scene2d.ImageFont;
import com.gdx.scene3d.FreeCamera;
import com.gdx.scene3d.land.LandScape;
import com.gdx.scene3d.lensflare.LensFlareSystem;
import com.gdx.scene3d.Mesh;
import com.gdx.scene3d.land.SplattingTerrain;
import com.gdx.scene3d.Scene;
import com.gdx.Screen;
import com.gdx.SpriteSheet;
import com.gdx.util.HeightMap;


/**
 * ...
 * @author Luis Santos AKA DJOKER
 */
class Screen_1 extends DemoScreen
{
public var camera:FreeCamera;


	
			 var lensflare:LensFlareSystem;
	var spr:SpriteSheet ;

var terrain:LandScape;

	override public function Start():Void 
	{
		Gdx.Instance().clearColor(0, 0, 0.4);
		
		 camera = scene.addFreeCamera( new Vector3(0, 20, -100), new Vector3(0, 0, 1000));
	     camera.setPerspective(45, Gdx.Instance().width / Gdx.Instance().height, 0.1, 5000);
	
			
	scene.setAmbientColor(0.2, 0.2, 0.2);
scene.setLightPosition( -1790, 1130, -1810);
	

			

		

	terrain = new LandScape('data/terra/Raid.png', 16, 1.0, scene );
	//terrain.GenerateTerrainEx(0, 0, 0, 0, 1, 1);
	terrain.GenerateHugeTerrain(4, 4, 0, 0);
	terrain.ExpandTexture(0,0,4, 4);
	terrain.brush.setTexture(Gdx.Instance().getTexture("data/terra/raidtexture.jpg"));
	terrain.brush.setDetail(Gdx.Instance().getTexture("data/terra/detail_texture.jpg"));
	terrain.brush.DiffuseColor.set(1, 1, 1);
//	terrain.smoothTerrain(1);
	terrain.Optimize();
	
	
	
		scene.addChild(terrain);
		
	scene.setSkyBox("data/skybox01");
		
	}

	
	override public function Update(delta:Float):Void 
	{
	
		 var dt:Float =  Gdx.Instance().deltaTime *3 ;
		 var speed:Float= 80;
		 
	
		 	 
	   if (keyPress(Keys.A))
		 {
			camera.Strafe( speed*dt);
		 } else
		 if (keyPress(Keys.D))
		 {
			 camera.Strafe( -speed*dt);
		 } 
		 
		 if (keyPress(Keys.W))
		 {
			 camera.Move( speed*dt);
		 } else
		 if (keyPress(Keys.S))
		 {
			 camera.Move( -speed*dt);
		 }
		 
			camera.MouseLook(8, 10, 5.5 * dt );
		
	
	}
	
		override	public function draw2d():Void
	{
		
	}
	override public function Render():Void 
	{
	
	  
	 
	}

	
	
	override public function Close():Void 
	{
	}
	
	
}
