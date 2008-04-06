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

class AABB {

	public var l:Float;
	public var b:Float;
	public var r:Float;
	public var t:Float;

	public var shape : phx.Shape;
	public var prev : AABB;
	public var next : AABB;

	public function new(left,top,right,bottom) {
		this.l = left;
		this.t = top;
		this.r = right;
		this.b = bottom;
	}

	public inline function intersects( aabb : AABB ) {
		return !(aabb.l > r || aabb.r < l || aabb.t > b || aabb.b < t);
	}

	public inline function intersects2( aabb:AABB ) {
		return (l<=aabb.r && aabb.l<=r && t<=aabb.b && aabb.t<=b);
	}

	public inline function containsPoint( v : phx.Vector ) {
		return !(v.y < t || v.y > b || v.x < l || v.x > r);
	}

	public function toString() {
		return "[l=" + l + " b=" + b + " r=" + r + " t=" + t + "]";
	}

}
