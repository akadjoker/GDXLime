package  com.gdx.collision;
import com.gdx.math.Plane;
import com.gdx.math.Triangle;
import com.gdx.math.Vector3;


/**
 * ...
 * @author Luis Santos AKA DJOKER
 */
class CollisionData
{
    public var eRadius: Vector3;
	public var R3Velocity: Vector3;
	public var R3Position: Vector3;
	public var velocity: Vector3;
	public var normalizedVelocity: Vector3;
	public var basePoint:Vector3;
	public var foundCollision:Bool;
	public var nearestDistance:Float;
	public var intersectionPoint:Vector3;
	public var triangle:Triangle;
	public var triangleHits:Int;
	public var slidingSpeed:Float;
	public var finalPosition:Vector3;
	public var Falling:Bool;
	public var hitPosition:Vector3;
	public var trianglePlane:Plane;
	public var planeIsFloor:Bool;
	
	
	public function new() 
	{
	eRadius = Vector3.zero;
	R3Velocity = Vector3.zero;
	R3Position = Vector3.zero;
	velocity = Vector3.zero;
	normalizedVelocity = Vector3.zero;
	basePoint = Vector3.zero;
	foundCollision=false;
	nearestDistance = 9999999999999.0;
	Falling = false;
	hitPosition = Vector3.zero;
	intersectionPoint = Vector3.zero;
	triangle = new Triangle(Vector3.zero,Vector3.zero,Vector3.zero,Vector3.zero);
	triangleHits = 0;
	slidingSpeed = 0;
	finalPosition = Vector3.zero;
	trianglePlane = new Plane(0, 0, 0, 0);
	planeIsFloor = false;
		
	}
	
}