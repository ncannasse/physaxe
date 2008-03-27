package phx.col;
import phx.col.BroadPhase;
import phx.Shape;

class BruteForce implements BroadPhase {

	var shapes : haxe.FastList<Shape>;
	var callb : BroadCallback;

	public function new() {
	}

	public function init( bounds, callb ) {
		this.callb = callb;
		shapes = new haxe.FastList<Shape>();
	}

	public function addShape( s : Shape ) {
		shapes.add(s);
	}

	public function removeShape( s : Shape ) {
		shapes.remove(s);
	}

	public function collide() {
		var s1 = shapes.head;
		while( s1 != null ) {
			var box1 = s1.elt.aabb;
			var s2 = s1.next;
			while( s2 != null ) {
				if( box1.intersects2(s2.elt.aabb) )
					callb.onCollide(s1.elt,s2.elt);
				s2 = s2.next;
			}
			s1 = s1.next;
		}
	}

	public function pick( box : AABB ) {
		var bodies = new haxe.FastList<phx.Body>();
		// we might test several time the same body
		// but assume that >1 shapes bodies are rare
		for( sh in shapes ) {
			var cull = true;
			for( s in sh.body.shapes )
				if( box.intersects(s.aabb) ) {
					cull = false;
					break;
				}
			if( cull ) {
				bodies.remove(sh.body);
				bodies.add(sh.body);
			}
		}
		return bodies;
	}

	public function syncShape( s : phx.Shape ) {
		// nothing
	}

	public function commit() {
		// nothing
	}

	public function validate() {
		return true;
	}

}
