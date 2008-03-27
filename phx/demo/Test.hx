package phx.demo;

class Test extends Demo {

	var body : phx.Body;

	public function init() {
		#if flash9
		var stage = flash.Lib.current.stage;
		//stage.frameRate = 1;
		#end
		Main.inst.recalStep = true;
		Main.inst.debug = true;
		steps = 1;
		world.gravity.set(0,1000);
		createFloor();
		body = addBody( 300, 300, phx.Shape.makeBox(32,64), new phx.Properties(1.0,1.0,0.9,1000000) );
	}

	public function step( dt ) {
		//trace(body.v.y * body.v.y);
	}

}