package com.gdx.math ;



class Matrix2D{
	

	public static  var DEG_TO_RAD:Float = 180 / Math.PI;
	
	public var a:Float;
	public var b:Float;
	public var c:Float;
	public var d:Float;
	public var tx:Float;
	public var ty:Float;
	
	
	public function new (a:Float = 1, b:Float = 0, c:Float = 0, d:Float = 1, tx:Float = 0, ty:Float = 0) {
		
		this.a = a;
		this.b = b;
		this.c = c;
		this.d = d;
		this.tx = tx;
		this.ty = ty;
		
	}
	
	
	public function clone ():Matrix2D {
		
		return new Matrix2D (a, b, c, d, tx, ty);
		
	}
	
	
	public function concat (m:Matrix2D):Void {
		
		var a1 = a * m.a + b * m.c;
		b = a * m.b + b * m.d;
		a = a1;
		
		var c1 = c * m.a + d * m.c;
		d = c * m.b + d * m.d;
		
		c = c1;
		
		var tx1 = tx * m.a + ty * m.c + m.tx;
		ty = tx * m.b + ty * m.d + m.ty;
		tx = tx1;
		
	}
	
	
	public function copyColumnFrom (column:Int, vector:Vector2):Void {
		
		if (column > 2) {
			
			throw "Column " + column + " out of bounds (2)";
			
		} else if (column == 0) {
			
			a = vector.x;
			c = vector.y;
			
		}else if (column == 1) {
			
			b = vector.x;
			d = vector.y;
			
		}else {
			
			tx = vector.x;
			ty = vector.y;
			
		}
		
	}
	
	
	public function copyColumnTo (column:Int, vector:Vector2):Void {
		
		if (column > 2) {
			
			throw "Column " + column + " out of bounds (2)";
			
		} else if (column == 0) {
			
			vector.x = a;
			vector.y = c;

			
		} else if (column == 1) {
			
			vector.x = b;
			vector.y = d;

			
		} else {
			
			vector.x = tx;
			vector.y = ty;

			
		}
		
	}
	
	
	public function copyFrom (other:Matrix2D):Void {
		
		this.a = other.a;
		this.b = other.b;
		this.c = other.c;
		this.d = other.d;
		this.tx = other.tx;
		this.ty = other.ty;
		
	}
	
	
	
	
	public function createBox (scaleX:Float, scaleY:Float, rotation:Float = 0, tx:Float = 0, ty:Float = 0):Void {
		
		a = scaleX;
		d = scaleY;
		b = rotation;
		this.tx = tx;
		this.ty = ty;
		
	}
	
	

	
	public function createGradientBox (width:Float, height:Float, rotation:Float = 0, tx:Float = 0, ty:Float = 0):Void {
		
		a = width / 1638.4;
		d = height / 1638.4;
		
		if (rotation != 0.0) {
			
			var cos = Math.cos (rotation);
			var sin = Math.sin (rotation);
			b = sin * d;
			c = -sin * a;
			a *= cos;
			d *= cos;
			
		} else {
			
			b = c = 0;
			
		}
		
		this.tx = tx + width / 2;
		this.ty = ty + height / 2;
		
	}
	
	
	public function deltaTransformPoint (point:Vector2):Vector2 {
		
		return new Vector2 (point.x * a + point.y * c, point.x * b + point.y * d);
		
	}
	
	
	public function identity ():Void {
		
		a = 1;
		b = 0;
		c = 0;
		d = 1;
		tx = 0;
		ty = 0;
		
	}
	
	
	public function invert ():Matrix2D {
		
		var norm = a * d - b * c;
		
		if (norm == 0) {
			
			a = b = c = d = 0;
			tx = -tx;
			ty = -ty;
			
		} else {
			
			norm = 1.0 / norm;
			var a1 = d * norm;
			d = a * norm;
			a = a1;
			b *= -norm;
			c *= -norm;
			
			var tx1 = - a * tx - c * ty;
			ty = - b * tx - d * ty;
			tx = tx1;
			
		}
		
		return this;
		
	}
	
	
	public function mult (m:Matrix2D):Matrix2D {
		
		var result = new Matrix2D ();
		
		result.a = a * m.a + b * m.c;
		result.b = a * m.b + b * m.d;
		result.c = c * m.a + d * m.c;
		result.d = c * m.b + d * m.d;
		
		result.tx = tx * m.a + ty * m.c + m.tx;
		result.ty = tx * m.b + ty * m.d + m.ty;
		
		return result;
		
	}
	
	
	public function rotate (angle:Float):Void {
		
		var cos = Math.cos (angle);
		var sin = Math.sin (angle);
		
		var a1 = a * cos - b * sin;
		b = a * sin + b * cos;
		a = a1;
		
		var c1 = c * cos - d * sin;
		d = c * sin + d * cos;
		c = c1;
		
		var tx1 = tx * cos - ty * sin;
		ty = tx * sin + ty * cos;
		tx = tx1;
		
	}
	
	
	public function scale (x:Float, y:Float):Void {
		
		a *= x;
		b *= y;
		
		c *= x;
		d *= y;
		
		tx *= x;
		ty *= y;
		
	}
	
	
	public function setRotation (angle:Float, scale:Float = 1):Void {
		
		a = Math.cos (angle) * scale;
		c = Math.sin (angle) * scale;
		b = -c;
		d = a;
		
	}
	
	
	public function setTo (a:Float, b:Float, c:Float, d:Float, tx:Float, ty:Float):Void {
		
		this.a = a;
		this.b = b;
		this.c = c;
		this.d = d;
		this.tx = tx;
		this.ty = ty;
		
	}
	public  inline function skew( skewX:Float, skewY:Float)
        {
            var sinX:Float = Math.sin(skewX);
            var cosX:Float = Math.cos(skewX);
            var sinY:Float = Math.sin(skewY);
            var cosY:Float = Math.cos(skewY);
           
            setTo(       a  * cosY - b  * sinX,
                         a  * sinY + b  * cosX,
                         c  * cosY - d  * sinX,
                         c  * sinY + d  * cosX,
                         tx * cosY - ty * sinX,
                         tx * sinY + ty * cosX);
        }
	public  inline function appendSkew( skewX:Float, skewY:Float):Matrix2D
        {
        skewX = skewX * Matrix2D.DEG_TO_RAD;
        skewY = skewY * Matrix2D.DEG_TO_RAD;
        this.append(Math.cos(skewY), Math.sin(skewY), -Math.sin(skewX), Math.cos(skewX), 0, 0);
        return this;
    }
	
	public  inline function convertTo3D(mat:Matrix4 )
        {
            
			
         
            mat.m[0] = a;
            mat.m[1] = b;
            mat.m[4] = c;
            mat.m[5] = d;
            mat.m[12] = tx;
            mat.m[13] = ty;
            
            
        
		}
	
	public function toString ():String {
		
		return "(a=" + a + ", b=" + b + ", c=" + c + ", d=" + d + ", tx=" + tx + ", ty=" + ty + ")";
		
	}
	
	
	public function transformPoint (point:Vector2):Vector2 {
		
		return new Vector2 (point.x * a + point.y * c + tx, point.x * b + point.y * d + ty);
		
	}
	
	
	public function translate (x:Float, y:Float):Void {
		
		tx += x;
		ty += y;
		
	}
	
	public function prepend (a:Float, b:Float, c:Float, d:Float, tx:Float, ty:Float):Matrix2D
	{
        var tx1:Float = this.tx;
        if (a != 1 || b != 0 || c != 0 || d != 1) {
            var a1:Float = this.a;
            var c1:Float = this.c;
            this.a = a1 * a + this.b * c;
            this.b = a1 * b + this.b * d;
            this.c = c1 * a + this.d * c;
            this.d = c1 * b + this.d * d;
        }
        this.tx = tx1 * a + this.ty * c + tx;
        this.ty = tx1 * b + this.ty * d + ty;
        return this;
    }
	 public function append (a:Float, b:Float, c:Float, d:Float, tx:Float, ty:Float):Matrix2D
	 {
        var a1 = this.a;
        var b1 = this.b;
        var c1 = this.c;
        var d1 = this.d;

        this.a = a * a1 + b * c1;
        this.b = a * b1 + b * d1;
        this.c = c * a1 + d * c1;
        this.d = c * b1 + d * d1;
        this.tx = tx * a1 + ty * c1 + this.tx;
        this.ty = tx * b1 + ty * d1 + this.ty;
        return this;
    }
	public function prependMatrix (matrix:Matrix2D):Matrix2D
	{
	this.prepend(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
	return this;
	}
	 public function appendMatrix(matrix:Matrix2D):Matrix2D
	{
	this.prepend(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
	return this;
	}
	 public function prependTransform  (x:Float, y:Float, scaleX:Float, scaleY:Float, rotation:Float, skewX:Float, skewY:Float, regX:Float, regY:Float):Matrix2D 
	 {
		 var cos:Float = 0;
		 var sin:Float = 0;
		 var r:Float = 0;
		 
        if (rotation !=0) 
		{
             r = rotation * Matrix2D.DEG_TO_RAD;
             cos = Math.cos(r);
             sin = Math.sin(r);
        } else {
            cos = 1;
            sin = 0;
        }

        if (regX!=0.0 || regY!=0.0) 
		{
            this.tx -= regX;
            this.ty -= regY;
        }
        if (skewX != 0.0 || skewY != 0.0)
		{
           skewX *= Matrix2D.DEG_TO_RAD;
            skewY *= Matrix2D.DEG_TO_RAD;
            this.prepend(cos * scaleX, sin * scaleX, -sin * scaleY, cos * scaleY, 0, 0);
            this.prepend(Math.cos(skewY), Math.sin(skewY), -Math.sin(skewX), Math.cos(skewX), x, y);
        } else {
            this.prepend(cos * scaleX, sin * scaleX, -sin * scaleY, cos * scaleY, x, y);
        }
        return this;
    }
	 public function appendTransform  (x:Float, y:Float, scaleX:Float, scaleY:Float, rotation:Float, skewX:Float, skewY:Float, regX:Float, regY:Float):Matrix2D 
	 {
		 var cos:Float = 0.0;
		 var sin:Float = 0.0;
		 var r:Float = 0.0;
		 
        if (rotation !=0.0) 
		{
             r = rotation * Matrix2D.DEG_TO_RAD;
             cos = Math.cos(r);
             sin = Math.sin(r);
        } else {
            cos = 1;
            sin = 0;
        }

    
        if (skewX != 0.0 || skewY != 0.0) 
		{
            skewX *= Matrix2D.DEG_TO_RAD;
            skewY *= Matrix2D.DEG_TO_RAD;
            this.append(Math.cos(skewY), Math.sin(skewY), -Math.sin(skewX), Math.cos(skewX), x, y);
            this.append(cos * scaleX, sin * scaleX, -sin * scaleY, cos * scaleY, 0, 0);
        } else {
            this.append(cos * scaleX, sin * scaleX, -sin * scaleY, cos * scaleY, x, y);
        }
		
		  
		 if (regX!=0.0 || regY!=0.0) 
		{
   
            this.tx -= regX * this.a + regY * this.c;
            this.ty -= regX * this.b + regY * this.d;
        }
		
        return this;
    }
}