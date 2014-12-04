package com.gdx.scene2d;







/**
 * ...
 * @author djoker
 */
class BitmapFont extends GlGraphic
{
public var align:Int;



	
private var image:Texture;
private var offsetX:Int;
private var offsetY:Int;
private var characterWidth:Int;
private var characterHeight:Int;
private var characterSpacingX:Int;
private var characterSpacingY:Int;
private var characterPerRow:Int;

private var glyphs:Array<Clip>;


public function new(tex:Texture,
width:Int, height:Int, 
charsPerRow:Int, 
xSpacing:Int = 0, ySpacing:Int = 0, 
xOffset:Int = 0, yOffset:Int = 0,
//?chars:String = " 0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[/]^-'abcdefghijklmnopqrstuvwxyz{|]~"):Void
chars:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ.,\"-+!?()':;0123456789"):Void
{

super();


image = tex;
align = 0;





		
characterWidth = width;
characterHeight = height;
characterSpacingX = xSpacing;
characterSpacingY = ySpacing;
characterPerRow = charsPerRow;
offsetX = xOffset;
offsetY = yOffset;


glyphs = [];

var currentX:Int = offsetX;
var currentY:Int = offsetY;
var r:Int = 0;
var index:Int = 0;

for(c in 0...chars.length)

{
 

glyphs[chars.charCodeAt(c)] = new Clip(currentX, currentY, characterWidth, characterHeight);
//trace(glyphs[chars.charCodeAt(c)].toString());

r++;
if (r == characterPerRow)
{
r = 0;
currentX = offsetX;
currentY += characterHeight + characterSpacingY;
}
else
{
currentX += characterWidth + characterSpacingX;
}
}
}




 public function print(batch:SpriteBatch, caption:String, x:Float, y:Float,?align:Int=0)
{
	

			
    var cx:Int = 0;
    var cy:Int = 0;
	var X:Float = x;
	var Y:Float = y;
	var newLine:Float = characterHeight + characterSpacingY;

	   switch (align) 
       { 
       case 0:
       cx = 0;
       case 1:
       cx = getTextWidth(caption);
       case 2:
       cx = Std.int(getTextWidth(caption) / 2);
	   default:
	   cx = 0;
   
       }
	   


  for (c in 0...caption.length)   
   {
    if(caption.charAt(c) == " ")
    {
       X += characterWidth + characterSpacingX;
    }
    else
	  if(caption.charAt(c) == "\n")
    {
	   Y += newLine;	
       X = x-characterWidth + characterSpacingX;
    } else
      {
        var glyph = glyphs[caption.charCodeAt(c)];
        X += characterWidth + characterSpacingX;
	   if (glyph != null) batch.RenderFontScale(image, (X - cx) - characterWidth, Y, scaleX, scaleY, glyph, false, false,  _red, _green, _blue, alpha, BlendMode.NORMAL);
	}
  }		
  

}


public function getTextWidth(caption:String):Int 
	{
		var w:Int = 0;
		var textLength:Int = caption.length;
		for (i in 0...(textLength)) 
		{
        var glyph:Int = Std.int(caption.charCodeAt(i));
		w += characterWidth+characterSpacingX;
		w = Math.round(w * scaleX);
		}
		return w;
	}


	
}