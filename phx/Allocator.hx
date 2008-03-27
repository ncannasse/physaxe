package phx;

class Allocator {

	var contactPool : Contact;
	var islandPool : Island;

	public function new() {
	}

	public inline function allocIsland(w) {
		var i = islandPool;
		if( i == null )
			return new Island(w);
		else {
			islandPool = i.allocNext;
			return i;
		}
	}

	public inline function freeIsland( i : Island ) {
		i.bodies.head = null;
		i.arbiters.head = null;
		i.joints.head = null;
		i.sleeping = false;
		i.allocNext = islandPool;
		islandPool = i;
	}

	public inline function allocArbiter() {
		return new Arbiter(this);
	}

	public inline function freeArbiter( a : Arbiter ) {
	}

	public inline function allocContact() {
		var c = contactPool;
		if( c == null )
			return new Contact();
		else {
			contactPool = c.next;
			return c;
		}
	}

	public inline function freeContact( c : Contact ) {
		c.next = contactPool;
		contactPool = c;
	}

	public inline function freeAllContacts( c : Contact ) {
		while( c != null ) {
			var next = c.next;
			c.next = contactPool;
			contactPool = c;
			c = next;
		}
	}

}