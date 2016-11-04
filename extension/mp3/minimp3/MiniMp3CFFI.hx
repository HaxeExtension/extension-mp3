package extension.mp3.minimp3;

#if cpp
import cpp.Lib;
#elseif neko
import neko.Lib;
#end

import haxe.io.Bytes;
import haxe.io.BytesData;

class MiniMp3CFFI {

	public static var maxSamplesPerFrame = 1152*2;

	public static function decode (input : Bytes, startPos : Int, output : Bytes) : DecodeResult {
		return minimp3_decode(input.getData(), startPos, input.length, output!=null ? output.getData() : null);
	}

	private static var minimp3_decode = Lib.load("extension-mp3", "minimp3_decode", 4);

}
