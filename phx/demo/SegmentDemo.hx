package phx.demo;

class SegmentDemo extends Demo {

	var bodies : Array<phx.Body>;
	var numBodies : Int;
	var refreshDelay : Int;
	var lastRefresh : Int;

	public function new() {
		super();
		bodies = new Array();
		numBodies = 200;
		refreshDelay = 9;
		lastRefresh = 50;
	}

	public function init() {
		world.gravity.set(0, 0.3125);

		world.addStaticShape( new phx.Segment( new phx.Vector(0, 0), new phx.Vector(220, 200), 4));
		world.addStaticShape( new phx.Segment( new phx.Vector(600, 0), new phx.Vector(380, 200), 4));

		world.addStaticShape( new phx.Segment( new phx.Vector(200, 350), new phx.Vector(300, 300), 4));
		world.addStaticShape( new phx.Segment( new phx.Vector(400, 350), new phx.Vector(300, 300), 4));

		world.addStaticShape( new phx.Segment( new phx.Vector(100, 400), new phx.Vector(200, 500), 2));
		world.addStaticShape( new phx.Segment( new phx.Vector(500, 400), new phx.Vector(400, 500), 2));

		var material = new phx.Material(0.0, 0.2, 1);
		for( i in 0...numBodies ) {
			var s : phx.Shape;
			if( rand(0,2) > 0 )
				s = createConvexPoly(Std.int(rand(3, 4)),rand(12, 20),0, material);
			else
				s = new phx.Circle(rand(8,20),new phx.Vector(0,0));
			var b = addBody( 300 + rand(-200, 200), rand(-50,-150), s );
			bodies.push(b);
		}
	}

	public function step( dt : Float ) {
		lastRefresh += 1;
		if( lastRefresh < refreshDelay )
			return;
		for( b in bodies ) {
			if( (b.y > size.y + 20) || (b.x < -20) || (b.y > size.x + 20) ) {
				b.setPos( 300 + rand(-200, 200), rand(-50,-100) );
				b.setSpeed( rand(-10,10)/40, rand(10,100)/40 );
			}
		}
	}
}
