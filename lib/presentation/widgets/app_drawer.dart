import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:notes_app/Bible/entrance.dart';
import 'package:notes_app/authentication/authenticate/authenticate.dart';
import 'package:notes_app/authentication/services/auth.dart';
import 'package:notes_app/internal/constants.dart';
import 'package:notes_app/kconstants.dart';
import 'package:notes_app/extensions.dart';
import 'package:notes_app/main.dart';
import 'package:notes_app/models/user_model.dart';
import 'package:notes_app/presentation/layout/adaptive.dart';
import 'package:notes_app/providers/configurationProvider.dart';
import 'package:notes_app/screens/admin/admin_screen.dart';
import 'package:notes_app/screens/home/edit_profile_screen.dart';
import 'package:notes_app/screens/notification/admin/PrayerRequestUploadScreen.dart';
import 'package:notes_app/utils/functions.dart';
import 'package:notes_app/utils/globals.dart';
import 'package:notes_app/values/values.dart';
import 'package:provider/provider.dart';
import 'package:websafe_svg/websafe_svg.dart';

import 'nav_item.dart';

const kSpacing20 = Sizes.SIZE_20;

class AppDrawer extends StatefulWidget {
  final Color color;
  final double? width;
  final List<NavItemData> menuList;
  final GestureTapCallback? onClose;

  AppDrawer({
    this.color = AppColors.black200,
    this.width,
    required this.menuList,
    this.onClose,
  });

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    final config = Provider.of<ConfigurationProvider>(context);
    final loggedUser = Provider.of<auth.User?>(context);
    //final themeData = AppTheme.getThemeFromThemeMode(config.darkThemeEnabled ? 2 : 1);
    double defaultWidthOfDrawer = responsiveSize(
      context,
      assignWidth(context, 0.85),
      assignWidth(context, 0.60),
      md: assignWidth(context, 0.60),
    );
    return Container(
      width: widget.width ?? defaultWidthOfDrawer,
      child: Drawer(
        child: Container(
          color: widget.color,
          padding: const EdgeInsets.symmetric(
            horizontal: Sizes.PADDING_24,
            vertical: Sizes.PADDING_24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      if (loggedUser?.uid != null) {
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
                      child: FutureBuilder(
                        future: FirebaseFirestore.instance.collection(Constants.users).doc(loggedUser?.uid).get(),
                        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>?> snapshot) {
                          return (snapshot.connectionState == ConnectionState.waiting)
                              ? shimmerNode(context, widget.onClose, widget.width, defaultWidthOfDrawer).addNeumorphism(
                                  blurRadius: kradius,
                                  borderRadius: kradius,
                                  offset: Offset(5, 5),
                                  topShadowColor: Colors.white60,
                                  bottomShadowColor: Color(0xFF234395).withOpacity(0.15),
                                )
                              : _buildMetricWidget(snapshot.data, defaultWidthOfDrawer);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Spacer(flex: 2),
              ..._buildMenuList(
                context: context,
                menuList: widget.menuList,
              ),
              Spacer(flex: 6),
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
              _buildFooterText(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMenuList({
    required BuildContext context,
    required List<NavItemData> menuList,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final loggedUser = Provider.of<auth.User?>(context, listen: false);
    List<Widget> menuItems = [];
    for (var i = 0; i < menuList.length; i++) {
      menuItems.add(
        NavItem(
          onTap: () => _onTapNavItem(
            context: menuList[i].key,
            navItemName: menuList[i].name,
          ),
          title: menuList[i].name,
          isMobile: true,
          isSelected: menuList[i].isSelected,
          titleStyle: textTheme.bodyText1?.copyWith(
            color: menuList[i].isSelected ? AppColors.primary200 : AppColors.white,
            fontSize: Sizes.TEXT_SIZE_16,
            fontWeight: menuList[i].isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      );
      menuItems.add(Spacer());
    }

    menuItems.add(
      NavItem(
        onTap: () {
          if (loggedUser?.uid != null) {
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
        title: "Profile",
        isMobile: true,
        isSelected: false,
        titleStyle: textTheme.bodyText1?.copyWith(
          color: AppColors.white,
          fontSize: Sizes.TEXT_SIZE_16,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
    menuItems.add(Spacer());

    menuItems.add(
      NavItem(
        onTap: () {
          Navigator.of(context).push(
            new MaterialPageRoute<Null>(
              builder: (BuildContext context) {
                return Entrance();
              },
              fullscreenDialog: true,
            ),
          );
        },
        title: "Bible",
        isMobile: true,
        isSelected: false,
        titleStyle: textTheme.bodyText1?.copyWith(
          color: AppColors.white,
          fontSize: Sizes.TEXT_SIZE_16,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
    menuItems.add(Spacer());

    menuItems.add(
      FutureBuilder(
        future: FirebaseFirestore.instance.collection(Constants.users).doc(loggedUser?.uid).get(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>?> snapshot) {
          return (snapshot.connectionState == ConnectionState.waiting) ? Container() : _build(snapshot.data?.data() ?? {}, context, textTheme);
        },
      ),
    );

    menuItems.add(Spacer());

    menuItems.add(
      FutureBuilder(
        future: FirebaseFirestore.instance.collection(Constants.users).doc(loggedUser?.uid).get(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>?> snapshot) {
          return (snapshot.connectionState == ConnectionState.waiting)
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : _chose(snapshot.data?.data() ?? {}, context, textTheme);
        },
      ),
    );

    menuItems.add(Spacer());
    return menuItems;
  }

  Widget _chose(Map<String, dynamic> data, BuildContext context, TextTheme textTheme) {
    var user = User.fromJson(data);
    Globals().updateGlobalUser(user);
    switch (user.role ?? Role.member) {
      case Role.admin:
        return NavItem(
          onTap: () {
            MyApp.validateTheme(context); //find another way to do this...
            //Navigator.push(context, MaterialPageRoute(builder: (context) => AdminScreen(role: Role.admin)));
          },
          title: "Admin Panel",
          isMobile: true,
          isSelected: false,
          titleStyle: textTheme.bodyText1?.copyWith(
            color: AppColors.white,
            fontSize: Sizes.TEXT_SIZE_16,
            fontWeight: FontWeight.normal,
          ),
        );
      default:
        return Container();
    }
  }

  Widget _build(Map<String, dynamic> data, BuildContext context, TextTheme textTheme) {
    var user = User.fromJson(data);
    Globals().updateGlobalUser(user);
    return NavItem(
      onTap: () {
        if (user.uid != null && user.firstName != null) {
          Navigator.of(context).push(
            new MaterialPageRoute<Null>(
              builder: (BuildContext context) {
                return PrayerRequestUploadScreen();
              },
              fullscreenDialog: true,
            ),
          );
        } else if (user.uid == null) {
          EasyLoading.showToast("Please Sign In and update your details before you proceed");
          Navigator.push(context, MaterialPageRoute(builder: (context) => Authenticate()));
        } else {
          EasyLoading.showToast("Please update your details before you proceed");
          Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen()));
        }
      },
      title: "Prayer Request",
      isMobile: true,
      isSelected: false,
      titleStyle: textTheme.bodyText1?.copyWith(
        color: AppColors.white,
        fontSize: Sizes.TEXT_SIZE_16,
        fontWeight: FontWeight.normal,
      ),
    );
  }

  _buildMetricWidget(DocumentSnapshot<Map<String, dynamic>>? doc, double defaultWidthOfDrawer) {
    var user = User.fromJson(doc?.data() ?? {});
    Globals().updateGlobalUser(user);
    return Container(
      padding: EdgeInsets.only(left: defaultPadding, right: defaultPadding),
      margin: EdgeInsets.only(bottom: defaultPadding / 2),
      width: (widget.width ?? defaultWidthOfDrawer) - 2 * Sizes.PADDING_24,
      decoration: BoxDecoration(
        color: kBgDarkColor,
        borderRadius: BorderRadius.circular(kradius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            width: nWidth,
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              backgroundImage: CachedNetworkImageProvider(user.avatarUrl ?? Constants.logoUrl),
            ),
          ),
          SizedBox(width: kDefaultPadding / 2),
          Column(
            children: [
              SizedBox(height: defaultPadding),
              Text.rich(
                TextSpan(
                  text: "${user.firstName ?? 'Unknown'} ${user.lastName ?? 'Name'} \n",
                  children: [
                    TextSpan(
                      text: "${user.role ?? "Visitor"} Profile \n",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: kTextColor,
                      ),
                    ),
                  ],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: kTextColor,
                  ),
                ),
              ),
            ],
          ),
          Spacer(),
          InkWell(
            onTap: widget.onClose ?? () => _closeDrawer(),
            child: Icon(
              Icons.close,
              size: Sizes.ICON_SIZE_30,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    ).addNeumorphism(
      blurRadius: kradius,
      borderRadius: kradius,
      offset: Offset(5, 5),
      topShadowColor: Colors.white60,
      bottomShadowColor: Color(0xFF234395).withOpacity(0.15),
    );
  }

  _onTapNavItem({
    required GlobalKey context,
    required String navItemName,
  }) {
    for (int index = 0; index < widget.menuList.length; index++) {
      if (navItemName == widget.menuList[index].name) {
        scrollToSection(context.currentContext!);
        setState(() {
          widget.menuList[index].isSelected = true;
        });
        _closeDrawer();
      } else {
        widget.menuList[index].isSelected = false;
      }
    }
  }

  _closeDrawer() {
    context.router.pop();
  }

  Widget _buildFooterText() {
    TextTheme textTheme = Theme.of(context).textTheme;
    TextStyle? footerTextStyle = textTheme.caption?.copyWith(
      color: AppColors.primaryText2Light,
      fontWeight: FontWeight.bold,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: SelectableText.rich(
            TextSpan(
              text: StringConst.RIGHTS_RESERVED + " ",
              style: footerTextStyle,
              /* children: [
                TextSpan(text: StringConst.DESIGNED_BY + " "),
                TextSpan(
                  text: StringConst.WEB_GENIUS_LAB,
                  style: footerTextStyle?.copyWith(
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w900,
                    color: AppColors.white,
                  ),
                ),
              ], */
            ),
            textAlign: TextAlign.center,
          ),
        ),
        /* Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
              text: TextSpan(
                text: StringConst.BUILT_BY + " ",
                style: footerTextStyle,
                children: [
                  TextSpan(
                    text: StringConst.DAVID_COBBINA + ". ",
                    style: footerTextStyle?.copyWith(
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w900,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SpaceH4(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(StringConst.MADE_IN_GHANA, style: footerTextStyle),
            SpaceW4(),
            ClipRRect(
              borderRadius: BorderRadius.all(const Radius.circular(20)),
              child: Image.asset(
                ImagePath.GHANA_FLAG,
                width: Sizes.WIDTH_16,
                height: Sizes.HEIGHT_16,
                fit: BoxFit.cover,
              ),
            ),
            SpaceW4(),
            Text(StringConst.WITH_LOVE, style: footerTextStyle),
            SpaceW4(),
            Icon(
              FontAwesomeIcons.solidHeart,
              color: AppColors.red,
              size: Sizes.ICON_SIZE_12,
            ),
          ],
        ), */
      ],
    );
  }
}
