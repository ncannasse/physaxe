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

class PentagonRain extends Demo {

	var pentagons : Array<phx.Body>;
	var numPentagons : Int;

	var refreshDelay : Float;
	var lastRefresh : Float;

	public function new() {
		super();
		pentagons = new Array();
		numPentagons = 500;
		refreshDelay = 1;
		lastRefresh = 0;
	}

	public function init() {
		world.gravity.set(0,0.0625);
		steps = 1;

		var triangle = [ new phx.Vector(-15,15), new phx.Vector(15,15), new phx.Vector(0,-10) ];
		var mat = new phx.Material(1, .1, 1);
		for( i in 0...8 ) {
			for( j in 0...7 ) {
				var stagger = (j%2)*40;
				var offset = new phx.Vector(i * 80 + stagger, 80 + j * 70 );
				world.addStaticShape( new phx.Polygon(triangle, offset, mat) );
			}
		}

		var mat = new phx.Material(0.2, 0, 1);
		for( i in 0...numPentagons ) {
			var p = addBody( 300 + rand(-300,300), rand(-50,-150), createConvexPoly(5, 10, 0, mat) );
			pentagons.push(p);
		}
	}

	public function step( dt : Float ) {
		lastRefresh += dt;
		if( lastRefresh < refreshDelay ) return;
		for( p in pentagons ) {
			if( (p.y > size.y + 20) || (p.x < -20) || (p.y > size.x + 20) ) {
				p.setPos( 300 + rand(-280,280), rand(-50,-100) );
				p.setSpeed( rand(-10,10)/40, rand(10,100)/40 );
			}
		}
	}

}
