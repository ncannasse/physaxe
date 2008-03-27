package phx.demo;

class BoxPyramidDemo extends Demo {

	public function init() {
		createFloor();
		world.gravity.set(0,0.09375);

		var box = phx.Shape.makeBox( 30, 30, new phx.Material(0.01,1,.8) );
		var cirBody = new phx.Body( 300, floor-30 );
		var circ = new phx.Circle( 14, new phx.Vector(0,0), new phx.Material(0.0,0.9,1) );
		cirBody.addShape(circ);
		world.addBody(cirBody);

		for( y in 0...14 )
			for( x in 0...y )
				createPoly( 300 + (x * 32) - (y*16), 70 + y*32, 0, box );
	}

}
