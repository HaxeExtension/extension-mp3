package extension.mp3.minimp3;

import extension.mp3.minimp3.input.DecoderInput;
import haxe.io.Bytes;

class Mp3Decoder {

	var input : DecoderInput;
	public var moreDataIsAvailable(default, null) : Bool;

	public function new (input : DecoderInput) {
		this.input = input;
		this.moreDataIsAvailable = true;
	}

	public function decodeFrame (output : Bytes) : DecodeResult {
		var r = MiniMp3CFFI.decode(input.getBytes(), input.getBytesPos(), output);
		if (r.frameSize==0) {
			moreDataIsAvailable = input.loadMoreBytes();
			r = MiniMp3CFFI.decode(input.getBytes(), input.getBytesPos(), output);
		}
		input.advanceBytes(r.frameSize);
		return r;
	}

}
