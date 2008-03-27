package phx;

class Contact {

	public var px:Float;	// contact point
	public var py:Float;
	public var nx:Float;	// contact normal
	public var ny:Float;
	public var dist:Float;	// contact penetration distance

	// cache prestep values
	public var r1x:Float;
	public var r1y:Float;
	public var r2x:Float;
	public var r2y:Float;
	public var r1nx:Float;
	public var r1ny:Float;
	public var r2nx:Float;
	public var r2ny:Float;
	public var nMass:Float;
	public var tMass:Float;
	public var bounce:Float;

	// persistant contact infomation
	public var jnAcc:Float;
	public var jtAcc:Float;
	public var jBias:Float;
	public var bias:Float;

	public var hash:Int;
	public var updated:Bool;
	public var next:Contact;

	public function new() {
	}

}
