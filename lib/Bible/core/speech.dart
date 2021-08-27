part of 'core.dart';

enum SpeechState { playing, stopped, paused, continued }

// speech
mixin _Speech {
  FlutterTts? speechCore;
  dynamic speechLangList;
  String? speechLangName;
  String currentText = "Audio is basically text-to-speech API that are available on your device. Language must be selected before it can play...";
  String currentWord = '';
  int startOffset = 0;
  int endOffset = 0;
  dynamic speechEngineList;

  double speechVolume = 0.9;
  double speechPitch = .9;
  double speechRate = .5;

  SpeechState speechState = SpeechState.stopped;

  Future initSpeech() async {
    speechCore = FlutterTts();
    speechLangList = await speechCore?.getLanguages;
    log("LANG LIST: $speechLangList");
    if (!kIsWeb) {
      if (Platform.isAndroid) {
        speechEngineList = await speechCore?.getEngines;
      }
    }
    speechEngineList = await speechCore?.getEngines;
    if (speechEngineList != null) {
      log("TTS ENGINES: $speechEngineList");
    }
  }
}

//[ko-KR, mr-IN, ru-RU, zh-TW, hu-HU, th-TH, ur-PK, nb-NO, da-DK, tr-TR, et-EE, bs, sw, pt-PT, vi-VN, en-US, sv-SE, ar, su-ID, bn-BD, gu-IN, kn-IN, el-GR, hi-IN, fi-FI, km-KH, bn-IN, fr-FR, uk-UA, en-AU, nl-NL, fr-CA, sr, pt-BR, ml-IN, si-LK, de-DE, ku, cs-CZ, pl-PL, sk-SK, fil-PH, it-IT, ne-NP, hr, en-NG, zh-CN, es-ES, cy, ta-IN, ja-JP, sq, yue-HK, en-IN, es-US, jv-ID,
