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

class Jumble extends Demo {

	var addDelay : Int;
	var lastAdd : Int;
	var material : phx.Material;

	public function new() {
		super();
		addDelay = 30;
		lastAdd = 50;
		material = new phx.Material(0.1, 0.5, 1);
	}

	public override function init() {
		world.gravity.set(0,0.3125);
		createFloor();
	}

	public override function step( dt : Float) {
		lastAdd += 1;
		if( lastAdd < addDelay ) return;
		lastAdd = 0;

		var body = new phx.Body(0,0);
		body.addShape(phx.Shape.makeBox(60,10,material));
		body.addShape(phx.Shape.makeBox(10,60,material));
		body.addShape(new phx.Circle(12,new phx.Vector(-30,0),material));
		body.addShape(new phx.Circle(12,new phx.Vector(30,0),material));
		body.addShape(new phx.Circle(12,new phx.Vector(0,-30),material));
		body.addShape(new phx.Circle(12,new phx.Vector(0,30),material));
		body.setPos( 300 + rand(-250,250), rand(-200,-20), rand(0,2*Math.PI) );
		body.w = rand( -2, 2 ) / 40;
		world.addBody(body);
	}

}
