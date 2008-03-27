package phx.col;

class AABB {

	public var l:Float;
	public var b:Float;
	public var r:Float;
	public var t:Float;

	public var shape : phx.Shape;
	public var prev : AABB;
	public var next : AABB;

	public function new(left,top,right,bottom) {
		this.l = left;
		this.t = top;
		this.r = right;
		this.b = bottom;
	}

	public inline function intersects( aabb : AABB ) {
		return !(aabb.l > r || aabb.r < l || aabb.t > b || aabb.b < t);
	}

	public inline function intersects2( aabb:AABB ) {
		return (l<=aabb.r && aabb.l<=r && t<=aabb.b && aabb.t<=b);
	}

	public inline function containsPoint( v : phx.Vector ) {
		return !(v.y < t || v.y > b || v.x < l || v.x > r);
	}

	public function toString() {
		return "[l=" + l + " b=" + b + " r=" + r + " t=" + t + "]";
	}

}
