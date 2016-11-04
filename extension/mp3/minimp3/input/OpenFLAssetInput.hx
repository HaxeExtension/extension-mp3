package extension.mp3.minimp3.input;

import openfl.Assets;

class OpenFLAssetInput extends DecoderInput {

	public function new (id : String) {
		super();
		this.inBytes = Assets.getBytes(id);
	}

}
