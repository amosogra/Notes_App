import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:notes_app/authentication/authenticate/authenticate.dart';
import 'package:notes_app/authentication/services/auth.dart';
import 'package:notes_app/internal/constants.dart';
import 'package:notes_app/screens/notification/NotificationScreen.dart';

import 'package:notes_app/ui/settings/themeSettings.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'profile_menu.dart';

class ProfileBody extends StatefulWidget {
  final Map<String, dynamic> data;
  ProfileBody({required this.data});
  @override
  _ProfileBodyState createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  var db = Hive.box('settings');
  @override
  Widget build(BuildContext context) {
    final loggedUser = Provider.of<User?>(context);
    //final deskScreen = Provider.of<WidgetScreenProvider>(context);
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          //ProfilePic(),
          SizedBox(height: 20),
          ProfileMenu(
            text: "Notifications",
            icon: "assets/Icons/bell.svg",
            press: () async {
              setState(() {
                db.put("isActive", "Notification");
              });
              //EasyLoading.showToast("Coming soon....");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationScreen(fromAdmin: widget.data['role'] == Role.admin ? true : false),
                ),
              );
            },
          ),
          ProfileMenu(
            text: "Settings",
            icon: "assets/Icons/Settings.svg",
            press: () {
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
          ProfileMenu(
            text: "Help Center",
            icon: "assets/Icons/Question mark.svg",
            press: () {
              EasyLoading.showToast("Coming soon...");
            },
          ),
          ProfileMenu(
            text: loggedUser != null ? "Log Out" : "Sign In",
            icon: loggedUser != null ? "assets/Icons/Log out.svg" : "assets/Icons/user.svg",
            press: () {
              loggedUser != null ? AuthService().signOut() : Navigator.push(context, MaterialPageRoute(builder: (context) => Authenticate()));
            },
          ),
        ],
      ),
    );
  }
}
