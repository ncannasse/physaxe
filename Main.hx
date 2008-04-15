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
#if js
import js.Dom;
#end

class Main {

	public var debug : Bool;
	public var stopped : Bool;
	public var recalStep : Bool;

	#if flash
	var root : flash.display.MovieClip;
	var tf : flash.text.TextField;
	#else js
	var root : HtmlDom;
	var timer : haxe.Timer;
	#end

	var world : phx.World;
	var demo : phx.demo.Demo;
	var draw : Bool;
	var curbf : Int;
	var frame : Int;
	var broadphases : Array<phx.col.BroadPhase>;

	public function new(root) {
		frame = 0;
		curbf = 0;
		draw = true;
		debug = false;
		stopped = false;
		this.root = root;
		var me = this;
		#if flash
		tf = new flash.text.TextField();
		tf.selectable = false;
		tf.width = 300;
		tf.height = 500;
		root.addChild(tf);
		var stage = root.stage;
		stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		stage.addEventListener(flash.events.Event.ENTER_FRAME,function(_) me.loop());
		stage.addEventListener(flash.events.MouseEvent.MOUSE_DOWN,function(_) me.fireBlock(me.root.mouseX,me.root.mouseY));
		stage.addEventListener(flash.events.KeyboardEvent.KEY_DOWN,function(e:flash.events.KeyboardEvent) me.onKeyDown(e.keyCode));
		#else js
		var fps = 20;
		timer = new haxe.Timer(Math.round(1000 / fps));
		timer.run = loop;
		js.Lib.document.onkeydown = function(e:Event) me.onKeyDown(e.keyCode);
		js.Lib.document.onmousedown = function(e:Event) me.fireBlock(e.clientX,e.clientY);
		#end
		broadphases = new Array();
		broadphases.push(new phx.col.SortedList());
		broadphases.push(new phx.col.BruteForce());
	}

	function loop() {

		// step
		var steps = if( stopped ) 0 else demo.steps;
		var dt = 1;
		var niter = #if flash 20 #else js 5 #end;
		for( i in 0...steps ) {
			try {
				demo.step(dt/steps);
				world.step(dt/steps,niter);
			} catch( e : Dynamic ) {
				trace("STOPPED!");
				stopped = true;
				throw e;
			}
		}
		if( recalStep ) world.step(0,1);

		// draw
		#if flash
		var g = root.graphics;
		#else js
		var g = new phx.JsCanvas(root);
		#end
		g.clear();
		var fd = new phx.FlashDraw(g);
		if( debug ) {
			fd.boundingBox.line = 0x000000;
			fd.contact.line = 0xFF0000;
			fd.sleepingContact.line = 0xFF00FF;
			fd.contact.fill = 0x00FF00;
			fd.contact.alpha = 0.5;
			fd.drawCircleRotation = true;
		}
		if( draw )
			fd.drawWorld(world);

		#if flash
		// update infos
		if( frame++ % Std.int(flash.Lib.current.stage.frameRate / 4) == 0 )
			tf.text = buildInfos().join("\n");
		#end
	}

	function onKeyDown( code : Int ) {
		switch( code ) {
		case 32:/*SPACE*/
			debug = !debug;
		case 66: /*B*/
			curbf = (curbf + 1) % broadphases.length;
			world.setBroadPhase(broadphases[curbf]);
		case 68: /*D*/
			draw = !draw;
		#if flash
		case 83: /*S*/
			root.stage.frameRate = (root.stage.frameRate == 1) ? root.stage.loaderInfo.frameRate : 1;
		#end
		case 49: /*1*/ setDemo(new phx.demo.DominoPyramid());
		case 50:/*2*/ setDemo(new phx.demo.BasicStack());
		case 51:/*3*/ setDemo(new phx.demo.PyramidThree());
		case 52:/*4*/ setDemo(new phx.demo.BoxPyramidDemo());
		case 53:/*5*/ setDemo(new phx.demo.PentagonRain());
		case 54:/*6*/ setDemo(new phx.demo.Jumble());
		case 55:/*7*/ setDemo(new phx.demo.SegmentDemo());
		case 56:/*8*/ setDemo(new phx.demo.TitleDemo());
		case 57:/*9*/ setDemo(new phx.demo.Test());
		case 27:/*ESC*/ setDemo(demo);
		}
	}

	public function setDemo( demo : phx.demo.Demo ) {
		this.demo = demo;
		stopped = false;
		recalStep = false;
		world = new phx.World(new phx.col.AABB(-2000,-2000,2000,2000),broadphases[curbf]);
		demo.start(world);
	}

	public function buildInfos() {
		var t = world.timer;
		var tot = t.total;
		var log = [
			"Stamp=" + world.stamp,
			"Demo=" + Type.getClassName(Type.getClass(demo)),
			"Bodies=" + Lambda.count(world.bodies),
			"Arbit=" + Lambda.filter(world.arbiters,function(a) return !a.sleeping).length + " / " + Lambda.count(world.arbiters),
			"BF=" + Type.getClassName(Type.getClass(world.broadphase)),
			"COLS=" + world.activeCollisions+ " / "+world.testedCollisions,
			t.format("all"),
			t.format("col"),
			t.format("island"),
			t.format("solve"),
		];
		var nislands = Lambda.count(world.islands);
		if( nislands > 5 )
			log.push("Islands="+nislands);
		else
			for( i in world.islands ) {
				var str = "Island= #" + Lambda.count(i.bodies);
				str += if( i.sleeping ) " SLEEP" else " e=" + Math.ceil(i.energy*1000)/1000;
				var b = i.bodies.first();
				str += " (" + Math.ceil(b.x) + "," + Math.ceil(b.y) + ")";
				log.push(str);
			}
		return log;
	}

	public function fireBlock( mouseX : Float, mouseY : Float ) {
		#if flash
		var width = root.stage.stageWidth;
		var height = root.stage.stageHeight;
		#else js
		var width : Int = untyped root.width;
		var height : Int = untyped root.height;
		#end

		var pos = new phx.Vector(width,height);
		pos.x += 100;
		pos.y /= 3;

		var v = new phx.Vector( mouseX - pos.x, mouseY - pos.y );
		var k = 15 / v.length();
		v.x *= k;
		v.y *= k;

		var b = new phx.Body(0,0);
		b.set(pos,0,v,2);
		b.addShape( phx.Shape.makeBox(20,20,new phx.Material(0.0, 1, 5)) );
		world.addBody(b);
	}

	public static var inst : Main;

	static function main() {
		#if flash
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		var root = flash.Lib.current;
		#else js
		var root = js.Lib.document.getElementById("draw");
		#end
		inst = new Main(root);
		inst.setDemo(new phx.demo.TitleDemo());
	}

}
