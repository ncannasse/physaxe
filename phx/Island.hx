package phx;
import phx.joint.Joint;

class Island {

	static var ID = 0;

	public var id : Int;
	public var bodies : haxe.FastList<Body>;
	public var arbiters : haxe.FastList<Arbiter>;
	public var joints : haxe.FastList<Joint>;
	public var sleeping : Bool;
	public var energy : Float;
	var world : World;

	public var allocNext : Island;

	public function new(w) {
		id = ID++;
		world = w;
		sleeping = false;
		bodies = new haxe.FastList<Body>();
		joints = new haxe.FastList<Joint>();
		arbiters = new haxe.FastList<Arbiter>();
	}

	public function solve( dt : Float, invDt : Float, iterations : Int ) {

		// update bodies
		var g = world.gravity;
		for( b in bodies ) {
			var v = b.v;
			var p = b.properties;
			v.x = v.x * p.lfdt + (g.x + b.f.x * b.invMass) * dt;
			v.y = v.y * p.lfdt + (g.y + b.f.y * b.invMass) * dt;
			b.w = b.w * p.afdt + b.t * b.invInertia * dt;
		}

		// prestep arbiters and joints
		for( a in arbiters )
			a.preStep(dt);
		for( joint in joints )
			joint.preStep(invDt);

		// solve velocity constraints
		for( i in 0...iterations ) {
			for( a in arbiters )
				a.applyImpulse();
			for( j in joints )
				j.applyImpuse();
		}

		// update bodies position
		var bf = world.broadphase;
		var e = 0.;
		var n = 0;
		for( b in bodies ) {
			var motion = b.v.x * b.v.x + b.v.y * b.v.y + b.w * b.w * Const.ANGULAR_TO_LINEAR;
			if( motion > b.properties.maxMotion ) {
				var k = Math.sqrt(b.properties.maxMotion / motion);
				b.v.x *= k;
				b.v.y *= k;
				b.w *= k;
				motion *= k * k;
			}
			b.x += b.v.x * dt + b.v_bias.x;
			b.y += b.v.y * dt + b.v_bias.y;
			b.setAngle( b.a + b.w * dt + b.w_bias );
			b.motion = b.motion * Const.SLEEP_BIAS + (1 - Const.SLEEP_BIAS) * motion;
			b.f.x = b.f.y = b.t = 0;
			b.v_bias.x = b.v_bias.y = b.w_bias = 0;
			e += b.motion;
			n++;
			for( s in b.shapes ) {
				s.update();
				bf.syncShape(s);
			}
		}
		energy = e / (n + 1);

		if( energy < Const.SLEEP_EPSILON && world.allowSleep ) {
			for( b in bodies ) {
				b.v.x = 0;
				b.v.y = 0;
				b.w = 0;
			}
			for( a in arbiters )
				a.sleeping = true;
			sleeping = true;
		}
	}

}