package phx.col;
import phx.col.BroadPhase;
import phx.Shape;

class SortedList implements BroadPhase {

	var boxes : AABB;
	var callb : BroadCallback;

	public function new() {
	}

	public function init( bounds, callb ) {
		this.callb = callb;
		boxes = null;
	}

	function addSort( b : AABB ) {
		var cur = boxes;
		var prev = null;
		while( cur != null && cur.t < b.t ) {
			prev = cur;
			cur = cur.next;
		}
		b.prev = prev;
		b.next = cur;
		if( prev == null )
			boxes = b;
		else
			prev.next = b;
		if( cur != null )
			cur.prev = b;
	}

	public function addShape( s : Shape ) {
		var b = s.aabb;
		b.shape = s;
		addSort(b);
	}

	public function removeShape( s : Shape ) {
		var b = s.aabb;
		var next = b.next;
		var prev = b.prev;
		if( prev == null )
			boxes = next;
		else
			prev.next = next;
		if( next != null )
			next.prev = prev;
	}

	public function collide() {
		var b1 = boxes;
		while( b1 != null ) {
			var b2 = b1.next;
			var bottom = b1.b;
			while( b2 != null ) {
				if( b2.t > bottom )	break;
				if( b1.intersects2(b2) )
					callb.onCollide(b1.shape,b2.shape);
				b2 = b2.next;
			}
			b1 = b1.next;
		}
	}

	public function pick( box : AABB ) {
		var bodies = new haxe.FastList<phx.Body>();
		// we might test several time the same body
		// but assume that >1 shapes bodies are rare
		var b = boxes;
		while( b != null ) {
			var body = b.shape.body;
			var cull = true;
			for( s in body.shapes )
				if( box.intersects(s.aabb) ) {
					cull = false;
					break;
				}
			if( cull ) {
				bodies.remove(body);
				bodies.add(body);
			}
			b = b.next;
		}
		return bodies;
	}

	public function syncShape( s : Shape ) {
		var b = s.aabb;
		var prev = b.prev;
		var next = b.next;
		if( prev != null && prev.t > b.t ) {
			prev.next = next;
			if( next != null )
				next.prev = prev;
			addSort(b);
		} else if( next != null && next.t < b.t ) {
			if( prev == null )
				boxes = next;
			else
				prev.next = next;
			next.prev = prev;
			addSort(b);
		}
	}

	public function commit() {
		// nothing, syncShape already sorted the list
	}

	public function validate() {
		var cur = boxes;
		while( cur != null ) {
			var next = cur.next;
			if( next != null && next.t < cur.t )
				return false;
			cur = next;
		}
		return true;
	}


}