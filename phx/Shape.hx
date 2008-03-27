package phx;

class Shape {

	static var ID = 0;

	public static inline var CIRCLE = 0;
	public static inline var SEGMENT = 1;
	public static inline var POLYGON = 2;

	public var id : Int;
	public var type : Int;
	public var circle : Circle;
	public var segment : Segment;
	public var polygon : Polygon;

	public var body : Body;
	public var offset : Vector;
	public var aabb : phx.col.AABB;

	public var material : Material;
	public var area : Float;

	public var groups : Int;

	function new( type : Int, material : Material ) {
		id = ID++;
		groups = 1;
		this.type = type;
		this.material = (material == null) ? Const.DEFAULT_MATERIAL : material;
		this.area = 0;
		aabb = new phx.col.AABB(0,0,0,0);
	}

	public function update() {
	}

	public function calculateInertia() {
		return 1.;
	}

	public static function makeBox( width : Float, height : Float, ?px, ?py, ?mat ) {
		if( px == null ) px = -width / 2;
		if( py == null ) py = -height / 2;
		return new Polygon([
			new phx.Vector(0,0),
			new phx.Vector(0,height),
			new phx.Vector(width,height),
			new phx.Vector(width,0),
		],new phx.Vector(px,py),mat);
	}

}
