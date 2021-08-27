import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:notes_app/providers/configurationProvider.dart';
import 'package:notes_app/providers/widgetScreenProvider.dart';
import 'package:notes_app/screens/profile/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';

import '../kconstants.dart';
import '../enums.dart';
import '../responsive.dart';

class CustomBottomNavBar extends StatefulWidget {
  CustomBottomNavBar({Key? key, required this.selectedMenu, this.fromadmin = false}) : super(key: key);
  final bool fromadmin;
  MenuState selectedMenu;

  @override
  _CustomBottomNavBarState createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
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
    final Color inActiveIconColor = Color(0xFFB6B6B6);
    final deskScreen = Provider.of<WidgetScreenProvider>(context);
    ConfigurationProvider config = Provider.of<ConfigurationProvider>(context);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: (config.darkThemeEnabled ? bgColorD : Colors.white),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, -15),
            blurRadius: 20,
            color: Color(0xFFDADADA).withOpacity(0.15),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Responsive.isMobile(context) ? 40 : 8),
          topRight: Radius.circular(Responsive.isMobile(context) ? 40 : 8),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: SvgPicture.asset(
                "assets/Icons/Heart Icon.svg",
                color: MenuState.favourite == widget.selectedMenu ? kPrimaryColor : inActiveIconColor,
              ),
              onPressed: () {
                db.put("isActive", "Store");
                setState(() {
                  widget.selectedMenu = MenuState.favourite;
                });
                //Navigator.pushNamed(context, CompleteProfileScreen.routeName);
              },
            ),
            IconButton(
              icon: SvgPicture.asset(
                "assets/Icons/Chat bubble Icon.svg",
                color: MenuState.message == widget.selectedMenu ? kPrimaryColor : inActiveIconColor,
              ),
              onPressed: () {
                db.put("isActive", "Store");
                setState(() {
                  widget.selectedMenu = MenuState.message;
                });
              },
            ),
            IconButton(
              icon: SvgPicture.asset(
                "assets/Icons/User Icon.svg",
                color: MenuState.profile == widget.selectedMenu ? kPrimaryColor : inActiveIconColor,
              ),
              onPressed: () {
                db.put("isActive", "Store");
                if (Responsive.isMobile(context)) {
                  Navigator.pushNamed(context, ProfileScreen.routeName);

                  return;
                }

                deskScreen.updateScreen(ProfileScreen());
                setState(() {
                  widget.selectedMenu = MenuState.profile;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
