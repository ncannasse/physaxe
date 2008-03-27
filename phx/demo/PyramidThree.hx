package phx.demo;

class PyramidThree extends Demo {

	public function init() {
		world.gravity.set(0,0.125);
		createFloor();

		var width = 70;
		var height = 11;
		var slab = phx.Shape.makeBox(width,height,new phx.Material(0.0, 1, 1));
		var p0 = phx.Const.DEFAULT_PROPERTIES;
		var props = new phx.Properties(p0.linearFriction,p0.angularFriction,0.001,phx.Const.FMAX);

		var startY = floor - (height / 2);
		var startX = size.y / 2;
		var segcount = 5;
		for( i in 0...5 ) {
			createPoly( startX - width, startY, 0, slab, props );
			createPoly( startX + width, startY, 0, slab, props );
			for( y in 0...segcount ) {
				for( x in 0...y+1 )
					createPoly( startX - (x * width) + y * (width / 2), startY, 0, slab, props );
				startY -= height;
			}
			var y = segcount;
			while( y > 0 ) {
				for( x in 0...y+1 )
					createPoly( startX - (x * width) + y * (width / 2), startY, 0, slab, props );
				startY -= height;
				y--;
			}
		}
	}

}

