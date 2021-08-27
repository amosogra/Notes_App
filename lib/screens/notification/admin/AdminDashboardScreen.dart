/*
* File : LMS Dashboard
* Version : 1.0.0
* */
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:notes_app/internal/constants.dart';
import 'package:notes_app/kconstants.dart';
import 'package:notes_app/providers/configurationProvider.dart';
import 'package:notes_app/responsive.dart';
import 'package:notes_app/screens/admin/prayers/prayer_screen.dart';
import 'package:notes_app/ui/AppTheme.dart';
import 'package:notes_app/ui/settings/themeSettings.dart';
import 'package:notes_app/utils/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/utils/log.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../NotificationScreen.dart';
import 'NotificationUploadScreen.dart';

class AdminNotificationDashboard extends StatefulWidget {
  @override
  _AdminNotificationDashboardState createState() => _AdminNotificationDashboardState();
}

class _AdminNotificationDashboardState extends State<AdminNotificationDashboard> {
  Future<bool> checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        log('connected');
        return true;
      }
    } on SocketException catch (_) {
      log('not connected');
      return false;
    }

    return false;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<ConfigurationProvider>(context);
    final themeData = AppTheme.getThemeFromThemeMode(config.darkThemeEnabled ? 2 : 1);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: "edit",
        backgroundColor: Colors.redAccent,
        mini: true,
        child: Icon(MdiIcons.pencil),
        onPressed: () {
          Navigator.of(context).push(
            new MaterialPageRoute<Null>(
              builder: (BuildContext context) {
                return NotificationUploadScreen();
              },
              /* fullscreenDialog: true */
            ),
          );
        },
      ),
      appBar: AppBar(
        backgroundColor: themeData.backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: BackButton(color: config.darkThemeEnabled ? null : bgColorD),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  new MaterialPageRoute<Null>(
                      builder: (BuildContext context) {
                        return ThemeSettings();
                      },
                      fullscreenDialog: true),
                );
              },
              child: Icon(
                Icons.app_settings_alt,
                color: config.darkThemeEnabled ? null : bgColorD,
              ),
            ),
          )
        ],
        title: Text("Notification Dashboard".toUpperCase(), style: AppTheme.getTextStyle(themeData.textTheme.headline6, fontWeight: 600)),
      ),
      body: Container(
        color: themeData.backgroundColor,
        child: ListView(
          children: <Widget>[
            Container(
                margin: EdgeInsets.only(top: MySize.size16, left: MySize.size16, right: MySize.size16),
                child: Text(
                  "TAKE CONTROL",
                  style: AppTheme.getTextStyle(themeData.textTheme.caption, fontWeight: 600, letterSpacing: 0.3),
                )),
            Container(
              child: GridView.count(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  crossAxisCount: 2,
                  padding: EdgeInsets.only(left: MySize.size16, right: MySize.size16, top: MySize.size16),
                  mainAxisSpacing: MySize.size16,
                  childAspectRatio: Responsive.isMobile(context) ? 1.2 : 4,
                  crossAxisSpacing: MySize.size16,
                  children: <Widget>[
                    /* _SingleSubject(
                      categories: 'Sermons, Worship, Others',
                      subject: 'UPLOAD VIDEO',
                      backgroundColor: Colors.blue,
                      onClick: () {
                        _openFileExplorerForVideo();
                      },
                    ),
                    _SingleSubject(
                      categories: 'Sermons, Songs, Others',
                      subject: 'UPLOAD AUDIO',
                      backgroundColor: Colors.red,
                      onClick: () {
                        _openFileExplorerForAudio();
                      },
                    ),
                    _SingleSubject(
                      categories: 'Devotionals, Books',
                      subject: 'UPLOAD PDF',
                      backgroundColor: Colors.green,
                      onClick: () {
                        _openFileExplorerForPdf();
                      },
                    ), */
                    _SingleSubject(
                      categories: 'Notifications & Events..',
                      subject: 'OTHER (ANNOUNCEMENT)',
                      backgroundColor: Colors.orange,
                      onClick: () async {
                        var connected = await checkInternet();
                        if (connected) {
                          Navigator.push(
                            context,
                            MaterialPageRoute<dynamic>(
                              builder: (_) => NotificationScreen(fromAdmin: true),
                            ),
                          );
                        } else {
                          EasyLoading.showError('Failed to connect to the internet, no internet connection... Please check your network connection and try again.',
                              duration: const Duration(seconds: 5), dismissOnTap: true);
                        }
                      },
                    ),
                    _SingleSubject(
                        categories: 'Prayer Requests..',
                        subject: 'PRAYER PORTAL',
                        backgroundColor: Colors.purple,
                        onClick: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute<dynamic>(
                              builder: (_) => PrayerScreen(),
                            ),
                          );
                        }),
                  ]),
            ),
            Container(
              padding: EdgeInsets.only(top: MySize.size16, left: MySize.size16, right: MySize.size16),
              child: Text(
                "MANAGE ANNOUNCEMENTS",
                style: AppTheme.getTextStyle(themeData.textTheme.caption, fontWeight: 600, letterSpacing: 0.3),
              ),
            ),
            Container(
              child: _SubmissionWidget(),
            )
          ],
        ),
      ),
    );
  }
}

class _SingleSubject extends StatelessWidget {
  final Color backgroundColor;
  final String subject;
  final String categories;
  final Function()? onClick;

  const _SingleSubject({Key? key, this.onClick, required this.backgroundColor, required this.subject, required this.categories}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MySize.size8 as double),
      ),
      child: InkWell(
        onTap: onClick,
        child: Container(
          color: backgroundColor,
          height: 125,
          child: Container(
            padding: EdgeInsets.only(bottom: MySize.size16, left: MySize.size16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(subject, style: AppTheme.getTextStyle(themeData.textTheme.subtitle1, fontWeight: 600, color: Colors.white)),
                Text(categories, style: AppTheme.getTextStyle(themeData.textTheme.caption, fontWeight: 500, color: Colors.white, letterSpacing: 0)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SubmissionWidget extends StatefulWidget {
  @override
  _SubmissionWidgetState createState() => _SubmissionWidgetState();
}

class _SubmissionWidgetState extends State<_SubmissionWidget> {
  int _currentStep = 0;
  var carouselScrollDisplay = false;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final config = Provider.of<ConfigurationProvider>(context);
    return Container(
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection(Constants.notification).orderBy("timestamp", descending: true).snapshots(),
        builder: (context, snapshot) {
          return (snapshot.connectionState == ConnectionState.waiting)
              ? Center(child: CircularProgressIndicator())
              : buildStepper(snapshot, themeData, context, config);
        },
      ),
    );
  }

  Widget buildStepper(AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot, ThemeData themeData, BuildContext context, ConfigurationProvider config) {
    if ((snapshot.data?.docs ?? []).length == 0) return Container();
    return Stepper(
      physics: ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      controlsBuilder: (BuildContext context, {VoidCallback? onStepContinue, VoidCallback? onStepCancel}) {
        return _buildControlBuilder(_currentStep, snapshot.data?.docs ?? [], themeData);
      },
      currentStep: _currentStep,
      onStepTapped: (pos) {
        setState(() {
          _currentStep = pos;
        });
      },
      steps: snapshot.data?.docs.map((document) {
            return Step(
              isActive: !checkIfTimeElapsed(document),
              title: Text(
                buildTitle(document),
                //style: AppTheme.getTextStyle(themeData.textTheme.bodyText1, fontWeight: 600),
              ),
              subtitle: Text(buildSubTitle(document), style: AppTheme.getTextStyle(themeData.textTheme.caption, fontWeight: 500)),
              state: StepState.indexed,
              content: Container(
                width: MediaQuery.of(context).size.width,
                child: Text(document["description"],
                    style: themeData.textTheme.caption?.merge(TextStyle(
                      color: config.darkThemeEnabled ? null : bgColorD,
                    ))),
              ),
            );
          }).toList() ??
          [],
    );
  }

  bool checkIfTimeElapsed(QueryDocumentSnapshot<Map<String, dynamic>> document) {
    var start = document["startDate"];
    var stop = document["endDate"];
    var now = new DateTime.now();

    if (stop != "") {
      var earlier = DateTime.parse(stop); //assuming date has passed...
      return earlier.isBefore(now); //checks if earlier occurs before now
    } else if (start != "") {
      var earlier = DateTime.parse(start); //assuming date has passed...
      return earlier.isBefore(now);
    } else {
      return false;
    }
  }

  String buildTitle(QueryDocumentSnapshot<Map<String, dynamic>> document) {
    var start = document["startDate"];
    var stop = document["endDate"];
    var now = new DateTime.now();

    if (start != "") {
      var earlier = DateTime.parse(start); //assuming date has passed...
      var duration = now.difference(earlier);
      return duration.isNegative
          ? (duration.inSeconds < 86400 ? "Due - ${DateFormat("EEE, d MMM yyyy").format(earlier)}" : "Upcoming - ${DateFormat("EEE, d MMM yyyy").format(earlier)}")
          : (stop != ""
              ? (now.difference(DateTime.parse(stop)).isNegative
                  ? "Due - ${DateFormat("EEE, d MMM yyyy").format(DateTime.parse(stop))}"
                  : "Completed - ${DateFormat("EEE, d MMM yyyy").format(DateTime.parse(stop))}")
              : "Completed - ${DateFormat("EEE, d MMM yyyy").format(earlier)}");
    } else {
      Timestamp time = document["timestamp"];
      return timeago.format(time.toDate());
    }
  }

  /* String buildSubTitle(QueryDocumentSnapshot<Map<String, dynamic>> document) {
    var type = document["type"];

    if (type == 'Announcement') {
      return 'Announcement';
    } else if (type == 'Event') {
      return 'Event | ${document["venue"]}';
    } else {
      return 'Meeting | $type | ${document["venue"]}';
    }
  }
 */
  String buildSubTitle(QueryDocumentSnapshot<Map<String, dynamic>> document) {
    var type = document["type"];

    if (type == 'Announcement') {
      return 'Announcement | to ${document["to"]}';
    } else if (type == 'Event') {
      return 'Event | to ${document["to"]} | ${document["venue"]}';
    } else {
      return 'Meeting | $type | to ${document["to"]} | ${document["venue"]}';
    }
  }

  void showSnackbarWithFloating(String message, ThemeData themeData) {
    ScaffoldMessenger.of(context).showSnackBar(
      new SnackBar(
        content: new Text(
          message,
          style: themeData.textTheme.subtitle2?.merge(TextStyle(color: themeData.colorScheme.onPrimary)),
        ),
        backgroundColor: themeData.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildControlBuilder(int position, List<QueryDocumentSnapshot<Map<String, dynamic>>> docs, ThemeData themeData) {
    if (!checkIfTimeElapsed(docs[position])) {
      return Container(
        margin: EdgeInsets.only(top: MySize.size8 as double),
        child: Align(
          alignment: Alignment.center,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(MySize.size8 as double)),
              boxShadow: [
                BoxShadow(
                  color: themeData.colorScheme.primary.withAlpha(18),
                  blurRadius: 2,
                  offset: Offset(0, 1), // changes position of shadow
                ),
              ],
            ),
            child: FlatButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MySize.size4)),
                color: themeData.colorScheme.primary,
                splashColor: Colors.white.withAlpha(100),
                highlightColor: themeData.colorScheme.primary,
                onPressed: () async {
                  carouselScrollDisplay = docs[position]['display'] == "true";
                  await showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                        insetAnimationDuration: const Duration(seconds: 1),
                        title: Text('Take Control Over this Notification'.toUpperCase()),
                        content: Text('What do you wish to do with this notification? You have various options:'),
                        actions: <Widget>[
                          CupertinoDialogAction(
                            onPressed: () async {
                              docs[position].reference.delete().then((value) {
                                log("Notification Deleted");
                                EasyLoading.showSuccess("Notification Deleted", duration: const Duration(seconds: 5), dismissOnTap: true);
                              }).catchError((error) {
                                log("Failed to delete Notification: $error");
                                EasyLoading.showError('Failed to delete Notification: $error', duration: const Duration(seconds: 5), dismissOnTap: true);
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Trash Me'),
                          ),
                          CupertinoDialogAction(
                            onPressed: () async {
                              var data = Map<String, dynamic>();
                              data['freeze'] = "true";
                              docs[position].reference.update(data).then((value) {
                                log("Notification Freezed");
                                EasyLoading.showSuccess("Notification Freezed", duration: const Duration(seconds: 5), dismissOnTap: true);
                              }).catchError((error) {
                                log("Failed to Freeze Notification: $error");
                                EasyLoading.showError('Failed to Freezed Notification: $error', duration: const Duration(seconds: 5), dismissOnTap: true);
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Freeze'),
                          ),
                          CupertinoDialogAction(
                            onPressed: () async {
                              var data = Map<String, dynamic>();
                              data['freeze'] = "false";
                              docs[position].reference.update(data).then((value) {
                                log("Notification Unfreezed");
                                EasyLoading.showSuccess("Notification Unfreezed", duration: const Duration(seconds: 5), dismissOnTap: true);
                              }).catchError((error) {
                                log("Failed to Unfreezed Notification: $error");
                                EasyLoading.showError('Failed to Unfreezed Notification: $error', duration: const Duration(seconds: 5), dismissOnTap: true);
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Unfreeze'),
                          ),
                          CupertinoDialogAction(
                            onPressed: () async {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  "Carousel Display: ",
                                  style: AppTheme.getTextStyle(themeData.textTheme.bodyText1, fontWeight: 600),
                                ),
                                Container(
                                    margin: EdgeInsets.only(top: MySize.size4),
                                    child: Text(carouselScrollDisplay ? "Shown" : "Not shown",
                                        style: AppTheme.getTextStyle(themeData.textTheme.caption, fontWeight: 400, letterSpacing: 0, height: 1))),
                                Switch(
                                  onChanged: (bool value) {
                                    setState(() {
                                      carouselScrollDisplay = value;
                                    });

                                    var data = Map<String, dynamic>();
                                    data['display'] = value ? "true" : "false";
                                    docs[position].reference.update(data).then((value) {
                                      log("Notification Display ${data['display'] == "true" ? 'Shown' : 'Off'}");
                                      EasyLoading.showSuccess("Notification Display ${data['display'] == "true" ? 'Shown' : 'Off'}",
                                          duration: const Duration(seconds: 5), dismissOnTap: true);
                                    }).catchError((error) {
                                      log("Failed to Update Notification Display on Carousel: $error");
                                      EasyLoading.showError('Failed to Update Notification Display on Carousel: $error',
                                          duration: const Duration(seconds: 5), dismissOnTap: true);
                                    });
                                    Navigator.pop(context);
                                  },
                                  value: carouselScrollDisplay,
                                  activeColor: themeData.colorScheme.primary,
                                )
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                padding: EdgeInsets.symmetric(vertical: MySize.size8 as double, horizontal: MySize.size32),
                child: Text("Action".toUpperCase(),
                    style: AppTheme.getTextStyle(themeData.textTheme.caption, color: themeData.colorScheme.onSecondary, letterSpacing: 0.3, fontWeight: 600))),
          ),
        ),
      );
    }
    return Container(
      margin: EdgeInsets.only(top: 8),
      child: Align(
        alignment: Alignment.center,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(MySize.size8 as double)),
            boxShadow: [
              BoxShadow(
                color: themeData.colorScheme.secondary.withAlpha(18),
                blurRadius: 3,
                offset: Offset(0, 2), // changes position of shadow
              ),
            ],
          ),
          child: FlatButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MySize.size4)),
              color: themeData.colorScheme.secondary,
              highlightColor: themeData.colorScheme.secondary,
              splashColor: Colors.white.withAlpha(100),
              onPressed: () async {
                docs[position].reference.delete().then((value) {
                  log("Notification Deleted");
                  EasyLoading.showSuccess("Notification Deleted", duration: const Duration(seconds: 5), dismissOnTap: true);
                }).catchError((error) {
                  log("Failed to delete Notification: $error");
                  EasyLoading.showError('Failed to delete Notification: $error', duration: const Duration(seconds: 5), dismissOnTap: true);
                });
              },
              padding: EdgeInsets.symmetric(vertical: MySize.size8 as double, horizontal: MySize.size32),
              child: Text("Trash Me".toUpperCase(),
                  style: AppTheme.getTextStyle(themeData.textTheme.caption, color: themeData.colorScheme.onSecondary, letterSpacing: 0.3, fontWeight: 600))),
        ),
      ),
    );
  }
}
