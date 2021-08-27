import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:notes_app/screens/home.dart';
import 'package:notes_app/utils/log.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';

class Wrapper extends StatelessWidget {
  final db = Hive.box('settings');
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<auth.User?>(context);
    log("Initial User:");
    log(user?.toString());
    return Home();
    //return either Home or Authenticate Widget
    /* if (user == null) {
      log("No User Yet. Going to OnBoarding Screen...");
      Globals globals = Globals();
      globals.updateGlobalUser(null);
      return HOGHome();
    } else {
      log("Returning to home...");
      //check for account type and push accordingly.. for now just push to User Dashboard
      db.put("isActive", "Dashboard");
      return FutureBuilder(
        future: FirebaseFirestore.instance.collection(Constants.users).doc(user.uid).get(GetOptions(source: Source.cache)),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>?> snapshot) {
          return (snapshot.connectionState == ConnectionState.waiting)
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : chose(snapshot.data?.data() ?? {}, context);
        },
      );
    } */
  }

  /*  Widget chose(Map<String, dynamic> data, BuildContext context) {
    var user = User.fromJson(data);
    Globals globals = Globals();
    globals.updateGlobalUser(user);
    switch (user.role ?? Role.member) {
      case Role.admin:
        return AdminScreen(role: Role.admin) /* AdminScreen() */;
      default:
        db.put("isActive", "All Users");
        return HOGHome();
    }
  } */
}
