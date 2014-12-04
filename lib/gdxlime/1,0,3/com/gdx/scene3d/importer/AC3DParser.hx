package com.gdx.scene3d.importer;


import com.gdx.color.Color3;
import com.gdx.gl.Texture;
import com.gdx.math.Vector2;
import com.gdx.math.Vector3;
import com.gdx.scene3d.Mesh;
import com.gdx.scene3d.Surface;
import lime.utils.ByteArray;
import haxe.ds.StringMap;
import lime.Assets;



using StringTools;

/**
 * AC3DParser provides a parser for the AC3D data type.
 *
 * unsupported tags: "numsurf","crease","texrep","refs lines of","url","data" and "numvert lines of":
 */
class AC3DParser  {
    private var LIMIT:Int = 65535;
    private var CR:String = String.fromCharCode(10);

    private var _textData:String;
    private var _startedParsing:Bool;
    private var _trunk:Array<String>;
    private var _kidsCount:Int = 0;
    private var _parsesV:Bool;
    private var _isQuad:Bool;
    private var _quadCount:Int;
    private var _lastType:String = "";
    private var _charIndex:Int;
    private var _oldIndex:Int;
    private var _stringLen:Int;
    private var _byteData:ByteArray;
    private var _groupCount:Int;

	private var materialIndex:Int;
	private var lastmaterialIndex:Int;
	private var lastAlpha:Float = 0;

	private var lastColor:Color3;

	private var vertices:Array<Vector3>;
	private var _uvs:Array<Dynamic>;
	private	var texture:Texture = null;

	

   public function new(filename:String,path:String,mesh:Mesh)
	{
		   
		lastColor = Color3.WHITE;
         _byteData =	Assets.getBytes(filename);
	  	
		if (supportsData(_byteData))
		{
	        proceedParsing(getTextData(_byteData),path,mesh);
		}
		cleanUP();
	}

	private function getTextData(ba:ByteArray):String
		{
			var s = Util.toString(ba);
			return s.split("xmlns").join("_xmlns");
		}
		

	  public static function supportsData(  ba:ByteArray):Bool 
	  {
 
        var str:String;
       if (ba != null) {
            ba.position = 0;
            str = ba.readUTFBytes(4);
        }
        else {
            str = Std.is(ba, String) ? cast(ba, String).substr(0, 4) : null;
        }

        if (str == 'AC3D')
            return true;

        return false;
    }

	public  function equalsCI(a : String, b : String) return a.toLowerCase() == b.toLowerCase();
	
     private function proceedParsing(data:String,path:String,mesh:Mesh):Bool 
	 {

		  var nameid:String;
        var refscount:Int=0;
        var tUrl:String = "";
       
		var position:Vector3 = Vector3.zero;
				
	_textData = data;
  	var lines:Array<String> = _textData.split("\n");
	if (lines.length == 1) lines =		_textData.split(String.fromCharCode(13));
	var version:String = lines[0].substring(lines[0].length-1, lines[0].length);
	lines.shift();

	var vertexIndex:Int = 0;
	var maxVertex:Int = 0;
	var buildSurface:Bool = false;
	var numSurfaces:Int = 0;
	var indexSurface:Float = 0;
    var invalidPoly:Bool = false;
	materialIndex = 0;
	lastmaterialIndex = 0;
	//var surface:Surface = mesh.createSurface();
	     
						 vertices = [];
                     	 _uvs = [];
						 
	for (line in lines )
	{
				
	 _trunk = line.replace("  ", " ").replace("  ", " ").replace("  ", " ").split(" ");
	 
	 


	 
            switch (_trunk[0])
            {
                case "MATERIAL":
                  {
					//  trace("MATERIAL");
					  parseMaterialLine(line);
				  }
                case  "crease", "refs lines of", "url", "data": //0x30
					{
						
					}
					case "texrep":
					{
						// %f %f tiling
					}
					case "numvert lines of":
					{
						break;
					}

                case "kids": //howmany children in the upcomming object. Probably need it later on, to couple with container/group generation
                    _kidsCount = Std.parseInt(_trunk[1]);

                case "OBJECT":
                   {
					
					   
		 		var objType:String = _trunk[1].trim();
					
			
				//	trace("MeshGeometry ");
					
					if (equalsCI(objType , "world") )
					{
						//trace("Create mesh (World)");
                        _lastType = "world";
			        } else
			       	if (equalsCI(objType , "poly") ) 
					{
						
						vertexIndex = 0;
						maxVertex = 0;
						numSurfaces = 0;
						indexSurface = 0;
						
						texture = null;
						
						
						 if (vertices != null)          cleanUpBuffers();
						 vertexIndex = 0;
						 maxVertex = 0;
                         
						 vertices = [];
                     	 _uvs = [];
	                 
	
						buildSurface = true;
					    _parsesV = true;
                        _lastType = "poly";
                    } else
                    
					if (equalsCI(objType , "group") )
					{
						//trace("create root (group)");
                       _lastType = "group";
			        } else
					
					{
					//	trace("Object type:"+_trunk[1]);
					}
					
                   }

//**********************
                     case "SURF":
					 {
						  		
							var flag:Int =	Std.parseInt(_trunk[1]);
							if (invalidPoly)
							invalidPoly = false;
							
								
					 }
			
                case "name":
                    nameid = line.substring(6, line.length - 1);
                    if (_lastType == "poly") 
					{
                  //  trace("Mesh :"+ nameid);
                    }
                    else {
                   // trace("Mesh : "+  nameid);
                    }

                case "numvert":
					{
						maxVertex = Std.parseInt(_trunk[1]);
					    _parsesV = true;
					}
				
				case "numsurf":
					{
						numSurfaces = Std.parseInt(_trunk[1]);
					//	trace("Num Surfaces : "+numSurfaces);
						
					}

                case "refs":
                    refscount = Std.parseInt(_trunk[1]);
					
					
					if (refscount != 3 ) 
					{
						trace("Unsupported polygon type with "+refscount+" sides. Triangulate in AC3D");
                       invalidPoly = true;
                    }
					
					/*
				    if (refscount == 4) 
					{
                        _isQuad = true;
                        _quadCount = 0;
						trace("Unsupported polygon type with "+refscount+" sides. Triangulate in AC3D");
                       invalidPoly = true;
                    }
                   else if (refscount != 3 ) 
					{
						trace("Unsupported polygon type with "+refscount+" sides. Triangulate in AC3D");
                       invalidPoly = true;
                    }
                    else 
					{
                     _isQuad = false;
                    }
					*/
				
					
                    _parsesV = false;

                case "mat":
					{
              		var matIndex:Int=Std.parseInt(_trunk[1]);
					}

					
					
                case "texture":
					{
						 tUrl = line.substring(line.indexOf('"') + 1, line.length - 1);
						 
						 materialIndex++;
						 var  texName:String = tUrl.replace('"', "").replace('"', "");
						 
						 
						//trace("texture:" + path + "/" + texName);
						
			if (Assets.exists(path + "/" + texName))
			{
			   texture=Gdx.Instance().getTexture(path+ "/" + texName);
			} else
			{
				trace("INFO: Replase :" + path + "/" + texName+", with dummy");
				texture = Gdx.Instance().getTexture("dummy");
				
			}
		
					}
                case "loc": //%f %f %f
					{
					
					position.x = Std.parseFloat(_trunk[1]);
					position.y = Std.parseFloat(_trunk[2]);
					position.z = Std.parseFloat(_trunk[3]);
				}



                case "rot": //%f %f %f  %f %f %f  %f %f %f
					{
						
					trace("3*3matrix trasfomr");
					}

                default:
               
					{
						
						if(_trunk[0] == "" || invalidPoly)
							break;

                    if (_parsesV) 
					{
						
						vertices.push(new Vector3( (Std.parseFloat(_trunk[0])), Std.parseFloat(_trunk[1]), -Std.parseFloat(_trunk[2])));
		                vertexIndex++;

                    }
                    else {
						
						if (_isQuad) 
						{
                            _quadCount++;
                            if (_quadCount == 4) 
							{
							
						
								_uvs.push(_uvs[_uvs.length - 2]);
								_uvs.push(_uvs[_uvs.length - 1]);
								_uvs.push(Std.parseInt(_trunk[0]));
								
							     var uv:Vector2 = new Vector2(Std.parseFloat(_trunk[1]),  -Std.parseFloat(_trunk[2]));
						         _uvs.push(uv);
								 
								_uvs.push(_uvs[_uvs.length - 10]);
								_uvs.push(_uvs[_uvs.length - 9]);
							
							
								
								
							    indexSurface++;		


			
                            }
                            else {
							    	
                                   _uvs.push(Std.parseInt(_trunk[0]));
                                   var uv:Vector2 = new Vector2(Std.parseFloat(_trunk[1]),  -Std.parseFloat(_trunk[2]));
						           _uvs.push(uv);			
						    
								
							    indexSurface++;		
                            }

                        }
                        else {
							       _uvs.push(Std.parseInt(_trunk[0]));
                                    var uv:Vector2 = new Vector2(Std.parseFloat(_trunk[1]),  -Std.parseFloat(_trunk[2]));
						           _uvs.push(uv);									
							       indexSurface++;		
                        }
						
							   						
								 
						
                    		
			if ((Std.int(indexSurface/refscount)>=numSurfaces)  && buildSurface)
			{

				buildSurface = false;
				buildMeshGeometry(mesh,position);
				
			}
				
						}
						
				
                    }
			
					
			

		//	trace(numSurfaces +"max - index:"+Std.int(indexSurface/refscount));
					
					
					
					
            }
			
        }
		
		mesh.sortMaterial();
		mesh.UpdateNormals();
		mesh.UpdateBoundingBox();
        return true;
    }

   

    private function buildMeshGeometry(mesh:Mesh,p:Vector3):Void 
	{
		var s:Surface =  mesh.createSurface();
		
		if (lastmaterialIndex != materialIndex)
		{
			lastmaterialIndex = materialIndex;
			//s=mesh.createSurface();
			//trace("Create surface");
		}
		
		    var i:Int = 0;
        while (i < _uvs.length) 
		{
	
			
			
            var v0:Vector3 = vertices[_uvs[i]];
            var v1:Vector3 = vertices[_uvs[i + 2]];
            var v2:Vector3 = vertices[_uvs[i + 4]];
		
		   	var uv0:Vector2 = _uvs[i + 1];
            var uv1:Vector2 = _uvs[i + 3];
            var uv2:Vector2 = _uvs[i + 5];

	
			
			var i0 = s.AddVertexVector(v0, uv0);
			var i1 = s.AddVertexVector(v1, uv1);
			var i2 = s.AddVertexVector(v2, uv2);
	
			
			s.AddTriangle(i2, i1, i0);

			
			
			
			  i += 6;
		}

		
		 if (texture != null)	
		 {
			 s.brush.setTexture(texture);
			 s.materialIndex = materialIndex-1;
		 }
		 
		 
	//	 trace(s.materialIndex);
		 
	//	 s.brush.DiffuseColor.set(lastColor.r, lastColor.g, lastColor.b);
	//	 s.brush.alpha = lastAlpha;	
		 s.translate(p.x, p.y, -p.z);
		 s.updateBounding();
	     s.UpdateVBO();
		
        
        
    }


    private function parseMaterialLine(materialString:String)
	{
        var trunk:Array<String> = materialString.split(" ");


        var color:UInt = 0x000000;
        var name:String = "";
        var ambient:Float = 0;
        var specular:Float = 0;
        var gloss:Float = 0;
        var alpha:Float = 0;

        var i:Int = 0;
        while (i < trunk.length) 
		{
            if (trunk[i] == "") 
			{
                i++;
                continue;
            }

            if (trunk[i].indexOf("\"") != -1 || trunk[i].indexOf("\'") != -1) 
			{
                name = trunk[i].substring(1, trunk[i].length - 1);
                i++;
                continue;
            }

            switch (trunk[i])
            {
                case "rgb":
                    var r:Float = Std.parseFloat(trunk[i + 1]) ;
                    var g:Float = Std.parseFloat(trunk[i + 2]) ;
                    var b:Float = Std.parseFloat(trunk[i + 3]);
			      i += 3;
                  
                 case "emis":
                    var r:Float = Std.parseFloat(trunk[i + 1]) ;
                    var g:Float = Std.parseFloat(trunk[i + 2]) ;
                    var b:Float = Std.parseFloat(trunk[i + 3]);
		           i += 3;
                case "amb":
                    var r:Float = Std.parseFloat(trunk[i + 1]) ;
                    var g:Float = Std.parseFloat(trunk[i + 2]) ;
                    var b:Float = Std.parseFloat(trunk[i + 3]);
			      i += 3;
               case "spec":
                    var r:Float = Std.parseFloat(trunk[i + 1]) ;
                    var g:Float = Std.parseFloat(trunk[i + 2]) ;
                    var b:Float = Std.parseFloat(trunk[i + 3]);
			      i += 3;
                case "shi":
                    gloss = Std.parseFloat(trunk[i + 1]) / 255;
                    i += 2;
                case "trans":
                    alpha = (1 - Std.parseFloat(trunk[i + 1]));
					lastAlpha = alpha;
            }

            i++;
        }

    }

    private function cleanUP():Void 
	{
        cleanUpBuffers();
    }

    private function cleanUpBuffers():Void 
	{
	
        for (i in 0...vertices.length)
            vertices[i] = null;

         for (i in 0..._uvs.length)
            _uvs[i] = null;
			_uvs = null;
        vertices = null;
    
    }
}

