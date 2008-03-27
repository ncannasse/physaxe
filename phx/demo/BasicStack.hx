package phx.demo;

class BasicStack extends Demo {

	public function init() {
		world.gravity.set(0,0.1875);
		createFloor();
		var box = phx.Shape.makeBox( 30, 30, new phx.Material(0.0, .8, 1) );
		var startY = floor - 15;
		for( y in 0...18 ) {
			var offset = (y % 2) != 0 ? 15:0;
			for( x in 0...10 )
				createPoly( offset + 150 + (x * 30), startY - (y * 30), 0, box );
		}
	}
}
