import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes_app/authentication/authenticate/authenticate.dart';
import 'package:notes_app/internal/constants.dart';
import 'package:notes_app/screens/home/edit_profile_screen.dart';
import 'package:notes_app/screens/notification/admin/AdminDashboardScreen.dart';
import 'package:notes_app/ui/notifiers/overlay.dart';
import 'package:notes_app/ui/settings/themeSettings.dart';
import 'package:notes_app/utils/log.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../../../providers/configurationProvider.dart';
import '../../../ui/AppTheme.dart';
import '../../../utils/SizeConfig.dart';
import 'package:hive/hive.dart';
import 'profile_body.dart';

const debug = true;

class ProfileHeader extends StatefulWidget {
  @override
  _ProfileHeaderState createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  late ThemeData themeData;
  late CustomAppTheme customAppTheme;
  var db = Hive.box('settings');

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
    ConfigurationProvider config = Provider.of<ConfigurationProvider>(context);
    themeData = AppTheme.getThemeFromThemeMode(config.darkThemeEnabled ? 2 : 1);
    customAppTheme = AppTheme.getCustomAppTheme(config.darkThemeEnabled ? 2 : 1);
    final loggedUser = Provider.of<User?>(context);
    return SafeArea(
      child: Scaffold(
        body: loggedUser?.uid != null
            ? StreamBuilder(
                initialData: null,
                stream: FirebaseFirestore.instance.collection(Constants.users).doc(loggedUser?.uid).snapshots(),
                builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>?> snapshot) {
                  //var data = snapshot?.data?.data();
                  return (snapshot.connectionState == ConnectionState.waiting)
                      ? Center(child: CircularProgressIndicator())
                      : buildContainer(loggedUser, context, config, snapshot);
                },
              )
            : buildContainer(loggedUser, context, config, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>?>.withData(ConnectionState.none, null)),
      ),
    );
  }

  Container buildContainer(User? loggedUser, BuildContext context, ConfigurationProvider config, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>?> snapshot) {
    var data = snapshot.data?.data() ?? {};
    log('DATA: $data LOGGED UID: ${loggedUser?.uid}');
    return Container(
      color: config.darkThemeEnabled ? null : customAppTheme.bgLayer1,
      child: ListView(
        padding: Spacing.top(24),
        children: <Widget>[
          Container(
            margin: Spacing.horizontal(24),
            child: Row(
              children: <Widget>[
                InkWell(
                    onTap: () {
                      if (loggedUser != null) {
                        Navigator.of(context).push(new MaterialPageRoute<Null>(
                          builder: (BuildContext context) {
                            return EditProfileScreen();
                          },
                          /* fullscreenDialog: true */
                        ));
                      } else {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Authenticate()));
                      }
                    },
                    child: Container(
                      child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(MySize.size8!)),
                          child: Image(
                            image: CachedNetworkImageProvider(data['avatar_url'] ?? Constants.logoUrl),
                            width: MySize.size48,
                            height: MySize.size48,
                          )),
                    )),
                Expanded(
                    child: InkWell(
                  onTap: () {
                    if (loggedUser != null) {
                      Navigator.of(context).push(new MaterialPageRoute<Null>(
                        builder: (BuildContext context) {
                          return EditProfileScreen();
                        },
                        /* fullscreenDialog: true */
                      ));
                    } else {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Authenticate()));
                    }
                  },
                  child: Container(
                    margin: Spacing.left(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          data['first_name'] != null ? "${data['first_name'] ?? ''} ${data['last_name'] ?? ''}" : Constants.appName,
                          style: AppTheme.getTextStyle(themeData.textTheme.bodyText1, color: themeData.colorScheme.onBackground, fontWeight: 600),
                        ),
                        Text(
                          "${data['role'] ?? 'Regular'} Profile",
                          style: AppTheme.getTextStyle(themeData.textTheme.caption, color: themeData.colorScheme.onBackground, muted: true, fontWeight: 600),
                        ),
                      ],
                    ),
                  ),
                )),
                Container(
                    child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(new MaterialPageRoute<Null>(
                              builder: (BuildContext context) {
                                return ThemeSettings();
                              },
                              fullscreenDialog: true));
                        },
                        child: Stack(clipBehavior: Clip.none, children: <Widget>[
                          Icon(
                            Icons.app_settings_alt,
                            color: themeData.colorScheme.onBackground.withAlpha(200),
                            size: 32,
                          ),
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              padding: EdgeInsets.all(0),
                              height: MySize.size14,
                              width: MySize.size14,
                              decoration: BoxDecoration(color: themeData.colorScheme.primary, borderRadius: BorderRadius.all(Radius.circular(MySize.size40))),
                              child: Center(
                                child: Text(
                                  "3",
                                  style: AppTheme.getTextStyle(
                                    themeData.textTheme.overline,
                                    color: themeData.colorScheme.onPrimary,
                                    fontSize: 9,
                                    fontWeight: 500,
                                  ),
                                ),
                              ),
                            ),
                          )
                        ])))
              ],
            ),
          ),
          upgradeWidget(snapshot, loggedUser),
          Container(
            margin: Spacing.fromLTRB(24, 16, 24, 0),
            child: Text(
              "Welcome",
              style:
                  AppTheme.getTextStyle(themeData.textTheme.bodyText2, color: themeData.colorScheme.onBackground, fontWeight: 600, muted: true, letterSpacing: 0.25),
            ),
          ),
          ProfileBody(
            data: data,
          ),
        ],
      ),
    );
  }

  Widget upgradeWidget(AsyncSnapshot snapshot, User? loggedUser) {
    var data = snapshot.data?.data() ?? {};
    return Container(
      margin: Spacing.fromLTRB(24, 24, 24, 0),
      decoration: BoxDecoration(color: themeData.colorScheme.primary, borderRadius: BorderRadius.all(Radius.circular(MySize.size8!)), boxShadow: [
        BoxShadow(color: themeData.colorScheme.primary.withAlpha(60), blurRadius: MySize.size6, spreadRadius: MySize.size2, offset: Offset(0, MySize.size2))
      ]),
      padding: Spacing.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: Text(
              data['role'] != Role.admin ? "Welcome\nTo Church" : "Admin Oversight",
              style: AppTheme.getTextStyle(themeData.textTheme.subtitle1, fontWeight: 700, color: themeData.colorScheme.onPrimary),
            ),
          ),
          Container(
            margin: Spacing.top(8),
            child: Text(
              data['role'] != Role.admin
                  ? "I was glad when they said unto me, let us go to the house of the Lord.."
                  : "Go to the administrator panel and take an oversight of all activities..",
              style: AppTheme.getTextStyle(themeData.textTheme.bodyText2, color: themeData.colorScheme.onPrimary.withAlpha(160), height: 1.2),
            ),
          ),
          InkWell(
            onTap: () {
              if (loggedUser?.uid == null) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Authenticate()));
              } else if (data['role'] == Role.admin) {
                if (data['first_name'] == null) {
                  //update profile
                  showOverlayNotification((context) {
                    return MessageNotification(
                      title: "Update Profile".toUpperCase(),
                      subtitle: 'Please update your profile before you proceed',
                      onReplay: () {
                        OverlaySupportEntry.of(context)!.dismiss(); //use OverlaySupportEntry to dismiss overlay
                        toast('Warm Regards');
                      },
                    );
                  }, duration: Duration.zero);

                  Navigator.of(context).push(
                    new MaterialPageRoute<Null>(
                      builder: (BuildContext context) {
                        return EditProfileScreen();
                      },
                      fullscreenDialog: true,
                    ),
                  );
                }
              } else {
                db.put("isActive", "Dashboard");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminNotificationDashboard(),
                  ),
                );
              }
            },
            child: Container(
              margin: Spacing.top(16),
              padding: Spacing.fromLTRB(12, 6, 12, 6),
              decoration: BoxDecoration(
                color: customAppTheme.colorInfo,
                borderRadius: BorderRadius.all(Radius.circular(MySize.size24)),
              ),
              child: Text(
                data['role'] != Role.admin ? "See More" : "Control Room",
                style: AppTheme.getTextStyle(themeData.textTheme.bodyText2, color: customAppTheme.onInfo),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget progressWidget({required String title, int? progress, Widget? iconData, Function()? onItemClick, Function()? onLongPress}) {
    return InkWell(
      splashColor: themeData.accentColor,
      onTap: onItemClick,
      onLongPress: onLongPress,
      child: Container(
        padding: Spacing.fromLTRB(8, 8, 4, 8),
        decoration: BoxDecoration(
            color: customAppTheme.bgLayer1,
            borderRadius: BorderRadius.all(Radius.circular(MySize.size8!)),
            boxShadow: [BoxShadow(color: customAppTheme.shadowColor, blurRadius: MySize.size10)]),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.getTextStyle(themeData.textTheme.bodyText1, color: themeData.colorScheme.onBackground, fontWeight: 600),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                        ),
                      ],
                    ),
                    Container(
                      margin: Spacing.top(8),
                      child: Row(
                        children: <Widget>[
                          /* Generator.buildProgress(
                              progress: progress.toDouble(),
                              activeColor: customAppTheme.colorInfo,
                              inactiveColor: customAppTheme.bgLayer3,
                              width: MediaQuery.of(context).size.width * 0.5) ,*/
                          Container(
                            margin: Spacing.left(10),
                            child: Text(
                              progress.toString() + "%",
                              style: AppTheme.getTextStyle(themeData.textTheme.caption,
                                  color: themeData.colorScheme.onBackground, muted: true, fontWeight: 600, letterSpacing: 0.5),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
              child: iconData,
            )
          ],
        ),
      ),
    );
  }
}
