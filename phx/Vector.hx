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

class Vector {

	public var x:Float;
	public var y:Float;

	public var next:Vector;

	public function new( px : Float, py : Float ) {
		x = px;
		y = py;
	}

	public inline function clone() {
		return new Vector(x,y);
	}

	public inline function set( px : Float, py : Float) {
		x = px;
		y = py;
	}

	public inline function dot( v : Vector ) {
		return x * v.x + y * v.y;
	}

	public inline function cross( v : Vector ) {
		return x * v.y - y * v.x;
	}

	public inline function plus( v : Vector ) {
		return new Vector(x + v.x, y + v.y);
	}

	public inline function minus( v : Vector ) : Vector {
		return new Vector(x - v.x, y - v.y);
	}

	public inline function mult( s : Float ) {
		return new Vector(x * s, y * s);
	}

	public inline function length() {
		return Math.sqrt(x * x + y * y);
	}

	public function toString() {
		return "("+(Math.round(x*100)/100)+","+(Math.round(y*100)/100)+")";
	}

	public static inline function normal( x : Float, y : Float ) {
		var d = Math.sqrt(x * x + y * y);
		var k = if( d < Const.EPSILON ) 0 else 1 / d;
		return new Vector( -y * k , x * k );
	}

}
