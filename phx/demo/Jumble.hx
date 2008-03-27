package phx.demo;

class Jumble extends Demo {

	var addDelay : Int;
	var lastAdd : Int;
	var material : phx.Material;

	public function new() {
		super();
		addDelay = 30;
		lastAdd = 50;
		material = new phx.Material(0.1, 0.5, 1);
	}

	public function init() {
		world.gravity.set(0,0.3125);
		createFloor();
	}

	public function step( dt : Float) {
		lastAdd += 1;
		if( lastAdd < addDelay ) return;
		lastAdd = 0;

		var body = new phx.Body(0,0);
		body.addShape(phx.Shape.makeBox(60,10,material));
		body.addShape(phx.Shape.makeBox(10,60,material));
		body.addShape(new phx.Circle(12,new phx.Vector(-30,0),material));
		body.addShape(new phx.Circle(12,new phx.Vector(30,0),material));
		body.addShape(new phx.Circle(12,new phx.Vector(0,-30),material));
		body.addShape(new phx.Circle(12,new phx.Vector(0,30),material));
		body.setPos( 300 + rand(-250,250), rand(-200,-20), rand(0,2*Math.PI) );
		body.w = rand( -2, 2 ) / 40;
		world.addBody(body);
	}

}
