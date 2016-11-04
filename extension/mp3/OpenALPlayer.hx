package extension.mp3;

import cpp.vm.Thread;
import extension.mp3.minimp3.DecodeResult;
import extension.mp3.minimp3.MiniMp3CFFI;
import extension.mp3.minimp3.Mp3Decoder;
import flash.utils.ByteArray;
import haxe.io.Bytes;
import openal.AL;

enum OnCompletedStatus {
	Stopped;
	EndOfStream;
}

#if windows
@:cppFileCode("
#include <thread>
#include <chrono>
")
#else
@:cppFileCode("#include <unistd.h>")
#end
class OpenALPlayer {

	var bufferBytes : Bytes;
	var buffers : Array<Int>;
	var input : Mp3Decoder;
	var playing : Bool;
	var needsMoreInputData : Bool;
	var gain : Float;

	var context : Context;
	var device : Device;
	var source : Int;

	public var onCompleted : OnCompletedStatus->Void;

	public function new (input : Mp3Decoder) {
		this.bufferBytes = Bytes.alloc(MiniMp3CFFI.maxSamplesPerFrame*2);
		this.buffers = [];
		this.input = input;
		this.playing = false;
		this.needsMoreInputData = false;
		this.gain = 1.0;
	}

	public function play () {
		device = ALC.openDevice();
		if(device == null) {
			trace('failed / couldn\'t create device!');
			return;
		}
		context = ALC.createContext(device, null);
		if(context == null) {
			trace('failed / couldn\'t create context!');
			return;
		}
		ALC.makeContextCurrent(context);
		source = AL.genSource();
		AL.sourcef(source, AL.PITCH, 1.0);
		AL.sourcef(source, AL.GAIN, gain);
		AL.source3f(source, AL.POSITION, 0.0, 0.0, 0.0);
		AL.source3f(source, AL.VELOCITY, 0.0, 0.0, 0.0);
		AL.sourcei(source, AL.LOOPING, AL.FALSE);
		playing = true;
		update();
		AL.sourcePlay(source);
		Thread.create(updateLoop);
	}

	public function setGain (gain : Float) {
		this.gain = gain;
		AL.sourcef(source, AL.GAIN, gain);
	}

	public function stop () {
		cleanWithStatus(Stopped);
	}

	function updateLoop () {
		while (playing) {
			#if windows
			untyped __cpp__("std::this_thread::sleep_for(std::chrono::milliseconds(50))");
			#else
			untyped __cpp__("usleep(50000)");
			#end
			update();
		}
	}

	function update () {
		var x  = Std.random(1000);
		if (playing) {
			if (!isPlaying()) {
				AL.sourcePlay(source);
			}
			freeUnusedBuffers();
			if (getAvailableBuffers()<32) {
				enqueueBuffers();
			}
			if (finishedPlaying()) {
				cleanWithStatus(EndOfStream);
			}
		}
	}

	function cleanWithStatus (status : OnCompletedStatus) {
		playing = false;
		AL.sourceStop(source);
		while (buffers.length>0) {
			AL.sourceUnqueueBuffer(source);
			AL.deleteBuffer(buffers.shift());
		}
		AL.deleteSource(source);
		ALC.destroyContext(context);
		ALC.closeDevice(device);
		if (onCompleted!=null) {
			onCompleted(status);
		}
	}

	function finishedPlaying () {
		return needsMoreInputData && !input.moreDataIsAvailable;
	}

	function isPlaying () : Bool {
		return AL.getSourcei(source, AL.SOURCE_STATE)==AL.PLAYING;
	}

	function enqueueBuffers () {
		var r : DecodeResult = null;
		for (i in 0...16) {
			r = input.decodeFrame(bufferBytes);
			if (r.frameSize==0) {
				needsMoreInputData = true;
				break;
			}
			var buffer = AL.genBuffer();
			buffers.push(buffer);
			var format = r.channels==1 ? AL.FORMAT_MONO16 : AL.FORMAT_STEREO16;
			AL.bufferData(buffer, format, r.sampleRate, bufferBytes.getData(), 0, r.audioBytes);
			AL.sourceQueueBuffer(source, buffer);
		}
	}

	function freeUnusedBuffers () {
		while (buffers.length>getAvailableBuffers()) {
			AL.sourceUnqueueBuffer(source);
			AL.deleteBuffer(buffers.shift());
		}
	}

	function getAvailableBuffers () : Int {
		return getQueuedBuffers() - AL.getSourcei(source, AL.BUFFERS_PROCESSED);
	}

	function getQueuedBuffers () : Int {
		return AL.getSourcei(source, AL.BUFFERS_QUEUED);
	}

}
