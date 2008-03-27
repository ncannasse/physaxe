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