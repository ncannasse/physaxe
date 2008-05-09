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

class Const {

	public static inline var FMAX = 1e99;
	public static inline var EPSILON = 1e-99;

	public static inline var AREA_MASS_RATIO = 0.01;
	public static inline var WORLD_BOUNDS_FREQ = 120;

	public static var DEFAULT_MATERIAL = new Material( 0.01, 0.9, 1 );
	public static var DEFAULT_PROPERTIES = new Properties( 0.999, 0.999, 0.1, FMAX );

	// sleep
	public static inline var SLEEP_BIAS = 0.95;
	public static inline var DEFAULT_SLEEP_EPSILON = 0.002;
	public static inline var WAKEUP_EPSILON = 0.004;
	public static inline var ANGULAR_TO_LINEAR = 30.0; // 1 degree ~= 0.5 pix

	// The amount that shapes are allowed to penetrate
	// Setting this to zero will work just fine, but using a small positive
	// amount will help prevent oscillating contacts.
	public static inline var SLOP = 0.1;

	public static inline function XROT( v : Vector, b : Body ) {
		return v.x * b.rcos - v.y * b.rsin;
	}

	public static inline function YROT( v : Vector, b : Body ) {
		return v.x * b.rsin + v.y * b.rcos;
	}

}