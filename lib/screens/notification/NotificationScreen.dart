import 'package:notes_app/internal/constants.dart';
import 'package:notes_app/providers/configurationProvider.dart';
import 'package:notes_app/screens/menus/drawer_list_title.dart';
import 'package:notes_app/ui/AppTheme.dart';
import 'package:notes_app/utils/Generator.dart';
import 'package:notes_app/utils/SizeConfig.dart';
import 'package:notes_app/utils/globals.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'MoreInfoScreen.dart';
import 'admin/NotificationUploadScreen.dart';

class NotificationScreen extends StatefulWidget {
  final bool fromAdmin;
  const NotificationScreen({Key? key, this.fromAdmin = false}) : super(key: key);
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  ThemeData? themeData;
  CustomAppTheme? customAppTheme;

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<ConfigurationProvider>(context);
    themeData = AppTheme.getThemeFromThemeMode(config.darkThemeEnabled ? 2 : 1);
    customAppTheme = AppTheme.getCustomAppTheme(config.darkThemeEnabled ? 2 : 1);
    return SafeArea(
      child: Scaffold(
        floatingActionButton: widget.fromAdmin
            ? FloatingActionButton(
                heroTag: "edit-n",
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
              )
            : null,
        body: Container(
          color: customAppTheme?.bgLayer1,
          child: ListView(
            padding: Spacing.bottom(16),
            children: <Widget>[
              Container(
                margin: Spacing.fromLTRB(24, 16, 24, 0),
                child: Row(
                  children: <Widget>[
                    Container(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          MdiIcons.chevronLeft,
                          color: themeData?.colorScheme.onBackground,
                          size: MySize.size24,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Container(
                          child: Text(
                            "Notification",
                            style: AppTheme.getTextStyle(themeData?.textTheme.bodyText1, color: themeData?.colorScheme.onBackground, fontWeight: 600),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          MdiIcons.notificationClearAll,
                          size: MySize.size24,
                          color: themeData?.colorScheme.onBackground,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection(Constants.notification)
                      .where("freeze", isEqualTo: "false")
                      .orderBy("timestamp", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    return (snapshot.connectionState == ConnectionState.waiting) ? Center(child: CircularProgressIndicator()) : buildColumn(snapshot);
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Column buildColumn(AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
    var datas = DrawerListTile.getNotifications(snapshot);

    return Column(
      children: datas
          .map((document) => document["type"] == "Event" || document["type"] == "Announcement" || document["type"] == "Everyone"
              ? Container(
                  margin: Spacing.fromLTRB(24, 24, 24, 0),
                  child: singleAnnouncement(
                      notification: document,
                      title: document["title"],
                      desc: Generator.getWords(15, document["description"]),
                      date: buildDate(document),
                      time: buildTime(document),
                      venue: document["venue"]))
              : Container())
          .toList(),
    );
  }

  String buildDate(QueryDocumentSnapshot<Map<String, dynamic>> document) {
    var start = document["startDate"];
    var stop = document["endDate"];

    if (stop == "" && start != "") {
      return DateFormat("EEE, d MMM yyyy").format(DateTime.parse(start));
    } else if (stop == "" && start == "") {
      return "";
    } else if (stop != "" && start != "") {
      var startDate = DateTime.parse(start);
      var stopDate = DateTime.parse(stop);

      if (startDate.year == stopDate.year) {
        if (startDate.month == stopDate.month) {
          if (startDate.day == stopDate.day) {
            return "${DateFormat("hh:mm a").format(startDate)} - ${DateFormat("hh:mm a").format(stopDate)}\n${DateFormat("EEE, d MMM yyyy").format(startDate)}";
          } else {
            return "${DateFormat("d").format(startDate)} - ${DateFormat("d MMM yyyy").format(stopDate)}";
          }
        } else {
          return "${DateFormat("d MMM").format(startDate)} - ${DateFormat("d MMM yyyy").format(stopDate)}";
        }
      } else {
        return "${DateFormat("d MMM yyyy").format(startDate)} - ${DateFormat("d MMM yyyy").format(stopDate)}";
      }
    }

    return "";
  }

  String buildTime(QueryDocumentSnapshot<Map<String, dynamic>> document) {
    var start = document["startDate"];

    if (start != "") {
      return DateFormat("hh:mm a").format(DateTime.parse(start));
    }

    Timestamp time = document["timestamp"];
    return timeago.format(time.toDate());
  }

  bool checkIfTimeElapsed(QueryDocumentSnapshot<Map<String, dynamic>> document) {
    var start = document["startDate"];
    //var stop = document["endDate"];
    var now = new DateTime.now();

    /*if (stop != "") {
      var earlier = DateTime.parse(stop); //assuming date has passed...
      return earlier.isBefore(now); //checks if earlier occurs before now
    } else*/
    if (start != "") {
      var earlier = DateTime.parse(start); //assuming date has passed...
      return earlier.isBefore(now);
    } else {
      return false;
    }
  }

  Widget singleAnnouncement({QueryDocumentSnapshot<Map<String, dynamic>>? notification, String? title, String? date, String? time, String? venue, String? desc}) {
    return Container(
      padding: Spacing.vertical(24),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(MySize.size8 as double)),
          color: customAppTheme?.bgLayer1,
          border: Border.all(color: customAppTheme?.bgLayer4 ?? Colors.lightBlueAccent, width: 1),
          boxShadow: [BoxShadow(color: customAppTheme?.shadowColor ?? Colors.purpleAccent, blurRadius: MySize.size4, offset: Offset(0, 1))]),
      child: InkWell(
        splashColor: themeData?.accentColor.withOpacity(0.6),
        onTap: () {
          if (notification!["meeting"]) {
            //if today is the day of the meeting, go to meeting screen
            if (checkIfTimeElapsed(notification)) {
              //meeting has started, go to meeting...
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MoreInfoScreen(document: notification), //MeetingScreen(document: notification),
                  fullscreenDialog: true,
                ),
              );
              return null;
            }
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MoreInfoScreen(document: notification),
              fullscreenDialog: true,
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: Spacing.horizontal(24),
              child: Text(
                title as String,
                style: AppTheme.getTextStyle(themeData?.textTheme.subtitle2, color: themeData?.colorScheme.onBackground, fontWeight: 600),
              ),
            ),
            Container(
              padding: Spacing.horizontal(24),
              margin: Spacing.top(4),
              child: Text(
                desc as String,
                style: AppTheme.getTextStyle(themeData?.textTheme.bodyText2,
                    color: themeData?.colorScheme.onBackground, letterSpacing: 0.3, fontWeight: 500, height: 1.7),
              ),
            ),
            Container(
                margin: Spacing.top(16),
                child: Divider(
                  height: 0,
                )),
            Container(
              padding: Spacing.only(left: 24, right: 24, top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    date as String,
                    style: AppTheme.getTextStyle(themeData?.textTheme.bodyText2, color: themeData?.colorScheme.primary),
                  ),
                  Text(
                    time as String,
                    style: AppTheme.getTextStyle(themeData?.textTheme.bodyText2, color: themeData?.colorScheme.primary),
                  ),
                ],
              ),
            ),
            venue != ""
                ? Container(
                    margin: Spacing.top(4),
                    padding: Spacing.horizontal(24),
                    child: Text(
                      venue as String,
                      style: AppTheme.getTextStyle(themeData?.textTheme.bodyText2, color: themeData?.colorScheme.onBackground.withAlpha(160), fontWeight: 500),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
