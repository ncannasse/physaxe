package phx.demo;

class TitleDemo extends Demo {

	public function init() {
		createWord("physaxe", 60, 180, 20, 0);
		var material = new phx.Material(0.1, 0.7, 3);
		var stick1 = addRectangle( -100, 0, 100, 20, material );
		stick1.setSpeed( 2, 1, .075 );
		var stick2 = addRectangle( 700, 600, 100, 20, material );
		stick2.setSpeed( -2, -1, -.025 );
		var stick3 = addBody( 290, 750, createConvexPoly(3,30,0,material) );
		stick3.setSpeed( .25, -1.25, .005 );
	}

}
