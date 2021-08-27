import 'package:flutter/material.dart';
import 'package:notes_app/screens/profile/components/profile_header.dart';
import '../../components/coustom_bottom_nav_bar.dart';
import '../../enums.dart';
import '../../responsive.dart';

class ProfileScreen extends StatelessWidget {
  static String routeName = "/profile";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ProfileHeader(),
      bottomNavigationBar: Responsive.isMobile(context) ? CustomBottomNavBar(selectedMenu: MenuState.profile) : null,
    );
  }
}
