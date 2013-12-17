package phx;

import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;

class JsCanvas {

	var ctx : CanvasRenderingContext2D;

	public function new( canvas : CanvasElement ) {
		ctx = canvas.getContext( '2d' );
	}

	public inline function clear() {
		ctx.clearRect( 0, 0, ctx.canvas.width, ctx.canvas.height );
	}

	public function lineStyle( ?width : Float, ?color : Int ) {
		if( width == null )
			return;
		ctx.lineWidth = width;
		ctx.strokeStyle = COL(color);
	}

	public inline function beginFill( color : Int, alpha : Float ) {
		ctx.fillStyle = COL(color);
		ctx.beginPath();
	}

	public inline function endFill() {
		ctx.fill();
		ctx.stroke();
	}

	public inline function drawCircle( x : Float, y : Float, radius : Float ) {
		ctx.arc(x,y,radius,0,6.29,true);
	}

	public inline function drawRect( x : Float, y : Float, w : Float, h : Float ) {
		ctx.rect(x,y,w,h);
	}

	public inline function moveTo( x : Float, y : Float ) {
		ctx.moveTo(x,y);
	}

	public inline function lineTo( x : Float, y : Float ) {
		ctx.lineTo(x,y);
	}

	static inline function COL( color : Int ) {
		return "rgb("+(color>>16)+","+((color>>8)&0xFF)+","+(color&0xFF)+")";
	}

}
