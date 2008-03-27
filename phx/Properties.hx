package phx;

class Properties {

	static var PID = 0;

	public var linearFriction : Float;
	public var angularFriction : Float;
	public var biasCoef : Float;
	public var maxMotion : Float;

	// internal
	public var id : Int;
	public var count : Int;
	public var lfdt : Float;
	public var afdt : Float;

	public function new( linearFriction, angularFriction, biasCoef, maxMotion ) {
		id = PID++;
		this.linearFriction = linearFriction;
		this.angularFriction = angularFriction;
		this.biasCoef = biasCoef;
		this.maxMotion = maxMotion;
	}

}