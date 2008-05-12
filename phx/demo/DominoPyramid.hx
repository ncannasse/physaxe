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

class DominoPyramid extends Demo {

	public override function init() {
		world.gravity.set(0,0.3125);
		createFloor();

		var d_width = 5;
		var d_heigth = 20;
		var stackHeigth = 9;
		var xstart = 60.0;
		var yp = floor;
		var d90 = Math.PI / 2;
		var domino = phx.Shape.makeBox(d_width*2, d_heigth*2, new phx.Material(0.0, 0.6, 0.5));

		for( i in 0...stackHeigth ) {
			var dw = ((i == 0)?2 * d_width:0);
			for( j in 0...stackHeigth - i ) {
				var xp = xstart + (3*d_heigth*j);
				if( i == 0 ) {
					createPoly( xp , yp - d_heigth, 0, domino );
					createPoly( xp , yp - (2 * d_heigth) - d_width, d90, domino );
				} else {
					createPoly( xp , yp - d_width, d90, domino );
					createPoly( xp , yp - (2 * d_width) - d_heigth, 0, domino );
					createPoly( xp , yp - (3 * d_width) - (2 * d_heigth), d90, domino );
				}
				if( j == 0 )
					createPoly( xp - d_heigth + d_width , yp - (3 * d_heigth) - (4 * d_width) + dw, 0, domino );
				if( j == stackHeigth - i - 1 )
					createPoly( xp + d_heigth - d_width , yp - (3 * d_heigth) - (4 * d_width) + dw, 0, domino );
			}
			yp -= (2*d_heigth)+(4*d_width) - dw;
			xstart += 1.5 * d_heigth;
		}
	}

}
