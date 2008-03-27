package phx;

class Material {

	public var restitution:Float;
	public var friction:Float;
	public var density:Float;

	public function new( restitution, friction, density ) {
		this.restitution = restitution;
		this.friction = friction;
		this.density = density;
	}

}
