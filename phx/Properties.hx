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

class Properties {

	static var PID = 0;

	/**
		The amount the linear speed of the object is reduced by time
	**/
	public var linearFriction : Float;

	/**
		The amount the angular speed of the object is reduced by time
	**/
	public var angularFriction : Float;

	/**
		The percentage the object position will be modified if it is inside another object
	**/
	public var biasCoef : Float;

	/**
		The maximum movement of the object
	**/
	public var maxMotion : Float;

	/**
		The maximum distance at which we can interpenerate another object without applying position bias
	**/
	public var maxDist : Float;

	// internal
	public var id : Int;
	public var count : Int;
	public var lfdt : Float;
	public var afdt : Float;

	public function new( linearFriction, angularFriction, biasCoef, maxMotion, maxDist ) {
		id = PID++;
		count = 0;
		this.linearFriction = linearFriction;
		this.angularFriction = angularFriction;
		this.biasCoef = biasCoef;
		this.maxMotion = maxMotion;
		this.maxDist = maxDist;
	}

}