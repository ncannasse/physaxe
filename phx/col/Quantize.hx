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
package phx.col;
import phx.col.BroadPhase;
import haxe.FastList;

/**
	This broaphase is optimized for large worlds with a majority of static
	shapes and few moving shapes. It divides the space in squares of 2^nbits
	pixels. Shapes are stored into one several squares that they cover.
	Collisions are only tested between dynamic shapes and all other shapes into
	each square. World bounds should be positive. Shapes outside of the world
	might be in the wrong square (but that's ok) or in a special square.
**/
class Quantize implements BroadPhase {

	var nbits : Int;
	var size : Int;

	var width : Int;
	var height : Int;
	var spanbits : Int;

	var all : haxe.FastList<haxe.FastList<AABB>>;
	var world : Array<haxe.FastList<AABB>>;
	var out : haxe.FastList<AABB>;
	var cb : BroadCallback;

	public function new( nbits : Int ) {
		this.nbits = nbits;
		this.size = 1 << nbits;
	}

	inline function ADDR(x,y) {
		return (x << spanbits) | y;
	}

	public function init( bounds : AABB, cb : BroadCallback ) {
		this.cb = cb;

		all = new haxe.FastList<haxe.FastList<AABB>>();
		world = new Array();
		out = new haxe.FastList<AABB>();
		all.add(out);

		width = Std.int(bounds.r + size - 0.1) >> nbits;
		height = Std.int(bounds.b + size - 0.1) >> nbits;

		var tmp = width - 1;
		var spanbits = 0;
		while( tmp > 0 ) {
			spanbits++;
			tmp >>= 1;
		}
	}

	function add( l : haxe.FastList<AABB>, box : AABB ) {
		if( !box.shape.body.isStatic ) {
			l.add(box);
			return;
		}
		var b = l.head;
		var prev = null;
		while( b != null ) {
			if( b.elt.shape.body.isStatic )
				break;
			prev = b;
			b = b.next;
		}
		if( prev == null )
			l.head = new FastCell<AABB>(box,b);
		else
			prev.next = new FastCell<AABB>(box,b);
	}

	public function addShape( s : phx.Shape ) {
		var box = s.aabb;
		var nbits = this.nbits;
		var x1 = Std.int(box.l) >> nbits;
		var y1 = Std.int(box.t) >> nbits;
		var x2 = (Std.int(box.r) >> nbits) + 1;
		var y2 = (Std.int(box.b) >> nbits) + 1;
		box.shape = s;
		box.bounds = new phx.col.IAABB(x1,y1,x2,y2);
		var isout = false;
		for( x in x1...x2 ) {
			for( y in y1...y2 ) {
				var l = world[ADDR(x,y)];
				if( l == null ) {
					if( x >= 0 && x < width && y >= 0 && y < height ) {
						l = new haxe.FastList<AABB>();
						all.add(l);
						world[ADDR(x,y)] = l;
					} else {
						if( isout ) continue;
						isout = true;
						l = out;
					}
				}
				add(l,box);
			}
		}
	}

	public function removeShape( s : phx.Shape ) {
		var box = s.aabb;
		var ib = box.bounds;
		for( x in ib.l...ib.r ) {
			for( y in ib.t...ib.b ) {
				var l = world[ADDR(x,y)];
				if( l == null ) l = out;
				l.remove(box);
			}
		}
	}

	public function syncShape( s : phx.Shape ) {
		var box = s.aabb;
		var nbits = this.nbits;
		var x1 = Std.int(box.l) >> nbits;
		var y1 = Std.int(box.t) >> nbits;
		var x2 = (Std.int(box.r) >> nbits) + 1;
		var y2 = (Std.int(box.b) >> nbits) + 1;
		var ib = box.bounds;
		if( x1 == ib.l && y1 == ib.t && x2 == ib.r && y2 == ib.b )
			return;
		removeShape(s);
		ib.l = x1;
		ib.t = y1;
		ib.r = x2;
		ib.b = y2;
		var isout = false;
		for( x in x1...x2 ) {
			for( y in y1...y2 ) {
				var l = world[ADDR(x,y)];
				if( l == null ) {
					if( x >= 0 && x < width && y >= 0 && y < height ) {
						l = new haxe.FastList<AABB>();
						all.add(l);
						world[ADDR(x,y)] = l;
					} else {
						if( isout ) continue;
						isout = true;
						l = out;
					}
				}
				add(l,box);
			}
		}
	}

	public function commit() {
		// NOTHING
	}

	public function collide() {
		for( list in all ) {
			var box1 = list.head;
			while( box1 != null ) {
				var b = box1.elt;
				if( b.shape.body.isStatic )
					break;
				var box2 = list.head;
				while( box2 != null ) {
					if( b.intersects2(box2.elt) && box1 != box2 )
						cb.onCollide(b.shape,box2.elt.shape);
					box2 = box2.next;
				}
				box1 = box1.next;
			}
		}
	}

	public function pick( box : AABB ) {
		// TODO
		return new haxe.FastList<phx.Body>();
	}

	public function validate() {
		// check internal data structures
		return true;
	}

}