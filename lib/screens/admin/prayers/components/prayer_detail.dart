import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:notes_app/internal/constants.dart';
import 'package:notes_app/models/user_model.dart';
import 'package:notes_app/providers/configurationProvider.dart';
import 'package:notes_app/responsive.dart';
import 'package:notes_app/ui/AppTheme.dart';
import 'package:notes_app/ui/widgets/MarqueeWidget.dart';
import 'package:notes_app/utils/SizeConfig.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class AboutPrayerRequesterScreen extends StatefulWidget {
  final PrayerRequester prayerRequester;
  const AboutPrayerRequesterScreen({Key? key, required this.prayerRequester}) : super(key: key);
  @override
  _AboutPrayerRequesterScreenState createState() => _AboutPrayerRequesterScreenState();
}

class _AboutPrayerRequesterScreenState extends State<AboutPrayerRequesterScreen> {
  ThemeData? themeData;

  Widget build(BuildContext context) {
    final config = Provider.of<ConfigurationProvider>(context);
    themeData = AppTheme.getThemeFromThemeMode(config.darkThemeEnabled ? 2 : 1);
    return Scaffold(
      appBar: AppBar(
        title: Text('Prayer Request'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: Responsive.isMobile(context) ? BackButton() : null,
        actions: [
          IconButton(
            icon: Icon(Icons.more),
            onPressed: () {
              _showDialog(context, "Here you can process and revert changes to prayer requests so as to track them in the prayer portal");
            },
          ),
        ],
      ),
      backgroundColor: themeData?.colorScheme.background,
      body: Container(
        margin: EdgeInsets.only(top: MySize.size32, left: MySize.size16, right: MySize.size16, bottom: MySize.size32),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                child: Row(
                  children: <Widget>[
                    Container(
                      width: MySize.size60,
                      height: MySize.size60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(image: CachedNetworkImageProvider(widget.prayerRequester.avatarUrl ?? ''), fit: BoxFit.fill),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: MySize.size16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "${widget.prayerRequester.firstName ?? "Unknown"} ${widget.prayerRequester.lastName ?? "User"}",
                            style: AppTheme.getTextStyle(themeData?.textTheme.subtitle1, fontWeight: 600, color: themeData?.colorScheme.onBackground),
                          ),
                          Container(
                              child: MarqueeWidget(
                            animationDuration: Duration(seconds: 8),
                            backDuration: Duration(seconds: 3),
                            pauseDuration: Duration(seconds: 2),
                            direction: Axis.horizontal,
                            child: Text(
                              timeago.format((widget.prayerRequester.timestamp ?? Timestamp.now()).toDate()) + ", ${widget.prayerRequester.phone}",
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              style: AppTheme.getTextStyle(themeData?.textTheme.subtitle2, fontWeight: 500, color: themeData?.colorScheme.onBackground),
                            ),
                          )),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          padding: EdgeInsets.only(left: MySize.size8!, right: MySize.size8!, top: MySize.size4, bottom: MySize.size4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(MySize.size4)),
                            color: themeData?.colorScheme.primary,
                          ),
                          child: Text(
                            widget.prayerRequester.gender ?? widget.prayerRequester.role ?? '',
                            style: AppTheme.getTextStyle(themeData?.textTheme.caption,
                                fontSize: 11, color: themeData?.colorScheme.onPrimary, fontWeight: 600, letterSpacing: 0.3),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: MySize.size16),
                child: Text(
                  widget.prayerRequester.description ?? '',
                  style: AppTheme.getTextStyle(themeData?.textTheme.bodyText2, fontWeight: 500, color: themeData?.colorScheme.onBackground),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _showDialog(BuildContext context, String message) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("Process Prayer Request".toUpperCase()),
          content: Container(
            margin: EdgeInsets.only(top: 16),
            child: Text.rich(
              TextSpan(
                text: message,
              ),
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(
                'Cancel',
                style:
                    AppTheme.getTextStyle(Theme.of(context).textTheme.subtitle1, color: Theme.of(context).colorScheme.primary, fontWeight: 600, letterSpacing: 0.3),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text(
                'Request Processed',
                style:
                    AppTheme.getTextStyle(Theme.of(context).textTheme.subtitle1, color: Theme.of(context).colorScheme.primary, fontWeight: 600, letterSpacing: 0.3),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                EasyLoading.show();
                FirebaseFirestore.instance.collection(Constants.prayerRequests).doc(widget.prayerRequester.pid).update({'prayed': true}).then((v) {
                  EasyLoading.showToast("Prayer Request processed as prayed");
                });
              },
            ),
            CupertinoDialogAction(
              child: Text(
                'Revert Changes',
                style:
                    AppTheme.getTextStyle(Theme.of(context).textTheme.subtitle1, color: Theme.of(context).colorScheme.primary, fontWeight: 600, letterSpacing: 0.3),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                EasyLoading.show();
                FirebaseFirestore.instance.collection(Constants.prayerRequests).doc(widget.prayerRequester.pid).update({'prayed': false}).then((v) {
                  EasyLoading.showToast("Prayer Request reverted as never prayed");
                });
              },
            ),
          ],
        );
      },
    );
  }
}
