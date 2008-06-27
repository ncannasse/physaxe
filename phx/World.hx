/*
 * Copyright (c) 2008, Nicolas Cannasse
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   - Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   - Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE HAXE PROJECT CONTRIBUTORS "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE HAXE PROJECT CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
 */
package phx;
import phx.joint.Joint;
import phx.col.BroadPhase;

class World implements BroadCallback {

	public var stamp : Int;
	public var bodies : haxe.FastList<Body>;
	public var joints : haxe.FastList<Joint>;
	public var arbiters : haxe.FastList<Arbiter>;
	public var staticBody : Body;
	public var allocator : Allocator;
	public var broadphase : phx.col.BroadPhase;
	public var collision : Collision;
	public var timer : Timer;
	public var box : phx.col.AABB;

	// config
	public var gravity : Vector;
	public var boundsCheck : Int;
	public var useIslands : Bool;
	public var debug : Bool;
	public var testedCollisions : Int;
	public var activeCollisions : Int;
	public var sleepEpsilon : Float;

	public var islands : haxe.FastList<Island>;
	var properties : IntHash<Properties>;
	var waitingBodies : haxe.FastList<Body>;

	public function new( worldBoundary, broadphase ) {
		bodies = new haxe.FastList<Body>();
		joints = new haxe.FastList<Joint>();
		arbiters = new haxe.FastList<Arbiter>();
		properties = new IntHash();
		gravity = new Vector(0,0);
		stamp = 0;
		debug = false;
		useIslands = true;
		sleepEpsilon = Const.DEFAULT_SLEEP_EPSILON;
		boundsCheck = Const.WORLD_BOUNDS_FREQ;
		allocator = new Allocator();
		collision = new Collision();
		staticBody = new phx.Body(0,0);
		staticBody.island = new Island(this);
		staticBody.updatePhysics();
		box = worldBoundary;
		this.broadphase = broadphase;
		broadphase.init(box,this,staticBody);
		timer = new Timer();

		islands = new haxe.FastList<Island>();
		waitingBodies = new haxe.FastList<Body>();
	}

	public function setBroadPhase( bf : BroadPhase ) {
		bf.init(box,this,staticBody);
		for( b in bodies ) {
			for( s in b.shapes ) {
				broadphase.removeShape(s);
				bf.addShape(s);
			}
		}
		for( s in staticBody.shapes ) {
			broadphase.removeShape(s);
			bf.addShape(s);
		}
		broadphase = bf;
	}

	function buildIslands() {
		var stack = new haxe.FastList<Body>();
		for( b in waitingBodies ) {
			if( b.island != null || b.isStatic )
				continue;
			var i = allocator.allocIsland(this);
			islands.add(i);
			stack.add(b);
			b.island = i;
			while( true ) {
				var b = stack.pop();
				if( b == null ) break;
				i.bodies.add(b);
				for( a in b.arbiters ) {
					if( a.island != null ) continue;
					i.arbiters.add(a);
					a.island = i;
					var b1 = a.s1.body;
					if( b1.island == null && !b1.isStatic ) {
						b1.island = i;
						stack.add(b1);
					}
					var b2 = a.s2.body;
					if( b2.island == null && !b2.isStatic ) {
						b2.island = i;
						stack.add(b2);
					}
				}
			}
		}
		waitingBodies = new haxe.FastList<Body>();
	}

	public function step( dt : Float, iterations : Int ) {
		if( dt < Const.EPSILON ) dt = 0;
		timer.start("all");

		// update properties
		var invDt = if( dt == 0 ) 0 else 1 / dt;
		for( p in properties ) {
			p.lfdt = Math.pow(p.linearFriction,dt);
			p.afdt = Math.pow(p.angularFriction,dt);
		}

		// build islands
		timer.start("island");
		if( useIslands )
			buildIslands();
		else {
			var i = allocator.allocIsland(this);
			i.bodies = bodies;
			i.arbiters = arbiters;
			i.joints = joints;
			sleepEpsilon = 0; // disable sleeping
			islands = new haxe.FastList<Island>();
			islands.add(i);
		}
		if( debug ) checkDatas();
		timer.stop();


		// solve physics
		timer.start("solve");
		for( i in islands )
			if( !i.sleeping )
				i.solve(dt,invDt,iterations);
		timer.stop();

		// cleanup old living arbiters
		for( a in arbiters )
			if( stamp - a.stamp > 3 ) {
				allocator.freeAllContacts(a.contacts);
				var b1 = a.s1.body;
				var b2 = a.s2.body;
				b1.arbiters.remove(a);
				b2.arbiters.remove(a);
				arbiters.remove(a);
				allocator.freeArbiter(a);
				destroyIsland(b1.island);
				destroyIsland(b2.island);
			}

		// collide
		timer.start("col");
		broadphase.commit();
		testedCollisions = 0;
		activeCollisions = 0;
		if( debug && !broadphase.validate() )
			throw "INVALID BF DATAS";
		broadphase.collide();
		timer.stop();

		// cleanup
		stamp++;
		if( boundsCheck > 0 && stamp % boundsCheck == 0 ) {
			for( b in broadphase.pick(box) ) {
				removeBody(b);
				b.onDestroy();
			}
		}
		timer.stop();
	}

	function destroyIsland( i : Island ) {
		if( i == null || !useIslands )
			return;
		if( !islands.remove(i) )
			return;
		for( b in i.bodies ) {
			b.island = null;
			waitingBodies.add(b);
		}
		for( a in i.arbiters ) {
			a.sleeping = false;
			a.island = null;
		}
		for( j in i.joints )
			j.island = null;
		allocator.freeIsland(i);
	}

	public function onCollide( s1 : Shape, s2 : Shape ) {
		var b1 = s1.body;
		var b2 = s2.body;

		testedCollisions++;

		if( b1 == b2 || (s1.groups & s2.groups) == 0 )
			return false;

		// prepare for testShapes
		if( s1.type > s2.type ) {
			var tmp = s1;
			s1 = s2;
			s2 = tmp;
		}

		var pairFound = true;
		var a;
		for( arb in b1.arbiters )
			if( (arb.s1 == s1 && arb.s2 == s2) || (arb.s1 == s2 && arb.s2 == s1) ) {
				a = arb;
				break;
			}
		if( a == null ) {
			a = allocator.allocArbiter();
			a.assign(s1,s2);
			pairFound = false;
		} else if( a.sleeping ) {
			a.stamp = stamp;
			return true;
		} else if( a.stamp == stamp ) // this contact has already been processed
			return true;

		a.sleeping = false;
		activeCollisions++;

		var col = collision.testShapes(s1,s2,a);
		if( col ) {
			a.stamp = stamp;
			if( pairFound ) {
				// in case it's been flipped
				a.s1 = s1;
				a.s2 = s2;
			} else {
				arbiters.add(a);
				var i1 = b1.island;
				if( i1 != b2.island ) {
					destroyIsland(i1);
					destroyIsland(b2.island);
				} else if( i1 != null ) {
					i1.arbiters.add(a);
					a.island = i1;
				}
				s2.body.arbiters.add(a);
				s1.body.arbiters.add(a);
			}
		} else if( !pairFound )
			allocator.freeArbiter(a);
		return col;
	}

	public function addStaticShape(s) {
		staticBody.addShape(s);
		s.update();
		broadphase.addShape(s);
		return s;
	}

	public function removeStaticShape(s) {
		staticBody.removeShape(s);
		broadphase.removeShape(s);
	}

	public function addBody(b) {
		bodies.add(b);
		waitingBodies.add(b);
		b.properties.count++;
		b.motion = sleepEpsilon * Const.WAKEUP_FACTOR;
		properties.set(b.properties.id,b.properties);
		if( b.isStatic ) {
			b.mass = Math.POSITIVE_INFINITY;
			b.invMass = 0;
			b.inertia = Math.POSITIVE_INFINITY;
			b.invInertia = 0;
			for( s in b.shapes )
				s.update();
		} else
			b.updatePhysics();
		for( s in b.shapes )
			broadphase.addShape(s);
	}

	public function removeBody(b) {
		if( !bodies.remove(b) ) return;
		b.properties.count--;
		if( b.properties.count == 0 )
			properties.remove(b.properties.id);
		for( s in b.shapes )
			broadphase.removeShape(s);
		destroyIsland(b.island);
		waitingBodies.remove(b);
	}

	public function activate( b : Body ) {
		var i = b.island;
		b.motion = sleepEpsilon * Const.WAKEUP_FACTOR;
		if( i != null && i.sleeping ) {
			i.sleeping = false;
			for( a in i.arbiters )
				a.sleeping = false;
		}
	}

	public function addJoint(j) {
		joints.add(j);
	}

	public function removeJoint(j) {
		joints.remove(j);
		destroyIsland(j.b1.island);
		destroyIsland(j.b2.island);
	}

	public function sync( b : Body ) {
		for( s in b.shapes ) {
			s.update();
			broadphase.syncShape(s);
		}
	}

	function checkBody( b : Body, i : Island ) {
		if( b.island != i )
			throw "ASSERT";
		for( a in b.arbiters ) {
			if( a.island != i )
				throw "ASSERT";
			if( a.s1.body.island != i && !a.s1.body.isStatic )
				throw "ASSERT";
			if( a.s2.body.island != i && !a.s2.body.isStatic )
				throw "ASSERT";
		}
	}

	function checkDatas() {
		for( b in waitingBodies )
			checkBody(b,null);
		for( i in islands )
			for( b in i.bodies )
				checkBody(b,i);
	}

}
