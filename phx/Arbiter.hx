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

class Arbiter {

	public var contacts : Contact;

	var friction : Float;
	var restitution : Float;
	var bias : Float;
	public var s1 : Shape;
	public var s2 : Shape;

	public var stamp : Int;
	public var updated : Bool;
	public var island : Island;
	public var allocator : Allocator;
	public var sleeping : Bool;

	public function new(alloc) {
		allocator = alloc;
	}

	public function assign( s1, s2 ) {
		this.s1 = s1;
		this.s2 = s2;
		var m1 = s1.material;
		var m2 = s2.material;
		var p1 = s1.body.properties;
		var p2 = s2.body.properties;
		restitution = m1.restitution * m2.restitution;
		friction = m1.friction * m2.friction;
		bias = (p1.biasCoef > p2.biasCoef) ? p1.biasCoef : p2.biasCoef;
	}

	public function injectContact( p : Vector, n : Vector, nCoef : Float, dist : Float, hash : Int ) {
		var c = contacts;
		while( c != null ) {
			if( hash == c.hash )
				break;
			c = c.next;
		}
		if( c == null ) {
			c = allocator.allocContact();
			c.hash = hash;
			c.jnAcc = c.jtAcc = 0;
			c.next = contacts;
			contacts = c;
		}
		// init datas
		c.px = p.x;
		c.py = p.y;
		c.nx = n.x * nCoef;
		c.ny = n.y * nCoef;
		c.dist = dist;
		c.updated = true;
	}

	inline function bodyImpulse( c : Contact, b1 : Body, b2 : Body, cjTx : Float, cjTy : Float ) {
		b1.v.x -= cjTx * b1.invMass;
		b1.v.y -= cjTy * b1.invMass;
		b1.w -= b1.invInertia * (c.r1x * cjTy - c.r1y * cjTx);
		b2.v.x += cjTx * b2.invMass;
		b2.v.y += cjTy * b2.invMass;
		b2.w += b2.invInertia * (c.r2x * cjTy - c.r2y * cjTx);
	}

	public function preStep( dt : Float ) {
		var b1 = s1.body;
		var b2 = s2.body;
		var mass_sum = b1.invMass + b2.invMass;

		var c = contacts;
		var prev = null;

		while( c != null ) {
			if( !c.updated ) {
				var old = c;
				c = c.next;
				allocator.freeContact(old);
				if( prev == null )
					contacts = c;
				else
					prev.next = c;
				continue;
			}
			c.updated = false;

			// local anchors and their normals
			c.r1x = c.px - b1.x;
			c.r1y = c.py - b1.y;
			c.r2x = c.px - b2.x;
			c.r2y = c.py - b2.y;

			c.r1nx = -c.r1y;
			c.r1ny =  c.r1x;
			c.r2nx = -c.r2y;
			c.r2ny =  c.r2x;

			// normal mass
			var r1cn = c.r1x * c.ny - c.r1y * c.nx;
			var r2cn = c.r2x * c.ny - c.r2y * c.nx;
			var kn = mass_sum + (b1.invInertia * r1cn * r1cn) + (b2.invInertia * r2cn * r2cn);
			c.nMass = 1 / kn;

			// tangent mass
			var tx = -c.ny;
			var ty = c.nx;
			var r1ct = c.r1x * ty - c.r1y * tx;
			var r2ct = c.r2x * ty - c.r2y * tx;
			var kt = mass_sum + b1.invInertia * r1ct * r1ct + b2.invInertia * r2ct * r2ct;
			c.tMass = 1 / kt;

			// bias
			c.bias = -bias * (c.dist + Const.SLOP);
			c.jBias = 0;

			var v1x = c.r1nx * b1.w + b1.v.x;
			var v1y = c.r1ny * b1.w + b1.v.y;
			var v2x = c.r2nx * b2.w + b2.v.x;
			var v2y = c.r2ny * b2.w + b2.v.y;
			c.bounce = (c.nx * (v2x - v1x) + c.ny * (v2y - v1y)) * restitution * dt;

			// apply impulse
			var cjTx = (c.nx * c.jnAcc) + (tx * c.jtAcc);
			var cjTy = (c.ny * c.jnAcc) + (ty * c.jtAcc);
			bodyImpulse(c,b1,b2,cjTx,cjTy);

			prev = c;
			c = c.next;
		}
	}

	public function applyImpulse() {
		var b1 = s1.body;
		var b2 = s2.body;
		var c = contacts;
		while( c != null ) {
			// calculate the relative bias velocities
			var vbn =
				((c.r2nx * b2.w_bias + b2.v_bias.x) - (c.r1nx * b1.w_bias + b1.v_bias.x)) * c.nx +
				((c.r2ny * b2.w_bias + b2.v_bias.y) - (c.r1ny * b1.w_bias + b1.v_bias.y)) * c.ny;

			// calculate and clamp the bias impulse
			var jbn = (c.bias - vbn) * c.nMass;
			var jbnOld = c.jBias;
			c.jBias = jbnOld + jbn;
			if( c.jBias < 0 ) c.jBias = 0;
			jbn = c.jBias - jbnOld;

			// apply the bias impulse
			var cjTx = c.nx * jbn;
			var cjTy = c.ny * jbn;

			b1.v_bias.x -= cjTx * b1.invMass;
			b1.v_bias.y -= cjTy * b1.invMass;
			b1.w_bias   -= b1.invInertia * (c.r1x * cjTy - c.r1y * cjTx);

			b2.v_bias.x += cjTx * b2.invMass;
			b2.v_bias.y += cjTy * b2.invMass;
			b2.w_bias   += b2.invInertia * (c.r2x * cjTy - c.r2y * cjTx);

			// calculate the relative velocity
			var vrx = (c.r2nx * b2.w + b2.v.x) - (c.r1nx * b1.w + b1.v.x);
			var vry = (c.r2ny * b2.w + b2.v.y) - (c.r1ny * b1.w + b1.v.y);

			// calculate and clamp the normal impulse
			var jn = (c.bounce + (vrx * c.nx + vry * c.ny)) * c.nMass;
			var jnOld = c.jnAcc;
			c.jnAcc = jnOld - jn;
			if( c.jnAcc < 0 ) c.jnAcc = 0;
			jn = c.jnAcc - jnOld;

			// calculate the relative tangent velocity
			var vrt = c.nx * vry - c.ny * vrx;

			// calculate and clamp the friction impulse
			var jtMax = friction * c.jnAcc;
			var jt = vrt * c.tMass;
			var jtOld = c.jtAcc;
			c.jtAcc = jtOld - jt;
			if( c.jtAcc < -jtMax ) c.jtAcc = -jtMax else if( c.jtAcc > jtMax ) c.jtAcc = jtMax;
			jt = c.jtAcc - jtOld;

			// apply the impulse
			var cjTx = c.nx * jn - c.ny * jt;
			var cjTy = c.ny * jn + c.nx * jt;
			bodyImpulse(c,b1,b2,cjTx,cjTy);

			c = c.next;
		}
	}

}
