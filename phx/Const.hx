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
	public static inline var SLEEP_EPSILON = 0.0002;
	public static inline var WAKEUP_EPSILON = 0.0004;
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