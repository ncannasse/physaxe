package phx;

class Segment extends Shape {

	public var a : Vector;
	public var b : Vector;
	public var n : Vector;

	public var r : Float;

	public var tA : Vector;
	public var tB : Vector;
	public var tN : Vector;
	public var tNneg : Vector;

	public function new( a : Vector, b : Vector, r : Float, ?material : Material ) {
		super(Shape.SEGMENT, material);
		segment = this;
		offset = new Vector(0,0);
		this.a = a.clone();
		this.b = b.clone();
		this.r = r;
		var delta = b.minus(a);
		n = Vector.normal(delta.x,delta.y);
		area = r * delta.length();
		tA = new Vector(0,0);
		tB = new Vector(0,0);
		tN = new Vector(0,0);
		tNneg = new Vector(0,0);
	}

	public override function update() {
		// transform
		tA.x = body.x + Const.XROT(a,body);
		tA.y = body.y + Const.YROT(a,body);
		tB.x = body.x + Const.XROT(b,body);
		tB.y = body.y + Const.YROT(b,body);
		tN.x = Const.XROT(n,body);
		tN.y = Const.YROT(n,body);
		tNneg.x = -tN.x;
		tNneg.y = -tN.y;

		// update bounding box
		if( tA.x < tB.x ) {
			aabb.l = tA.x - r;
			aabb.r = tB.x + r;
		} else {
			aabb.l = tB.x - r;
			aabb.r = tA.x + r;
		}
		if( tA.y < tB.y ) {
			aabb.t = tA.y - r;
			aabb.b = tB.y + r;
		} else {
			aabb.t = tB.y - r;
			aabb.b = tA.y + r;
		}
	}

	public override function calculateInertia() {
		return 1.;
	}

}
