import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/authentication/authenticate/authenticate.dart';
import 'package:notes_app/authentication/services/auth.dart';
import 'package:notes_app/internal/constants.dart';
import 'package:notes_app/kconstants.dart';
import 'package:notes_app/providers/configurationProvider.dart';
import 'package:notes_app/responsive.dart';
import 'package:notes_app/screens/home/edit_profile_screen.dart';
import 'package:notes_app/screens/notification/NotificationScreen.dart';
import 'package:notes_app/ui/settings/themeSettings.dart';
import 'package:provider/provider.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'drawer_list_title.dart';
import 'package:hive/hive.dart';
import '../../../extensions.dart';

class UserSideMenu extends StatefulWidget {
  UserSideMenu({Key? key, this.fromAdmin = false}) : super(key: key);
  final bool? fromAdmin;

  @override
  _UserSideMenuState createState() => _UserSideMenuState();
}

class _UserSideMenuState extends State<UserSideMenu> {
  var db = Hive.box('settings');
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loggedUser = Provider.of<User?>(context);
    final config = Provider.of<ConfigurationProvider>(context);
    //final themeData = AppTheme.getThemeFromThemeMode(config.darkThemeEnabled ? 2 : 1);
    return Drawer(
      child: Container(
        //height: double.infinity,
        padding: EdgeInsets.only(top: kIsWeb ? kDefaultPadding : 0),
        color: (config.darkThemeEnabled ? bgColorD.withOpacity(0.9) : Colors.white.withOpacity(0.9)),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: kDefaultPadding),
            // it enables scrolling
            child: Column(
              children: [
                Row(
                  children: [
                    Image.asset(
                      "assets/images/logo.png",
                      width: 46,
                    ),
                    Spacer(),
                    // We don't want to show this close button on Desktop mood
                    if (!Responsive.isDesktop(context)) CloseButton(),
                  ],
                ),
                DrawerHeader(
                  child: DrawerListTile.buildHeaderProfile(context, loggedUser),
                ),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance.collection(Constants.notification).snapshots(),
                  builder: (context, snapshot) {
                    return (snapshot.connectionState == ConnectionState.waiting)
                        ? Container()
                        : DrawerListTile(
                            title: "Notification",
                            itemCount: DrawerListTile.getNotifications(snapshot).length,
                            svgSrc: "assets/Icons/menu_notification.svg",
                            isActive: db.get("isActive", defaultValue: "Users") == "Notification",
                            press: () {
                              setState(() {
                                db.put("isActive", "Notification");
                              });
                              //EasyLoading.showToast("Coming soon....");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NotificationScreen(
                                    fromAdmin: widget.fromAdmin ?? false,
                                  ),
                                ),
                              );
                            },
                          );
                  },
                ),
                DrawerListTile(
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
                DrawerListTile(
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
                /* SizedBox(height: kDefaultPadding * 2),
                Tags(), */
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
