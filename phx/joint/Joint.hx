package phx.joint;

class Joint {

	public var b1:phx.Body;
	public var b2:phx.Body;

	public var anchr1:phx.Vector;
	public var anchr2:phx.Vector;

	public var r1:phx.Vector;
	public var r2:phx.Vector;

	public var n:phx.Vector;
	public var nMass:Float;

	public var jnAcc:Float;
	public var jBias:Float;
	public var bias:Float;

	public var island : phx.Island;

	public function new( b1, b2, anchr1, anchr2 ) {
		this.b1 = b1;
		this.b2 = b2;
		this.anchr1 = anchr1;
		this.anchr2 = anchr2;
		this.jnAcc = 0;
		r1 = new phx.Vector(0,0);
		r2 = new phx.Vector(0,0);
		n = new phx.Vector(0,0);
	}

	public function preStep( invDt : Float ) {
	}

	public function applyImpuse() {
	}

}
