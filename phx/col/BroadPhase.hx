package phx.col;

interface BroadCallback {
	function onCollide( s1 : phx.Shape, s2 : phx.Shape ) : Bool;
}

interface BroadPhase {
	// initiliaze when added into world
	function init( bounds : AABB, cb : BroadCallback ) : Void;
	// modify the shape list
	function addShape( s : phx.Shape ) : Void;
	function removeShape( s : phx.Shape ) : Void;
	// when modified : one sync per shape then one final commit
	function syncShape( s : phx.Shape ) : Void;
	function commit() : Void;
	// perform the collisions
	function collide() : Void;
	// pick the content of the box
	function pick( bounds : AABB ) : haxe.FastList<phx.Body>;
	// check the validity of inner datas (for debug)
	function validate() : Bool;
}
