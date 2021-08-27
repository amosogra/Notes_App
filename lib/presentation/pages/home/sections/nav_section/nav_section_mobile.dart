import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:notes_app/internal/constants.dart';
import 'package:notes_app/kconstants.dart';
import 'package:notes_app/presentation/widgets/spaces.dart';
import 'package:notes_app/providers/configurationProvider.dart';
import 'package:notes_app/screens/menus/drawer_list_title.dart';
import 'package:notes_app/screens/notification/NotificationScreen.dart';
import 'package:notes_app/ui/AppTheme.dart';
import 'package:notes_app/utils/globals.dart';
import 'package:notes_app/values/values.dart';
import 'package:provider/provider.dart';

class NavSectionMobile extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const NavSectionMobile({required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<ConfigurationProvider>(context);
    return Container(
      height: Sizes.HEIGHT_100,
      decoration: BoxDecoration(
        color: AppColors.black100,
      ),
      child: Row(
        children: [
          SpaceW20(),
          IconButton(
            icon: Icon(
              FeatherIcons.menu,
              color: AppColors.white,
              size: Sizes.ICON_SIZE_26,
            ),
            onPressed: () {
              if (scaffoldKey.currentState!.isEndDrawerOpen) {
                scaffoldKey.currentState?.openEndDrawer();
              } else {
                scaffoldKey.currentState?.openDrawer();
              }
            },
          ),
          Spacer(flex: 2),
          Center(
            child: InkWell(
              onTap: () {},
              child: Image.asset(
                ImagePath.LOGO_LIGHT,
                height: Sizes.HEIGHT_52,
              ),
            ),
          ),
          Spacer(flex: 2),
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
                      color: Colors.white.withAlpha(
                          200) /*config.darkThemeEnabled ? Theme.of(context).colorScheme.onBackground.withAlpha(200)  : Colors.grey[800]?.withAlpha(200) */),
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
          SizedBox(width: defaultPadding)
        ],
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
}
