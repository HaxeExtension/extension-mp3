package extension.taglib;

#if cpp
import cpp.Lib;
#elseif neko
import neko.Lib;
#end

typedef Tags = {
	var ALBUM : String;
	var ARTIST : String;
	var COMMENT : String;
	var GENRE : String;
	var LENGTH : Int;
	var REPLAYGAIN_ALBUM_GAIN : Float;
	var REPLAYGAIN_ALBUM_PEAK : Float;
	var REPLAYGAIN_TRACK_GAIN : Float;
	var REPLAYGAIN_TRACK_PEAK : Float;
	var TITLE : String;
}

class TaglibCFFI {

	public static function taglibParse (path : String) : Tags {
		var t = taglib_parse(path);
		return {
			ALBUM : t.ALBUM,
			ARTIST : t.ARTIST,
			COMMENT : t.COMMENT,
			GENRE : t.GENRE,
			LENGTH : Std.parseInt(t.LENGTH),
			REPLAYGAIN_ALBUM_GAIN : Std.parseFloat(t.REPLAYGAIN_ALBUM_GAIN),
			REPLAYGAIN_ALBUM_PEAK : Std.parseFloat(t.REPLAYGAIN_ALBUM_PEAK),
			REPLAYGAIN_TRACK_GAIN : Std.parseFloat(t.REPLAYGAIN_TRACK_GAIN),
			REPLAYGAIN_TRACK_PEAK : Std.parseFloat(t.REPLAYGAIN_TRACK_PEAK),
			TITLE : t.TITLE
		};
	}

	private static var taglib_parse = Lib.load("extension-mp3", "taglib_parse", 1);

}
