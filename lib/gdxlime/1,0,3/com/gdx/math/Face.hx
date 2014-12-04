package com.gdx.math;

/**
 * ...
 * @author djoekr
 */
class Face
{

	  public  var v0:Int;
	  public  var v1:Int;
	  public  var v2:Int;
	  public function new(v0:Int, v1:Int, v2:Int)
	  {
		  this.v0 = v0;
		  this.v1 = v1;
		  this.v2 = v2;
	  }
	  public function toString():String
	  {
		  return "v0:" + v0 + ",v1:" + v1 + ",v2:" + v2;
	  }
	  public function clone():Face
	  {
		  return new Face(v0, v1, v2);
	  }
 
	
}