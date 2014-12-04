package com.gdx.util;

abstract Vector<T>(VectorData<T>) {
	
	
	public var length (get, set):Int;
	public var fixed (get, set):Bool;
	
	
	public function new (?length:Int = 0, ?fixed:Bool = false):Void {
		
		this = new VectorData<T> ();
		this.data = new haxe.ds.Vector<T> (length);
		this.length = length;
		this.fixed = fixed;
		
	}
	
	
	public function concat (?a:VectorData<T>):Vector<T> {
		
		var vectorData = new VectorData<T> ();
		vectorData.length = (a != null) ? this.length + a.length : this.length;
		vectorData.fixed = false;
		vectorData.data = new haxe.ds.Vector<T> (vectorData.length);
		
		haxe.ds.Vector.blit (this.data, 0, vectorData.data, 0, this.length);
		
		if (a != null) {
			
			haxe.ds.Vector.blit (a.data, 0, vectorData.data, this.length, a.length);
			
		}
		
		return cast vectorData;
		
	}
	
	
	public function copy ():Vector<T> {
		
		var vectorData = new VectorData<T> ();
		vectorData.length = length;
		vectorData.fixed = fixed;
		vectorData.data = new haxe.ds.Vector<T> (length);
		haxe.ds.Vector.blit (this.data, 0, vectorData.data, 0, this.length);
		return cast vectorData;
		
	}
	
	
	public function iterator<T> ():Iterator<T> {
		
		return new VectorDataIterator<T> (this);
		
	}
	
	
	public function join (sep:String):String {
		
		var output = "";
		
		for (i in 0...this.length) {
			
			if (i > 0) output += sep;
			output += this.data[i];
		
		}
		
		return output;
		
	}
	
	
	public function pop ():Null<T> {
		
		if (!this.fixed) {
			
			if (this.length > 0) {
				
				this.length--;
				return this.data[this.length];
				
			}
			
		}
		
		return null;
		
	}
	
	
	public inline function push (x:T):Int {
		
		if (!this.fixed) {
			
			this.length++;
			
			if (this.data.length < this.length) {
				
				var data = new haxe.ds.Vector<T> (this.data.length + 10);
				haxe.ds.Vector.blit (this.data, 0, data, 0, this.data.length);
				this.data = data;
				
			}
			
			this.data[this.length - 1] = x;
			
		}
		
		return this.length;
		
	}
	
	
	public function reverse ():Void {
		
		var data = new haxe.ds.Vector<T> (this.length);
		
		for (i in 0...this.length) {
			
			data[this.length - 1 - i] = this.data[i];
			
		}
		
		this.data = data;
		
	}
	
	
	public function shift ():Null<T> {
		
		if (!this.fixed && this.length > 0) {
			
			var value = this.data[0];
			this.length--;
			haxe.ds.Vector.blit (this.data, 1, this.data, 0, this.length);
			return value;
			
		}
		
		return null;
		
	}
	
	
	public inline function unshift (x:T):Void {
		
		if (!this.fixed) {
			
			this.length++;
			
			if (this.data.length < this.length) {
				
				var data = new haxe.ds.Vector<T> (this.length + 10);
				haxe.ds.Vector.blit (this.data, 0, data, 1, this.data.length);
				this.data = data;
				
			} else {
				
				haxe.ds.Vector.blit (this.data, 0, this.data, 1, this.length - 1);
				
			}
			
			this.data[0] = x;
			
		}
		
	}
	
	
	public function slice (?pos:Int = 0, ?end:Int = 0):Vector<T> {
		
		if (pos < 0) pos += this.length;
		if (end <= 0) end += this.length;
		if (end > this.length) end = this.length;
		var length = end - pos;
		if (length <= 0 || length > this.length) length = this.length;
		
		var vectorData = new VectorData<T> ();
		vectorData.length = end - pos;
		vectorData.fixed = true;
		vectorData.data = new haxe.ds.Vector<T> (length);
		haxe.ds.Vector.blit (this.data, pos, vectorData.data, 0, length);
		return cast vectorData;
		
	}
	
	
	public function sort (f:T -> T -> Int):Void {
		
		#if (haxe_ver > 3.100)
		var array = this.data.toArray ();
		#else
		var array:Array<T> = cast this.data;
		#end
		array.sort (f);
		this.data = haxe.ds.Vector.fromArrayCopy (array);
		
	}
	
	
	public function splice (pos:Int, len:Int):Vector<T> {
		
		if (pos < 0) pos += this.length;
		if (pos + len > this.length) len = this.length - pos;
		if (len < 0) len = 0;
		
		var vectorData = new VectorData<T> ();
		vectorData.length = len;
		vectorData.fixed = false;
		vectorData.data = new haxe.ds.Vector<T> (len);
		haxe.ds.Vector.blit (this.data, pos, vectorData.data, 0, len);
		
		if (len > 0) {
			
			this.length -= len;
			haxe.ds.Vector.blit (this.data, pos + len, this.data, pos, this.length - pos);
			
		}
		
		return cast vectorData;
		//return this.splice (pos, len);
		
	}
	
	
	public function toString ():String {
		
		return "";
		//return this.toString ();
		
	}
	
	
	public function indexOf (x:T, ?from:Int = 0):Int {
		
		for (i in from...this.length) {
			
			if (this.data[i] == x) {
				
				return i;
				
			}
			
		}
		
		return -1;
		
	}
	
	
	public function lastIndexOf (x:T, ?from:Int = 0):Int {
		
		var i = this.length - 1;
		
		while (i >= from) {
			
			if (this.data[i] == x) return i;
			i--;
			
		}
		
		return -1;
		
	}
	
	
	public inline static function ofArray<T> (a:Array<Dynamic>):Vector<T> {
		
		var vectorData = new VectorData<T> ();
		vectorData.length = a.length;
		vectorData.fixed = true;
		vectorData.data = haxe.ds.Vector.fromArrayCopy (a);
		return cast vectorData;
		
	}
	
	
	public inline static function convert<T,U> (v:Vector<T>):Vector<U> {
		
		return cast v;
		
	}
	
	
	@:arrayAccess public inline function arrayAccess (key:Int):T {
		
		return this.data[key];
		
	}
	
	
	@:arrayAccess public inline function arrayWrite (key:Int, value:T):T {
		
		if (key >= this.length && !this.fixed) this.length = key + 1;
		
		return this.data[key] = value;
		
	}
	
	
	@:from static public inline function fromArray<T> (value:Array<T>):Vector<T> {
		
		var vectorData = new VectorData<T> ();
		vectorData.length = value.length;
		vectorData.fixed = true;
		vectorData.data = haxe.ds.Vector.fromArrayCopy (value);
		return cast vectorData;
		
	}
	
	
	@:to public inline function toArray<T> ():Array<T> {
		
		var value = new Array ();
		
		for (i in 0...this.data.length) {
			
			value.push (this.data[i]);
			
		}
		
		return value;
		
	}
	
	
	@:from static public inline function fromHaxeVector<T> (value:haxe.ds.Vector<T>):Vector<T> {
		
		var vectorData = new VectorData<T> ();
		vectorData.length = value.length;
		vectorData.fixed = true;
		vectorData.data = value;
		return cast vectorData;
		
	}
	
	
	@:to public inline function toHaxeVector<T> ():haxe.ds.Vector<T> {
		
		return this.data;
		
	}
	
	
	@:from static public inline function fromVectorData<T> (value:VectorData<T>):Vector<T> {
		
		return cast value;
		
	}
	
	
	@:to public inline function toVectorData<T> ():VectorData<T> {
		
		return cast this;
		
	}
	
	
	
	
	// Getters & Setters
	
	
	
	
	private inline function get_length ():Int {
		
		return this.length;
		
	}
	
	
	private inline function set_length (value:Int):Int {
		
		if (!fixed) {
			
			if (value > this.length) {
				
				var data = new haxe.ds.Vector<T> (value);
				haxe.ds.Vector.blit (this.data, 0, data, 0, Std.int (Math.min (this.data.length, value)));
				this.data = data;
				
			}
			
			this.length = value;
			
		}
		
		return value;
		
	}
	
	
	private inline function get_fixed ():Bool {
		
		return this.fixed;
		
	}
	
	
	private inline function set_fixed (value:Bool):Bool {
		
		return this.fixed = value;
		
	}
	
	
}


@:dox(hide) class VectorData<T> {
	
	
	public var data:haxe.ds.Vector<T>;
	public var fixed:Bool;
	public var length:Int;
	
	
	public function new () {
		
		length = 0;
		
	}
	
	
}


@:dox(hide) class VectorDataIterator<T> {
	
	
	private var index:Int;
	private var vectorData:VectorData<T>;
	
	
	public function new (data:VectorData<T>) {
		
		index = 0;
		vectorData = data;
		
	}
	
	
	public function hasNext ():Bool {
		
		return index < vectorData.length;
		
	}
	
	
	public function next ():T {
		
		return vectorData.data[index++];
		
	}
	
	
}
