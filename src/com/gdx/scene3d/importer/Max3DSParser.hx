/**
 * Max3DSParser provides a parser for the 3ds data type.
 */
package com.gdx.scene3d.importer;



import com.gdx.color.Color3;
import com.gdx.gl.Texture;
import com.gdx.math.Vector2;
import com.gdx.math.Vector3;
import com.gdx.util.Vector;
import com.gdx.scene3d.Mesh;
import com.gdx.scene3d.Surface;
import lime.utils.ByteArray;
import haxe.ds.StringMap;
import lime.Assets;





class Max3DSParser  {
  


    private var _byteData:ByteArray;

 
    public var _materials:StringMap<MaterialVO>;
 
    private var _cur_obj_end:Float;
    private var _cur_obj:ObjectVO;
	
	public var objList:Array<ObjectVO>;

    private var _cur_mat_end:UInt;
    private var _cur_mat:MaterialVO;
	
	private var mesh:Mesh;


    public function new(filename:String)
	{
		objList = [];
    _byteData =	Assets.getBytes(filename);
	 proceedParsing();
	 
	 
    }



     private function proceedParsing():Bool 
	 {
    
 
            _byteData.position = 0;
            _byteData.endian = "littleEndian";

         //   _textures = new StringMap<TextureVO>();
            _materials = new StringMap<MaterialVO>();
          //  _unfinalized_objects = new StringMap<ObjectVO>();
      

 
		while (_byteData.position <= _byteData.length)
		{

       

            if (_byteData.bytesAvailable > 0) 
			{
                var cid:UInt;
                var len:UInt;
                var end:UInt;

                cid = _byteData.readUnsignedShort();
                len = _byteData.readUnsignedInt();
                end = _byteData.position + (len - 6);
				
				
				

                switch (cid)
                {
					
					  case 0x0002:
						  {
							    var version = _byteData.readUnsignedInt();
								//trace(version);
						  }
						  
                    case 0x4D4D, 0x3D3D, 0xB000 ,0xB010,0xB008,0xB013,0xB020,0xB021,0xB022: 
 
                      {
						//  trace("lixo:" + _byteData.position + ", " + _byteData.length);
						  
						//
						if (_byteData.position >= _byteData.length - 13)
						{
						//	trace("end of file "+cid + "<>" + len + "<>" + end);
						break;
						
						//trace(cid + "<>" + len + "<>" + end);
						}


						  continue;
					  }

					

                    case 0xAFFF: // MATERIAL
						{
                        _cur_mat_end = end;
                        _cur_mat = parseMaterial();
						
		
		
						//trace("material");
						}


                    case 0x4000: // EDIT_OBJECT
						{
                        _cur_obj_end = end;
                        _cur_obj = new ObjectVO();
                        _cur_obj.name = readNulTermString();
                        _cur_obj.materials = new Array<String>();
                        _cur_obj.materialFaces = new StringMap();
						}


                    case 0x4100: // OBJ_TRIMESH
						{
                        _cur_obj.type = "MESH";
					 	buildSurface();
						//  trace("new mesh :" + _byteData.position + ", " + _byteData.length);
						}


                    case 0x4110: // TRI_VERTEXL
						{
                        parseVertexList();
						//trace("vertex list");
						}


                    case 0x4120: // TRI_FACELIST
						{
                        parseFaceList();
						//trace("face list");
						}


                    case 0x4140: // TRI_MAPPINGCOORDS
						{
                        parseUVList();
						//trace("uvs");
						}
						


                    case 0x4130: // Face materials
						{
                        parseFaceMaterialList();
						//trace("face materials");
						}


                    case 0x4160: // Transform
						{
                        _cur_obj.transform = readTransform();
						//trace("matrix");
						}

/*
                    case 0xB002: // Object animation (including pivot)
						{
                         parseObjectAnimation(end);
						//continue;
						 trace("animation");
						 
						 if (_byteData.position >= _byteData.length )
						{
							break;
						}
						}
*/

                    case 0x4150: // Smoothing groups
						{
                        parseSmoothingGroups();
					//	trace("smooth");
						}

                    default:
                        // Skip this (unknown) chunk
                        _byteData.position += (len - 6);

                }
                
				
				if (_byteData.position > end ) 
				{
					trace("end of file");
					break;
				}
				
				
            }
			
			
        
		}

     return true;
    }


    private function parseMaterial():MaterialVO
	{
        var mat:MaterialVO;

        mat = new MaterialVO();

        while (_byteData.position < _cur_mat_end) 
		{
            var cid:UInt;
            var len:UInt;
            var end:UInt;

            cid = _byteData.readUnsignedShort();
            len = _byteData.readUnsignedInt();
            end = _byteData.position + (len - 6);

            switch (cid)
            {
                case 0xA000: // Material name
                    mat.name = readNulTermString();


                case 0xA010: // Ambient color
                    mat.ambientColor = readColor();


                case 0xA020: // Diffuse color
                    mat.diffuseColor = readColor();


                case 0xA030: // Specular color
                    mat.specularColor = readColor();


                case 0xA081: // Two-sided, existence indicates "true"
                    mat.twoSided = true;


                case 0xA200: // Main (color) texture
                    mat.colorMap = parseTexture(end);


                case 0xA204: // Specular map
                    mat.specularMap = parseTexture(end);


                default:
                    _byteData.position = end;

            }
        }
   
		
		_cur_mat = mat;
		_materials.set(_cur_mat.name, _cur_mat);
		_cur_mat = null;
        
    //    trace(mat.name);
	//	trace(mat.colorMap);
	//	trace(mat.specularColor);

        return mat;
    }


    private function parseTexture(end:UInt):String 
	{
        var tex:String="dummy";

    
        while (_byteData.position < end) {
            var cid:UInt;
            var len:UInt;

            cid = _byteData.readUnsignedShort();
            len = _byteData.readUnsignedInt();


            switch (cid)
            {
                case 0xA300:
					{
                    tex = readNulTermString();
			
					}
	           default:
					{
						
                    // Skip this unknown texture sub-chunk
                    _byteData.position += (len - 6);
					}

            }
        }
		
	

        return tex;
    }


    private function parseVertexList():Void {
        var i:UInt;
        var len:UInt;
        var count:Int;

        count = _byteData.readUnsignedShort();
        _cur_obj.verts = Util.Prefill( new Array<Float>(), count * 3, 0);

        i = 0;
        len = count * 3;
        while (i < len) {
            var x:Float, y:Float, z:Float;

            x = _byteData.readFloat();
            y = _byteData.readFloat();
            z = _byteData.readFloat();

	
            _cur_obj.verts[i++] = x;
            _cur_obj.verts[i++] = z;
            _cur_obj.verts[i++] = y;
        }
    }


    private function parseFaceList():Void {
        var i:UInt;
        var len:UInt;
        var count:Int;

        count = _byteData.readUnsignedShort();
        _cur_obj.indices = Util.Prefill( new Array<UInt>(), count * 3, 0);

        i = 0;
        len =count * 3;
        while (i < len) {
            var i0:UInt, i1:UInt, i2:UInt;

            i0 = _byteData.readUnsignedShort();
            i1 = _byteData.readUnsignedShort();
            i2 = _byteData.readUnsignedShort();

            _cur_obj.indices[i++] = i0;
            _cur_obj.indices[i++] = i2;
            _cur_obj.indices[i++] = i1;

            // Skip "face info", irrelevant in a3d
            _byteData.position += 2;
        }

        _cur_obj.smoothingGroups = Util.Prefill( new Array<UInt>(), count, 0 );		
    }

    private function parseSmoothingGroups():Void {
        var len:Int = Std.int(_cur_obj.indices.length / 3);
        var i:Int = 0;
        
        //trace("IN SMOOTHING GROUP: arr.len="+_cur_obj.smoothingGroups.length+" i="+i+" len="+len);
        while (i < len) {
            _cur_obj.smoothingGroups[i] = _byteData.readUnsignedInt();
            i++;
        }
    }

    private function parseUVList():Void {
        var i:UInt;
        var len:UInt;
        var count:Int;

        count = _byteData.readUnsignedShort();
        _cur_obj.uvs = Util.Prefill( new Array<Float>(), count * 2, 0 );

        i = 0;
        len = count * 2;
        while (i < len) {
            _cur_obj.uvs[i++] = _byteData.readFloat();
            _cur_obj.uvs[i++] = 1.0 - _byteData.readFloat();
        }
    }


    private function parseFaceMaterialList():Void {
        var mat:String;
        var count:Int;
        var i:Int;
        var faces:Array<Int>;

        mat = readNulTermString();
        count = _byteData.readUnsignedShort();

        faces = Util.Prefill( new Array<Int>(), count, 0);
        i = 0;
        while (i < count) {
            faces[i++] = _byteData.readUnsignedShort();
        }

        _cur_obj.materials.push(mat);
        _cur_obj.materialFaces.set(mat, faces);
    }


	private function buildSurface():Void
	{
		 constructObject(this._cur_obj);
		 objList.push(this._cur_obj);
		

	}
    private function parseObjectAnimation(end:Float):Void 
	{
        var vo:ObjectVO = null;
     
     //   var pivot:Vector3D = null;
        var name:String = null;
        var hier:Int;

        // Pivot defaults to origin
     var  pivot = new Vector3();
	


        while (_byteData.position < end) 
		{
            var cid:UInt;
            var len:UInt;

            cid = _byteData.readUnsignedShort();
            len = _byteData.readUnsignedInt();
			
            switch (cid)
            {
                case 0xb010: // Name/hierarchy
					{
                    name = readNulTermString();
                    _byteData.position += 4;
                    hier = _byteData.readShort();
					trace(name);
					}

                case 0xb013: // Pivot
					{
                    pivot.x = _byteData.readFloat();
                    pivot.z = _byteData.readFloat();
                    pivot.y = _byteData.readFloat();
					}

                default:
                    _byteData.position += (len - 6);

            }
			
			
			//trace(_byteData.position+"<>"+cid + "<>" + len + "<>" + end);
        }

		  if (name != "$$$DUMMY" )
		  {
			  trace("build :" + name);
		  }
	  //   constructObject(this._cur_obj);
		// objList.push(this._cur_obj);	
   
    }


    private function constructObject(obj:ObjectVO):Void
	{
    
		
          //  var mtx:Matrix4 = null;
            var vertices:Array<VertexVO> = null;
            var faces:Array<FaceVO> = null;

        //    if (obj.materials.length > 1)
           //     trace('The a3d 3DS parser does not support multiple materials per mesh at this point.');

            // Ignore empty objects
            if (obj.indices == null || obj.indices.length == 0)
                return null;

            vertices = Util.Prefill( new Array<VertexVO>(), Std.int(obj.verts.length / 3) );
            faces = Util.Prefill( new Array<FaceVO>(), Std.int(obj.indices.length / 3) );

            prepareData(vertices, faces, obj);
            applySmoothGroups(vertices, faces);
			
			

            obj.verts = Util.Prefill( new Array<Float>(), vertices.length * 3, 0 );
            for (i in 0...vertices.length)
			{
                obj.verts[i * 3] = vertices[i].x;
                obj.verts[i * 3 + 1] = vertices[i].y;
                obj.verts[i * 3 + 2] = vertices[i].z;
	
            }
            obj.indices = Util.Prefill( new Array<UInt>(), faces.length * 3, 0 );
            for (i in 0...faces.length) {
                obj.indices[i * 3] = faces[i].a;
                obj.indices[i * 3 + 1] = faces[i].b;
                obj.indices[i * 3 + 2] = faces[i].c;
            }

            if (obj.uvs != null) 
			{
                // If the object had UVs to start with, use UVs generated by
                // smoothing group splitting algorithm. Otherwise those UVs
                // will be nonsense and should be skipped.
                obj.uvs = Util.Prefill( new Array<Float>(), vertices.length * 2, 0 );
                for (i in 0...vertices.length) {
                    obj.uvs[i * 2] = vertices[i].u;
                    obj.uvs[i * 2 + 1] = vertices[i].v;
                }
            }

        // If reached, unknown
        return null;
    }

	
    private function prepareData(vertices:Array<VertexVO>, faces:Array<FaceVO>, obj:ObjectVO):Void {
        // convert raw ObjectVO's data to structured VertexVO and FaceVO
        var i:Int;
        var j:Int;
        var k:Int;
        var len:Int = obj.verts.length;
        i = 0;
        j = 0;
        k = 0;
        while (i < len) {
            var v:VertexVO = new VertexVO();
            v.x = obj.verts[i++];
            v.y = obj.verts[i++];
            v.z = obj.verts[i++];
            if (obj.uvs != null) {
                v.u = obj.uvs[j++];
                v.v = obj.uvs[j++];
            }
            vertices[k++] = v;
        }

        len = obj.indices.length;
        i = 0;
        k = 0;
        while (i < len) {
            var f:FaceVO = new FaceVO();
            f.a = obj.indices[i++];
            f.b = obj.indices[i++];
            f.c = obj.indices[i++];
            f.smoothGroup = obj.smoothingGroups[k];
            faces[k++] = f;
        }
    }

    private function applySmoothGroups(vertices:Array<VertexVO>, faces:Array<FaceVO>):Void {
        // clone vertices according to following rule:
        // clone if vertex's in faces from groups 1+2 and 3
        // don't clone if vertex's in faces from groups 1+2, 3 and 1+3

        var i:Int;
        var j:Int;
        var k:Int;
        var l:Int;
        var len:Int;
        var numVerts:Int = vertices.length;
        var numFaces:Int = faces.length;

        // extract groups data for vertices
        var vGroups:Array<Array<Int>> = Util.Prefill( new Array<Array<Int>>(), numVerts);
        for (i in 0...numVerts) {
            vGroups[i] = new Array<Int>();
        }
        var groups:Array<Int>;
        var group:UInt;
        var face:FaceVO;
        for (i in 0...numFaces) {
            face = faces[i];
            for (j in 0...3) {
                groups = vGroups[(j == 0) ? face.a : ((j == 1) ? face.b : face.c)];
                group = face.smoothGroup;
                k = groups.length - 1;
                while (k >= 0) {
                    if ((group & groups[k]) > 0) {
                        group |= groups[k];
                        groups.splice(k, 1);
                        k = groups.length - 1;
                    }
                    k--;
                }
                groups.push(group);
            }
        }
        // clone vertices
        var vClones:Array<Array<Int>> = Util.Prefill(new Array<Array<Int>>(), numVerts );
        var clones:Array<Int>;
        for (i in 0...numVerts) {
            if ((len = vGroups[i].length) < 1)
                continue;
            clones = Util.Prefill(new Array<Int>(), len);
			Util.Prefill(clones, len, 0);
            vClones[i] = clones;
            clones[0] = i;
            var v0:VertexVO = vertices[i];
            for (j in 1...len) {
                var v1:VertexVO = new VertexVO();
                v1.x = v0.x;
                v1.y = v0.y;
                v1.z = v0.z;
                v1.u = v0.u;
                v1.v = v0.v;
                clones[j] = vertices.length;
                vertices.push(v1);
            }
        }
        numVerts = vertices.length;

        for (i in 0...numFaces) {
            face = faces[i];
            group = face.smoothGroup;
            for (j in 0...3) {
                k = (j == 0) ? face.a : ((j == 1) ? face.b : face.c);
                groups = vGroups[k];
                len = groups.length;
                clones = vClones[k];
                var l:Int = 0;
                while (l < len) {
                    if (((group == 0) && (groups[l] == 0)) ||
                    ((group & groups[l]) > 0)) {
                        var index:Int = clones[l];
                        if (group == 0) {
                            // vertex is unique if no smoothGroup found
                            groups.splice(l, 1);
                            clones.splice(l, 1);
                        }
                        if (j == 0)
                            face.a = index;
                        else if (j == 1)
                            face.b = index;
                        else
                            face.c = index;
                        l = len;
                    }
                    l++;
                }
            }
        }
    }


  

    private function readNulTermString():String {
        var chr:UInt;
        var str:String = "";

        while ((chr = _byteData.readUnsignedByte()) > 0) {
            str += String.fromCharCode(chr);
        }

        return str;
    }


    private function readTransform():Array<Float> {
        var data:Array<Float>;

        data = Util.Prefill( new Array<Float>(), 16 );

        // X axis
        data[0] = _byteData.readFloat(); // X
        data[2] = _byteData.readFloat(); // Z
        data[1] = _byteData.readFloat(); // Y
        data[3] = 0;

        // Z axis
        data[8] = _byteData.readFloat(); // X
        data[10] = _byteData.readFloat(); // Z
        data[9] = _byteData.readFloat(); // Y
        data[11] = 0;

        // Y Axis
        data[4] = _byteData.readFloat(); // X
        data[6] = _byteData.readFloat(); // Z
        data[5] = _byteData.readFloat(); // Y
        data[7] = 0;

        // Translation
        data[12] = _byteData.readFloat(); // X
        data[14] = _byteData.readFloat(); // Z
        data[13] = _byteData.readFloat(); // Y
        data[15] = 1;

        return data;
    }


    private function readColor():UInt {
        var cid:UInt;
        var len:UInt;
        var r:Int = 0;
        var g:Int = 0;
        var b:Int = 0;

        cid = _byteData.readUnsignedShort();
        len = _byteData.readUnsignedInt();

        switch (cid)
        {
            case 0x0010: // Floats
                r = Std.int(_byteData.readFloat() * 255);
                g = Std.int(_byteData.readFloat() * 255);
                b = Std.int(_byteData.readFloat() * 255);

            case 0x0011: // 24-bit color
                r = _byteData.readUnsignedByte();
                g = _byteData.readUnsignedByte();
                b = _byteData.readUnsignedByte();

            default:
                _byteData.position += (len - 6);

        }

        return (r << 16) | (g << 8) | b;
    }
}

class TextureVO {
    public var url:String;
    public function new() {
    }
}

class MaterialVO {
    public var name:String;
    public var ambientColor:UInt;
    public var diffuseColor:UInt;
    public var specularColor:UInt;
    public var twoSided:Bool;
    public var colorMap:String;
    public var specularMap:String;


    public function new() {
    }
}

class ObjectVO {
    public var name:String;
    public var type:String;
    public var pivotX:Float;
    public var pivotY:Float;
    public var pivotZ:Float;
    public var transform:Vector<Float>;
    public var verts:Array<Float>;
    public var indices:Array<UInt>;
    public var uvs:Array<Float>;
    public var materialFaces:StringMap<Array<Int>>;
    public var materials:Array<String>;
    public var smoothingGroups:Array<Int>;

    public function new() {
    }
}

class VertexVO {
    public var x:Float;
    public var y:Float;
    public var z:Float;
    public var u:Float;
    public var v:Float;
    public var normal:Vector3;
    public var tangent:Vector3;

    public function new() {
    }
}

class FaceVO {
    public var a:Int;
    public var b:Int;
    public var c:Int;
    public var smoothGroup:Int;

    public function new() {
    }
}

