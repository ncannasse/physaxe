class Main {

	public var debug : Bool;
	public var stopped : Bool;
	public var recalStep : Bool;

	var root : flash.display.MovieClip;
	var tf : flash.text.TextField;
	var world : phx.World;
	var demo : phx.demo.Demo;
	var draw : Bool;
	var curbf : Int;
	var frame : Int;
	var broadphases : Array<phx.col.BroadPhase>;

	public function new(root) {
		this.root = root;
		tf = new flash.text.TextField();
		tf.selectable = false;
		tf.width = 300;
		tf.height = 500;
		root.addChild(tf);
		frame = 0;
		draw = true;
		debug = false;
		stopped = false;
		var stage = root.stage;
		stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		stage.addEventListener(flash.events.Event.ENTER_FRAME,onEnterFrame);
		stage.addEventListener(flash.events.MouseEvent.MOUSE_DOWN,onMouseDown);
		stage.addEventListener(flash.events.KeyboardEvent.KEY_DOWN,onKeyDown);
		broadphases = new Array();
		broadphases.push(new phx.col.SortedList());
		broadphases.push(new phx.col.BruteForce());
	}

	function onEnterFrame(_) {

		// step
		var steps = if( stopped ) 0 else demo.steps;
		var dt = 1;
		var niter = 20;
		for( i in 0...steps ) {
			try {
				demo.step(dt/steps);
				world.step(dt/steps,niter);
			} catch( e : Dynamic ) {
				trace("STOPPED!");
				stopped = true;
				throw e;
			}
		}
		if( recalStep ) world.step(0,1);

		// draw
		root.graphics.clear();
		var fd = new phx.FlashDraw(root.graphics);
		if( debug ) {
			fd.boundingBox.line = 0x000000;
			fd.contact.line = 0xFF0000;
			fd.sleepingContact.line = 0xFF00FF;
			fd.contact.fill = 0x00FF00;
			fd.contact.alpha = 0.5;
		}
		if( draw )
			fd.drawWorld(world);

		// update infos
		if( frame++ % Std.int(flash.Lib.current.stage.frameRate / 4) == 0 )
			tf.text = buildInfos().join("\n");
	}

	function onMouseDown( e : flash.events.MouseEvent ) {
		fireBlock();
	}

	function onKeyDown( e : flash.events.KeyboardEvent ) {
		switch( e.keyCode ) {
		case flash.ui.Keyboard.SPACE:
			debug = !debug;
		case 66: /*B*/
			curbf = (curbf + 1) % broadphases.length;
			world.setBroadPhase(broadphases[curbf]);
		case 68: /*D*/
			draw = !draw;
		case 83: /*S*/
			root.stage.frameRate = (root.stage.frameRate == 1) ? root.stage.loaderInfo.frameRate : 1;
		case 49: /*1*/ setDemo(new phx.demo.DominoPyramid());
		case 50:/*2*/ setDemo(new phx.demo.BasicStack());
		case 51:/*3*/ setDemo(new phx.demo.PyramidThree());
		case 52:/*4*/ setDemo(new phx.demo.BoxPyramidDemo());
		case 53:/*5*/ setDemo(new phx.demo.PentagonRain());
		case 54:/*6*/ setDemo(new phx.demo.Jumble());
		case 55:/*7*/ setDemo(new phx.demo.SegmentDemo());
		case 56:/*8*/ setDemo(new phx.demo.TitleDemo());
		case 57:/*9*/ setDemo(new phx.demo.Test());
		case flash.ui.Keyboard.ESCAPE: setDemo(demo);
		}
	}

	public function setDemo( demo : phx.demo.Demo ) {
		this.demo = demo;
		stopped = false;
		recalStep = false;
		world = new phx.World(new phx.col.AABB(-2000,-2000,2000,2000),broadphases[curbf]);
		demo.start(world);
	}

	public function buildInfos() {
		var t = world.timer;
		var tot = t.total;
		var log = [
			"Stamp=" + world.stamp,
			"Demo=" + Type.getClassName(Type.getClass(demo)),
			"Bodies=" + Lambda.count(world.bodies),
			"Arbit=" + Lambda.filter(world.arbiters,function(a) return !a.sleeping).length + " / " + Lambda.count(world.arbiters),
			"BF=" + Type.getClassName(Type.getClass(world.broadphase)),
			"COLS=" + world.activeCollisions+ " / "+world.testedCollisions,
			t.format("all"),
			t.format("col"),
			t.format("island"),
			t.format("solve"),
		];
		var nislands = Lambda.count(world.islands);
		if( nislands > 5 )
			log.push("Islands="+nislands);
		else
			for( i in world.islands ) {
				var str = "Island= #" + Lambda.count(i.bodies);
				str += if( i.sleeping ) " SLEEP" else " e=" + Math.ceil(i.energy*1000)/1000;
				var b = i.bodies.first();
				str += " (" + Math.ceil(b.x) + "," + Math.ceil(b.y) + ")";
				log.push(str);
			}
		return log;
	}

	public function fireBlock() {
		var pos = new phx.Vector(root.stage.stageWidth,root.stage.stageHeight);
		pos.x += 100;
		pos.y /= 3;

		var v = new phx.Vector( root.mouseX - pos.x, root.mouseY - pos.y );
		var k = 15 / v.length();
		v.x *= k;
		v.y *= k;

		var b = new phx.Body(0,0);
		b.set(pos,0,v,2);
		b.addShape( phx.Shape.makeBox(20,20,new phx.Material(0.0, 1, 5)) );
		world.addBody(b);
	}

	public static var inst : Main;

	static function main() {
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		inst = new Main(flash.Lib.current);
		inst.setDemo(new phx.demo.TitleDemo());
	}

}
