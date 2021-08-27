import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as user;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:notes_app/authentication/authenticate/authenticate.dart';
import 'package:notes_app/authentication/services/auth.dart';
import 'package:notes_app/authentication/services/service.dart';
import 'package:notes_app/components/tags.dart';
import 'package:notes_app/internal/constants.dart';
import 'package:notes_app/models/push_notification.dart';
import 'package:notes_app/providers/configurationProvider.dart';
import 'package:notes_app/responsive.dart';
import 'package:notes_app/screens/admin/admin_screen.dart';
import 'package:notes_app/screens/admin/prayers/prayer_screen.dart';
import 'package:notes_app/screens/home/edit_profile_screen.dart';
import 'package:notes_app/screens/home/hog_screen.dart';
import 'package:notes_app/screens/menus/drawer_list_title.dart';
import 'package:notes_app/screens/notification/NotificationScreen.dart';
import 'package:notes_app/screens/notification/admin/AdminDashboardScreen.dart';
import 'package:notes_app/ui/AppTheme.dart';
import 'package:notes_app/ui/settings/themeSettings.dart';
import 'package:notes_app/utils/do.dart';
import 'package:notes_app/utils/log.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'package:hive/hive.dart';

import '../../../kconstants.dart';
import '../../../extensions.dart';
import '../../../components/counter_badge.dart';

Future<void> _firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  // Initialize the Firebase app
  await Firebase.initializeApp();
  log('onBackgroundMessage received: ${message.data}');
}

class AdminSideMenu extends StatefulWidget {
  const AdminSideMenu({Key? key}) : super(key: key);

  @override
  _AdminSideMenuState createState() => _AdminSideMenuState();
}

class _AdminSideMenuState extends State<AdminSideMenu> {
  int _totalNotifications = 0;

  late PushNotification _notificationInfo;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  late ThemeData themeData;

  String profile = Constants.slogan;

  String username = Constants.appName;

  var profilePhotoUrl = Constants.logoUrl;

  user.User? loggedUser;

  var db = Hive.box('settings');

  @override
  void initState() {
    _totalNotifications = 0;
    registerNotification();
    super.initState();
  }

  void registerNotification() async {
    // On iOS, this helps to take the user permissions
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    _messaging.onTokenRefresh.listen((newToken) async {
      log("NEW TOKEN: $newToken");

      //check if you have the notification_key for your group device else create one
      return await tokenChecks(newToken);
    });

    //Once the [RemoteMesage] has been consumed, it will be removed and further calls to [getInitialMessage] will be null.
    await _messaging.getInitialMessage().then((RemoteMessage? message) {
      log('INITIAL MESSAGE received: ${message?.data}');

      if (message != null) {
        PushNotification notification = PushNotification.fromJson(message);

        setState(() {
          _notificationInfo = notification;
          _totalNotifications++;
        });

        // For displaying the notification as an overlay
        showSimpleNotification(
          Text(_notificationInfo.title!),
          leading: CounterBadge(count: _totalNotifications),
          trailing: IconButton(
              icon: Icon(Icons.reply),
              onPressed: () {
                OverlaySupportEntry.of(context)!.dismiss(); //use OverlaySupportEntry to dismiss overlay
                toast('Good one');
              }),
          subtitle: Text(_notificationInfo.body!),
          //background: Colors.cyan[700],
          duration: Duration(seconds: 2),
        );
      }
    });

    // For handling the received notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('onMessage received: ${message.data}');

      PushNotification notification = PushNotification.fromJson(message);

      setState(() {
        _notificationInfo = notification;
        _totalNotifications++;
      });

      // For displaying the notification as an overlay
      showSimpleNotification(
        Text(_notificationInfo.title!),
        leading: CounterBadge(count: _totalNotifications),
        trailing: IconButton(
            icon: Icon(Icons.reply),
            onPressed: () {
              OverlaySupportEntry.of(context)!.dismiss(); //use OverlaySupportEntry to dismiss overlay
              toast('Good one');
            }),
        subtitle: Text(_notificationInfo.body!),
        //background: Colors.cyan[700],
        duration: Duration(seconds: 2),
      );
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('onLaunch: ${message.data}');

      PushNotification notification = PushNotification.fromJson(message);

      setState(() {
        _notificationInfo = notification;
        _totalNotifications++;
      });
    });

    // Used to get the current FCM token
    _messaging.getToken().then((token) async {
      log('Mobile Token: $token');
      //check if you have the notification_key for your group device else create one
      return await tokenChecks(token);
    }).catchError((e) {
      log(e);
    });
  }

  Future<Future<dynamic>?> tokenChecks(String? token) async {
    final loggeduser = Provider.of<user.User?>(context, listen: false);
    if (loggeduser != null) {
      log('Checking notification_key & Getting Current User Info... uid: ${loggeduser.uid}');
      return FirebaseFirestore.instance.collection(Constants.users).doc(loggeduser.uid).get().then((DocumentSnapshot<Map<String, dynamic>> ds) async {
        //if notification_key doesn't exist, create a new one
        if (["", null, false, 0].contains((ds.data() ?? {})[Constants.notificationKey])) {
          await Do.checkToken(ds);
          return null;
        }

        log('notification_key exists with this user..');
        //check if this user's device token is registered on notification_key else register it
        return await FirebaseFirestore.instance.collection(Constants.users).doc(loggeduser.uid).get().then((DocumentSnapshot<Map<String, dynamic>> dss) async {
          var keyList = List.castFrom<dynamic, String>((dss.data() ?? {})['deviceTokenList'] as List? ?? []);
          if (!keyList.contains(token)) {
            Service service = new Service();
            //if deviceTokenList > 20, purge fcm subscription token list and purge the list as well...
            if (keyList.length > 20) {
              Do.subTopic(service, token, _messaging);
              var notKey = await service.removeUsersFromDeviceGroup((dss.data() ?? {})['uid'], (dss.data() ?? {})[Constants.notificationKey], keyList);
              if (notKey == null) {
                //this operation wasn't carried out
                return null;
              }

              //purge deviceTokenList
              await dss.reference.update({'deviceTokenList': FieldValue.arrayRemove(keyList)});
              log('Tokens removed from list as fcm limit has been exceeded: ${keyList.toString()}');
            }

            log('Adding token to user device list. This must be a new device');

            if ((dss.data() ?? {})[Constants.notificationKey] != null) {
              await dss.reference.update({
                'deviceTokenList': FieldValue.arrayUnion([token])
              }).then((v) {
                log('Token added to list..');
              });

              //subscribe token to notification_key
              return await service.addUserToDeviceGroup((dss.data() ?? {})['uid'], dss.data()![Constants.notificationKey], token).then((notificationKey) async {
                if (notificationKey == null) {
                  //remove token from user deviceTokenList since it's not on fcm yet
                  await dss.reference.update({
                    'deviceTokenList': FieldValue.arrayRemove([token])
                  });
                  log('Token removed from list..');
                  return null;
                }
                //try push
                await service.sendDeviceGroupNotification(
                    (dss.data() ?? {})[Constants.notificationKey], "Welcome", "Hello ${dss.data()!['username']}... You just singed in from a new device");
                return null;
              });
            } else {
              Do.checkToken(dss);
            }
          }
          return null;
        });
      });
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    loggedUser = Provider.of<user.User?>(context);
    final config = Provider.of<ConfigurationProvider>(context);
    themeData = AppTheme.getThemeFromThemeMode(config.darkThemeEnabled ? 2 : 1);
    return Drawer(
      child: Container(
        height: double.infinity,
        padding: EdgeInsets.only(top: kIsWeb ? kDefaultPadding : 0),
        color: (config.darkThemeEnabled ? bgColorD.withOpacity(0.9) : Colors.white.withOpacity(0.9)),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: kDefaultPadding),
            child: Column(
              children: [
                Row(
                  children: [
                    Image.asset(
                      "assets/images/ic_launcher.png",
                      width: 46,
                    ),

                    Spacer(),
                    // We don't want to show this close button on Desktop mood
                    if (!Responsive.isDesktop(context)) CloseButton(),
                  ],
                ),
                SizedBox(height: kDefaultPadding),
                DrawerListTile.buildHeaderProfile(context, loggedUser),
                SizedBox(height: kDefaultPadding),

                FlatButton.icon(
                  minWidth: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: kDefaultPadding,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: db.get("isActive", defaultValue: "Home") == "Home" ? kPrimaryColor : kBgDarkColor,
                  onPressed: () async {
                    setState(() {
                      db.put("isActive", "Home");
                    });

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HOGHome(),
                      ),
                    );
                  },
                  icon: WebsafeSvg.asset("assets/Icons/gem.svg", width: 16),
                  label: Text(
                    "HOG Home",
                    style: TextStyle(color: db.get("isActive", defaultValue: "Home") == "Home" ? Colors.white : kTextColor),
                  ),
                ).addNeumorphism(
                  topShadowColor: config.darkThemeEnabled ? secondaryColorD : Colors.white60,
                  bottomShadowColor: config.darkThemeEnabled ? Colors.yellow.withOpacity(0.2) : Color(0x26234395).withOpacity(0.2),
                ),
                SizedBox(height: kDefaultPadding * 2),
                // Menu Items
                SideMenuItem(
                  press: () {
                    setState(() {
                      db.put("isActive", "Dashboard");
                    });

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminNotificationDashboard(),
                      ),
                    );
                  },
                  title: "Dashboard",
                  svgSrc: "assets/Icons/menu_dashbord.svg",
                  isActive: db.get("isActive", defaultValue: "Users") == "Dashboard",
                  //itemCount: _totalNotifications,
                ),
                SideMenuItem(
                  press: () {
                    setState(() {
                      db.put("isActive", "Prayer Requests");
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrayerScreen(),
                      ),
                    );
                  },
                  title: "Prayer Requests",
                  svgSrc: "assets/Icons/Mail.svg",
                  isActive: db.get("isActive", defaultValue: "All Users") == "Prayer Requests",
                  //itemCount: _totalNotifications,
                ),
                SideMenuItem(
                  press: () {
                    setState(() {
                      db.put("isActive", "All Users");
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminScreen(role: Role.admin),
                      ),
                    );
                  },
                  title: "All Users",
                  svgSrc: "assets/Icons/id-card.svg",
                  isActive: db.get("isActive", defaultValue: "All Users") == "All Users",
                  //itemCount: _totalNotifications,
                ),
                SideMenuItem(
                  press: () {
                    setState(() {
                      db.put("isActive", "Visitors");
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminScreen(role: Role.visitor),
                      ),
                    );
                  },
                  title: "Visitors",
                  svgSrc: "assets/Icons/User Icon.svg",
                  isActive: db.get("isActive", defaultValue: "All Users") == "Visitors",
                ),
                SideMenuItem(
                  press: () {
                    setState(() {
                      db.put("isActive", "Members");
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminScreen(role: Role.member),
                      ),
                    );
                  },
                  title: "Members",
                  svgSrc: "assets/Icons/User Icon.svg",
                  isActive: db.get("isActive", defaultValue: "Members") == "Members",
                ),
                SideMenuItem(
                  press: () {
                    setState(() {
                      db.put("isActive", "Teenager");
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminScreen(role: Role.teenager),
                      ),
                    );
                  },
                  title: "Teenagers",
                  svgSrc: "assets/Icons/User Icon.svg",
                  isActive: db.get("isActive", defaultValue: "Members") == "Teenagers",
                ),
                SideMenuItem(
                  press: () {
                    setState(() {
                      db.put("isActive", "Workers");
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminScreen(role: Role.worker),
                      ),
                    );
                  },
                  title: "Workers",
                  svgSrc: "assets/Icons/id-card.svg",
                  isActive: db.get("isActive", defaultValue: "Members") == "Workers",
                  //itemCount: _totalNotifications,
                ),

                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance.collection(Constants.notification).snapshots(),
                  builder: (context, snapshot) {
                    return (snapshot.connectionState == ConnectionState.waiting)
                        ? Container()
                        : SideMenuItem(
                            title: "Notification",
                            itemCount: DrawerListTile.getNotifications(snapshot).length,
                            svgSrc: "assets/Icons/menu_notification.svg",
                            isActive: db.get("isActive", defaultValue: "Members") == "Notification",
                            press: () {
                              setState(() {
                                db.put("isActive", "Notification");
                              });
                              //EasyLoading.showToast("Coming soon....");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NotificationScreen(fromAdmin: true),
                                ),
                              );
                            },
                          );
                  },
                ),
                SideMenuItem(
                  title: "Profile",
                  svgSrc: "assets/Icons/menu_profile.svg",
                  isActive: db.get("isActive", defaultValue: "Users") == "Profile",
                  press: () {
                    setState(() {
                      db.put("isActive", "Profile");
                    });
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
                ),
                SideMenuItem(
                  title: "Settings",
                  svgSrc: "assets/Icons/menu_setting.svg",
                  isActive: db.get("isActive", defaultValue: "Users") == "Settings",
                  press: () {
                    setState(() {
                      db.put("isActive", "Settings");
                    });
                    Navigator.of(context).push(
                      new MaterialPageRoute<Null>(
                        builder: (BuildContext context) {
                          return ThemeSettings();
                        },
                        fullscreenDialog: true,
                      ),
                    );
                  },
                ),
                SizedBox(height: kDefaultPadding * 2),
                Tags(),
                SizedBox(height: kDefaultPadding * 2),
                FlatButton.icon(
                  minWidth: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: kDefaultPadding,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: kBgDarkColor,
                  onPressed: () async {
                    if (loggedUser != null) {
                      AuthService().signOut();
                    } else {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Authenticate()));
                    }
                  },
                  icon: WebsafeSvg.asset(loggedUser != null ? "assets/Icons/Log out.svg" : "assets/Icons/user.svg", width: 16),
                  label: Text(
                    loggedUser != null ? "Log Out" : "Sign In",
                    style: TextStyle(color: kTextColor),
                  ),
                ).addNeumorphism(
                  topShadowColor: config.darkThemeEnabled ? secondaryColorD : Colors.white60,
                  bottomShadowColor: config.darkThemeEnabled ? Colors.yellow.withOpacity(0.2) : Color(0x26234395).withOpacity(0.2),
                ),
                SizedBox(height: kDefaultPadding * 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
