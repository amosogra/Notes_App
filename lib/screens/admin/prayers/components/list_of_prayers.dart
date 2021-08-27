import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire;
import 'package:flutter/material.dart';
import 'package:notes_app/kconstants.dart';
import 'package:notes_app/models/user_model.dart';
import 'package:notes_app/providers/selectedItemProvider.dart';
import 'package:notes_app/providers/widgetScreenProvider.dart';
import 'package:notes_app/responsive.dart';
import 'package:notes_app/screens/admin/prayers/components/prayer_card.dart';
import 'package:notes_app/screens/admin/prayers/components/prayer_detail.dart';
import 'package:notes_app/ui/components/shimmerContainer.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

class ListOfPrayers extends StatefulWidget {
  const ListOfPrayers({
    Key? key,
    required this.board,
    this.prayed,
  }) : super(key: key);

  final bool? prayed;
  final String board;

  @override
  _ListOfPrayersState createState() => _ListOfPrayersState();
}

class _ListOfPrayersState extends State<ListOfPrayers> {
  SelectedItemProvider? selectedPrayerProvider;
  var db = Hive.box('settings');

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 100), () {
      Provider.of<SelectedItemProvider>(context, listen: false).updateSelected(0);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loggedUser = Provider.of<fire.User?>(context);
    final deskScreen = Provider.of<WidgetScreenProvider>(context);
    selectedPrayerProvider = Provider.of<SelectedItemProvider>(context);
    return Container(
      padding: EdgeInsets.only(top: kIsWeb ? kDefaultPadding : 0),
      color: Colors.transparent,
      child: SafeArea(
        //right: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: loggedUser?.uid != null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.prayed != null)
                          StreamBuilder(
                            initialData: null,
                            stream: FirebaseFirestore.instance
                                .collection(widget.board)
                                .where("prayed", isEqualTo: widget.prayed)
                                .orderBy("timestamp", descending: false)
                                .snapshots(),
                            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>?> snapshot) {
                              return (snapshot.connectionState == ConnectionState.waiting) ? buildShimmer() : buildListView(snapshot, deskScreen);
                            },
                          )
                        else
                          StreamBuilder(
                            initialData: null,
                            stream: FirebaseFirestore.instance.collection(widget.board).orderBy("timestamp", descending: false).snapshots(),
                            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>?> snapshot) {
                              return (snapshot.connectionState == ConnectionState.waiting) ? buildShimmer() : buildListView(snapshot, deskScreen);
                            },
                          )
                      ],
                    )
                  : buildShimmer(),
            ),
          ],
        ),
      ),
    );
  }

  ListView buildListView(AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>?> snapshot, WidgetScreenProvider deskScreen) {
    var data = snapshot.data?.docs ?? [];
    var users = data.map((qds) => PrayerRequester.fromJson(qds.data())).toList();
    return ListView.builder(
      shrinkWrap: true,
      physics: kIsWeb ? AlwaysScrollableScrollPhysics() : NeverScrollableScrollPhysics(),
      itemCount: users.length,
      itemBuilder: (context, index) {
        // On mobile this active dosen't mean anything
        return PrayerCard(
          isActive: Responsive.isMobile(context) ? false : index == selectedPrayerProvider?.selected(),
          user: users[index],
          press: () {
            if (Responsive.isMobile(context)) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AboutPrayerRequesterScreen(prayerRequester: users[index]),
                ),
              );

              return;
            }

            selectedPrayerProvider?.updateSelected(index);
            deskScreen.updateScreen(AboutPrayerRequesterScreen(prayerRequester: users[index]));
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
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.prayed != null)
                          ShimmerContainer(
                            height: 15,
                            width: 180,
                            borderRadius: BorderRadius.circular(10),
                            margin: EdgeInsets.only(left: 8, top: 4, bottom: 8),
                          ),
                        ShimmerContainer(
                          height: 15,
                          width: double.infinity,
                          borderRadius: BorderRadius.circular(10),
                          margin: EdgeInsets.only(left: 8, right: 8),
                        ),
                        ShimmerContainer(
                          height: 15,
                          width: 120,
                          borderRadius: BorderRadius.circular(10),
                          margin: EdgeInsets.only(left: 8, top: 4, bottom: 8),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              if (widget.prayed == null)
                ShimmerContainer(
                  height: 12,
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(10),
                  margin: EdgeInsets.only(right: 8, top: 4),
                ),
            ],
          ),
        );
      },
    );
  }
}
