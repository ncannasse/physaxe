package phx;

class Axis {

	public var n : Vector; // normal
	public var d : Float; // distance from origin

	public var next : Axis;

	public function new( n : Vector, d : Float ) {
		this.n = n;
		this.d = d;
	}

	public inline function clone() {
		return new Axis( this.n.clone(), this.d );
	}

	public function toString() {
		return "[Axis= " + n.x + "," + n.y + " d=" + d+"]";
	}

}
