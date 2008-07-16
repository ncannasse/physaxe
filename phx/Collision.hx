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

class Collision {

	public function new() {
	}

	public inline function testShapes( s1 : Shape, s2 : Shape, a : Arbiter ) {
		return if( s1.type == Shape.POLYGON && s2.type == Shape.POLYGON )
			poly2poly(s1.polygon,s2.polygon,a);
		else if( s1.type == Shape.CIRCLE ) {
			if( s2.type == Shape.POLYGON )
				circle2poly(s1.circle,s2.polygon,a);
			else if( s2.type == Shape.CIRCLE )
				circle2circle(s1.circle,s2.circle,a);
			else /* type = SEGMENT */
				circle2segment(s1.circle,s2.segment,a);
		} else if( s1.type == Shape.SEGMENT && s2.type == Shape.POLYGON )
			segment2poly(s1.segment,s2.polygon,a);
		else
			false; // segment-segment
	}

	inline function polyAxisProject( s : Polygon, n : Vector, d : Float ) {
		var v = s.tVerts;
		var min = phx.Const.FMAX;
		while( v != null ) {
			var k = n.dot(v);
			if( k < min ) min = k;
			v = v.next;
		}
		return min - d;
	}

	function poly2poly( shape1 : Polygon, shape2 : Polygon, arb : Arbiter ) {
		// first, project shape 2 vertices onto shape 1 axes & find MSA
		var max1 = -Const.FMAX;
		var axis1 = null;
		var a = shape1.tAxes;
		while( a != null ) {
			var min = polyAxisProject(shape2,a.n,a.d);
			if( min > 0 ) return false;
			if( min > max1 ) {
				max1 = min;
				axis1 = a;
			}
			a = a.next;
		}

		// Second, project shape 1 vertices onto shape 2 axes & find MSA
		var max2 = -Const.FMAX;
		var axis2 = null;
		a = shape2.tAxes;
		while( a != null ) {
			var min = polyAxisProject(shape1,a.n,a.d);
			if( min > 0 ) return false;
			if( min > max2 ) {
				max2 = min;
				axis2 = a;
			}
			a = a.next;
		}
		if( max1 > max2 )
			findVerts(arb, shape1, shape2, axis1,  1, max1);
		else
			findVerts(arb, shape1, shape2, axis2, -1, max2);
		return true;
	}

	function findVerts( arb : Arbiter, poly1 : Polygon, poly2 : Polygon, n : Axis, nCoef : Float, dist : Float ) {
		// we need to uniquely identify the contact
		// and the poly can be swaped so the id calculus
		// needs to be commutative
		var id = (poly1.id > poly2.id) ? 0 : 65000;
		var c = 0;
		var v = poly1.tVerts;
		while( v != null ) {
			if( polyContainsPoint(poly2,v) ) {
				arb.injectContact(v,n.n,nCoef,dist,id);
				if( ++c > 1 ) return; // max = 2 contacts
			}
			id++;
			v = v.next;
		}
		id = (poly1.id > poly2.id) ? 65000 : 0;
		v = poly2.tVerts;
		while( v != null ) {
			if( polyContainsPoint(poly1,v) ) {
				arb.injectContact(v,n.n,nCoef,dist,id);
				if( ++c > 1 ) return; // max = 2 contacts
			}
			id++;
			v = v.next;
		}
	}

	inline function circle2circle( circle1, circle2, arb ) {
		return circle2circleQuery( arb, circle1.tC, circle2.tC, circle1.r, circle2.r );
	}

	function circle2circleQuery( arb : Arbiter, p1 : Vector, p2 : Vector, r1 : Float, r2 : Float ) {
		var minDist = r1 + r2;
		var x = p2.x - p1.x;
		var y = p2.y - p1.y;
		var distSqr = x * x + y * y;
		if( distSqr >= minDist * minDist )
			return false;
		var dist = Math.sqrt(distSqr);
		var invDist = (dist < Const.EPSILON) ? 0 : 1 / dist;
		var df = 0.5 + (r1 - 0.5 * minDist) * invDist;
		arb.injectContact( new Vector(p1.x + x * df,p1.y + y * df), new Vector(x * invDist, y * invDist), 1.0, dist - minDist, 0);
		return true;
	}

	function circle2segment( circle : Circle, seg : Segment, arb : Arbiter ) {
		var dn = seg.tN.dot(circle.tC) - seg.tA.dot(seg.tN);
		var dist = (dn < 0 ? -dn : dn) - circle.r - seg.r;
		if( dist > 0 )
			return false;
		var dt = -seg.tN.cross(circle.tC);
		var dtMin = -seg.tN.cross(seg.tA);
		var dtMax = -seg.tN.cross(seg.tB);
		if( dt < dtMin ) {
			if( dt < dtMin - circle.r )
				return false;
			return circle2circleQuery(arb, circle.tC, seg.tA, circle.r, seg.r);
		} else {
			if( dt < dtMax ) {
				var n = (dn < 0) ? seg.tN : seg.tN.mult(-1);
				var hdist = circle.r + dist * 0.5;
				arb.injectContact(new Vector(circle.tC.x + n.x * hdist, circle.tC.y + n.y * hdist),n,1.0,dist,0);
				return true;
			}
			if( dt < dtMax + circle.r )
				return circle2circleQuery(arb,circle.tC, seg.tB, circle.r, seg.r);
		}
		return false;
	}

	function findPolyPointsBehindSegment( seg : Segment, poly : Polygon, pDist : Float, coef : Float, arb : Arbiter ) {
		var dta = seg.tN.cross(seg.tA);
		var dtb = seg.tN.cross(seg.tB);
		var n = new Vector(seg.tN.x * coef, seg.tN.y * coef);
		var k = seg.tN.dot(seg.tA) * coef;
		var v = poly.tVerts;
		var i = 2; // 0 and 1 are reserved for segment
		while( v != null ) {
			if( v.dot(n) < k + seg.r ) {
				var dt = seg.tN.cross(v);
				if( dta >= dt && dt >= dtb )
					arb.injectContact(v, n, 1.0, pDist, i );
			}
			i++;
			v = v.next;
		}
	}

	inline function segAxisProject( seg : Segment, n : Vector, d : Float ) {
		var vA = n.dot(seg.tA) - seg.r;
		var vB = n.dot(seg.tB) - seg.r;
		return if( vA < vB ) vA - d else vB - d;
	}

	function segment2poly( seg : Segment, poly : Polygon, arb : Arbiter ) {
		var segD = seg.tN.dot(seg.tA);
		var minNorm = polyAxisProject(poly,seg.tN,segD) - seg.r;
		var minNeg = polyAxisProject(poly,seg.tNneg,-segD) - seg.r;
		if( minNeg > 0 || minNorm > 0 ) return false;

		var a = poly.tAxes;
		var polyMin = -Const.FMAX;
		var axis = null;
		while( a != null ) {
			var dist = segAxisProject(seg,a.n,a.d);
			if( dist > 0 )
				return false;
			if( dist > polyMin ) {
				polyMin = dist;
				axis = a;
			}
			a = a.next;
		}

		var n = axis.n;
		var va = new Vector( seg.tA.x - n.x * seg.r, seg.tA.y - n.y * seg.r );
		var vb = new Vector( seg.tB.x - n.x * seg.r, seg.tB.y - n.y * seg.r );
		if( polyContainsPoint(poly,va) )
			arb.injectContact(va, n, -1.0, polyMin, 0 );
		if( polyContainsPoint(poly,vb) )
			arb.injectContact(vb, n, -1.0, polyMin, 1 );

		polyMin -= Const.SLOP;
		if( minNorm >= polyMin || minNeg >= polyMin ) {
			if( minNorm > minNeg )
				findPolyPointsBehindSegment(seg, poly, minNorm, 1.0, arb);
			else
				findPolyPointsBehindSegment(seg, poly, minNeg, -1.0, arb);
		}
		return true;

	}

	function circle2poly( circle : Circle, poly : Polygon, arb : Arbiter ) {
		var a0 = null, v0 = null;
		var a = poly.tAxes;
		var v = poly.tVerts;

		var min = -Const.FMAX;
		while( a != null ) {
			var dist = a.n.dot(circle.tC) - a.d - circle.r;
			if( dist > 0 )
				return false;
			if( dist > min ) {
				min = dist;
				a0 = a;
				v0 = v;
			}
			a = a.next;
			v = v.next;
		}

		var n = a0.n;
		var v1 = (v0.next == null)?poly.tVerts:v0.next;
		var dt = n.cross(circle.tC);
		if( dt < n.cross(v1) )
			return circle2circleQuery(arb, circle.tC, v1, circle.r, 0);
		if( dt >= n.cross(v0) )
			return circle2circleQuery(arb, circle.tC, v0, circle.r, 0);

		var nx = n.x * (circle.r + min * 0.5);
		var ny = n.y * (circle.r + min * 0.5);
		arb.injectContact(new Vector(circle.tC.x - nx, circle.tC.y - ny),n,-1.0,min,0) ;
		return true;
	}

	function polyContainsPoint( s : Polygon, p : Vector ) {
		var a = s.tAxes;
		while( a != null ) {
			if( a.n.dot(p) > a.d )
				return false;
			a = a.next;
		}
		return true;
	}

	public inline function testPoint( s : Shape, p : Vector ) {
		return switch( s.type ) {
		case Shape.POLYGON:
			polyContainsPoint(s.polygon,p);
		case Shape.CIRCLE:
			var c = s.circle;
			var dx = c.tC.x - p.x;
			var dy = c.tC.y - p.y;
			(dx * dx + dy * dy) <= (c.r * c.r);
		default:
			false;
		}
	}

}
