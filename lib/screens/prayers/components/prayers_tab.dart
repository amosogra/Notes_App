import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/internal/constants.dart';
import 'package:notes_app/kconstants.dart';
import 'package:notes_app/providers/configurationProvider.dart';
import 'package:notes_app/responsive.dart';
import 'package:notes_app/screens/admin/prayers/components/list_of_prayers.dart';
import 'package:provider/provider.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';

class PrayerTabs extends StatefulWidget {
  const PrayerTabs({Key? key}) : super(key: key);

  @override
  _PrayerTabsState createState() => _PrayerTabsState();
}

class _PrayerTabsState extends State<PrayerTabs> {
  @override
  Widget build(BuildContext context) {
    final config = Provider.of<ConfigurationProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text("PRAYER PORTAL"), centerTitle: true, leading: Responsive.isMobile(context) ? BackButton() : null),
      body: DefaultTabController(
        length: 3,
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(defaultPadding, 0, defaultPadding, defaultPadding),
                child: TabBar(
                  isScrollable: true,
                  indicatorColor: Colors.green,
                  labelColor: config.darkThemeEnabled ? Colors.white : Colors.black, //Theme.of(context).accentColor,
                  labelStyle: TextStyle(fontSize: 13, fontFamily: 'Product Sans', fontWeight: FontWeight.w600, letterSpacing: 0.3),
                  unselectedLabelStyle: TextStyle(fontSize: 13, fontFamily: 'Product Sans', fontWeight: FontWeight.w600, letterSpacing: 0.2),
                  unselectedLabelColor: Theme.of(context).textTheme.bodyText1?.color?.withOpacity(0.4),
                  indicator: DotIndicator(
                    color: config.darkThemeEnabled ? Colors.white : Colors.black,
                    radius: 3,
                    distanceFromCenter: defaultPadding,
                    paintingStyle: PaintingStyle.fill,
                  ),
                  tabs: [
                    Tab(child: Text("All Requests")),
                    Tab(child: Text("Pending Requests")),
                    Tab(child: Text("Processed Requests")),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    ListOfPrayers(board: Constants.prayerRequests),
                    ListOfPrayers(board: Constants.prayerRequests, prayed: false),
                    ListOfPrayers(board: Constants.prayerRequests, prayed: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
