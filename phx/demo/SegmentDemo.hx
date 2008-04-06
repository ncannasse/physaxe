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
package phx.demo;

class SegmentDemo extends Demo {

	var bodies : Array<phx.Body>;
	var numBodies : Int;
	var refreshDelay : Int;
	var lastRefresh : Int;

	public function new() {
		super();
		bodies = new Array();
		numBodies = 200;
		refreshDelay = 9;
		lastRefresh = 50;
	}

	public function init() {
		world.gravity.set(0, 0.3125);

		world.addStaticShape( new phx.Segment( new phx.Vector(0, 0), new phx.Vector(220, 200), 4));
		world.addStaticShape( new phx.Segment( new phx.Vector(600, 0), new phx.Vector(380, 200), 4));

		world.addStaticShape( new phx.Segment( new phx.Vector(200, 350), new phx.Vector(300, 300), 4));
		world.addStaticShape( new phx.Segment( new phx.Vector(400, 350), new phx.Vector(300, 300), 4));

		world.addStaticShape( new phx.Segment( new phx.Vector(100, 400), new phx.Vector(200, 500), 2));
		world.addStaticShape( new phx.Segment( new phx.Vector(500, 400), new phx.Vector(400, 500), 2));

		var material = new phx.Material(0.0, 0.2, 1);
		for( i in 0...numBodies ) {
			var s : phx.Shape;
			if( rand(0,2) > 0 )
				s = createConvexPoly(Std.int(rand(3, 4)),rand(12, 20),0, material);
			else
				s = new phx.Circle(rand(8,20),new phx.Vector(0,0));
			var b = addBody( 300 + rand(-200, 200), rand(-50,-150), s );
			bodies.push(b);
		}
	}

	public function step( dt : Float ) {
		lastRefresh += 1;
		if( lastRefresh < refreshDelay )
			return;
		for( b in bodies ) {
			if( (b.y > size.y + 20) || (b.x < -20) || (b.y > size.x + 20) ) {
				b.setPos( 300 + rand(-200, 200), rand(-50,-100) );
				b.setSpeed( rand(-10,10)/40, rand(10,100)/40 );
			}
		}
	}
}
