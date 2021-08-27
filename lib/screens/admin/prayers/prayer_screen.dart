import 'package:flutter/material.dart';
import 'package:notes_app/providers/widgetScreenProvider.dart';
import 'package:notes_app/responsive.dart';
import 'package:notes_app/screens/menus/admin_side_menu.dart';
import 'package:notes_app/screens/prayers/components/prayers_tab.dart';
import 'package:provider/provider.dart';

class PrayerScreen extends StatelessWidget {
  static String routeName = "/prayer";
  const PrayerScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // It provide us the width and height
    Size _size = MediaQuery.of(context).size;
    final deskScreen = Provider.of<WidgetScreenProvider>(context);
    return Scaffold(
      //appBar: AppBar(backgroundColor: Colors.blue.withOpacity(0.6),),
      body: Responsive(
        // Let's work on our mobile part
        mobile: PrayerTabs(),
        // Let's work on our tablet part
        tablet: Row(
          children: [
            Expanded(
              flex: 7,
              child: PrayerTabs(),
            ),
            Expanded(
              flex: 8,
              child: deskScreen.screenWidget()!,
            ),
          ],
        ),
        // Let's work on our desktop part
        desktop: Row(
          children: [
            // Once our width is less then 1300 then it start showing errors
            // Now there is no error if our width is less then 1340
            Expanded(
              flex: _size.width > 1340 ? 2 : 3,
              child: AdminSideMenu(),
            ),
            Expanded(
              flex: _size.width > 1340 ? 4 : 5,
              child: PrayerTabs(),
            ),
            Expanded(
              flex: _size.width > 1340 ? 6 : 7,
              child: deskScreen.screenWidget()!,
            ),
          ],
        ),
      ),
    );
  }
}
