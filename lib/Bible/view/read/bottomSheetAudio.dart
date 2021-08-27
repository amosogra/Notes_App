part of 'main_read.dart';

//To enable: uncomment
/* core.dart
speech.dart */

class BottomSheetAudio extends StatefulWidget {
  BottomSheetAudio({
    Key? key,
    this.controller,
    this.verseSelectionList,
    this.scrollToIndex,
  }) : super(key: key);
  final ScrollController? controller;
  final List<int>? verseSelectionList;
  final Future<void> Function(int)? scrollToIndex;

  @override
  BottomSheetAudioState createState() => BottomSheetAudioState();
}

class BottomSheetAudioState extends State<BottomSheetAudio> {
  // final scaffoldKey = GlobalKey<ScaffoldState>();
  final core = Core();

  int _verseIndex = 0;
  int get _verseIndexMax => verseList.length - 1;
  bool get hasVersePrevious => _verseIndex > 0;
  bool get hasVerseNext => _verseIndex < _verseIndexMax;

  CollectionBible get info => core.collectionPrimary;
  BIBLE? get bible => core.scripturePrimary?.verseChapterData;
  // CollectionBible get info => core.collectionParallel;
  // BIBLE get bible => core.scriptureParallel.verseChapterData;

  // CollectionBible get tmpbible => bible?.info;
  DefinitionBook? get book => bible?.book?.first.info;
  CHAPTER? get chapter => bible?.book?.first.chapter?.first;
  List<VERSE> get verseList => chapter?.verse ?? [];

  String? get bookName => book?.name;
  String? get chapterName => chapter?.name;
  // String get verseName => bible.book.first.chapter.first.verse.first.name;
  //String? get verseName => verseList[_verseIndex].name;

  String? get widgetTitle => bible?.info?.name;

  // NOTE: when verse slider slide, click next or previous button while playing
  set isPaused(bool paused) {
    if (paused) {
      core.speechState = SpeechState.paused;
    } else {
      core.speechState = SpeechState.playing;
    }
  }

  bool get isPaused => core.speechState == SpeechState.paused;
  bool get isPlaying => core.speechState == SpeechState.playing;
  bool get isStopped => core.speechState == SpeechState.stopped;
  bool get isContinued => core.speechState == SpeechState.continued;

  @override
  initState() {
    super.initState();
    // TODO: change primary scroll when next and previous button are tap
    initTts();
  }

  initTts() {
    core.speechCore?.setStartHandler(() {
      setState(() => core.speechState = SpeechState.playing);
    });

    core.speechCore?.setCompletionHandler(() {
      if (_verseIndex < verseList.length) {
        _verseIndex++;
        if (_verseIndex < verseList.length) {
          _play();
          return;
        }
      }
      _verseIndex = 0;
      setState(() => core.speechState = SpeechState.stopped);
    });

    core.speechCore?.setCancelHandler(() {
      setState(() => core.speechState = SpeechState.stopped);
    });

    core.speechCore?.setErrorHandler((e) {
      log(e);
      setState(() => core.speechState = SpeechState.stopped);
    });

    core.speechCore?.setContinueHandler(() {
      setState(() {
        log("Continued");
        core.speechState = SpeechState.continued;
      });
    });

    core.speechCore?.setProgressHandler((String text, int startOffset, int endOffset, String word) {
      setState(() {
        core.currentWord = word;
        core.currentText = text;
        core.startOffset = startOffset;
        core.endOffset = endOffset;
        log("STARTOFFSET: $startOffset");
        log(" ENDOFFSET: $endOffset");
      });
    });

    //if (kIsWeb || Platform.isIOS)
    core.speechCore?.setPauseHandler(() {
      setState(() {
        log("Paused");
        core.speechState = SpeechState.paused;
      });
    });
  }

  List<TextSpan> _hightLight(String text, String matchWord, TextStyle style) {
    List<TextSpan> spans = [];
    if (matchWord.length == 0) {
      spans.add(TextSpan(text: text, semanticsLabel: text));
    } else {
      int spanBoundary = 0;

      if (core.startOffset == -1) {
        spans.add(TextSpan(text: text.substring(spanBoundary)));
        return spans;
      }
      // add any unstyled text before the match
      if (core.startOffset > spanBoundary) {
        spans.add(TextSpan(text: text.substring(spanBoundary, core.startOffset)));
      }
      // style the matched text
      final spanText = text.substring(core.startOffset, core.endOffset);
      log("PRINTING CURRENT WORD: $spanText");
      spans.add(TextSpan(text: spanText, style: style));

      //finally, add any unstyled text after the match
      if (core.endOffset < text.length) {
        spans.add(TextSpan(text: text.substring(core.endOffset)));
      }
    }
    return spans;
  }

  Future _play() async {
    await core.speechCore?.setVolume(core.speechVolume);
    await core.speechCore?.setSpeechRate(core.speechRate);
    await core.speechCore?.setPitch(core.speechPitch);
    if (core.speechLangName != null) {
      if (verseToSpeech.isNotEmpty) {
        await widget.scrollToIndex!(_verseIndex);
        var result = await core.speechCore?.speak(verseToSpeech);
        if (result == 1) setState(() => core.speechState = SpeechState.playing);
      }
    } else {
      log('please choose language');
    }
  }

  Future _stop() async {
    var result = await core.speechCore?.stop();
    if (result == 1) setState(() => core.speechState = SpeechState.stopped);
  }

  void _next() {
    if (hasVerseNext) {
      _verseIndex++;
    } else {
      _verseIndex = 0;
    }
    setState(() {});
    if (isPlaying) {
      _stop();
      _play();
    } else {
      widget.scrollToIndex!(_verseIndex);
    }
  }

  void _previous() {
    if (hasVersePrevious) {
      _verseIndex--;
    } else {
      _verseIndex = 0;
    }
    setState(() {});
    if (isPlaying) {
      _stop();
      _play();
    } else {
      widget.scrollToIndex!(_verseIndex);
    }
  }

  VERSE? get verse {
    if (verseList.length > 0) {
      // if (_verseIndex < verseList.length) {
      //   return verseList[_verseIndex];
      // }
      // NOTE: when primary chapter change, and previous.length is greater than current.length
      if (_verseIndex > _verseIndexMax) {
        _verseIndex = 0;
      }
      return verseList[_verseIndex];
    }
    return null;
  }

  String get verseToSpeech {
    return verse?.text ?? '';
  }

  @override
  void dispose() {
    super.dispose();
    core.speechCore?.stop();
  }

  List<DropdownMenuItem<String>> getLanguageDropDownMenuItems() {
    var items = <DropdownMenuItem<String>>[];
    for (dynamic type in core.speechLangList) {
      items.add(DropdownMenuItem(value: type as String, child: Text(type as String)));
    }
    return items;
  }

  void changedLanguageDropDownItem(String? selectedType) {
    setState(() {
      core.speechLangName = selectedType;
      core.speechCore?.setLanguage(core.speechLangName ?? selectedType ?? 'en-GB');
    });
  }

  Widget dropdownWidget() {
    return DropdownButton(
      items: getLanguageDropDownMenuItems(),
      onChanged: changedLanguageDropDownItem,
      value: core.speechLangName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        // controller: widget.controller,
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text(widgetTitle ?? "No Title"),
                actions: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                    child: dropdownWidget(),
                  )
                ],
              ),
            ),
          ];
        },
        body: Builder(
          builder: (BuildContext context) {
            return CustomScrollView(
              physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: <Widget>[
                SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
                // SliverToBoxAdapter()
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: audioStatus(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: audioController(),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: information(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _settingColumn(),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: 20.0),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    width: 150,
                    height: 45,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 200),
                      child: RaisedButton(
                        color: Color.fromRGBO(113, 119, 249, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(25.7),
                        ),
                        child: Text(
                          'Default',
                          style: TextStyle(color: Colors.white),
                        ),
                        elevation: 4,
                        onPressed: () async {
                          setState(() {
                            core.speechVolume = 0.9;
                            core.speechPitch = 0.9;
                            core.speechRate = 0.5;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: 20.0),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget audioController() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RaisedButton(
          padding: EdgeInsets.all(5),
          child: Icon(
            Icons.keyboard_arrow_left,
            size: 40,
          ),
          shape: new CircleBorder(),
          elevation: 1.5,
          highlightElevation: 1.0,
          disabledElevation: 0.5,
          color: Colors.white,
          textColor: Colors.grey,
          disabledColor: Colors.white.withOpacity(0.9),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onPressed: hasVersePrevious ? _previous : null,
          // shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0),
          // side: BorderSide(color: Colors.grey))
        ),
        RaisedButton(
          padding: EdgeInsets.all(5),
          child: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
            size: 50,
          ),
          shape: new CircleBorder(
              // side: BorderSide(color: Colors.grey[200])
              ),
          elevation: 1.5,
          highlightElevation: 1.0,
          disabledElevation: 0.8,
          color: Colors.white,
          textColor: Colors.grey,
          disabledColor: Colors.white.withOpacity(0.9),
          disabledTextColor: Colors.grey.withOpacity(0.9),
          focusColor: AppColors.blue300.withOpacity(0.75),
          hoverColor: AppColors.primaryColor.withOpacity(0.6),
          splashColor: AppColors.primaryColor,
          highlightColor: AppColors.primaryColor.withOpacity(0.85),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onPressed: (core.speechLangName == null)
              ? () {
                  EasyLoading.showToast("Please select a language from the dropdown.");
                }
              : isPlaying
                  ? _stop
                  : _play,
          // onPressed: ()=>null,
        ),
        RaisedButton(
          padding: EdgeInsets.all(5),
          child: Icon(
            Icons.keyboard_arrow_right,
            size: 40,
          ),
          shape: new CircleBorder(),
          elevation: 1.5,
          highlightElevation: 1.0,
          disabledElevation: 0.5,
          color: Colors.white,
          textColor: Colors.grey,
          disabledColor: Colors.white.withOpacity(0.9),
          disabledTextColor: Colors.grey.withOpacity(0.9),
          focusColor: AppColors.blue300.withOpacity(0.75),
          hoverColor: AppColors.primaryColor.withOpacity(0.6),
          splashColor: AppColors.primaryColor,
          highlightColor: AppColors.primaryColor.withOpacity(0.85),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onPressed: hasVerseNext ? _next : null,
        ),
      ],
    );
  }

  Widget audioStatus() {
    return RichText(
      textAlign: TextAlign.center,
      text: new TextSpan(
        text: '$bookName ',
        children: <TextSpan>[
          new TextSpan(text: chapterName),
          new TextSpan(text: ": ${verse?.name}"),
        ],
        style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54),
      ),
    );
  }

  Widget information() {
    return RichText(
      textAlign: TextAlign.center,
      text: new TextSpan(
        text: info.name,
        children: <TextSpan>[
          new TextSpan(text: ' (${info.year}). \n'),
          ..._hightLight(
            core.currentText,
            core.currentWord,
            TextStyle(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.yellow : Colors.red,
            ),
          ),
        ],
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54,
        ),
      ),
    );
  }

  Widget _settingColumn() {
    return Column(
      children: [_verseSlider(), _volume(), _pitch(), _rate()],
    );
  }

  Widget _verseSlider() {
    return Slider(
      value: _verseIndex.toDouble(),
      onChanged: (v) {
        if (isPlaying) {
          _stop();
          isPaused = true;
        }
        setState(() => _verseIndex = v.toInt());
      },
      onChangeEnd: (v) async {
        await widget.scrollToIndex!(_verseIndex);
        if (isPaused) {
          _play();
          isPaused = false;
        }
      },
      min: 0.0,
      max: (verseList.length - 1).toDouble(),
      divisions: verseList.length,
      label: "Verse: ${verse?.name}",
      inactiveColor: Colors.grey[300],
      activeColor: Colors.grey,
    );
  }

  Widget _volume() {
    return Slider(
      value: core.speechVolume,
      onChanged: (volume) {
        setState(() => core.speechVolume = volume);
      },
      min: 0.0,
      max: 1.0,
      divisions: 10,
      label: "Volume: ${core.speechVolume}",
      inactiveColor: Colors.grey[300],
      activeColor: Colors.grey,
    );
  }

  Widget _pitch() {
    return Slider(
      value: core.speechPitch,
      onChanged: (pitch) {
        setState(() => core.speechPitch = pitch);
      },
      min: 0.5,
      max: 2.0,
      divisions: 15,
      label: "Pitch: ${core.speechPitch}",
      inactiveColor: Colors.grey[300],
      activeColor: Colors.grey,
    );
  }

  Widget _rate() {
    return Slider(
      value: core.speechRate,
      onChanged: (rate) {
        setState(() => core.speechRate = rate);
      },
      min: 0.0,
      max: 1.0,
      divisions: 10,
      label: "Rate: ${core.speechRate}",
      inactiveColor: Colors.grey[300],
      activeColor: Colors.grey,
    );
  }
}
