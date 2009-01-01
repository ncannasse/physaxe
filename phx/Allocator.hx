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

class Allocator {

	var contactPool : Contact;
	var islandPool : Island;
	public var slop : Float;

	public function new() {
	}

	public inline function allocIsland(w) {
		var i = islandPool;
		if( i == null )
			return new Island(w);
		else {
			islandPool = i.allocNext;
			return i;
		}
	}

	public inline function freeIsland( i : Island ) {
		i.bodies.head = null;
		i.arbiters.head = null;
		i.joints.head = null;
		i.sleeping = false;
		i.allocNext = islandPool;
		islandPool = i;
	}

	public inline function allocArbiter() {
		return new Arbiter(this);
	}

	public inline function freeArbiter( a : Arbiter ) {
	}

	public inline function allocContact() {
		var c = contactPool;
		if( c == null )
			return new Contact();
		else {
			contactPool = c.next;
			return c;
		}
	}

	public inline function freeContact( c : Contact ) {
		c.next = contactPool;
		contactPool = c;
	}

	public inline function freeAllContacts( c : Contact ) {
		while( c != null ) {
			var next = c.next;
			c.next = contactPool;
			contactPool = c;
			c = next;
		}
	}

}