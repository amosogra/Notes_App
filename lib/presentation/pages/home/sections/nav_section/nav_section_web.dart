import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:notes_app/Bible/entrance.dart';
import 'package:notes_app/authentication/authenticate/authenticate.dart';
import 'package:notes_app/internal/constants.dart';
import 'package:notes_app/kconstants.dart';
import 'package:notes_app/extensions.dart';
import 'package:notes_app/main.dart';
import 'package:notes_app/models/user_model.dart';
import 'package:notes_app/presentation/layout/adaptive.dart';
import 'package:notes_app/presentation/widgets/buttons/nimbus_button.dart';
import 'package:notes_app/presentation/widgets/buttons/social_button.dart';
import 'package:notes_app/presentation/widgets/empty.dart';
import 'package:notes_app/presentation/widgets/nav_item.dart';
import 'package:notes_app/presentation/widgets/nimbus_vertical_divider.dart';
import 'package:notes_app/presentation/widgets/spaces.dart';
import 'package:notes_app/providers/configurationProvider.dart';
import 'package:notes_app/screens/admin/admin_screen.dart';
import 'package:notes_app/screens/home/edit_profile_screen.dart';
import 'package:notes_app/screens/menus/drawer_list_title.dart';
import 'package:notes_app/screens/notification/NotificationScreen.dart';
import 'package:notes_app/screens/notification/admin/PrayerRequestUploadScreen.dart';
import 'package:notes_app/ui/AppTheme.dart';
import 'package:notes_app/utils/functions.dart';
import 'package:notes_app/utils/globals.dart';
import 'package:notes_app/values/values.dart';
import 'package:provider/provider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:responsive_builder/responsive_builder.dart';

//TODO:: Add proper link to nimbus logo to reload the page
//TODO:: Add animation to contact me button (if I am feeling adventurous)

const double logoSpaceLeftLg = 40.0;
const double logoSpaceLeftSm = 20.0;
const double logoSpaceRightLg = 70.0;
const double logoSpaceRightSm = 35.0;
const double contactButtonSpaceLeftLg = 60.0;
const double contactButtonSpaceLeftSm = 30.0;
const double contactButtonSpaceRightLg = 40.0;
const double contactButtonSpaceRightSm = 20.0;
const double contactBtnWidthLg = 150.0;
const double contactBtnWidthSm = 120.0;
const int menuSpacerRightLg = 5;
const int menuSpacerRightMd = 4;
const int menuSpacerRightSm = 3;

class NavSectionWeb extends StatefulWidget {
  final List<NavItemData> navItems;

  NavSectionWeb({required this.navItems});

  @override
  _NavSectionWebState createState() => _NavSectionWebState();
}

class _NavSectionWebState extends State<NavSectionWeb> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final config = Provider.of<ConfigurationProvider>(context);
    final loggedUser = Provider.of<auth.User?>(context, listen: false);

    double logoSpaceLeft = responsiveSize(context, logoSpaceLeftSm, logoSpaceLeftLg);
    double logoSpaceRight = responsiveSize(context, logoSpaceRightSm, logoSpaceRightLg);
    double contactBtnSpaceLeft = responsiveSize(
      context,
      contactButtonSpaceLeftSm,
      contactButtonSpaceLeftLg,
    );
    double contactBtnSpaceRight = responsiveSize(
      context,
      contactButtonSpaceRightSm,
      contactButtonSpaceRightLg,
    );
    double contactBtnWidth = responsiveSize(
      context,
      contactBtnWidthSm,
      contactBtnWidthLg,
    );
    int menuSpacerRight = responsiveSizeInt(
      context,
      menuSpacerRightSm,
      menuSpacerRightLg,
      md: menuSpacerRightMd,
    );

    return Container(
      height: Sizes.HEIGHT_100,
      decoration: BoxDecoration(
        color: config.darkThemeEnabled ? AppColors.black100 : Colors.white,
        boxShadow: [
          Shadows.elevationShadow,
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            SizedBox(width: logoSpaceLeft),
            InkWell(
              onTap: () {},
              child: Image.asset(
                config.darkThemeEnabled ? ImagePath.LOGO_LIGHT : ImagePath.LOGO_DARK,
                height: Sizes.HEIGHT_52,
              ),
            ),
            SizedBox(width: logoSpaceRight),
            NimbusVerticalDivider(),
            Spacer(flex: 1),
            ..._buildNavItems(widget.navItems, config),
            FutureBuilder(
              future: FirebaseFirestore.instance.collection(Constants.users).doc(loggedUser?.uid).get(),
              builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>?> snapshot) {
                return (snapshot.connectionState == ConnectionState.waiting) ? Container() : _build(snapshot.data?.data() ?? {}, context, textTheme, config);
              },
            ),
            Spacer(),
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
              isSelected: false,
              titleColor: config.darkThemeEnabled ? Colors.white : Colors.black,
            ),
            Spacer(),
            FutureBuilder(
              future: FirebaseFirestore.instance.collection(Constants.users).doc(loggedUser?.uid).get(),
              builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>?> snapshot) {
                return (snapshot.connectionState == ConnectionState.waiting)
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : _chose(snapshot.data?.data() ?? {}, context, textTheme, config);
              },
            ),
            Spacer(),
            NavItem(
              onTap: () {
                Navigator.of(context).push(
                  new MaterialPageRoute<Null>(
                    builder: (BuildContext context) {
                      return Entrance();
                    },
                  ),
                );
              },
              title: "Bible",
              isSelected: false,
              titleColor: config.darkThemeEnabled ? Colors.white : Colors.black,
            ),
            Spacer(),
            Container(
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    new MaterialPageRoute<Null>(
                      builder: (BuildContext context) {
                        return NotificationScreen(fromAdmin: Globals().globalUser?.role == Role.admin);
                      },
                      fullscreenDialog: true,
                    ),
                  );
                },
                child: Stack(
                  overflow: Overflow.visible,
                  children: <Widget>[
                    Icon(MdiIcons.bellOutline,
                        color: config.darkThemeEnabled
                            ? Colors.white
                            : Colors.grey[900]?.withAlpha(
                                200) /* config.darkThemeEnabled ? Theme.of(context).colorScheme.onBackground.withAlpha(200) : Colors.grey[800]?.withAlpha(200) */),
                    Positioned(
                      top: -08.0,
                      right: -08.0,
                      child: Card(
                        elevation: 0,
                        clipBehavior: Clip.antiAlias,
                        shape: StadiumBorder(),
                        color: Colors.red,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          constraints: BoxConstraints(minWidth: 20.0),
                          child: Center(
                            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                              stream: FirebaseFirestore.instance.collection(Constants.notification).snapshots(),
                              builder: (context, snapshot) {
                                return (snapshot.connectionState == ConnectionState.waiting) ? Container() : buildText(snapshot, context);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            ResponsiveBuilder(
              refinedBreakpoints: RefinedBreakpoints(),
              builder: (context, sizingInformation) {
                double screenWidth = sizingInformation.screenSize.width;
                if (screenWidth < (RefinedBreakpoints().desktopSmall + 450)) {
                  return Empty();
                } else {
                  return Row(
                    children: [
                      ..._buildSocialIcons(Data.socialData),
                      SpaceW20(),
                    ],
                  );
                }
              },
            ),
            NimbusVerticalDivider(),
            if (loggedUser?.uid == null) SizedBox(width: contactBtnSpaceLeft),
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
                child: loggedUser?.uid != null
                    ? FutureBuilder(
                        future: FirebaseFirestore.instance.collection(Constants.users).doc(loggedUser?.uid).get(),
                        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>?> snapshot) {
                          return (snapshot.connectionState == ConnectionState.waiting)
                              ? Padding(
                                  padding: const EdgeInsets.all(defaultPadding * 2),
                                  child: NimbusButton(
                                    buttonTitle: StringConst.CONTACT_US,
                                    width: contactBtnWidth,
                                    onPressed: () => openUrlLink(StringConst.EMAIL_URL),
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(defaultPadding / 4),
                                  child: _buildMetricWidget(snapshot.data, contactBtnWidth),
                                );
                        },
                      )
                    : NimbusButton(
                        buttonTitle: StringConst.CONTACT_US,
                        width: contactBtnWidth,
                        onPressed: () => openUrlLink(StringConst.EMAIL_URL),
                      ),
              ),
            ),
            if (loggedUser?.uid == null) SizedBox(width: contactBtnSpaceRight),
          ],
        ),
      ),
    );
  }

  Text buildText(AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot, BuildContext context) {
    var datas = DrawerListTile.getNotifications(snapshot);

    return Text(
      "${datas.length > 9 ? '9+' : datas.length}",
      style: AppTheme.getTextStyle(
        Theme.of(context).textTheme.overline,
        color: Colors.white,
        fontSize: 9,
        fontWeight: 500,
      ),
    );
  }

  Widget _chose(Map<String, dynamic> data, BuildContext context, TextTheme textTheme, ConfigurationProvider config) {
    var user = User.fromJson(data);
    Globals().updateGlobalUser(user);
    switch (user.role ?? Role.member) {
      case Role.admin:
        return NavItem(
          onTap: () {
            MyApp.validateTheme(context);
            //Navigator.push(context, MaterialPageRoute(builder: (context) => AdminScreen(role: Role.admin)));
          },
          title: "Admin Panel",
          isSelected: false,
          titleColor: config.darkThemeEnabled ? Colors.white : Colors.black,
        );
      default:
        return Container();
    }
  }

  Widget _build(Map<String, dynamic> data, BuildContext context, TextTheme textTheme, ConfigurationProvider config) {
    var user = User.fromJson(data);
    Globals().updateGlobalUser(user);
    return NavItem(
      onTap: () {
        if (user.uid != null && user.firstName != null) {
          Navigator.of(context).push(new MaterialPageRoute<Null>(
            builder: (BuildContext context) {
              return PrayerRequestUploadScreen();
            },
            /* fullscreenDialog: true */
          ));
        } else if (user.uid == null) {
          EasyLoading.showToast("Please Sign In and update your details before you proceed");
          Navigator.push(context, MaterialPageRoute(builder: (context) => Authenticate()));
        } else {
          EasyLoading.showToast("Please update your details before you proceed");
          Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen()));
        }
      },
      title: "Prayer Request",
      isSelected: false,
      titleColor: config.darkThemeEnabled ? Colors.white : Colors.black,
    );
  }

  _buildMetricWidget(DocumentSnapshot<Map<String, dynamic>>? doc, double contactBtnWidth) {
    var user = User.fromJson(doc?.data() ?? {});
    Globals().updateGlobalUser(user);
    return Container(
      padding: EdgeInsets.all(defaultPadding / 2),
      //margin: EdgeInsets.only(bottom: defaultPadding / 2),
      //width: contactBtnWidth,
      decoration: BoxDecoration(
        color: kBgDarkColor,
        borderRadius: BorderRadius.circular(kradius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: nWidth,
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              backgroundImage: CachedNetworkImageProvider(user.avatarUrl ?? Constants.logoUrl),
            ),
          ),
          SizedBox(width: kDefaultPadding / 2),
          Flexible(
            child: Column(
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
    for (int index = 0; index < widget.navItems.length; index++) {
      if (navItemName == widget.navItems[index].name) {
        scrollToSection(context.currentContext!);
        setState(() {
          widget.navItems[index].isSelected = true;
        });
      } else {
        widget.navItems[index].isSelected = false;
      }
    }
  }

  List<Widget> _buildNavItems(List<NavItemData> navItems, ConfigurationProvider config) {
    List<Widget> items = [];
    for (int index = 0; index < navItems.length; index++) {
      items.add(
        NavItem(
          title: navItems[index].name,
          isSelected: navItems[index].isSelected,
          titleColor: config.darkThemeEnabled ? Colors.white : Colors.black,
          onTap: () => _onTapNavItem(
            context: navItems[index].key,
            navItemName: navItems[index].name,
          ),
        ),
      );
      items.add(Spacer());
    }
    return items;
  }

  List<Widget> _buildSocialIcons(List<SocialButtonData> socialItems) {
    List<Widget> items = [];
    for (int index = 0; index < socialItems.length; index++) {
      items.add(
        SocialButton(
          tag: socialItems[index].tag,
          iconData: socialItems[index].iconData,
          onPressed: () => openUrlLink(socialItems[index].url),
        ),
      );
      items.add(SpaceW16());
    }
    return items;
  }
}
