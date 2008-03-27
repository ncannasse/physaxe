package phx.demo;

class DominoPyramid extends Demo {

	public function init() {
		world.gravity.set(0,0.3125);
		createFloor();

		var d_width = 5;
		var d_heigth = 20;
		var stackHeigth = 9;
		var xstart = 60.0;
		var yp = floor;
		var d90 = Math.PI / 2;
		var domino = phx.Shape.makeBox(d_width*2, d_heigth*2, new phx.Material(0.0, 0.6, 0.5));

		for( i in 0...stackHeigth ) {
			var dw = ((i == 0)?2 * d_width:0);
			for( j in 0...stackHeigth - i ) {
				var xp = xstart + (3*d_heigth*j);
				if( i == 0 ) {
					createPoly( xp , yp - d_heigth, 0, domino );
					createPoly( xp , yp - (2 * d_heigth) - d_width, d90, domino );
				} else {
					createPoly( xp , yp - d_width, d90, domino );
					createPoly( xp , yp - (2 * d_width) - d_heigth, 0, domino );
					createPoly( xp , yp - (3 * d_width) - (2 * d_heigth), d90, domino );
				}
				if( j == 0 )
					createPoly( xp - d_heigth + d_width , yp - (3 * d_heigth) - (4 * d_width) + dw, 0, domino );
				if( j == stackHeigth - i - 1 )
					createPoly( xp + d_heigth - d_width , yp - (3 * d_heigth) - (4 * d_width) + dw, 0, domino );
			}
			yp -= (2*d_heigth)+(4*d_width) - dw;
			xstart += 1.5 * d_heigth;
		}
	}

}
