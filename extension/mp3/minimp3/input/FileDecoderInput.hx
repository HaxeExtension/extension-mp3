package extension.mp3.minimp3.input;

import flash.utils.ByteArray;
import haxe.io.Bytes;
import sys.io.FileInput;

class FileDecoderInput extends DecoderInput {

	var fInput : FileInput;

	public function new (fInput : FileInput) {
		super();
		this.fInput = fInput;
		loadMoreBytes();
	}

	override public function loadMoreBytes () : Bool {
		if (fInput.eof()) {
			return false;
		}
		var prevBytes = inBytes;
		inBytes = new ByteArray();
		var b = Bytes.alloc(1024*256);
		fInput.readBytes(b, 0, 1024*256);
		if (prevBytes!=null) {
			inBytes.writeBytes(prevBytes, inBytesPos);
		}
		inBytes.writeBytes(b);
		inBytesPos = 0;
		return true;
	}

}
