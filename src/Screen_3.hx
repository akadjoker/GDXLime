package ;
import com.gdx.color.Color3;
import com.gdx.Gdx;
import com.gdx.gl.batch.SpriteBatch;
import com.gdx.gl.shaders.FlatUnlit;
import com.gdx.gl.shaders.SkinShader;
import com.gdx.input.Keys;
import com.gdx.math.Vector3;
import com.gdx.scene2d.CameraOrtho;
import com.gdx.scene2d.ImageFont;
import com.gdx.scene3d.FreeCamera;
import com.gdx.scene3d.H3DMeshEx;
import com.gdx.scene3d.land.LandScape;
import com.gdx.scene3d.lensflare.LensFlareSystem;
import com.gdx.scene3d.Mesh;
import com.gdx.scene3d.land.SplattingTerrain;
import com.gdx.scene3d.Scene;
import com.gdx.scene3d.SceneNode;
import com.gdx.Screen;
import com.gdx.SpriteSheet;
import com.gdx.util.HeightMap;


/**
 * ...
 * @author Luis Santos AKA DJOKER
 */
class Screen_3 extends DemoScreen
{
public var camera:FreeCamera;

public var mesh:H3DMeshEx;
public var shader:SkinShader;
	
	override public function Start():Void 
	{
		Gdx.Instance().clearColor(0, 0, 0.4);
		
		 camera = scene.addFreeCamera( new Vector3(0, 20, 100), new Vector3(0, 0, -1000));
	     camera.setPerspective(45, Gdx.Instance().width / Gdx.Instance().height, 0.1, 5000);
	
			
	scene.setAmbientColor(0.9, 0.9, 0.9);
scene.setLightPosition( 200, 130, -110);
	

var m:Mesh = scene.addCube();
m.setPosition(0, 50, -50);
m.setScale(120, 60, 1);
m.setTexture(getTexture("data/f.jpg", true));

var m:Mesh = scene.addCube();
m.setPosition(0, -10, 0);
m.setScale(100, 0.5, 100);
m.setTexture(getTexture("data/g.jpg", true));

	
mesh = new  H3DMeshEx(scene);
mesh.load("data/models/bob.h3d", "data/models/");

mesh.surfaces[3].brush.BlendFace = true;
mesh.surfaces[3].brush.BlendType = 2;
scene.addChild(mesh);

var bone:SceneNode = mesh.getJoint("lamp");

var m:Mesh = scene.addSphere(bone);
m.setPosition(-2, 10, 0);
m.setScale(2, 2, 2);






		
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
		
		//mesh.addYaw(0.01);
	
	}
	
		override	public function draw2d():Void
	{
		 font.print(batch, "farme:" + mesh.getFrameNr(), 10, 20, 0);
		
		
	}
	override public function Render():Void 
	{
	
	  
	 
	}

	
	
	override public function Close():Void 
	{
	}
	
	
}
