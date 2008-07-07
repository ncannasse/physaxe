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
import phx.Shape;

class BruteForce implements BroadPhase {

	var shapes : haxe.FastList<Shape>;
	var callb : BroadCallback;

	public function new() {
	}

	public function init( bounds, callb, staticBody ) {
		this.callb = callb;
		shapes = new haxe.FastList<Shape>();
	}

	public function addShape( s : Shape ) {
		shapes.add(s);
	}

	public function removeShape( s : Shape ) {
		shapes.remove(s);
	}

	public function collide() {
		var s1 = shapes.head;
		while( s1 != null ) {
			var box1 = s1.elt.aabb;
			var s2 = s1.next;
			while( s2 != null ) {
				if( box1.intersects2(s2.elt.aabb) )
					callb.onCollide(s1.elt,s2.elt);
				s2 = s2.next;
			}
			s1 = s1.next;
		}
	}

	public function pick( box : AABB ) {
		var shapes = new haxe.FastList<phx.Shape>();
		for( s in this.shapes )
			if( s.aabb.intersects(box) )
				shapes.add(s);
		return shapes;
	}

	public function syncShape( s : phx.Shape ) {
		// nothing
	}

	public function commit() {
		// nothing
	}

	public function validate() {
		return true;
	}

}
