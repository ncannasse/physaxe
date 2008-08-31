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

typedef Color = {
	public var lineSize : Float;
	public var line : Null<Int>;
	public var fill : Null<Int>;
	public var alpha : Float;
}

class FlashDraw {

	#if (flash || neko)
	var g : flash.display.Graphics;
	#elseif js
	var g : phx.JsCanvas;
	#end

	public var shape : Color;
	public var staticShape : Color;
	public var sleepingShape : Color;
	public var boundingBox : Color;
	public var contact : Color;
	public var sleepingContact : Color;
	public var contactSize : Color;
	public var drawSegmentsBorders : Bool;
	public var drawSegmentsNormals : Bool;
	public var drawCircleRotation : Bool;

	public var xmin : Int;
	public var ymin : Int;
	public var xmax : Int;
	public var ymax : Int;

	public function new( g ) {
		this.g = g;
		this.xmin = this.ymin = -2000000000;
		this.xmax = this.ymax = 2000000000;
		drawSegmentsBorders = true;
		drawSegmentsNormals = false;
		shape = { lineSize : 2., line : 0x333333, fill : 0xDFECEC, alpha : 1. };
		staticShape = { lineSize : 2., line : 0x333333, fill : 0xE6DC64, alpha : 1. };
		sleepingShape = { lineSize : 2., line : 0x333333, fill : 0x7FECEC, alpha : 1. };
		boundingBox = { lineSize : 0., line : null, fill : null, alpha : 1. };
		contact = { lineSize : 1., line : null, fill : null, alpha : 1. };
		sleepingContact = { lineSize : 1., line : null, fill : null, alpha : 1. };
		contactSize = { lineSize : 1., line : null, fill : null, alpha : 1. };
	}

	function begin( c : Color ) {
		if( c == null || (c.line == null && c.fill == null) ) return false;
		if( c.line == null ) g.lineStyle() else g.lineStyle(c.lineSize,c.line);
		if( c.fill != null ) g.beginFill(c.fill,c.alpha);
		return true;
	}

	function end( c : Color ) {
		if( c.fill != null ) g.endFill();
	}

	function selectColor( s : Shape ) {
		return s.body.isStatic ? staticShape : (s.body.island != null && s.body.island.sleeping ? sleepingShape : shape);
	}

	function selectArbiterColor( a : Arbiter ) {
		return a.sleeping ? sleepingContact : contact;
	}

	public function drawWorld( w : World ) {
		drawBody(w.staticBody);
		for( b in w.bodies )
			drawBody(b);
		for( j in w.joints )
			drawJoint(j);
		for( a in w.arbiters ) {
			var col = selectArbiterColor(a);
			if( begin(col) ) {
				var c = a.contacts;
				if( c == null ) {
					var b1 = a.s1.body;
					var b2 = a.s2.body;
					var p1 = (a.s1.offset == null) ? new phx.Vector(b1.x,b1.y) : new phx.Vector( b1.x + Const.XROT(a.s1.offset,b1), b1.y + Const.YROT(a.s1.offset,b1) );
					var p2 = (a.s2.offset == null) ? new phx.Vector(b1.x,b1.y) : new phx.Vector( b2.x + Const.XROT(a.s2.offset,b2), b2.y + Const.YROT(a.s2.offset,b2) );
					g.moveTo(p1.x,p1.y);
					g.lineTo(p2.x,p2.y);
					g.drawCircle(p1.x,p1.y,5);
					g.drawCircle(p2.x,p2.y,5);
				}
				while( c != null ) {
					if( c.updated )
						g.drawRect(c.px - 1,c.py - 1,2,2);
					c = c.next;
				}
				end(col);
			}
			if( begin(contactSize) ) {
				var c = a.contacts;
				while( c != null ) {
					if( c.updated )
						g.drawCircle(c.px, c.py, c.dist);
					c = c.next;
				}
				end(contactSize);
			}
		}
	}

	public function drawBody( b : Body ) {
		for( s in b.shapes ) {
			var b = s.aabb;
			if( b.r < xmin || b.b < ymin || b.l > xmax || b.t > ymax )
				continue;
			drawShape(s);
		}
	}

	public function drawShape( s : Shape ) {
		var c = selectColor(s);
		if( begin(c) ) {
			switch( s.type ) {
			case Shape.CIRCLE: drawCircle(s.circle);
			case Shape.POLYGON: drawPoly(s.polygon);
			case Shape.SEGMENT: drawSegment(s.segment);
			}
			end(c);
		}
		if( begin(boundingBox) ) {
			g.drawRect(s.aabb.l, s.aabb.t, s.aabb.r - s.aabb.l, s.aabb.b - s.aabb.t);
			end(boundingBox);
		}
	}

	function drawSegment( s : Segment ) {
		var delta = s.tB.minus(s.tA);
		var angle = Math.atan2( delta.x, delta.y );
		var dx = Math.cos(angle) * s.r;
		var dy = Math.sin(angle) * s.r;
		if( drawSegmentsBorders ) {
			g.drawCircle(s.tA.x, s.tA.y, s.r);
			g.drawCircle(s.tB.x, s.tB.y, s.r);
		}
		if( drawSegmentsNormals ) {
			var hx = (s.tA.x + s.tB.x) / 2;
			var hy = (s.tA.y + s.tB.y) / 2;
			g.moveTo(hx,hy);
			g.lineTo(hx + s.tN.x * (s.r * 2),hy + s.tN.y * (s.r * 2));
		}
		g.moveTo(s.tA.x + dx,s.tA.y - dy);
		g.lineTo(s.tB.x + dx,s.tB.y - dy);
		g.lineTo(s.tB.x - dx,s.tB.y + dy);
		g.lineTo(s.tA.x - dx,s.tA.y + dy);
		g.moveTo(s.tA.x + dx,s.tA.y - dy);
	}

	function drawCircle( c : Circle ) {
		g.drawCircle(c.tC.x, c.tC.y, c.r );
		if( drawCircleRotation ) {
			g.moveTo(c.tC.x, c.tC.y);
			g.lineTo(c.tC.x + c.body.rcos * c.r, c.tC.y + c.body.rsin * c.r);
		}
	}

	function drawPoly( p : Polygon ) {
		var v = p.tVerts;
		g.moveTo( v.x, v.y );
		while( v != null ) {
			g.lineTo(v.x, v.y);
			v = v.next;
		}
		g.lineTo( p.tVerts.x, p.tVerts.y );
	}

	public function drawJoint( j : Joint ) {
	}

}