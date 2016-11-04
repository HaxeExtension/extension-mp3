package extension.mp3.minimp3;

typedef DecodeResult = {
	var sampleRate : Int;
	var channels : Int;
	var audioBytes : Int;
	var frameSize : Int;
	var outBuf : Array<Int>;
}
