package com.gdx;
import com.gdx.gl.Texture;

/**
 * ...
 * @author djoekr
 */
class Screen 
{

	public  var width:Int ;
    public  var height:Int;
	
	public function new() 
	{
		width  = Gdx.Instance().getWidth();
		height = Gdx.Instance().getHeight();
		
	}
	public function getTexture(url:String, mip:Bool):Texture
	{
		return Gdx.Instance().getTexture(url, mip);
	}
	
	public function update(delta:Float):Void 
	{
		
	}
	public function render():Void 
	{
		
	}
	public function keyPress(keyCode:Int):Bool
    {
   return Gdx.Instance().keyPress(keyCode);
	}
	public function resize(width:Int, height:Int):Void 
	{
		this.width = width;
		this.height = height;
	}
	
	public function show():Void 
	{
		
	}
	
	public function hide():Void 
	{
		
	}
	
	public function pause():Void 
	{
		
	}
	
	public function resume():Void 
	{
		
	}
	
	public function dipose():Void 
	{
		
	}
	public function KeyUp(key:Int):Void 
	{
		
	}
	public function KeyDown(key:Int):Void 
	{
		
	}
	public function TouchDown(x:Float,y:Float,num:Int):Void 
	{
		
	}
	public function TouchMove(x:Float,y:Float,num:Int):Void 
	{
		
	}
	public function TouchUp(x:Float,y:Float,num:Int):Void 
	{
		
	}
	public function tickcount():Int
	{
		return Gdx.Instance().getTimer();
	}
}