import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/providers/configurationProvider.dart';
import 'package:notes_app/ui/AppTheme.dart';
import 'package:notes_app/utils/SizeConfig.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';

class MoreInfoScreen extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> document;
  MoreInfoScreen({Key? key, required this.document}) : super(key: key);
  ThemeData? themeData;
  CustomAppTheme? customAppTheme;

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<ConfigurationProvider>(context);
    themeData = AppTheme.getThemeFromThemeMode(config.darkThemeEnabled ? 2 : 1);
    customAppTheme = AppTheme.getCustomAppTheme(config.darkThemeEnabled ? 2 : 1);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: Spacing.fromLTRB(16, 16, 16, 16),
              child: singleAnnouncement(
                title: document["title"],
                desc: document["description"],
                date: buildDate(document),
                time: buildTime(document),
                venue: document["venue"],
              ),
            ),
          ),
        ),
      ),
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

  Widget singleAnnouncement({String? title, String? date, String? time, String? venue, String? desc}) {
    return Container(
      padding: Spacing.vertical(24),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(MySize.size8 as double)),
          color: customAppTheme?.bgLayer1,
          border: Border.all(color: customAppTheme?.bgLayer4 ?? Colors.purpleAccent, width: 1),
          boxShadow: [BoxShadow(color: customAppTheme?.shadowColor ?? Colors.blueAccent, blurRadius: MySize.size4, offset: Offset(0, 1))]),
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
              style:
                  AppTheme.getTextStyle(themeData?.textTheme.bodyText2, color: themeData?.colorScheme.onBackground, letterSpacing: 0.3, fontWeight: 500, height: 1.7),
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
              : Container(),
          if (document['images'].length != 0)
            Container(
              child: Image(
                image: CachedNetworkImageProvider(document['images'][0]),
              ),
            ),
        ],
      ),
    );
  }
}
