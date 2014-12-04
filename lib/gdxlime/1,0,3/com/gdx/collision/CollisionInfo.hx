package  com.gdx.collision;
import com.gdx.math.Vector3;
/**
 * ...
 * @author Luis Santos AKA DJOKER
 */
class CollisionInfo
{
        public var vn:Vector3;
		public var vt:Vector3;
		
		public function new(vn:Vector3, vt:Vector3) {
			this.vn = vn;
			this.vt = vt;
		}
	
}