package extension.taglib;

class Taglib {

	static var mFadeOut = 0.8;

	public static function getReplayGainValue (trackGain : Float, albumGain : Float) : Float {
		var adjust = 0.0;
		if (!Math.isNaN(albumGain) && albumGain!=0) adjust = albumGain;
		if (!Math.isNaN(trackGain) && trackGain!=0) adjust = trackGain;
		var rg_result = Math.pow(10, adjust/20.0);
		rg_result -= 1.0;
		rg_result *= mFadeOut;
		rg_result += mFadeOut;
		rg_result = Math.max(rg_result, 0.0);
		rg_result = Math.min(rg_result, 1.0);
		return rg_result;
	}

}
