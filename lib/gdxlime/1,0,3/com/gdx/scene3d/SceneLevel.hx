package com.gdx.scene3d;
/*
 Copyright (C) 2013-2014 Luis Santos AKA DJOKER
 
 This file is part of GDXLime .
 
 TrenchBroom is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 TrenchBroom is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with GDXLime.  If not, see <http://www.gnu.org/licenses/>.
 */

 
import com.gdx.collision.Coldet;
import com.gdx.collision.CollisionData;
import com.gdx.Gdx;
import com.gdx.gl.shaders.Brush;
import com.gdx.gl.Texture;
import com.gdx.math.BoundingBox;
import com.gdx.math.BoundingSphere;
import com.gdx.math.Matrix4;
import com.gdx.math.Ray;
import com.gdx.math.Triangle;
import com.gdx.math.Vector2;
import com.gdx.math.Vector3;
import com.gdx.scene3d.SceneLevel.LevelEntitie;
import haxe.xml.Fast;
import lime.Assets;

/**
 * ...
 * @author Luis Santos AKA DJOKER
 */

 
class SceneLevel extends SceneNode
{
	public static inline var EntityStatic = 0;
	public static inline var EntityModel  = 1;
	public static inline var EntityInfo   = 2;
	
	public var level_scaling:Float;
	
	private var playerStart:Vector3;


	public var colideRadius:Float;
	
	public var CameraTrigger:String->String->Bool;	
	public var CameraColide:String->LevelEntitie->Void;	
	public var bigMesh:Mesh;
	public var levelModels:Array<LevelEntitie>;
	public var levelInfo:Array<LevelEntitie>;
	public var textures:Map<Int,Texture> = new Map<Int,Texture>();
	
	public function new(scene:Scene,Parent:SceneNode = null , id:Int = 0, name:String="SceneLevel")  
	{
		 super(scene, Parent, id, name);
		 levelModels = [];	  	
		 levelInfo = [];	  
		 playerStart = Vector3.zero;
		 colideRadius = 2;
		 
	}
	
	public function parse(filename:String,texturePath:String,scale:Float=1.0,ignoreMesh:Bool=false,ignoreModels:Bool=false)
	{
		level_scaling = scale;
		
		var xml:Xml = Xml.parse (Assets.getText(filename));
		var xmlNode = xml.firstElement();
		var min:Vector3 = Vector3.zero;
		var max:Vector3 = Vector3.zero;
		var pos:Vector3 = Vector3.zero;
		var normal:Vector3 = Vector3.zero;
		var uv:Vector2 = Vector2.zero;
  		var fast = new Fast(xmlNode);
		
		var textures:Map<Int,Texture> = new Map<Int,Texture>();
		var surfs:Array<Surface> = [];
		
		//trace("Num materials :" + numMaterials);
		
		bigMesh = new Mesh(scene);
	    
		
    	 var list:List<Fast> = fast.node.resolve("Textures").nodes.resolve("Texture");
		 var index:Int = 0;
		 for (item in list)
		{
			var texture = item.att.name;
		
			if (Assets.exists(texturePath + texture))
			{
				
			
			if (texture.indexOf("png") >= 3)
			{
				 textures.set(index, Gdx.Instance().getTexture(texturePath  + texture, false));
			} else
			{
				 textures.set(index, Gdx.Instance().getTexture(texturePath  + texture, true));
			}
			
			} else
			{
				trace("INFO: Replase "+texturePath+texture+" with dummy");
				textures.set(index, Gdx.Instance().getTexture("dummy", true));
			}
			index++;
       }
		
	var lastTextureId:Int = -1;
	var textureId:Int = 0;
	var index:Int=0;

	    var list:List<Fast> =  fast.nodes.resolve("Entitie");
		for (entitie in list)
		{
			var entityTtype:Int = Std.parseInt(entitie.att.Type);
	
			if (ignoreMesh) 
			{
				if (entityTtype == 0) continue;
			}
			
			if (ignoreModels) 
			{
				if (entityTtype == 1) continue;
			}
			
			
	    var entity:LevelEntitie = new LevelEntitie(this);
		entity.type = entityTtype;
		
		switch (entity.type)
		{
		case EntityModel  : levelModels.push(entity);
		case EntityInfo   : levelInfo.push(entity);
		
		}
		 
		
	
			 for (node in  entitie.elements)
			 {
				 if (node.name == "Attributes")
				 {
				 	for (att in node.elements)
			       {
					   
				    if (att.has.Name)
				     {
					  entity.Attributes.set(att.att.Name, att.att.Value);
					  if (att.att.Name == "classname")
					  {
						  
					  }
					
				     }
			        }
				}
	
				 entity.classname = entity.Attributes.get("classname");
				 if (entity.type == EntityInfo)
					{
						  entity.config();
					}
		
				 if (node.name == "Brush")
				 {
					   entity.brush = new Mesh(scene, null, index, entity.classname); 
					   for (brush in node.elements)
				       {
					   if (brush.name == "Surface")
					   {
						    var surf:Surface = new Surface(scene.shader);
					    	textureId = Std.parseInt(brush.att.TexID);
						    surf.materialIndex = textureId;
							surf.brush.materialId= textureId;
						    surf.brush.setTexture(textures.get(surf.materialIndex));
							
							if (entity.classname == "func_blend")
							{
								surf.brush.BlendFace = true;
								surf.brush.BlendType = 2;
							}
					    
						
			
						 
						 for ( n in brush.elements)
						 {
					    	 if (n.name == "Polys")
							 {
								
				              for (poly in n.elements)
				             {
					 var x = Std.parseFloat(poly.att.x);
					 var y = Std.parseFloat(poly.att.y);
					 var z = Std.parseFloat(poly.att.z);
					 var nx = Std.parseFloat(poly.att.nx);
					 var ny = Std.parseFloat(poly.att.ny);
					 var nz = Std.parseFloat(poly.att.nz);
					 var tu = Std.parseFloat(poly.att.tu);
					 var tv = Std.parseFloat(poly.att.tv);
					 if (nx == -0) nx = 0.0;
					 if (ny == -0) ny = 0.0;
					 if (nz == -0) nz = 0.0;
							 surf.AddFullVertex(x*level_scaling, y*level_scaling, z*level_scaling, nx, ny, nz, tu, tv);
			
				            }//vertex
							}
							
							
							  if (n.name == "Faces")
							 {
								for (face in n.elements)
				                {
	      			             var a = Std.parseInt(face.att.A);
					             var b = Std.parseInt(face.att.B);
					             var c = Std.parseInt(face.att.C);
								 surf.AddTriangle(a, b, c);
						
				              }//face 
							 }
						 }
						
						
					  if (entity.type == EntityStatic)
					  {
					  bigMesh.addSurface(surf);
					  } else
					  {
						   
						   surf.UpdateVBO();
						   surf.updateBounding();
				 	       entity.brush.addSurface(surf);
					  }
						 
					  }// surface
					  
					   if (entity.type != EntityStatic)
					  {
						  entity.brush.UpdateBoundingBox();
					      entity.center.copyFrom(entity.brush.Bounding.boundingSphere.center);
					      entity.config();
					      entity.brush.Optimize();
					  
					  } else
					  {
						  entity.brush = null;
						  entity.Attributes = null;
						  
						//  entity = null; 
					  }
			          
					  
					  
					//  trace(entity.brush.Bounding.boundingBox.center.toString());
						   
				       }///brush elements
				 }
			 }
			 index++;
		}
	    
		bigMesh.Optimize();
		sortNodes();
		trace("INFO : Num Models:"+ levelModels.length);
		trace("INFO : Num Info:"+levelInfo.length);
		trace("INFO : Num Static Surfaces:"+bigMesh.CountSurfaces());
    
		update();
	}
	public function setActive(targetName:String,activateTarget:Bool=true):Bool
	{
		for (i in 0...levelModels.length)
		{
			var ent = levelModels[i];
			if (ent != null)
			{
				if (ent.TargetName == targetName)
				{
				 ent.setActivate(activateTarget);
				 return true;
				}
			}
		}
		return false;
	}
	private function sortNodes():Void
	{
	levelModels.sort(brushType);
	}
	
	function brushType(a:LevelEntitie, b:LevelEntitie):Int
    {
	if (a.brush == null) return 0;
	if (b.brush == null) return 0;

    if (a.brush.renderType < b.brush.renderType) return -1;
    if (a.brush.renderType > b.brush.renderType) return 1;
    return 0;
    } 
	
	public function getDoorModels():Array<LevelEntitie>
	{
		var list:Array<LevelEntitie> = [];
		for (i in 0...this.levelModels.length)
		{
			var model = levelModels[i];
			if (model.classname == "func_door")
			{
				list.push(model);
			}
		}
		return list;
	}
	public function getButtonModels():Array<LevelEntitie>
	{
		var list:Array<LevelEntitie> = [];
		for (i in 0...this.levelModels.length)
		{
			var model = levelModels[i];
			if (model.classname == "func_button")
			{
				list.push(model);
			}
		}
		return list;
	}
	public function getPlatModels():Array<LevelEntitie>
	{
		var list:Array<LevelEntitie> = [];
		for (i in 0...this.levelModels.length)
		{
			var model = levelModels[i];
			if (model.classname == "func_plat")
			{
				list.push(model);
			}
		}
		return list;
	}	
	public function getTrainModels():Array<LevelEntitie>
	{
		var list:Array<LevelEntitie> = [];
		for (i in 0...this.levelModels.length)
		{
			var model = levelModels[i];
			if (model.classname == "func_train")
			{
				list.push(model);
			}
		}
		return list;
	}	
			
	public function getPlayerOrigin():Vector3
	{
		var data:String="";
		for (i in 0... this.levelInfo.length)
		{
			var info:LevelEntitie = levelInfo[i];
			if (info.classname == "info_player_start")
			{
				data=info.Attributes.get("origin");
				
				break;
			}
		}
		
		var origin:Array<String> = data.split(" ");
		
		playerStart.set(Std.parseFloat(origin[0])*level_scaling,
		Std.parseFloat(origin[2])*level_scaling,
		Std.parseFloat(origin[1])*level_scaling);
		
		
		return this.playerStart;
	}
	override public function render(camera:Camera) :Void
	{

	
		 
		this.bigMesh.render(camera);

		for (i in 0...levelModels.length)
		{
			if (levelModels[i].brush == null) continue;
			levelModels[i].update(Gdx.Instance().getTimer(), Gdx.Instance().fixedTime*1.0);
			levelModels[i].brush.render(camera);
		}
	}
	

	

	

}


class LevelEntitie 
{
	public static inline var MODE_STOP = 0;
	public static inline var MODE_MOVE = 1;
	public static inline var MODE_WAIT = 2;
	public static inline var MODE_RETURN = 3;
	public static inline var MODE_FINISHED = 4;
	public static inline var MOVE_SPEED = 5;
	public static inline var RETURN_SPEED = 10;
	public static inline var ACTIVATE_DISTANCE = 15;
	
	public static inline var FLAG_START_ON   = 1;
	public static inline var FLAG_START_OPEN   = 1;
	public static inline var FLAG_SEND_EVENT   = 4;
	public static inline var FLAG_TOGGLE   = 32;
	
	public static inline var EntityInfo   = 0;
	public static inline var EntityDoor   = 1;
	public static inline var EntityButton = 2;
	public static inline var EntityRotor = 3;
	public static inline var EntityBlend = 4;
	public static inline var EntityLift = 5;
	public static inline var EntityTrain = 6;
	public static inline var EntityPoint = 6;
	
	
	public var brush:Mesh;
	public var level:SceneLevel;
	public var Attributes:Map<String,String>;

	
	public var Tag1:Int;
	public var Tag2:Int;
	public var userData:Dynamic;
	
	public var classname:String;
	
	public var type:Int;
	public var modelType:Int;
	public var CurrOffset:Vector3;
	

	public var move:Vector3;
	private var useOrigin:Bool;
	private var mode:Int;
	private var CurTime:Int;
	private var toggle:Bool;
	private var isManual:Bool;
	private var isOpen:Bool;
	public var activate:Bool;
	public var active:Bool;
	public  var center:Vector3;
	public  var origin:Vector3;
	public var Height:Float;
	public var Angle:Int;
	public var Flags:Int;
	public var Offset:Float;
	public var Speed:Float;
	public var Lip:Float;
	public var Wait:Int;
	public var sendEvent:Bool;
	public var Target:String;
	public var TargetName:String;
	public var IgnoreTrigger:Bool;
	public var Loop:Bool;
	public var WaitCameraRange:Bool;//if camera are close the door dont close
	public var moveSpeed:Float;
	private var moveTo:Vector3;

	public function new(pai:SceneLevel)  
	{
		useOrigin = false;
		 brush = null; 
		 level = pai;
		 Attributes = new  Map<String,String>();
		 type = 0;
		 modelType = -1;
		 CurrOffset = Vector3.zero;
		 center = Vector3.zero;
		 moveTo= Vector3.zero;
		 WaitCameraRange = true;
		  Tag1=0;
	      Tag2=1;
	      userData = null;
		  IgnoreTrigger = false;
          Loop = false;
		  origin = Vector3.zero;
		 // ACTIVATE_DISTANCE = Std.int(pai.level_scaling);
		 
	}

	public function setActivate(activateTarget:Bool=true):Void
	{
		activate = true;
		trace("activate " + TargetName);
	    if (Target != "none")
		{
		 if (activateTarget)
		 {
			
		 for (i in 0... level.levelModels.length)
			 {
				 
				 if (level.levelModels[i].TargetName == Target)
				 {
			    	 level.levelModels[i].setActivate();
					 break;
				 }
			 }
		}
		}
	}
	public function getTarget(name:String):LevelEntitie
	{
			
		 for (i in 0... level.levelModels.length)
			 {
				 
				 if (level.levelModels[i].TargetName == name)
				 {
			    	return  level.levelModels[i];
					 
				 }
			 }
			 for (i in 0... level.levelInfo.length)
			 {
				 
				 if (level.levelInfo[i].TargetName == name)
				 {
			    	return  level.levelInfo[i];
					 
				 }
			 }
		return null;
	 }
	
	public function config():Void
	{
		
	 		if (Attributes.exists("target"))	Target = Attributes.get("target"); else Target = "none";
			if (Attributes.exists("targetname"))	TargetName = Attributes.get("targetname"); else TargetName = "none";
			if (Attributes.exists("spawnflags"))	Flags = Std.parseInt( Attributes.get("spawnflags")); else Flags = 0;
	
		 
		if (Attributes.exists("classname"))
		{
			
			if  (Attributes.get("classname") == "func_door")
			{
			 modelType =	EntityDoor;
			 configDoor();
			} else
			if  (Attributes.get("classname") == "func_button")
			{
			 modelType =	EntityButton;
			 configButton();
			}  else
			if  (Attributes.get("classname") == "func_rotating")
			{
			 modelType =	EntityRotor;
			 configRotor();
			} else 
				if  (Attributes.get("classname") == "func_train")
			{
			 modelType =	EntityTrain;
			 configTrain();
			} else 
			if  (Attributes.get("classname") == "func_plat")
			{
			 modelType =	EntityLift;
			 configLift();
			} else 
			if  (Attributes.get("classname") == "path_corner")
			{
			 modelType =	EntityPoint;
			 configPoint();
			 
			} else 
			if  (Attributes.get("classname") == "func_blend")
			{
			 modelType =	EntityBlend;
			 var blendType:Int = 0;
			 if (Attributes.exists("mode"))	blendType = Std.parseInt( Attributes.get("mode"));
			 brush.setBlend(true);
			 brush.setBlendType(blendType);
			}  
			else
			{
			modelType =	EntityInfo;
			}
		}
		
		
	//trace(Attributes.get("classname")+","+type);
	}
	private function centerModel():Void
	{
		if (brush != null) 
		{
			brush.UpdateBoundingBox();
			var pos:Vector3 = brush.Bounding.boundingSphere.center;
			
		    for (i in 0... brush.CountSurfaces())
			{
				var surf:Surface = brush.getSurface(i);
         		var center =	surf.Bounding.boundingBox.center;
	        	surf.translate( -center.x, -center.y, -center.z);
			}
			
			brush.update();
			brush.setPositionVector(pos);
		    brush.UpdateBoundingBox();
			
	
			
		}
		
	}

		
	public function getOrigin():Vector3
	{
		if (Attributes.exists("origin"))
		{
		 var data:String=Attributes.get("origin");
		 var value:Array<String> = data.split(" ");
		
		origin.set(Std.parseFloat(value[0])*level.level_scaling,
		Std.parseFloat(value[2])*level.level_scaling,
		Std.parseFloat(value[1])*level.level_scaling);
		}
		return origin;
	}
	private function configPoint():Void
	{
			if (Attributes.exists("angle"))
			{
				useOrigin = false;
			    Angle = Std.parseInt( Attributes.get("angle")); 
				if (Angle == 360 || Angle==0)
			{
				move = new Vector3(1, 0, 0); 
			}else
			if (Angle == 180)
			{
				move = new Vector3( -1, 0, 0); 
			}  else
			if (Angle == 90)
			{
			move = new Vector3(0, 0, 1);
			} else
			if (Angle == 270)
			{
			move = new Vector3(0, 0, -1);
			} else
			if (Angle == 90)
			{
			move = new Vector3(0, 0, 1);
			} else
			if (Angle == -1)
			{
			move = new Vector3(0, 1, 0);
			} else
			if (Angle == -2)
			{
			move = new Vector3(0, -1, 0);
			} else
			{
			move = new Vector3(1, 0, 0); 
			}
			} else
			{
				 Angle = 0;
				 move = null;
				 useOrigin = true;
				 
				 
			}
		
			if (Attributes.exists("wait"))	Wait = Std.parseInt( Attributes.get("wait")); else Wait = 0;
			
			// var p = level.scene.addCube();
		//	 p.setPositionVector(getOrigin());
			
			
	}
	private function configLift():Void
	{
		
		 	if (Attributes.exists("speed"))	Speed = Std.parseInt( Attributes.get("speed")); else Speed = 40;
			if (Attributes.exists("height"))	Height = Std.parseFloat( Attributes.get("height")); else Height = 0;
			if (Attributes.exists("wait"))	Wait = Std.parseInt( Attributes.get("wait")); else Wait = 100;
			if (Attributes.exists("lip"))	Lip = Std.parseFloat( Attributes.get("lip")); else Lip = 0;
		   if (Attributes.exists("loop")) 
			{
				var i:Int = Std.parseInt( Attributes.get("loop"));
				Loop = (i == 1)? true: false;
			}
	
		
			
			
			if (Height > 0)
			{
				move = new Vector3(0, 1, 0);
				Offset = Math.abs( brush.Bounding.boundingBox.minimum.y - brush.Bounding.boundingBox.maximum.y)*Height;
				Offset -= Lip;
	
			} else
			{
				move = new Vector3(0, 0, 0);
				Offset = Math.abs( brush.Bounding.boundingBox.maximum.y - brush.Bounding.boundingBox.minimum.y)*-Height;
				Offset -= Lip;
		
			}
			
				
			mode = 0;
			activate = false;
			
			if (Flags & FLAG_START_ON==1)
			{
				mode = MODE_WAIT;
		    	activate = true;
			} 
			
			if (Flags & FLAG_SEND_EVENT==4)
			{
				sendEvent = true;
				
			} else
			{
				sendEvent = false;
			   
			}
			if (Flags & FLAG_TOGGLE==32)
			{
				toggle = true;
				
			} else
			{
				toggle = false;
			}
			
				
			brush.update();
		    CurTime = 0;
	}
	private function configTrain():Void
	{
		
		  
			if (Attributes.exists("speed"))	Speed = Std.parseInt( Attributes.get("speed")); else Speed = 40;
			if (Attributes.exists("wait"))	Wait = Std.parseInt( Attributes.get("wait")); else Wait = 0;
		   if (Attributes.exists("loop")) 
			{
				var i:Int = Std.parseInt( Attributes.get("loop"));
				Loop = (i == 1)? true: false;
			}
	

			brush.GetSceneDimensions();
		
			
			
			
				move = new Vector3(0, 0, 0);
				Offset = 0;
			
				
			mode = 0;
	
			activate = false;
			
			if (Flags & FLAG_START_ON==1)
			{
	    		activate = true;
			} 
			
			if (Flags & FLAG_SEND_EVENT==4)
			{
				sendEvent = true;
				
			} else
			{
				sendEvent = false;
			   
			}
			if (Flags & FLAG_TOGGLE==32)
			{
				toggle = true;
				
			} else
			{
				toggle = false;
			}
			
				
			brush.update();
		    CurTime = 0;
	}
	private function configButton():Void
	{
			
	  		if (Attributes.exists("speed"))	Speed = Std.parseInt( Attributes.get("speed")); else Speed = 40;
			if (Attributes.exists("angle"))	Angle = Std.parseInt( Attributes.get("angle")); else Angle = 0;
			if (Attributes.exists("wait"))	Wait = Std.parseInt( Attributes.get("wait")); else Wait = 1;
			if (Attributes.exists("lip"))	Lip = Std.parseFloat( Attributes.get("lip")); else Lip = 0;

			
		
			if (Angle == 360 || Angle==0)
			{
				move = new Vector3(1, 0, 0); Offset = Math.abs( brush.Bounding.boundingBox.minimum.x - brush.Bounding.boundingBox.maximum.x); Offset -= Lip;
			}else
			if (Angle == 180)
			{
				move = new Vector3( -1, 0, 0); Offset = Math.abs( brush.Bounding.boundingBox.minimum.x - brush.Bounding.boundingBox.maximum.x); Offset -= Lip;
			}  else
			if (Angle == 90)
			{
			move = new Vector3(0, 0, 1);Offset =Math.abs( brush.Bounding.boundingBox.minimum.z-brush.Bounding.boundingBox.maximum.z);Offset -= Lip;
			} else
			if (Angle == 270)
			{
			move = new Vector3(0, 0, -1);Offset =Math.abs( brush.Bounding.boundingBox.minimum.z-brush.Bounding.boundingBox.maximum.z);Offset -= Lip;
			} else
			if (Angle == 90)
			{
			move = new Vector3(0, 0, 1);Offset =Math.abs( brush.Bounding.boundingBox.minimum.z-brush.Bounding.boundingBox.maximum.z);Offset -= Lip;
			} else
			if (Angle == -1)
			{
			move = new Vector3(0, 1, 0);Offset =Math.abs( brush.Bounding.boundingBox.minimum.y-brush.Bounding.boundingBox.maximum.y);Offset -= Lip;
			} else
			if (Angle == -2)
			{
			move = new Vector3(0, -1, 0);Offset =Math.abs( brush.Bounding.boundingBox.minimum.y-brush.Bounding.boundingBox.maximum.y);Offset -= Lip;
			} else
			{
			move = new Vector3(1, 0, 0); Offset = Math.abs( brush.Bounding.boundingBox.minimum.x - brush.Bounding.boundingBox.maximum.x); Offset -= Lip;	
			}
			
		
			/*
			trace(classname);
			trace(Speed);
			trace(Target);
			trace(Angle);
			*/
			mode = 0;
			isOpen = false;
			activate = false;
			
			if (Flags & FLAG_START_OPEN==1)
			{
				mode = MODE_WAIT;
				isOpen = true;
				brush.position.addInPlace(Vector3.Mult(move, Offset));
			} 
			
			if (Flags & FLAG_SEND_EVENT==4)
			{
				sendEvent = true;
				
			} else
			{
				sendEvent = false;
			   
			}
			if (Flags & FLAG_TOGGLE==32)
			{
				toggle = true;
				
			} else
			{
				toggle = false;
			}
				
			brush.update();
		    CurTime = 0;
	}
	private function configRotor():Void
	{
			if (Attributes.exists("speed"))	Speed = Std.parseInt( Attributes.get("speed")); else Speed = 10;
			if (Attributes.exists("wait"))	Wait = Std.parseInt( Attributes.get("wait")); else Wait = 0;
		
		
	    	if (brush != null) 
		   {
		
			var pos:Vector3 = brush.Bounding.boundingSphere.center;
			
		    for (i in 0... brush.CountSurfaces())
			{
				var surf:Surface = brush.getSurface(i);
         		var center =	surf.Bounding.boundingSphere.center;
	        	surf.translate( -center.x, -center.y, -center.z);
			}
		    brush.setPositionVector(pos);
		    brush.UpdateBoundingBox();
		
			
		}
			
			if (Attributes.exists("origin"))	
			{
     		var data=Attributes.get("origin");
		    var origin:Array<String> = data.split(" ");
	    	brush.position.set(Std.parseFloat(origin[0])*level.level_scaling,
		    Std.parseFloat(origin[2])*level.level_scaling,
		    Std.parseFloat(origin[1]) *level.level_scaling);		
				
			}
			
			activate = false;
			
			if (Flags & FLAG_START_ON==1)
			{
				activate = true;
			} 
			
			if (Flags & FLAG_SEND_EVENT==4)
			{
				sendEvent = true;
				
			} else
			{
				sendEvent = false;
			   
			}
			
			
		brush.update();
	}
	private function configDoor():Void
	{
			if (Attributes.exists("speed"))	Speed = Std.parseInt( Attributes.get("speed")); else Speed = 40;
			if (Attributes.exists("angle"))	Angle = Std.parseInt( Attributes.get("angle")); else Angle = 0;
			if (Attributes.exists("wait"))	Wait = Std.parseInt( Attributes.get("wait")); else Wait = 1000;
			if (Attributes.exists("lip"))	Lip = Std.parseFloat( Attributes.get("lip")); else Lip = 0;
            if (Attributes.exists("loop")) 
			{
				var i:Int = Std.parseInt( Attributes.get("loop"));
				Loop = (i == 1)? true: false;
			}
		if (Angle == 360 || Angle==0)
			{
				move = new Vector3(1, 0, 0); Offset = Math.abs( brush.Bounding.boundingBox.minimum.x - brush.Bounding.boundingBox.maximum.x); Offset -= Lip;
			}else
			if (Angle == 180)
			{
				move = new Vector3( -1, 0, 0); Offset = Math.abs( brush.Bounding.boundingBox.minimum.x - brush.Bounding.boundingBox.maximum.x); Offset -= Lip;
			}  else
			if (Angle == 90)
			{
			move = new Vector3(0, 0, 1);Offset =Math.abs( brush.Bounding.boundingBox.minimum.z-brush.Bounding.boundingBox.maximum.z);Offset -= Lip;
			} else
			if (Angle == 270)
			{
			move = new Vector3(0, 0, -1);Offset =Math.abs( brush.Bounding.boundingBox.minimum.z-brush.Bounding.boundingBox.maximum.z);Offset -= Lip;
			} else
			if (Angle == 90)
			{
			move = new Vector3(0, 0, 1);Offset =Math.abs( brush.Bounding.boundingBox.minimum.z-brush.Bounding.boundingBox.maximum.z);Offset -= Lip;
			} else
			if (Angle == -1)
			{
			move = new Vector3(0, 1, 0);Offset =Math.abs( brush.Bounding.boundingBox.minimum.y-brush.Bounding.boundingBox.maximum.y);Offset -= Lip;
			} else
			if (Angle == -2)
			{
			move = new Vector3(0, -1, 0);Offset =Math.abs( brush.Bounding.boundingBox.minimum.y-brush.Bounding.boundingBox.maximum.y);Offset -= Lip;
			} else
			{
			move = new Vector3(1, 0, 0); Offset = Math.abs( brush.Bounding.boundingBox.minimum.x - brush.Bounding.boundingBox.maximum.x); Offset -= Lip;	
			}
			
		
			

			
			mode = 0;
			isOpen = false;
			activate = false;
			
			if (Flags & FLAG_START_OPEN==1)
			{
				mode = MODE_WAIT;
				isOpen = true;
				brush.position.addInPlace(Vector3.Mult(move, Offset));
			} 
			
			if (Flags & FLAG_SEND_EVENT==4)
			{
				sendEvent = true;
				
			} else
			{
				sendEvent = false;
			   
			}
			if (Flags & FLAG_TOGGLE==32)
			{
				toggle = true;
				
			} else
			{
				toggle = false;
			}
			
			toggle = false;
		     brush.update();
		    CurTime = 0;
    }
	
   public function update(tickcount:Int, dt:Float):Void
   {
	 
	   
      switch (modelType)
	   {
	     case EntityDoor:door_update(tickcount, dt);
		 case EntityRotor:rotor_update(tickcount, dt);
		 case EntityButton:botton_update(tickcount, dt);
		 case EntityLift:lift_update(tickcount, dt);
		 case EntityTrain:train_update(tickcount, dt);
	   }
	 
	   if (brush != null) 
	   {
		   brush.update();
		   center = brush.Bounding.boundingSphere.centerWorld;   
	   }
   }

   private function rotor_update(tickcount:Int,dt:Float):Void
	{
	     
		if (activate)
		{
			brush.addYaw(Speed / 100*dt);
		}
	}
	private function botton_update(tickcount:Int,dt:Float):Void
	{
		
     CurrOffset = brush.position;
	
		
	
        var moveDistance = Vector3.Distance(CurrOffset, Vector3.zero);
		
		
	
		switch mode
		{
		case MODE_STOP:
			{
				    if (activate)
					{
				    mode = MODE_MOVE;
					}
			}
			case MODE_MOVE:
				{
			        Add(CurrOffset, move, Speed,dt,MOVE_SPEED) ;
	           		 if (moveDistance > Offset)
					{
						
						 CurTime = tickcount + Wait;
						 mode = MODE_WAIT;
						 isOpen = true;
						 activate = false;
						
					}
				}
				case MODE_WAIT:
					{
						if (toggle)
						{
							if (isOpen && activate)
							{
								mode = MODE_RETURN;
							}
							
						}
						else
						{
						if (CurTime < tickcount) mode = MODE_RETURN;
						
						}
					}
				case MODE_RETURN:
						{
			             Sub(CurrOffset, move, Speed, dt, MOVE_SPEED) ;
					     if (moveDistance <=Speed*dt/MOVE_SPEED)
					      {
						     mode = MODE_STOP;
							 CurrOffset.set(0, 0, 0);
							 activate = false;
							 isOpen = false;
					      }
						}
			 }
	  
     brush.position = CurrOffset;
	
	}
	private function door_update(tickcount:Int,dt:Float):Void
	{
		
		
		CurrOffset = brush.position;
	
        var moveDistance = Vector3.Distance(CurrOffset, Vector3.zero);
		var cameraDistance = Math.abs(Vector3.Distance(brush.Bounding.boundingSphere.center, level.scene.mainCamera.position)) ;
		
		
	
		switch mode
		{
		case MODE_STOP:
			{
				  active = false;
				    if (activate)
					{
				    mode = MODE_MOVE;
					}
			}
			case MODE_MOVE:
				{
			        Add(CurrOffset, move, Speed, dt, MOVE_SPEED) ;
					active = true;
						 
	   			   if (moveDistance > Offset)
					{
						
						 CurTime = tickcount + Wait;
						 mode = MODE_WAIT;
						 isOpen = true;
						  if(!Loop)	 activate = false;
						
					}
				}
				case MODE_WAIT:
					{
						active = false;
						//se a porta e do tipo switch ele fica a espera do comando para fexar
						if (toggle)
						{
							if (isOpen && activate)
							{
								mode = MODE_RETURN;
							}
							
						}else
						{
//se estamos perto da porta ela mantem se aberta
//se sairmos da distancia ele conta os segundo e manda fechar

                       if (WaitCameraRange)
					   {
						   if (cameraDistance <= ACTIVATE_DISTANCE)
				            {
					         CurTime = tickcount + Wait;
				            } 
					     	else
						    {
						    if (CurTime < tickcount) mode = MODE_RETURN;
					        }
					   
					   } else
					   {
						   if (CurTime < tickcount) mode = MODE_RETURN;
					   }
					   
						
						
						
							}
					}
				case MODE_RETURN:
						{
			             Sub(CurrOffset, move, Speed, dt, MOVE_SPEED) ;
						 active = true;
						 
					     if (moveDistance <=Speed*dt/MOVE_SPEED)
					      {
						     mode = MODE_STOP;
							 CurrOffset.set(0, 0, 0);
							 if(!Loop)	 activate = false;
							 isOpen = false;
							 
					      }
						}
			 }
	  
		 brush.position=CurrOffset;
	
	}
	private function lift_update(tickcount:Int,dt:Float):Void
	{
		
		var camera:Camera = level.scene.mainCamera;
		CurrOffset = brush.position;
	    
        var moveDistance = Vector3.Distance(CurrOffset, Vector3.zero);
		
	
		switch mode
		{
		case MODE_STOP:
			{
			        active = false;
				    if (activate)
					{
				     mode = MODE_MOVE;
					 
					}
				
			}
			case MODE_MOVE:
				{
			        Add(CurrOffset, move, Speed, dt, MOVE_SPEED) ;
					if (isOnTop(camera))
					{
					 addMoveCameraNode(camera,Speed, dt, MOVE_SPEED) ;
					}
					active = true;
	   			   if (moveDistance > Offset)
					{
						
						 CurTime = tickcount + Wait;
						 mode = MODE_WAIT;
						 isOpen = true;
						 if(!Loop)	 activate = false;
						
					}
				}
				case MODE_WAIT:
					{
						
						if (CurTime < tickcount) mode = MODE_RETURN;
						active = false;
						
						
					}
				case MODE_RETURN:
						{
			             Sub(CurrOffset, move, Speed, dt, MOVE_SPEED) ;
					   
						 	if (isOnTop(camera))
				        	{
						     subMoveCameraNode(camera,Speed, dt, MOVE_SPEED) ;
					        }
				
						 active = true;
					     if (moveDistance <=Speed*dt/MOVE_SPEED)
					      {
						     mode = MODE_STOP;
							 CurrOffset.set(0, 0, 0); 
							 if(!Loop)	 activate = false;
							 isOpen = false;
					      }
						}
			 }
	  
	  moveSpeed = CurrOffset.length();
	  
	  brush.position=CurrOffset;
	}
	private function train_update(tickcount:Int,dt:Float):Void
	{
		brush.update();
		
		var camera:Camera = level.scene.mainCamera;
		CurrOffset = brush.position;
	    
        
		var size:Float = brush.Size;
	
		switch mode
		{
		case MODE_STOP:
			{
			        active = false;
				    if (activate)
					{
				       var point = getTarget(Target);
					   if (point != null)
					   {
						   if (point.useOrigin)
						   {
							     move = point.getOrigin().subtract(brush.Bounding.boundingSphere.centerWorld);
                         	     move.normalize();
								 moveTo.copyFrom(point.getOrigin());
		                         size = (brush.Size/2);
						         Wait = point.Wait;
						         mode = MODE_MOVE;
						         active = true;
						   
						   }else
						   {
						   move.copyFrom(point.move);
						   moveTo.copyFrom(point.getOrigin());
						   
			if (point.Angle == 360 || point.Angle==0 || point.Angle==180)
			{
				size = brush.maxWidth;
			}  else
			if (point.Angle == 270 ||  point.Angle==90)
			{
		        size = brush.maxDepth;
            } 
			else
			if (point.Angle == -1 ||  point.Angle==-2)
			{
		        size = brush.maxHeight;
            } 		   
						//  trace(Target+" move to "+move.toString()+" next: "+point.TargetName +' size:'+size);
						
						   Wait = point.Wait;
						   mode = MODE_MOVE;
						   active = true;
						   
						   }
					   } 
					}
				
			}
			case MODE_MOVE:
				{
					var moveDistance = Vector3.DistanceSquared( brush.Bounding.boundingSphere.centerWorld,moveTo) ;
				//	trace(moveDistance+" , "+Std.int(brush.Size)+" trg:"+ Target);
					
					
			        Add(CurrOffset, move, Speed, dt, MOVE_SPEED) ;
					if (isOnTop(camera))
					{
					 addMoveCameraNode(camera,Speed, dt, MOVE_SPEED) ;
					}
					if (moveDistance <= size)
					{
					     CurTime = tickcount + Wait;
						 mode = MODE_WAIT;
					}
				}
				case MODE_WAIT:
					{
						
						 if (CurTime < tickcount) 
						 {
							 
							 var point = getTarget(Target);
					       if (point != null)
					       {
						         Target = point.Target;
						 		 mode = MODE_STOP;
								 active = false;
						   }
						 }
						//active = false;
						
						
					}
				
			 }
	  
	  moveSpeed = CurrOffset.length();
	  
	  brush.position=CurrOffset;
	}
	private function Add(v1:Vector3, v2:Vector3,s:Float,FrameTime:Float,movespeed:Float):Vector3
    { 
     CurrOffset.x = v1.x + (v2.x * s) * FrameTime / movespeed;
	 CurrOffset.y = v1.y + (v2.y * s) * FrameTime / movespeed;
	 CurrOffset.z = v1.z + (v2.z * s) * FrameTime / movespeed;
	 return CurrOffset;
	}
   private function Sub(v1:Vector3, v2:Vector3,s:Float,FrameTime:Float,movespeed:Float):Vector3
    { 
     CurrOffset.x = v1.x - (v2.x * s) * FrameTime / movespeed;
	 CurrOffset.y = v1.y - (v2.y * s) * FrameTime / movespeed;
	 CurrOffset.z = v1.z - (v2.z * s) * FrameTime / movespeed;
	 return CurrOffset;
	}
	public function getDistanceFrom(v:Vector3):Float
	{
		return Vector3.Distance(v, center);
	}
	 public function isObscure(point:Vector3,fastCheck:Bool=false ):Bool 
	{
		if (level.scene.collider == null) return false;
	      var direction:Vector3 =point.subtract(center);
          var distance:Float = direction.length();
	     direction.normalize();
		var ray:Ray = new Ray(center, direction);
        var pickInfo = level.scene.collider.RayPick(ray, fastCheck);
		return (pickInfo && level.scene.inpactDistance < distance);
	
	}
  
	public function isOnTop(node:SceneNode) :Bool
	{
		   var bound:BoundingBox = brush.Bounding.boundingBox;
		   var other:Vector3 = node.position;
		
				return (other.x >= bound.minimumWorld.x && 
				        other.y >= bound.minimumWorld.y && 
						other.z >= bound.minimumWorld.z &&
				        other.x <= bound.maximumWorld.x && 
				        other.z <= bound.maximumWorld.z);
	
	}
   private function addMoveCameraNode(node:SceneNode,s:Float,FrameTime:Float,movespeed:Float):Void
	   {
		 node.position.x = node.position.x + (move.x * s) * FrameTime / movespeed;
		 node.velocity.x = node.velocity.x + (move.x * s) * FrameTime / movespeed;
		 node.position.y = node.position.y + (move.y * s) * FrameTime / movespeed;
		 node.velocity.y = node.velocity.y + (move.y * s) * FrameTime / movespeed;
	   	 node.position.z = node.position.z + (move.z * s) * FrameTime / movespeed;
		 node.velocity.z = node.velocity.z + (move.z * s) * FrameTime / movespeed;
	   }
   private function subMoveCameraNode(node:Camera,s:Float,FrameTime:Float,movespeed:Float):Void
	   {
		 node.position.x = node.position.x - (move.x *  s) * FrameTime / movespeed;
		 node.velocity.x = node.velocity.x - (move.x *  s) * FrameTime / movespeed;
		 node.position.y = node.position.y - (move.y * s) * FrameTime / movespeed;
		 node.velocity.y = node.velocity.y - (move.y * s) * FrameTime / movespeed;
	   	 node.position.z = node.position.z - (move.z * s) * FrameTime / movespeed;
		 node.velocity.z = node.velocity.z - (move.z * s) * FrameTime / movespeed;
	   }
}