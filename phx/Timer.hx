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

class Timer {

	var times : Array<Float>;
	var curs : Array<String>;
	var datas : Hash<{ total : Float, avg : Float }>;
	public var total : Float;

	public function new() {
		total = 0.;
		datas = new Hash();
		times = new Array();
		curs = new Array();
	}

	public function start( phase ) {
		times.push(haxe.Timer.stamp());
		curs.push(phase);
	}

	public function stop() {
		var dt = (haxe.Timer.stamp() - times.pop()) * 1000;
		var name = curs.pop();
		var data = datas.get(name);
		if( data == null ) {
			data = { total : 0., avg : 0. };
			datas.set(name,data);
		}
		data.total += dt;
		data.avg = data.avg * 0.99 + 0.01 * dt;
		if( curs.length == 0 ) total += dt;
	}

	public function getTotal( name : String ) {
		var data = datas.get(name);
		if( data == null ) return 0.;
		return data.total;
	}

	public function format( name ) {
		var data = datas.get(name);
		if( data == null ) return name + " ????";
		return name + " : "+Std.int(data.avg*1000) + " ("+(Std.int(data.total*1000/total)/10)+"%)";
	}

}