package com.gdx.gl;


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
 * @author djoker
 */
class BlendMode
{

public static var NORMAL:Int      = 0;
public static var ADD:Int         = 1;
public static var MULTIPLY:Int    = 2;
public static var SCREEN:Int      = 3;
public static var TRANSPARENT:Int  = 4;





static 	public function setBlend(mode:Int ) 
	{
	 switch( mode ) {
    case BlendMode.NORMAL:
		
       Gdx.Instance().setBlendFunc(GL.SRC_ALPHA,GL.ONE_MINUS_SRC_ALPHA );
    case BlendMode.ADD:
        Gdx.Instance().setBlendFunc(GL.SRC_ALPHA, GL.DST_ALPHA );
    case BlendMode.MULTIPLY:
        Gdx.Instance().setBlendFunc(GL.DST_COLOR,GL.ONE_MINUS_SRC_ALPHA );
    case BlendMode.SCREEN:
       Gdx.Instance().setBlendFunc(GL.SRC_ALPHA, GL.ONE );	
	case BlendMode.TRANSPARENT:   
		Gdx.Instance().setBlendFunc(GL.ONE, GL.ONE_MINUS_SRC_ALPHA );	
    default:
      Gdx.Instance().setBlendFunc(GL.ONE,GL.ONE_MINUS_SRC_ALPHA );
    }
}
	
	
	
	
		
	
}