package com.gdx.gl.shaders;
import com.gdx.color.Color3;
import com.gdx.gl.Texture;
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
class Brush extends Material
{
public static inline var MaterialBlend:Int = 1000;	
public static inline var MaterialBlendAlpha:Int = 1100;	
public static inline var MaterialBlendMult:Int = 1200;	
public static inline var MaterialBlendAdd:Int = 1300;	
public static inline var MaterialBlendOne:Int = 1400;	
	
			 
public static inline var MaterialSolid:Int = 0;
public static inline var MaterialSolid2Layer:Int = 1;
public static inline var MaterialLightMap:Int = 2;
public static inline var MaterialDetailMap:Int = 3;
public static inline var MaterialReflection2Layer:Int = 4;
public static inline var MaterialTransparentAlphaChannel:Int = 5;
public static inline var MaterialTransparentAlphaChannelRef:Int = 6;
public static inline var MaterialTransparentVertexAlpha:Int = 7;
public static inline var MaterialTransparentReflection2Layer:Int = 8;

  public var materialType:Int;
  public var materialId:Int;
  public var texture0:Texture;
  public var texture1:Texture;
  public var isDetail:Bool;
  public var useTextures:Bool;

  
  
  

	public function new(type:Int=0) 
	{
		super();
	 materialType = type;
	 texture0 = null;
	 texture1 = null;
	 isDetail = false;
	 alpha = 1;
	 useTextures = false;
	 materialId = 0;

	
	}
	public static function CompareBrushes(brush1:Brush, brush2:Brush):Bool
	{
		if (brush1 == null && brush2 != null) return false;
		if (brush1 != null && brush2 == null) return false;
		if (brush1 != null && brush2 != null) return false;
		if (brush1.useTextures != brush2.useTextures) return false;
		if (brush1.isDetail != brush2.isDetail) return false;
		if (brush1.materialId != brush2.materialId) return false;
		if (brush1.BlendFace != brush2.BlendFace) return false;
		if (brush1.BlendType != brush2.BlendType) return false;
		if (brush1.CullingFace != brush2.CullingFace) return false;
		if (brush1.DepthMask != brush2.DepthMask) return false;
		if (brush1.DepthTest != brush2.DepthTest) return false;
		if (brush1.texture0 == null && brush2.texture0 != null) return false;
		if (brush1.texture0 != null && brush2.texture0 == null) return false;
		if (brush1.texture0 != null && brush2.texture0 != null) return false;
		if (brush1.texture1 == null && brush2.texture1 != null) return false;
		if (brush1.texture1 != null && brush2.texture1 == null) return false;
		if (brush1.texture1 != null && brush2.texture1 != null) return false;
		
	
		return true;
	}
	public static function CompareBrushesMaterial(brush1:Brush, brush2:Brush):Bool
	{
		
		if (brush1.materialId != brush2.materialId) return false;
		if (brush1.BlendFace != brush2.BlendFace) return false;
		if (brush1.BlendType != brush2.BlendType) return false;
		return true;
	}
	public function clone(b:Brush):Void
	{
		this.alpha = b.alpha;
		this.BlendFace = b.BlendFace;
		this.BlendType = b.BlendType;
		this.CullingFace = b.CullingFace;
		this.DepthMask = b.DepthMask;
		this.DepthTest = b.DepthTest;
		this.materialId = b.materialId;
		this.DiffuseColor.copyFrom(b.DiffuseColor);
		this.isDetail = b.isDetail;
		this.materialType = b.materialType;
		this.useTextures = b.useTextures;
		this.isDetail = b.isDetail;
		this.texture0 = b.texture0;
		this.texture1 = b.texture1;
		
	}
	
	public function setTexture(tex:Texture)
	{
	useTextures = true;
	texture0 = tex;
	}
	public function setDetail(tex:Texture)
	{
	isDetail = true;	
	texture1 = tex;
	}
	public function setMaterialType(type:Int):Void
	{
	 materialType = type;
 	}

	
}