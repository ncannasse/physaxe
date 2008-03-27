package phx;

class Vector {

	public var x:Float;
	public var y:Float;

	public var next:Vector;

	public function new( px : Float, py : Float ) {
		x = px;
		y = py;
	}

	public inline function clone() {
		return new Vector(x,y);
	}

	public inline function set( px : Float, py : Float) {
		x = px;
		y = py;
	}

	public inline function dot( v : Vector ) {
		return x * v.x + y * v.y;
	}

	public inline function cross( v : Vector ) {
		return x * v.y - y * v.x;
	}

	public inline function plus( v : Vector ) {
		return new Vector(x + v.x, y + v.y);
	}

	public inline function minus( v : Vector ) : Vector {
		return new Vector(x - v.x, y - v.y);
	}

	public inline function mult( s : Float ) {
		return new Vector(x * s, y * s);
	}

	public inline function length() {
		return Math.sqrt(x * x + y * y);
	}

	public function toString() {
		return "("+(Math.round(x*100)/100)+","+(Math.round(y*100)/100)+")";
	}

	public static inline function normal( x : Float, y : Float ) {
		var d = Math.sqrt(x * x + y * y);
		var k = if( d < Const.EPSILON ) 0 else 1 / d;
		return new Vector( -y * k , x * k );
	}

}
