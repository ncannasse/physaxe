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

class Test extends Demo {

	var body : phx.Body;
	var body2 : phx.Body;
	var dir : Int;
	var et : Float;

	public function init() {
		#if flash9
		var stage = flash.Lib.current.stage;
		//stage.frameRate = 1;
		#end
		Main.inst.recalStep = true;
		Main.inst.debug = true;
		world.gravity = new phx.Vector(0,0.9);
		steps = 1;
		body = addBody( 300, 500, phx.Shape.makeBox(128,16) );
		body.isStatic = true;
		world.removeBody(body);
		world.addBody(body);
		body2 = addBody( 250, 500 - 64, new phx.Circle(10,new phx.Vector(0,0)) );
		body2.v.x = 0.5;
		//body2 = addBody( 250, 500 - 64, phx.Shape.makeBox(64,64) );
		body2.preventRotation();
		dir = 1;
		et = 0;
	}

	public function step( dt : Float ) {
		et += dt;
		if( et > 100 ) {
			et -= 100;
			dir *= -1;
		}
		body.v.x = 1 * dir;
		body.v.y = -0.5 * dir;
		body.x += body.v.x * dt;
		body.y += body.v.y * dt;
		world.sync(body);
	}

}