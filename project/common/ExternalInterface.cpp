#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif

#include <hx/CFFI.h>
#include "minimp3.c"

#include <apetag.h>
#include <fileref.h>
#include <mpegfile.h>
#include <tpropertymap.h>
#include <tstring.h>
#include <id3v1tag.h>
#include <id3v2tag.h>

namespace minimp3 {
	mp3_decoder_t dec;
}

unsigned char *getBytes (value bytes, int base) {
	if (val_is_string(bytes)) {
		return (unsigned char *)(&(val_string(bytes)[base]));
	}
	buffer buf = val_to_buffer(bytes);
	if (buf==0)	{
		val_throw(alloc_string("Bad ByteArray"));
	}
	return (unsigned char *)(buffer_data(buf)+base);
}

static value minimp3_decode (value _inBuf, value _startPos, value _endPos, value _outBuf) {
	mp3_info_t info;
	int startPos = val_int(_startPos);
	int endPos = val_int(_endPos);
	int bytesLeft = endPos - startPos;
	int frameSize = 0;
	unsigned char *buf = getBytes(_inBuf, startPos);
	value obj = alloc_empty_object();
	if (val_is_null(_outBuf)) {
		signed short sampleBuf[MP3_MAX_SAMPLES_PER_FRAME];
		frameSize = mp3_decode(minimp3::dec, buf, bytesLeft, sampleBuf, &info);
		value outBuf = alloc_array(MP3_MAX_SAMPLES_PER_FRAME);
		for (int i=0;i<MP3_MAX_SAMPLES_PER_FRAME;++i) {
			val_array_set_i(outBuf, i, alloc_int(sampleBuf[i]));
		}
		alloc_field(obj, val_id("outBuf"), outBuf);
	} else {
		signed short *sampleBuf = (signed short *) getBytes(_outBuf, 0);
		frameSize = mp3_decode(minimp3::dec, buf, bytesLeft, sampleBuf, &info);
	}
	alloc_field(obj, val_id("sampleRate"), alloc_int(info.sample_rate));
	alloc_field(obj, val_id("channels"), alloc_int(info.channels));
	alloc_field(obj, val_id("audioBytes"), alloc_int(info.audio_bytes));
	alloc_field(obj, val_id("frameSize"), alloc_int(frameSize));

	return obj;
}
DEFINE_PRIM (minimp3_decode, 4);

void addTagToObject (value obj, const TagLib::PropertyMap &pMap, const char *tag) {
	if (!pMap.contains(tag)) {
		return;
	}
	TagLib::String str = pMap[tag].back();
	alloc_field(obj, val_id(tag), alloc_wstring(str.toCWString()));
}

static value taglib_parse (value filePath) {
	TagLib::MPEG::File f(val_string(filePath));
	TagLib::PropertyMap pMap;
	if (f.hasID3v1Tag()) {
		pMap.merge(f.ID3v1Tag()->properties());
	}
	if (f.hasID3v2Tag()) {
		pMap.merge(f.ID3v2Tag()->properties());
	}
	if (f.hasAPETag()) {
		pMap.merge(f.APETag()->properties());
	}
	value obj = alloc_empty_object();
	addTagToObject(obj, pMap, "ALBUM");
	addTagToObject(obj, pMap, "ARTIST");
	addTagToObject(obj, pMap, "COMMENT");
	addTagToObject(obj, pMap, "GENRE");
	addTagToObject(obj, pMap, "TITLE");
	addTagToObject(obj, pMap, "REPLAYGAIN_TRACK_GAIN");
	addTagToObject(obj, pMap, "REPLAYGAIN_TRACK_PEAK");
	addTagToObject(obj, pMap, "REPLAYGAIN_ALBUM_GAIN");
	addTagToObject(obj, pMap, "REPLAYGAIN_ALBUM_PEAK");
	alloc_field(obj, val_id("LENGTH"), alloc_int(f.audioProperties()->length()));
	return obj;
}
DEFINE_PRIM (taglib_parse, 1)

extern "C" void extension_main () {
	minimp3::dec = mp3_create();
	val_int(0); // Fix Neko init
}
DEFINE_ENTRY_POINT (extension_main);


extern "C" int minimp3_register_prims () { return 0; }
