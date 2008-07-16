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

class Polygon extends Shape {

	public var verts : Vector;
	public var tVerts : Vector;
	public var vcount : Int;

	public var axes : Axis;
	public var tAxes : Axis;

	public function new( vl : Array<Vector>, offset : Vector, ?material : Material )  {
		super(Shape.POLYGON, material);
		polygon = this;
		this.offset = offset;
		initVertexes(vl);
	}

	function initVertexes( vl : Array<Vector> ) {
		var l_verts = null, l_tVerts = null, l_axes = null, l_tAxes = null;
		var count = vl.length;
		vcount = count;
		area = 0;
		var off = (offset != null);
		for( i in 0...count ) {
			var v0 = vl[i];
			var v1 = vl[(i + 1) % count];
			var v2 = vl[(i + 2) % count];
			area += v1.x * (v0.y - v2.y);

			var v = off ? v0.plus(offset) : v0;
			var n = Vector.normal(v1.x - v0.x,v1.y - v0.y);
			var a = new Axis(n, n.dot(v));

			var vt = v.clone();
			var at = a.clone();

			// enqueue
			if( i == 0 ) {
				verts	= v;
				tVerts 	= vt;
				axes 	= a;
				tAxes	= at;
			} else {
				l_verts.next = v;
				l_tVerts.next = vt;
				l_axes.next = a;
				l_tAxes.next = at;
			}
			l_verts 	= v;
			l_tVerts 	= vt;
			l_axes		= a;
			l_tAxes		= at;
		}
		area *= 0.5;
	}

	public override function update() {
		var v = verts;
		var tv = tVerts;
		var body = body;
		var aabb = aabb;

		// reset bounding box
		aabb.l = aabb.t =  Const.FMAX;
		aabb.r = aabb.b = -Const.FMAX;

		// transform points
		while( v != null ) {
			tv.x = body.x + Const.XROT(v,body);
			tv.y = body.y + Const.YROT(v,body);
			if( tv.x < aabb.l ) aabb.l = tv.x;
			if( tv.x > aabb.r ) aabb.r = tv.x;
			if( tv.y < aabb.t ) aabb.t = tv.y;
			if( tv.y > aabb.b ) aabb.b = tv.y;
			v = v.next;
			tv = tv.next;
		}

		// transform axes
		var a = axes;
		var ta = tAxes;
		while( a != null ) {
			var n = a.n;
			ta.n.x = Const.XROT(n,body);
			ta.n.y = Const.YROT(n,body);
			ta.d   = body.x * ta.n.x + body.y * ta.n.y + a.d;
			a = a.next;
			ta = ta.next;
		}
	}

	public override function calculateInertia() {
		// not very optimized (using a tmp array)
		// but simplifying the maths is not easy here
		var tVertsTemp = new Array();
		var v = verts;
		while( v != null ) {
			tVertsTemp.push( new Vector( v.x + offset.x , v.y + offset.y) );
			v = v.next;
		}
		var sum1 = 0.;
		var sum2 = 0.;
		for( i in 0...vcount ) {
			var v0 = tVertsTemp[i];
			var v1 = tVertsTemp[(i + 1) % vcount];
			var a = v1.cross(v0);
			var b = v0.dot(v0) + v0.dot(v1) + v1.dot(v1);
			sum1 += a * b;
			sum2 += a;
		}
		return sum1 / (6 * sum2);
	}

}
