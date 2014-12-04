package com.gdx.color ;



class Color3 {

	
	public static var WHITE:Color3 = new Color3(1.0, 1.0, 1.0);
	public static var BLACK:Color3 = new Color3(0.0, 0.0, 0.0);
	public static var RED:Color3 = new Color3(1.0, 0.0, 0.0);
	public static var GREEN:Color3 = new Color3(0.0, 1.0, 0.0);
	public static var BLUE:Color3 = new Color3(0.0, 0.0, 1.0);
	public static var DARKVIOLET:Color3 = new Color3(0.58, 0.0, 0.83);
	public static var DARKORANGE:Color3 = new Color3(1.0, 0.50, 0.83);
	public static var BROWN:Color3 = new Color3(0.64, 0.16, 0.16);
	public static var DARKSALMON:Color3 = new Color3(0.91, 0.59, 0.48);
	public static var YELLOW:Color3 = new Color3(1.0, 1.0, 0.0);
	public static var FORESTGREEN:Color3 = new Color3(0.13, 0.55, 0.13);
	public static var CYAN:Color3 = new Color3(0.0, 1.0, 1.0);
	public static var MAGNETA:Color3 = new Color3(1.0, 0.0, 1.0);
	public static var STEELBLUE:Color3 = new Color3(0.32, 0.58, 0.80);
	public static var GRAY60:Color3 = new Color3(0.60, 0.60, 0.60);
	public static var GRAY40:Color3 = new Color3(0.40, 0.40, 0.40);
	
	public var r:Float;		
	public var g:Float;
	public var b:Float;


	
	public function new(initialR:Float = 0, initialG:Float = 0, initialB:Float = 0) {
		this.r = initialR;
        this.g = initialG;
        this.b = initialB;
	}
		public function set(initialR:Float = 0, initialG:Float = 0, initialB:Float = 0) {
		this.r = initialR;
        this.g = initialG;
        this.b = initialB;
	}
   inline public static function Lerp(start:Color3, end:Color3, amount:Float):Color3 
   {
		var _r = start.r + ((end.r - start.r) * amount);
		var _g = start.g + ((end.g - start.g) * amount);
		var _b = start.b + ((end.b - start.b) * amount);
        

     return new Color3(_r, _g, _b);
	}
	  inline public  function interpolateLocal(beginColor:Color3, finalColor:Color3, changeAmnt:Float):Color3 
   {
		r = (1 - changeAmnt) * beginColor.r + changeAmnt * finalColor.r;
        g = (1 - changeAmnt) * beginColor.g + changeAmnt * finalColor.g;
        b = (1 - changeAmnt) * beginColor.b + changeAmnt * finalColor.b;
        

     return this;
	}
	inline public  function interpolate( finalColor:Color3,changeAmnt :Float):Color3 
   {
	    this.r = (1 - changeAmnt) * this.r + changeAmnt * finalColor.r;
        this.g = (1 - changeAmnt) * this.g + changeAmnt * finalColor.g;
        this.b = (1 - changeAmnt) * this.b + changeAmnt * finalColor.b;
   

     return this;
	}
	inline public function equals(otherColor:Color3):Bool {
		return this.r == otherColor.r && this.g == otherColor.g && this.b == otherColor.b;
	}
	
	public function toString():String {
		return "{R: " + this.r + " G:" + this.g + " B:" + this.b + "}";
	}
	
	inline public function clone():Color3 {
		return new Color3(this.r, this.g, this.b);
	}
	
	inline public function asArray():Array<Float> {
        var result = []; 
        this.toArray(result, 0); 
        return result;
    }
 
    inline public function toArray(array:Array<Float>, index:Int = 0) { 
        array[index] = this.r;
        array[index + 1] = this.g;
        array[index + 2] = this.b;
    }
	
	inline public function multiply(otherColor:Color3):Color3 {
		return new Color3(this.r * otherColor.r, this.g * otherColor.g, this.b * otherColor.b);
	}
	
	inline public function multiplyToRef(otherColor:Color3, result:Color3) {
		result.r = this.r * otherColor.r;
        result.g = this.g * otherColor.g;
        result.b = this.b * otherColor.b;
	}
	
	inline public function scale(scale:Float):Color3 {
		return new Color3(this.r * scale, this.g * scale, this.b * scale);
	}
	
	inline public function scaleToRef(scale:Float, result:Color3) {
		result.r = this.r * scale;
        result.g = this.g * scale;
        result.b = this.b * scale;
	}
	
	inline public function copyFrom(source:Color3) {
		this.r = source.r;
        this.g = source.g;
        this.b = source.b;
	}
	
	inline public function copyFromFloats(r:Float, g:Float, b:Float) {
		this.r = r;
        this.g = g;
        this.b = b;
	}
	
	
	inline public static function FromArray(array:Array<Float>):Color3 {
		return new Color3(array[0], array[1], array[2]);
	}

}
