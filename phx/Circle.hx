package phx;

class Circle extends Shape {

	public var c:Vector;
	public var r:Float;
	public var tC:Vector;

	public function new( radius, offset : Vector, ?material ) {
		super(Shape.CIRCLE, material);
		circle = this;
		this.offset = offset.clone();
		c = offset.clone();
		r = radius;
		area = Math.PI * (r * r);
		tC = c.clone();
	}

	public override function update() {
		tC.x = body.x + Const.XROT(c,body);
		tC.y = body.y + Const.YROT(c,body);
		aabb.l = tC.x - r;
		aabb.r = tC.x + r;
		aabb.t = tC.y - r;
		aabb.b = tC.y + r;
	}

	public override function calculateInertia() {
		return 0.5 * (r * r) + offset.dot(offset);
	}

}
