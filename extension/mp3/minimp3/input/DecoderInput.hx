package extension.mp3.minimp3.input;

import flash.utils.ByteArray;

class DecoderInput {

	var inBytes : ByteArray;
	var inBytesPos : Int;

	private function new () {
		inBytes = new ByteArray();
		inBytesPos = 0;
	}

	public function advanceBytes (n : Int) {
		inBytesPos += n;
	}

	public function getBytes () : ByteArray {
		return inBytes;
	}

	public function getBytesPos () {
		return inBytesPos;
	}

	/// Returns true if can load more bytes
	public function loadMoreBytes () : Bool {
		return false;
	}

}

