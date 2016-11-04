package;

import extension.mp3.minimp3.input.OpenFLAssetInput;
import extension.mp3.minimp3.input.FileDecoderInput;
import extension.mp3.minimp3.Mp3Decoder;
import extension.mp3.OpenALPlayer;
import extension.taglib.Taglib;
import extension.taglib.TaglibCFFi;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.Lib;
import openfl.Assets;
import openfl.display.Sprite;
import sys.io.File;
import sys.io.FileInput;

class Main extends Sprite {

	static var mp3List : Array<String> = [
		"assets/test1.mp3",
		"assets/test2.mp3",
		"assets/test3.mp3",
		"assets/test4.mp3",
		"assets/test5.mp3",
		"assets/test6.mp3",
		"assets/test7.mp3",
		"assets/normtest1.mp3",
		"assets/normtest2.mp3",
		"assets/normtest3.mp3",
		"assets/normtest4.mp3",
		"assets/normtest5.mp3",
		"assets/normtest6.mp3",
		"assets/normtest7.mp3"
	];

	var currentMp3 : OpenALPlayer;
	var playing : Bool;

	public function new () {
		super ();
		playing = false;
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
		Lib.current.stage.addEventListener(MouseEvent.CLICK, onKeyDown);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
	}

	function playRandomMp3 () {

		var path = Assets.getPath(mp3List[Std.random(mp3List.length)]);
		var currentFile = File.read(path);
		//var input = new OpenFLAssetInput(mp3List[Std.random(mp3List.length)]);
		var input = new FileDecoderInput(currentFile);
		var decoder = new Mp3Decoder(input);
		currentMp3 = new OpenALPlayer(decoder);
		currentMp3.play();

		var tags = TaglibCFFI.taglibParse(path);
		var gain = Taglib.getReplayGainValue(tags.REPLAYGAIN_TRACK_GAIN, tags.REPLAYGAIN_ALBUM_GAIN);
		trace("playing " + path + " with gain: " + gain);
		currentMp3.setGain(gain);

		currentMp3.onCompleted = function (status) { 
			trace("onCompleted, status: " + status);
			currentFile.close();
			playing = false;
		};

	}

	function onEnterFrame (_) {
		if (!playing) {
			playRandomMp3();
			playing = true;
		}
	}

	function onKeyDown (_) {
		currentMp3.stop();
		playing = false;
	}

}
