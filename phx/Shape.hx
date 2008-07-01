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

class Shape {

	static var ID = 0;

	public static inline var CIRCLE = 0;
	public static inline var SEGMENT = 1;
	public static inline var POLYGON = 2;

	public var id : Int;
	public var type : Int;
	public var circle : Circle;
	public var segment : Segment;
	public var polygon : Polygon;

	public var body : Body;
	public var offset : Vector;
	public var aabb : phx.col.AABB;

	public var material : Material;
	public var area : Float;

	public var groups : Int;

	function new( type : Int, material : Material ) {
		id = ID++;
		groups = 1;
		this.type = type;
		this.material = (material == null) ? Const.DEFAULT_MATERIAL : material;
		this.area = 0;
		aabb = new phx.col.AABB(0,0,0,0);
	}

	public function update() {
	}

	public function calculateInertia() {
		return 1.;
	}

	public function toString() {
		return "Shape#"+id;
	}

	public static function makeBox( width : Float, height : Float, ?px, ?py, ?mat ) {
		if( px == null ) px = -width / 2;
		if( py == null ) py = -height / 2;
		return new Polygon([
			new phx.Vector(0,0),
			new phx.Vector(0,height),
			new phx.Vector(width,height),
			new phx.Vector(width,0),
		],new phx.Vector(px,py),mat);
	}

}
