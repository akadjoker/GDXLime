package ;

import com.gdx.Gdx;
import com.gdx.gl.batch.SpriteBatch;
import com.gdx.scene2d.CameraOrtho;
import com.gdx.scene2d.ImageFont;
import com.gdx.scene3d.Scene;
import com.gdx.Screen;
/**
 * ...
 * @author Luis Santos AKA DJOKER
 */
class DemoScreen extends Screen
{

public var Ortho:CameraOrtho;
public var scene:Scene;
public var batch:SpriteBatch;	
public var font:ImageFont;



public function Start()
{
}
public function Close()
{
}
public function Update(dt:Float)
{
}
public function Render()
{
}


	override public function show():Void 
	{
		Gdx.Instance().clearColor(0, 0, 0.4);
		
		 scene = new Scene();
		 batch = new SpriteBatch(1000);
		 Ortho = new CameraOrtho(width, height);
		 font = new ImageFont(Gdx.Instance().getTexture("data/arial.png"),-6);
		 Start();
		
		
		
		 
	}
	override public function resize(width:Int, height:Int):Void 
	{			
	Gdx.Instance().setViewPort(0, 0, width, height);
	}
	
	override public function update(delta:Float):Void 
	{
	  
	  scene.update();	
	  Update(delta);
	}
	
	public function draw2d():Void
	{
		
	}
	override public function render():Void 
	{
	 Render();
	 scene.renderAll();
	 
	 Ortho.update();
	 batch.setProjMatrix(Ortho.getProj());
	 batch.setViewMatrix(Ortho.getView());
	 batch.Begin();
	 draw2d();
	 font.print(batch, "Camera:" + scene.mainCamera.position.toString(), 10, (height-15)-14*4, 0);
	 font.print(batch, "FPS:" + Gdx.Instance().lastFPS, 10, (height-15)-14*3, 0);
	 font.print(batch, "Tris:" + Gdx.Instance().numTris + "/Vertexs:" + Gdx.Instance().numVertex, 10, (height-15)-14*2, 0);
	 font.print(batch, "Mesh:" + Gdx.Instance().numMesh + "/Surfaces:" + Gdx.Instance().numSurfaces, 10, (height - 15) - 14, 0);
	 font.print(batch,"Textures:"+Gdx.Instance().numTextures+"/Brushs:"+Gdx.Instance().numBrush, 10, (height-15), 0);
	 batch.End();
	 
	   
	 
	}

	override public function KeyUp(key:Int):Void 
	{
    	}

	
	override public function dipose():Void 
	{
        Close();
		scene.dispose();
	}
	
	
}
