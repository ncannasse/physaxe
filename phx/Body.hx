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

class Body {

	static var ID = 0;

	public var id : Int;

	public var mass : Float;
	public var invMass : Float;
	public var inertia : Float;
	public var invInertia : Float;

	public var x:Float;			// position
	public var y:Float;
	public var v:Vector;		// velocity
	public var f:Vector;		// force
	public var v_bias:Vector;	// used internally for penetration/joint correction

	public var a:Float;			// angle
	public var w:Float;			// angular velocity
	public var t:Float;			// torque
	public var w_bias:Float;	// used internally for penetration/joint correction
	public var rcos:Float;		// current rotation
	public var rsin:Float;

	public var motion:Float;
	public var isStatic:Bool;
	public var island : Island;

	public var shapes : haxe.FastList<Shape>;
	public var arbiters : haxe.FastList<Arbiter>;
	public var properties : Properties;

	public function new( x, y, ?props ) {
		id = ID++;
		properties = if( props == null ) Const.DEFAULT_PROPERTIES else props;
		this.x = x;
		this.y = y;
		v = new phx.Vector(0,0);
		f = new phx.Vector(0,0);
		v_bias = new phx.Vector(0,0);
		a = w = t = w_bias = 0;
		rcos = 1; rsin = 0;
		motion = Const.WAKEUP_EPSILON;
		shapes = new haxe.FastList<Shape>();
		arbiters = new haxe.FastList<Arbiter>();
	}

	public function addShape( s : Shape ) {
		shapes.add(s);
		s.body = this;
	}

	public function removeShape( s : Shape ) {
		shapes.remove(s);
		s.body = null;
	}

	public function updatePhysics() {
		var m = 0.;
		var i = 0.;
		for( s in shapes ) {
			var sm = s.area * Const.AREA_MASS_RATIO * s.material.density;
			m += sm;
			i += s.calculateInertia();
		}
		if( m > 0 ) {
			mass = m;
			invMass = 1 / m;
		} else {
			mass = Math.POSITIVE_INFINITY;
			invMass = 0;
			isStatic = true;
		}
		if( i > 0 ) {
			inertia = i;
			invInertia = 1 / i;
		} else {
			inertia = Math.POSITIVE_INFINITY;
			invInertia = 0;
		}
	}

	public function setAngle( a : Float ) {
		this.a = a;
		rcos = Math.cos(a);
		rsin = Math.sin(a);
	}

	public function set( ?pos : Vector, ?a : Float, ?v : Vector, ?w : Float ) {
		if( pos != null ) {
			x = pos.x;
			y = pos.y;
		}
		if( a != null ) setAngle(a);
		if( v != null ) {
			this.v.x = v.x;
			this.v.y = v.y;
		}
		if( w != null ) this.w = w;
	}

	public function setPos( x, y, ?a ) {
		this.x = x;
		this.y = y;
		if( a != null ) setAngle(a);
	}

	public function setSpeed( vx, vy, ?w ) {
		v.x = vx;
		v.y = vy;
		if( w != null ) this.w = w;
	}

	public f9dynamic function onDestroy() {
	}

}
