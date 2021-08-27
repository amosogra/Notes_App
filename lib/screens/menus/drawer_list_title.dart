import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:notes_app/authentication/authenticate/authenticate.dart';
import 'package:notes_app/components/counter_badge.dart';
import 'package:notes_app/internal/constants.dart';
import 'package:notes_app/kconstants.dart';
import 'package:notes_app/providers/configurationProvider.dart';
import 'package:notes_app/screens/home/edit_profile_screen.dart';
import 'package:notes_app/ui/AppTheme.dart';
import 'package:notes_app/utils/SizeConfig.dart';
import 'package:notes_app/utils/globals.dart';
import 'package:notes_app/values/values.dart';
import 'package:provider/provider.dart';
import 'package:websafe_svg/websafe_svg.dart';

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    // For selecting those three line once press "Command+D"
    required this.title,
    required this.svgSrc,
    required this.press,
    this.isActive = false,
    this.isHover = false,
    this.itemCount,
  }) : super(key: key);

  final String title, svgSrc;
  final VoidCallback press;
  final bool? isActive, isHover;
  final int? itemCount;

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<ConfigurationProvider>(context);
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: SvgPicture.asset(
        svgSrc,
        color: (isActive! || isHover!)
            ? config.darkThemeEnabled
                ? ePrimaryColor
                : AppColors.primaryColor //kPrimaryColor
            : config.darkThemeEnabled
                ? Colors.white54
                : kTextColor,
        height: 16,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.button!.copyWith(
              color: (isActive! || isHover!)
                  ? config.darkThemeEnabled
                      ? ePrimaryColor
                      : AppColors.primaryColor //kPrimaryColor
                  : config.darkThemeEnabled
                      ? Colors.white54
                      : kTextColor,
            ),
      ),
      trailing: itemCount != null ? CounterBadge(count: itemCount ?? 0) : null,
    );
  }

  static Widget buildHeaderProfile(BuildContext context, User? loggedUser) {
    return InkWell(
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
      child: loggedUser?.uid != null
          ? StreamBuilder(
              initialData: null,
              stream: FirebaseFirestore.instance.collection(Constants.users).doc(loggedUser?.uid).snapshots(),
              builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>?> snapshot) {
                var data = snapshot.data?.data() ?? {};
                return (snapshot.connectionState == ConnectionState.waiting)
                    ? Center(child: CircularProgressIndicator())
                    : Column(
                        children: [
                          Stack(
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
                                  margin: EdgeInsets.only(bottom: MySize.size16 / 2),
                                  width: MySize.getScaledSizeHeight(100),
                                  height: MySize.getScaledSizeHeight(100),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(image: CachedNetworkImageProvider(data['avatar_url'] ?? ''), fit: BoxFit.fill),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text("${data['first_name'] ?? ''} ${data['last_name'] ?? ''}",
                              style: AppTheme.getTextStyle(Theme.of(context).textTheme.headline6, fontWeight: 600, letterSpacing: 0)),
                          Text("${data['role'] ?? 'Regular'} Profile", style: AppTheme.getTextStyle(Theme.of(context).textTheme.subtitle2, fontWeight: 500)),
                        ],
                      );
              },
            )
          : Image.asset("assets/images/logo.png"),
    );
  }

  static List<QueryDocumentSnapshot<Map<String, dynamic>>> getNotifications(AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
    Globals globalUser = Globals();
    var datas = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    if (globalUser.globalUser != null && globalUser.globalUser?.role == Role.returningVisitor) {
      datas = snapshot.data?.docs.where((qds) => qds['to'] == '${Role.returningVisitor}s' || qds['to'] == 'Everyone').toList() ?? [];
    } else if (globalUser.globalUser != null && globalUser.globalUser?.role == Role.visitor) {
      datas =
          snapshot.data?.docs.where((qds) => qds['to'] == '${Role.visitor}s' || qds['to'] == '${Role.returningVisitor}s' || qds['to'] == 'Everyone').toList() ?? [];
    } else if (globalUser.globalUser != null && globalUser.globalUser?.role == Role.member) {
      datas = snapshot.data?.docs
              .where(
                  (qds) => qds['to'] == '${Role.member}s' || qds['to'] == '${Role.visitor}s' || qds['to'] == '${Role.returningVisitor}s' || qds['to'] == 'Everyone')
              .toList() ??
          [];
    } else if (globalUser.globalUser != null && globalUser.globalUser?.role == Role.teenager) {
      datas = snapshot.data?.docs
              .where((qds) =>
                  qds['to'] == '${Role.teenager}s' ||
                  qds['to'] == '${Role.member}s' ||
                  qds['to'] == '${Role.visitor}s' ||
                  qds['to'] == '${Role.returningVisitor}s' ||
                  qds['to'] == 'Everyone')
              .toList() ??
          [];
    } else if (globalUser.globalUser != null && globalUser.globalUser?.role == Role.worker) {
      datas = snapshot.data?.docs
              .where((qds) =>
                  qds['to'] == '${Role.worker}s' ||
                  qds['to'] == '${Role.member}s' ||
                  qds['to'] == '${Role.visitor}s' ||
                  qds['to'] == '${Role.returningVisitor}s' ||
                  qds['to'] == 'Everyone')
              .toList() ??
          [];
    } else if (globalUser.globalUser != null && globalUser.globalUser?.role == Role.hod) {
      datas = snapshot.data?.docs
              .where((qds) =>
                  qds['to'] == '${Role.hod}s' ||
                  qds['to'] == '${Role.teenager}s' ||
                  qds['to'] == '${Role.worker}s' ||
                  qds['to'] == '${Role.member}s' ||
                  qds['to'] == '${Role.visitor}s' ||
                  qds['to'] == '${Role.returningVisitor}s' ||
                  qds['to'] == 'Everyone')
              .toList() ??
          [];
    } else if (globalUser.globalUser != null && globalUser.globalUser?.role == Role.minister) {
      datas = snapshot.data?.docs
              .where((qds) =>
                  qds['to'] == '${Role.minister}s' ||
                  qds['to'] == '${Role.hod}s' ||
                  qds['to'] == '${Role.teenager}s' ||
                  qds['to'] == '${Role.worker}s' ||
                  qds['to'] == '${Role.member}s' ||
                  qds['to'] == '${Role.visitor}s' ||
                  qds['to'] == '${Role.returningVisitor}s' ||
                  qds['to'] == 'Everyone')
              .toList() ??
          [];
    } else if (globalUser.globalUser != null && globalUser.globalUser?.role == 'Admin') {
      datas = snapshot.data?.docs
              .where((qds) =>
                  qds['to'] == '${Role.admin}s' ||
                  qds['to'] == '${Role.minister}s' ||
                  qds['to'] == '${Role.hod}s' ||
                  qds['to'] == '${Role.teenager}s' ||
                  qds['to'] == '${Role.worker}s' ||
                  qds['to'] == '${Role.member}s' ||
                  qds['to'] == '${Role.visitor}s' ||
                  qds['to'] == '${Role.returningVisitor}s' ||
                  qds['to'] == 'Everyone')
              .toList() ??
          [];
    } else {
      datas = snapshot.data?.docs.where((qds) => qds['to'] == 'Everyone').toList() ?? [];
    }

    return datas;
  }
}

class SideMenuItem extends StatelessWidget {
  const SideMenuItem({
    Key? key,
    this.isActive,
    this.isHover = false,
    this.itemCount,
    this.showBorder = false,
    required this.svgSrc,
    required this.title,
    required this.press,
  }) : super(key: key);

  final bool? isActive, isHover, showBorder;
  final int? itemCount;
  final String svgSrc, title;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<ConfigurationProvider>(context);
    return Padding(
      padding: const EdgeInsets.only(top: kDefaultPadding),
      child: InkWell(
        onTap: press,
        child: Row(
          children: [
            (isActive! || isHover!)
                ? WebsafeSvg.asset(
                    "assets/Icons/Angle right.svg",
                    width: 15,
                  )
                : SizedBox(width: 15),
            SizedBox(width: kDefaultPadding / 4),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(bottom: 15, right: 5),
                decoration: showBorder!
                    ? BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFDFE2EF)),
                        ),
                      )
                    : null,
                child: Row(
                  children: [
                    WebsafeSvg.asset(
                      svgSrc,
                      height: 20,
                      color: (isActive! || isHover!)
                          ? config.darkThemeEnabled
                              ? AppColors.primaryColor
                              : AppColors.primaryColor //kPrimaryColor
                          : kGrayColor,
                    ),
                    SizedBox(width: kDefaultPadding * 0.75),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.button!.copyWith(
                            color: (isActive! || isHover!)
                                ? config.darkThemeEnabled
                                    ? AppColors.primaryColor
                                    : AppColors.primaryColor //kPrimaryColor
                                : kGrayColor,
                          ),
                    ),
                    Spacer(),
                    if (itemCount != null) CounterBadge(count: itemCount ?? 0)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
