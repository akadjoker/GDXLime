package com.gdx.scene3d;

import com.gdx.collision.CollisionInfo;
import com.gdx.math.Vector3;

/**
 * ...
 * @author Luis Santos AKA DJOKER
 */

 

class Body extends SceneNode
{
//fisica
	
	public var  isStatic : Bool;

	public var elasticity(get_elasticity, set_elasticity):Float;
	public var friction(get_friction, set_friction):Float;

	public var isColliding:Bool;

	public var mass(get_mass, set_mass):Float;
	private var _mass:Float;
	private var _invMass:Float;
    private var forces:Vector3;
	private var _bounce:Float;
	private var _friction:Float;
	private var collision:CollisionInfo;

		public var px(get_px, set_px):Float;
		public var py(get_py, set_py):Float;
		public var pz(get_pz, set_pz):Float;
		public var invMass(get_invMass, null):Float;

		
	public function new(scene:Scene,Parent:SceneNode = null , id:Int = 0, name:String="Body") 
	{
		super(scene, Parent, id, name);
		
		
		 isStatic = true;
		 this._bounce = 0.3;
		 this._friction = 0;
	
	  
	}
	
	public function setBody(is_static:Bool,
	        mass:Float,
			elasticity:Float,
			friction:Float)
	{
		this._bounce = elasticity;
		this._friction = friction;
	    this.isStatic = is_static;
		forces = Vector3.zero;
		collision = new CollisionInfo(Vector3.zero, Vector3.zero);
        isColliding = false;
		this.mass  	 	 = mass;

	}
	private function get_invMass():Float 
	{
				return (isStatic) ? 0 : _invMass; 
	}
	public function AdvanceForce(v:Vector3):Void
	{
		var dst:Vector3 = Vector3.zero;
		dst=localRotation.TransformVec(v, 0);
		addForce(dst);
		
	}
	public function addForce(f:Vector3):Void 
	{

			var f:Vector3 = Vector3.Mult(f, invMass);
			//forces=Vector3.Add(forces,f);
			forces.addInPlace(f);
	}
		
		public function addMasslessForce(f:Vector3):Void 
		{
			//forces=Vector3.Add(forces,f);
			forces.addInPlace(f);
		}
	
        private function get_mass():Float 
       {
			return _mass; 
		}
		
		
	
		private function set_mass(m:Float):Float {
			if (m <= 0) { return 0.1; }
			_mass = m;
			_invMass = 1 / _mass;
			return _mass; 
		}	
		private function get_elasticity():Float {
			return _bounce; 
		}
		
		
		/**
		 * @private
		 */
		private function set_elasticity(k:Float):Float {
			_bounce = k;
			return _bounce; 
		}
		private function get_friction():Float {
			return _friction; 
		}
	
		
		/**
		 * @private
		 */
		private function set_friction(f:Float):Float {
			if (f < 0 || f > 1){return 0.0;}
			_friction = Math.max(Math.min(f, 1), 0);
			return _friction;
		}
		



		
		

	
		private function get_Position():Vector3 
		{
			
			return position;
		}
		


 		private function set_Position(p:Vector3):Vector3
		{
			position.copy(p);
			return position;
		}

	

		private function get_px():Float {
			return position.x;
		}


		private function set_px(x:Float):Float {
			position.x = x;
			return x;
		}

		private function get_py():Float {
			return position.y;
		}


		private function set_py(y:Float):Float {

			position.y = y;
			return y;
		}
		

		private function get_pz():Float {

			return position.z;
		}

		private function set_pz(z:Float):Float {
	
			position.z = z;
			return z;
		}


		public function getComponents(collisionNormal:Vector3):CollisionInfo 
		{
			var vel:Vector3 =velocity;
			var vdotn:Float = Vector3.Dot(collisionNormal,vel);
			collision.vn = Vector3.Mult(collisionNormal,vdotn);
			collision.vt = Vector3.Sub(vel,collision.vn);
			return collision;
		}
	
	
		public  function resolveCollision(mtd:Vector3, vel:Vector3):Void 
		{
 			         position=Vector3.Add(position,mtd);
					if (! isColliding) velocity = vel;
					isColliding = true;		
					
			
		}
		
		
	

	public function integrate(dt:Float):Void
	{
	
		 if (isStatic) return;
		 
		 addMasslessForce(scene.masslessForce);
		// addForce(scene.force);
	
		    forces.multiplyBy(dt);// = Vector3.Mult(forces, dt);
		    var nv:Vector3 = Vector3.Add(velocity, forces);
		 	nv = Vector3.Mult(nv, 1);
			position.addInPlace(nv);
			forces.set(0,0, 0);

		
	}
		
}