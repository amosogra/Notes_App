import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/internal/constants.dart';
import 'package:notes_app/providers/configurationProvider.dart';
import 'package:notes_app/screens/notification/admin/pick_upload_images.dart';
import 'package:notes_app/ui/AppTheme.dart';
import 'package:notes_app/utils/SizeConfig.dart';
import 'package:notes_app/utils/crop.dart';
import 'package:notes_app/utils/generate_search.dart';
import 'package:notes_app/utils/log.dart';
import 'package:notes_app/utils/tasks.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;

class NotificationUploadScreen extends StatefulWidget {
  const NotificationUploadScreen({Key? key}) : super(key: key);

  @override
  _NotificationUploadScreenState createState() => _NotificationUploadScreenState();
}

class _NotificationUploadScreenState extends State<NotificationUploadScreen> {
  TextEditingController descriptionController = TextEditingController();
  TextEditingController eventPlaceController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  String? validator;
  List<String> _type = [], _selectedType = [], _to = [], _selectedTo = [];
  DateTime? start;
  DateTime? stop;

  bool enabled = true;
  bool carouselScrollDisplay = false;

  List<String> images = [];
  var _images = <String>[];
  Color? maskColor;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    eventPlaceController = TextEditingController();
    descriptionController = TextEditingController();
    startDateController = TextEditingController();
    endDateController = TextEditingController();

    _type = ['Announcement', 'Event'];
    _selectedType = ["Event"];

    _to = [
      '${Role.admin}s',
      '${Role.minister}s',
      '${Role.hod}s',
      '${Role.worker}s',
      '${Role.member}s',
      '${Role.teenager}s',
      '${Role.visitor}s',
      '${Role.returningVisitor}s',
      'Everyone'
    ];
    _selectedTo = ["Everyone"];
  }

  @override
  void dispose() {
    titleController.dispose();
    eventPlaceController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<ConfigurationProvider>(context);
    final themeData = AppTheme.getThemeFromThemeMode(config.darkThemeEnabled ? 2 : 1);
    final customAppTheme = AppTheme.getCustomAppTheme(config.darkThemeEnabled ? 2 : 1);
    List<Widget> typeWidget = [];
    for (int i = 0; i < _type.length; i++) {
      typeWidget.add(optionTypeChip(isSelected: _selectedType.contains(_type[i]), option: _type[i], themeData: themeData, customAppTheme: customAppTheme));
    }

    List<Widget> toWidget = [];
    for (int i = 0; i < _to.length; i++) {
      toWidget.add(optionToChip(isSelected: _selectedTo.contains(_to[i]), option: _to[i], themeData: themeData, customAppTheme: customAppTheme));
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Container(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                  color: themeData.backgroundColor,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(MySize.size16), topRight: Radius.circular(MySize.size16))),
              child: Padding(
                padding: EdgeInsets.only(top: MySize.size16, left: MySize.size24, right: MySize.size24, bottom: MySize.size16),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Row(
                          children: [
                            Expanded(
                              child: Center(
                                child: Text(
                                  "Upload Notification to server".toUpperCase(),
                                  style: AppTheme.getTextStyle(themeData.textTheme.subtitle1, color: themeData.colorScheme.onBackground, fontWeight: 700),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: Spacing.all(6),
                                decoration: BoxDecoration(color: themeData.colorScheme.primary.withAlpha(40), shape: BoxShape.circle),
                                child: Icon(
                                  MdiIcons.check,
                                  color: themeData.colorScheme.primary,
                                  size: MySize.size20,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: Spacing.top(24),
                        child: Text(
                          "Type",
                          style: AppTheme.getTextStyle(themeData.textTheme.subtitle2, color: themeData.colorScheme.onBackground, fontWeight: 600),
                        ),
                      ),
                      Container(
                        margin: Spacing.top(12),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 12,
                          children: typeWidget,
                        ),
                      ),
                      Container(
                        margin: Spacing.top(24),
                        child: Text(
                          "Send To",
                          style: AppTheme.getTextStyle(themeData.textTheme.subtitle2, color: themeData.colorScheme.onBackground, fontWeight: 600),
                        ),
                      ),
                      Container(
                        margin: Spacing.top(12),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 12,
                          children: toWidget,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: MySize.size16),
                        child: TextFormField(
                          style: AppTheme.getTextStyle(themeData.textTheme.bodyText1, letterSpacing: 0.1, color: themeData.colorScheme.onBackground, fontWeight: 500),
                          decoration: InputDecoration(
                            hintText: "Title of notification",
                            hintStyle:
                                AppTheme.getTextStyle(themeData.textTheme.subtitle2, letterSpacing: 0.1, color: themeData.colorScheme.onBackground, fontWeight: 500),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                borderSide: BorderSide.none),
                            filled: true,
                            fillColor: themeData.colorScheme.background,
                            prefixIcon: Icon(
                              MdiIcons.formatTitle,
                            ),
                            contentPadding: EdgeInsets.all(0),
                          ),
                          controller: titleController,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ),
                      _selectedType[0] == "Event"
                          ? Container(
                              margin: EdgeInsets.only(top: MySize.size16),
                              child: TextFormField(
                                style: AppTheme.getTextStyle(themeData.textTheme.bodyText1,
                                    letterSpacing: 0.1, color: themeData.colorScheme.onBackground, fontWeight: 500),
                                decoration: InputDecoration(
                                  hintText: "Place of event (Venue)",
                                  hintStyle: AppTheme.getTextStyle(themeData.textTheme.subtitle2,
                                      letterSpacing: 0.1, color: themeData.colorScheme.onBackground, fontWeight: 500),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                      borderSide: BorderSide.none),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                      borderSide: BorderSide.none),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                      borderSide: BorderSide.none),
                                  filled: true,
                                  fillColor: themeData.colorScheme.background,
                                  prefixIcon: Icon(
                                    Icons.place,
                                  ),
                                  contentPadding: EdgeInsets.all(0),
                                ),
                                controller: eventPlaceController,
                                textCapitalization: TextCapitalization.sentences,
                              ),
                            )
                          : Container(),
                      _selectedType[0] == "Event"
                          ? Container(
                              margin: EdgeInsets.only(top: MySize.size16),
                              child: TextFormField(
                                onTap: () {
                                  DatePicker.showDateTimePicker(context, showTitleActions: true, onChanged: (date) {
                                    log('change $date in time zone ' + date.timeZoneOffset.inHours.toString());
                                  }, onConfirm: (date) {
                                    log('confirm $date');
                                    setState(() {
                                      start = date;
                                      startDateController.text = DateFormat("d MMMM, yyyy - hh:mm a").format(date);
                                    });
                                  }, currentTime: DateTime.now());
                                },
                                style: AppTheme.getTextStyle(themeData.textTheme.bodyText1,
                                    letterSpacing: 0.1, color: themeData.colorScheme.onBackground, fontWeight: 500),
                                decoration: InputDecoration(
                                  hintText: "Event Start Date (Required)",
                                  hintStyle: AppTheme.getTextStyle(themeData.textTheme.subtitle2,
                                      letterSpacing: 0.1, color: themeData.colorScheme.onBackground, fontWeight: 500),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                      borderSide: BorderSide.none),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                      borderSide: BorderSide.none),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                      borderSide: BorderSide.none),
                                  filled: true,
                                  fillColor: Colors.amberAccent, //themeData.colorScheme.background,
                                  prefixIcon: Icon(
                                    MdiIcons.timelineAlert,
                                  ),
                                  contentPadding: EdgeInsets.all(0),
                                ),
                                controller: startDateController,
                                textCapitalization: TextCapitalization.sentences,
                              ),
                            )
                          : Container(),
                      _selectedType[0] == "Event"
                          ? Container(
                              margin: EdgeInsets.only(top: MySize.size16),
                              child: TextFormField(
                                onTap: () {
                                  DatePicker.showDateTimePicker(context, showTitleActions: true, onChanged: (date) {
                                    log('change $date in time zone ' + date.timeZoneOffset.inHours.toString());
                                  }, onConfirm: (date) {
                                    log('confirm $date');
                                    setState(() {
                                      stop = date;
                                      endDateController.text = DateFormat("d MMMM, yyyy - hh:mm a").format(date);
                                    });
                                  }, currentTime: DateTime.now());
                                },
                                style: AppTheme.getTextStyle(themeData.textTheme.bodyText1,
                                    letterSpacing: 0.1, color: themeData.colorScheme.onBackground, fontWeight: 500),
                                decoration: InputDecoration(
                                  hintText: "Event End Date (Optional)",
                                  hintStyle: AppTheme.getTextStyle(themeData.textTheme.subtitle2,
                                      letterSpacing: 0.1, color: themeData.colorScheme.onBackground, fontWeight: 500),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                      borderSide: BorderSide.none),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                      borderSide: BorderSide.none),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                      borderSide: BorderSide.none),
                                  filled: true,
                                  fillColor: themeData.accentColor.withOpacity(0.6), //themeData.colorScheme.background,
                                  prefixIcon: Icon(
                                    MdiIcons.timelineClock,
                                  ),
                                  contentPadding: EdgeInsets.all(0),
                                ),
                                controller: endDateController,
                                textCapitalization: TextCapitalization.sentences,
                              ),
                            )
                          : Container(),
                      Container(
                        margin: Spacing.top(24),
                        child: Text(
                          "Add Banner Image or Flyer (Optional):",
                          style: AppTheme.getTextStyle(themeData.textTheme.subtitle2, color: themeData.colorScheme.onBackground, fontWeight: 600),
                        ),
                      ),
                      Container(
                        child: PickUploadImages(
                          images: images,
                          selected: (String image) {
                            log('Selected Image $image');
                          },
                          add: () {
                            getImage();
                          },
                          remove: (String image) {
                            if (_images.length != 0) {
                              log("REMOVING IMAGE: $image");
                              _images.remove(image);
                              if (mounted) {
                                setState(() {
                                  images = _images;
                                });
                              }
                            }
                          },
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: MySize.size4, bottom: MySize.size4),
                        child: IntrinsicHeight(
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "Carousel Display",
                                      style: AppTheme.getTextStyle(themeData.textTheme.bodyText1, fontWeight: 600),
                                    ),
                                    Container(
                                        margin: EdgeInsets.only(top: MySize.size4),
                                        child: Text(carouselScrollDisplay ? "Show this notification in home screen" : "Don't show this notification in home screen",
                                            style: AppTheme.getTextStyle(themeData.textTheme.caption, fontWeight: 400, letterSpacing: 0, height: 1))),
                                  ],
                                ),
                              ),
                              VerticalDivider(
                                color: themeData.dividerColor,
                                thickness: 1.2,
                              ),
                              Switch(
                                onChanged: (bool value) {
                                  setState(() {
                                    carouselScrollDisplay = value;
                                  });
                                },
                                value: carouselScrollDisplay,
                                activeColor: themeData.colorScheme.primary,
                              )
                            ],
                          ),
                        ),
                      ),
                      _buildComposer(themeData),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Center(
                          child: Container(
                              width: 120,
                              height: 40,
                              decoration: BoxDecoration(
                                color: themeData.accentColor,
                                borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(color: Colors.grey.withOpacity(0.6), offset: const Offset(4, 4), blurRadius: 8.0),
                                ],
                              ),
                              child:
                                  /* ScopedModelDescendant<AppStateModel>(builder: (context, child, model) {
                          return*/
                                  Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    FocusScope.of(context).requestFocus(FocusNode());
                                    if (descriptionController.text != "" && titleController.text != "") {
                                      if (_selectedType[0] == "Event" && startDateController.text == "") {
                                        EasyLoading.showInfo("Please pick a starting date and time for your event",
                                            duration: const Duration(seconds: 5), dismissOnTap: true);

                                        return null;
                                      }

                                      if (_selectedType[0] == "Event" && eventPlaceController.text == "") {
                                        EasyLoading.showInfo("Place of event or venue is a required field...",
                                            duration: const Duration(seconds: 5), dismissOnTap: true);

                                        return null;
                                      } else {}

                                      //commit changes to cloud firestore...
                                      EasyLoading.showInfo('Please wait..', duration: const Duration(seconds: 5), dismissOnTap: true);
                                      var data = Map<String, dynamic>();
                                      data['title'] = titleController.text;
                                      data['images'] = images;
                                      data['venue'] = eventPlaceController.text;
                                      data['startDate'] = start != null ? start.toString() : "";
                                      data['description'] = descriptionController.text;
                                      data['category'] = 'Notification';
                                      data['type'] = _selectedType[0];
                                      data['to'] = _selectedTo[0];
                                      data['meeting'] = false;
                                      data['freeze'] = "false";
                                      data['display'] = carouselScrollDisplay ? "true" : "false";
                                      data['endDate'] = stop != null ? stop.toString() : "";
                                      data['timestamp'] = Timestamp.now();
                                      // timeago.format(_timestamp.toDate(), locale: appStateModel.appLocale.languageCode),
                                      data['searchKeywords'] = GenerateSearch.getSearchKeywords(titleController.text); //usage at bottom of page
                                      var commited = await commitToFireStore(data, Constants.notification /*_selectedType[0]*/);
                                      if (commited) {
                                        EasyLoading.showSuccess("${_selectedType[0]} committed to database successfully",
                                            duration: const Duration(seconds: 5), dismissOnTap: true);
                                      } else {
                                        EasyLoading.showError('Failed to commit changes to the database, please try again..',
                                            duration: const Duration(seconds: 5), dismissOnTap: true);
                                      }
                                      //Navigator.pop(context);
                                      //EasyLoading.dismiss();
                                      Navigator.of(context).pop();
                                    } else {
                                      await showDialog<void>(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Please provide input!'),
                                            content: Text('The title and description of your message are requied...'),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  },
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text('Upload',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          )),
                                    ),
                                  ),
                                ),
                              )
                              //}),
                              ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )),
      ),
    );
  }

  Widget optionTypeChip({String? option, bool isSelected = false, ThemeData? themeData, CustomAppTheme? customAppTheme}) {
    return InkWell(
      onTap: () {
        setState(() {
          if (_selectedType.contains(option)) {
            //_selectedType.remove(option);
          } else {
            _selectedType.clear();
            _selectedType.add(option as String);
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
            color: isSelected ? themeData?.colorScheme.primary : Colors.transparent,
            border: Border.all(
                color: isSelected ? themeData?.colorScheme.primary ?? const Color(4278190080) : customAppTheme?.bgLayer4 ?? const Color(4278190080), width: 1),
            borderRadius: BorderRadius.all(Radius.circular(MySize.size16))),
        padding: Spacing.fromLTRB(10, 6, 10, 6),
        child: Text(
          option as String,
          style: AppTheme.getTextStyle(themeData?.textTheme.bodyText2, color: isSelected ? themeData?.colorScheme.onPrimary : themeData?.colorScheme.onBackground),
        ),
      ),
    );
  }

  Widget optionToChip({String? option, bool isSelected = false, ThemeData? themeData, CustomAppTheme? customAppTheme}) {
    return InkWell(
      onTap: () {
        setState(() {
          if (_selectedTo.contains(option)) {
            //_selectedType.remove(option);
          } else {
            _selectedTo.clear();
            _selectedTo.add(option as String);
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
            color: isSelected ? themeData?.colorScheme.primary : Colors.transparent,
            border: Border.all(
                color: isSelected ? themeData?.colorScheme.primary ?? const Color(4278190080) : customAppTheme?.bgLayer4 ?? const Color(4278190080), width: 1),
            borderRadius: BorderRadius.all(Radius.circular(MySize.size16))),
        padding: Spacing.fromLTRB(10, 6, 10, 6),
        child: Text(
          option as String,
          style: AppTheme.getTextStyle(themeData?.textTheme.bodyText2, color: isSelected ? themeData?.colorScheme.onPrimary : themeData?.colorScheme.onBackground),
        ),
      ),
    );
  }

  Widget _buildComposer(ThemeData? themeData) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 32, right: 32),
      child: Container(
        decoration: BoxDecoration(
          color: themeData?.cardTheme.color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: <BoxShadow>[
            BoxShadow(color: themeData?.cardTheme.shadowColor?.withAlpha(25) ?? const Color(4278190080), offset: const Offset(4, 4), blurRadius: 8),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Container(
            padding: const EdgeInsets.all(4.0),
            constraints: const BoxConstraints(minHeight: 80, maxHeight: 160),
            color: themeData?.cardTheme.color,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0),
              child: TextField(
                maxLines: null,
                controller: descriptionController,
                onChanged: (String value) async {
                  validator = value;
                  //return;
                },
                style: AppTheme.getTextStyle(themeData?.textTheme.bodyText1, fontWeight: 600, letterSpacing: 0.2),
                cursorColor: themeData?.accentColor,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintStyle: AppTheme.getTextStyle(themeData?.textTheme.bodyText1,
                        fontWeight: 500, letterSpacing: 0, color: themeData?.colorScheme.onBackground.withAlpha(180)),
                    hintText: 'Describe your message here...'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> commitToFireStore(Map<String, dynamic> data, String _collection) {
    CollectionReference collection = FirebaseFirestore.instance.collection(_collection);
    // Call the user's CollectionReference to add a new user
    return collection.add(data).then((value) async {
      return await value.update({"nid": value.id}).then((v) {
        log("$_collection Added");
        return true;
      });
    }).catchError((error) {
      log("Failed to add document: $error");
      log("Stack Trace: " + error);
      return false;
    });
  }

  Future getImage() async {
    var image = await ImagePicker().getImage(source: ImageSource.gallery);
    log('Image Path ${image?.path}');
    _cropImage(await image!.readAsBytes(), image);
  }

  Future _cropImage(Uint8List bytes, PickedFile? file) async {
    return await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: CropImage(
            bytes: bytes,
            onDoneCropping: (Uint8List data) {
              uploadPic(file, data);
              return true;
            },
          ),
        ),
        fullscreenDialog: true,
      ),
    );
  }

  Future uploadPic(PickedFile? image, Uint8List data) async {
    String fileName = path.basename(image!.path);

    Map<String, dynamic> result = await Tasks.uploadImageTask(image, data, fileName.contains(".") ? fileName : "$fileName.png", maskColor, "uploading product photo");
    if (result['uploaded']) {
      var _profilePhotoUrl = result['url'];
      _images.add(_profilePhotoUrl);

      if (mounted) {
        setState(() {
          images = _images;
        });
      }
      log("Product Picture Uploaded: $images");
    }
  }
}
/* import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CloudFirestoreSearch extends StatefulWidget {
  @override
  _CloudFirestoreSearchState createState() => _CloudFirestoreSearchState();
}

class _CloudFirestoreSearchState extends State<CloudFirestoreSearch> {
  String name = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Card(
          child: TextField(
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.search), hintText: 'Search...'),
            onChanged: (val) {
              setState(() {
                name = val;
              });
            },
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: (name != "" && name != null)
            ? Firestore.instance
                .collection('items')
                .where("searchKeywords", arrayContains: name)
                .snapshots()
            : Firestore.instance.collection("items").snapshots(),
        builder: (context, snapshot) {
          return (snapshot.connectionState == ConnectionState.waiting)
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot data = snapshot.data.documents[index];
                    return Card(
                      child: Row(
                        children: <Widget>[
                          Image.network(
                            data['imageUrl'],
                            width: 150,
                            height: 100,
                            fit: BoxFit.fill,
                          ),
                          SizedBox(
                            width: 25,
                          ),
                          Text(
                            data['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
        },
      ),
    );
  }

} */
