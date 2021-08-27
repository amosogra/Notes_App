import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:notes_app/internal/constants.dart';

import 'package:notes_app/models/user_model.dart';

import 'package:notes_app/responsive.dart';
import 'package:notes_app/ui/AppTheme.dart';
import 'package:websafe_svg/websafe_svg.dart';
import '../../../kconstants.dart';

class Header extends StatelessWidget {
  Header({
    Key? key,
    this.user,
  }) : super(key: key);
  final User? user;

  @override
  Widget build(BuildContext context) {
    //ConfigurationProvider config = Provider.of<ConfigurationProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // We need this back button on mobile only
          if (Responsive.isMobile(context)) BackButton(),
          if (Responsive.isDesktop(context))
            IconButton(
              icon: WebsafeSvg.asset(
                "assets/Icons/Trash.svg",
                width: 24,
              ),
              tooltip: "Delete User",
              onPressed: () {
                EasyLoading.showToast("Coming soon..");
              },
            ),
          Spacer(),
          // We don't need print option on mobile
          if (Responsive.isDesktop(context))
            IconButton(
              icon: WebsafeSvg.asset(
                "assets/Icons/Printer.svg",
                width: 24,
              ),
              tooltip: "Print Details",
              onPressed: () {
                EasyLoading.showToast("Coming soon..");
              },
            ),
          if (Responsive.isDesktop(context))
            IconButton(
              icon: WebsafeSvg.asset(
                "assets/Icons/Markup.svg",
                width: 24,
              ),
              onPressed: () {
                EasyLoading.showToast("Coming soon..");
              },
            ),
          IconButton(
            icon: WebsafeSvg.asset(
              "assets/Icons/More vertical.svg",
              width: 24,
            ),
            tooltip: "More",
            onPressed: () {
              _showDialog(context,
                  "You are about to assign ${user?.firstName ?? 'Unknown'} ${user?.lastName ?? 'User'} a membership, ministerial or admin role. Please assign with caution!");
            },
          ),
        ],
      ),
    );
  }

  _showDialog(BuildContext context, String message) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("Assign Membership or roles".toUpperCase()),
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
                Role.admin,
                style:
                    AppTheme.getTextStyle(Theme.of(context).textTheme.subtitle1, color: Theme.of(context).colorScheme.primary, fontWeight: 600, letterSpacing: 0.3),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                EasyLoading.show();
                FirebaseFirestore.instance.collection(Constants.users).doc(user?.uid).update({'role': Role.admin}).then((v) {
                  EasyLoading.showToast("${Role.admin}'s role has been assigned to ${user?.firstName ?? 'Unknown'} ${user?.lastName ?? 'User'}");
                });
              },
            ),
            CupertinoDialogAction(
              child: Text(
                Role.minister,
                style:
                    AppTheme.getTextStyle(Theme.of(context).textTheme.subtitle1, color: Theme.of(context).colorScheme.primary, fontWeight: 600, letterSpacing: 0.3),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                EasyLoading.show();
                FirebaseFirestore.instance.collection(Constants.users).doc(user?.uid).update({'role': Role.minister}).then((v) {
                  EasyLoading.showToast("${Role.minister}'s role has been assigned to ${user?.firstName ?? 'Unknown'} ${user?.lastName ?? 'User'}");
                });
              },
            ),
            CupertinoDialogAction(
              child: Text(
                Role.hod,
                style:
                    AppTheme.getTextStyle(Theme.of(context).textTheme.subtitle1, color: Theme.of(context).colorScheme.primary, fontWeight: 600, letterSpacing: 0.3),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                EasyLoading.show();
                FirebaseFirestore.instance.collection(Constants.users).doc(user?.uid).update({'role': Role.hod}).then((v) {
                  EasyLoading.showToast("${Role.hod}'s role has been assigned to ${user?.firstName ?? 'Unknown'} ${user?.lastName ?? 'User'}");
                });
              },
            ),
            CupertinoDialogAction(
              child: Text(
                Role.worker,
                style:
                    AppTheme.getTextStyle(Theme.of(context).textTheme.subtitle1, color: Theme.of(context).colorScheme.primary, fontWeight: 600, letterSpacing: 0.3),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                EasyLoading.show();
                FirebaseFirestore.instance.collection(Constants.users).doc(user?.uid).update({'role': Role.worker}).then((v) {
                  EasyLoading.showToast("${Role.worker}'s role has been assigned to ${user?.firstName ?? 'Unknown'} ${user?.lastName ?? 'User'}");
                });
              },
            ),
            CupertinoDialogAction(
              child: Text(
                Role.member,
                style:
                    AppTheme.getTextStyle(Theme.of(context).textTheme.subtitle1, color: Theme.of(context).colorScheme.primary, fontWeight: 600, letterSpacing: 0.3),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                EasyLoading.show();
                FirebaseFirestore.instance.collection(Constants.users).doc(user?.uid).update({'role': Role.member}).then((v) {
                  EasyLoading.showToast("${Role.member}'s role has been assigned to ${user?.firstName ?? 'Unknown'} ${user?.lastName ?? 'User'}");
                });
              },
            ),
            CupertinoDialogAction(
              child: Text(
                Role.teenager,
                style:
                    AppTheme.getTextStyle(Theme.of(context).textTheme.subtitle1, color: Theme.of(context).colorScheme.primary, fontWeight: 600, letterSpacing: 0.3),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                EasyLoading.show();
                FirebaseFirestore.instance.collection(Constants.users).doc(user?.uid).update({'role': Role.teenager}).then((v) {
                  EasyLoading.showToast("${Role.teenager}'s role has been assigned to ${user?.firstName ?? 'Unknown'} ${user?.lastName ?? 'User'}");
                });
              },
            ),
            CupertinoDialogAction(
              child: Text(
                Role.visitor,
                style:
                    AppTheme.getTextStyle(Theme.of(context).textTheme.subtitle1, color: Theme.of(context).colorScheme.primary, fontWeight: 600, letterSpacing: 0.3),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                EasyLoading.show();
                FirebaseFirestore.instance.collection(Constants.users).doc(user?.uid).update({'role': Role.visitor}).then((v) {
                  EasyLoading.showToast("${Role.visitor}'s role has been assigned to ${user?.firstName ?? 'Unknown'} ${user?.lastName ?? 'User'}");
                });
              },
            ),
            CupertinoDialogAction(
              child: Text(
                Role.returningVisitor,
                style:
                    AppTheme.getTextStyle(Theme.of(context).textTheme.subtitle1, color: Theme.of(context).colorScheme.primary, fontWeight: 600, letterSpacing: 0.3),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                EasyLoading.show();
                FirebaseFirestore.instance.collection(Constants.users).doc(user?.uid).update({'role': Role.returningVisitor}).then((v) {
                  EasyLoading.showToast("${Role.returningVisitor}'s role has been assigned to ${user?.firstName ?? 'Unknown'} ${user?.lastName ?? 'User'}");
                });
              },
            ),
          ],
        );
      },
    );
  }
}
