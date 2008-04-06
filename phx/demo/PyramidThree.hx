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

class PyramidThree extends Demo {

	public function init() {
		world.gravity.set(0,0.125);
		createFloor();

		var width = 70;
		var height = 11;
		var slab = phx.Shape.makeBox(width,height,new phx.Material(0.0, 1, 1));
		var p0 = phx.Const.DEFAULT_PROPERTIES;
		var props = new phx.Properties(p0.linearFriction,p0.angularFriction,0.001,phx.Const.FMAX);

		var startY = floor - (height / 2);
		var startX = size.y / 2;
		var segcount = 5;
		for( i in 0...5 ) {
			createPoly( startX - width, startY, 0, slab, props );
			createPoly( startX + width, startY, 0, slab, props );
			for( y in 0...segcount ) {
				for( x in 0...y+1 )
					createPoly( startX - (x * width) + y * (width / 2), startY, 0, slab, props );
				startY -= height;
			}
			var y = segcount;
			while( y > 0 ) {
				for( x in 0...y+1 )
					createPoly( startX - (x * width) + y * (width / 2), startY, 0, slab, props );
				startY -= height;
				y--;
			}
		}
	}

}

