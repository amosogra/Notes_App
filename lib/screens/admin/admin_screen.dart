import 'package:flutter/material.dart';
import 'package:notes_app/providers/widgetScreenProvider.dart';
import 'package:notes_app/responsive.dart';
import 'package:notes_app/screens/menus/admin_side_menu.dart';
import 'package:provider/provider.dart';
import 'components/list_of_users.dart';

class AdminScreen extends StatelessWidget {
  static String routeName = "/admin";
  const AdminScreen({Key? key, this.role}) : super(key: key);
  final String? role;
  @override
  Widget build(BuildContext context) {
    // It provide us the width and height
    Size _size = MediaQuery.of(context).size;
    final deskScreen = Provider.of<WidgetScreenProvider>(context);
    return Scaffold(
      //appBar: AppBar(backgroundColor: Colors.blue.withOpacity(0.6),),
      body: Responsive(
        // Let's work on our mobile part
        mobile: ListOfUsers(role: role),
        // Let's work on our tablet part
        tablet: Row(
          children: [
            Expanded(
              flex: 7,
              child: ListOfUsers(role: role),
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
              child: ListOfUsers(role: role),
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
