import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire;
import 'package:flutter/material.dart';
import 'package:notes_app/internal/constants.dart';
import 'package:notes_app/models/user_model.dart';
import 'package:notes_app/providers/bodyTypeWidgetProvider.dart';
import 'package:notes_app/providers/configurationProvider.dart';
import 'package:notes_app/providers/selectedUserProvider.dart';
import 'package:notes_app/providers/widgetScreenProvider.dart';
import 'package:notes_app/responsive.dart';
import 'package:notes_app/screens/menus/admin_side_menu.dart';

import 'package:notes_app/screens/user/user_screen.dart';
import 'package:notes_app/ui/components/shimmerContainer.dart';
import 'package:notes_app/utils/log.dart';
import 'package:provider/provider.dart';
import 'package:websafe_svg/websafe_svg.dart';

import '../../../kconstants.dart';
import 'user_card.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

class ListOfUsers extends StatefulWidget {
  static String routeName = "/users";
  // Press "Command + ."
  const ListOfUsers({Key? key, this.role}) : super(key: key);
  final String? role;

  @override
  _ListOfUsersState createState() => _ListOfUsersState();
}

class _PrivateGlobalKey<T extends State<StatefulWidget>> extends GlobalObjectKey<T> {
  const _PrivateGlobalKey(Object value) : super(value);
}

class _ListOfUsersState extends State<ListOfUsers> {
  //final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _PrivateGlobalKey<ScaffoldState> _scaffoldKey = _PrivateGlobalKey<ScaffoldState>(
      'UserListMenuController-${Random().nextInt(1234)}-unique-${Random().nextInt(346)}-key-${Random().nextInt(16)}-${Random(1000).nextDouble()}');

  int selected = 0;
  WidgetScreenProvider? deskScreen;
  SelectedUserProvider? selectedUserProvider;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        Provider.of<SelectedUserProvider>(context, listen: false).updateSelectedUser(0);
      } else {
        log("User position not selected!");
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loggedUser = Provider.of<fire.User?>(context);
    final config = Provider.of<ConfigurationProvider>(context);
    final bodyTypeProvider = Provider.of<BodyTypeWidgetProvider>(context);
    deskScreen = Provider.of<WidgetScreenProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      drawer: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 250),
        child: AdminSideMenu(),
      ),
      body: Container(
        padding: EdgeInsets.only(top: kIsWeb ? kDefaultPadding : 0),
        color: config.darkThemeEnabled ? bgColorD : kBgDarkColor,
        child: SafeArea(
          right: false,
          child: Column(
            children: [
              // This is our Seearch bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                child: Row(
                  children: [
                    // Once user click the menu icon the menu shows like drawer
                    // Also we want to hide this menu icon on desktop
                    if (!Responsive.isDesktop(context))
                      /* IconButton(
                        icon: Icon(Icons.menu),
                        onPressed: context.read<UserListMenuController>().controlMenu,
                      ), */
                      IconButton(
                        icon: Icon(Icons.menu),
                        onPressed: () {
                          _scaffoldKey.currentState!.openDrawer();
                        },
                      ),
                    if (!Responsive.isDesktop(context)) SizedBox(width: 5),
                    Expanded(
                      child: TextField(
                        onChanged: (value) {},
                        decoration: InputDecoration(
                          hintText: "Search",
                          fillColor: (config.darkThemeEnabled ? secondaryColorD : secondaryColor),
                          filled: true,
                          suffixIcon: InkWell(
                            child: Padding(
                              padding: const EdgeInsets.all(kDefaultPadding * 0.75), //15
                              child: WebsafeSvg.asset(
                                "assets/Icons/Search.svg",
                                width: 24,
                                color: (config.darkThemeEnabled ? secondaryColor : bgColorD),
                              ),
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: kDefaultPadding),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                child: Row(
                  children: [
                    WebsafeSvg.asset(
                      "assets/Icons/Angle down.svg",
                      width: 16,
                      color: (config.darkThemeEnabled ? Colors.white : Colors.black),
                    ),
                    SizedBox(width: 5),
                    Text(
                      "Sort by date",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Spacer(),
                    MaterialButton(
                      minWidth: 20,
                      onPressed: () {},
                      child: WebsafeSvg.asset(
                        "assets/Icons/Sort.svg",
                        width: 16,
                        color: (config.darkThemeEnabled ? Colors.white : Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: kDefaultPadding),
              Flexible(
                fit: FlexFit.loose,
                child: loggedUser?.uid != null
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.role == Role.admin)
                            Flexible(
                              child: StreamBuilder(
                                initialData: null,
                                stream: FirebaseFirestore.instance
                                    .collection(Constants.users)
                                    .where("user", isEqualTo: true)
                                    .orderBy("regTimestamp", descending: false)
                                    .snapshots(),
                                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>?> snapshot) {
                                  return (snapshot.connectionState == ConnectionState.waiting) ? buildShimmer() : buildListView(snapshot, bodyTypeProvider);
                                },
                              ),
                            )
                          else
                            Flexible(
                              child: StreamBuilder(
                                initialData: null,
                                stream: FirebaseFirestore.instance
                                    .collection(Constants.users)
                                    .where("user", isEqualTo: true)
                                    .where("role", isEqualTo: widget.role)
                                    .orderBy("regTimestamp", descending: false)
                                    .snapshots(),
                                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>?> snapshot) {
                                  return (snapshot.connectionState == ConnectionState.waiting) ? buildShimmer() : buildListView(snapshot, bodyTypeProvider);
                                },
                              ),
                            ),
                        ],
                      )
                    : buildShimmer(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ListView buildListView(AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>?> snapshot, BodyTypeWidgetProvider bodyTypeProvider) {
    var data = snapshot.data?.docs ?? [];
    var users = data.map((qds) => User.fromJson(qds.data())).toList();

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        // On mobile this active dosen't mean anything
        return UserCard(
          isActive: Responsive.isMobile(context) ? false : index == selectedUserProvider?.selected,
          user: users[index],
          press: () {
            if (Responsive.isMobile(context)) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserScreen(user: users[index]),
                ),
              );

              return;
            }

            selectedUserProvider?.updateSelectedUser(index);
            deskScreen?.updateScreen(UserScreen(user: users[index]));
          },
        );
      },
    );
  }

  ListView buildShimmer() {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(left: 12, right: 12, top: index == 0 ? 12 : 0, bottom: 12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: ShimmerContainer(
                      height: 32,
                      width: 32,
                      //borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerContainer(
                          height: 15,
                          width: 150,
                          borderRadius: BorderRadius.circular(10),
                          margin: EdgeInsets.only(left: 8, top: 4, bottom: 8),
                        ),
                        ShimmerContainer(
                          height: 15,
                          width: double.infinity,
                          borderRadius: BorderRadius.circular(10),
                          margin: EdgeInsets.only(left: 8, right: 8),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              ShimmerContainer(
                height: 12,
                width: double.infinity,
                borderRadius: BorderRadius.circular(10),
                margin: EdgeInsets.only(right: 8, top: 4, bottom: 8),
              ),
              ShimmerContainer(
                height: 12,
                width: double.infinity,
                borderRadius: BorderRadius.circular(10),
                margin: EdgeInsets.only(right: 8),
              ),
            ],
          ),
        );
      },
    );
  }
}
