import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/models/user_model.dart';
import 'package:notes_app/providers/configurationProvider.dart';
import 'package:notes_app/responsive.dart';
import 'package:provider/provider.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../kconstants.dart';
import 'components/header.dart';

class UserScreen extends StatefulWidget {
  static String routeName = "/user_details";

  UserScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  final User user;

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        body: buildDetail(context),
      ),
    );
  }

  Container buildDetail(BuildContext context) {
    ConfigurationProvider config = Provider.of<ConfigurationProvider>(context);
    return Container(
      color: config.darkThemeEnabled ? bgColorD : Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Header(
              user: widget.user,
            ),
            Divider(thickness: 1),
            Padding(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    maxRadius: 24,
                    backgroundColor: Colors.transparent,
                    backgroundImage: CachedNetworkImageProvider(widget.user.avatarUrl!),
                  ),
                  SizedBox(width: kDefaultPadding),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      text: "${widget.user.firstName ?? 'Unknown'} ${widget.user.lastName ?? ''}\n",
                                      style: Theme.of(context).textTheme.button,
                                      children: [
                                        TextSpan(
                                          text: "${widget.user.role} Profile <${widget.user.email}>",
                                          style: Theme.of(context).textTheme.caption?.copyWith(
                                                color: config.darkThemeEnabled ? Colors.white70 : null,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: kDefaultPadding / 2),
                            Text(
                              "${timeago.format((widget.user.lastSignedTimestamp ?? widget.user.regTimestamp as Timestamp).toDate())}",
                              style: Theme.of(context).textTheme.caption?.copyWith(
                                    color: config.darkThemeEnabled ? Colors.white70 : null,
                                  ),
                            ),
                          ],
                        ),
                        SizedBox(height: kDefaultPadding),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(kDefaultPadding, 0, kDefaultPadding, kDefaultPadding),
              child: TabBar(
                indicatorColor: Colors.green,
                labelColor: config.darkThemeEnabled ? Colors.white : Colors.black, //Theme.of(context).accentColor,
                labelStyle: TextStyle(fontSize: 13, fontFamily: 'Product Sans', fontWeight: FontWeight.w600, letterSpacing: 0.3),
                unselectedLabelStyle: TextStyle(fontSize: 13, fontFamily: 'Product Sans', fontWeight: FontWeight.w600, letterSpacing: 0.2),
                unselectedLabelColor: Theme.of(context).textTheme.bodyText1?.color?.withOpacity(0.4),
                indicator: RectangularIndicator(
                  color: config.darkThemeEnabled ? Colors.white : Colors.black,
                  bottomLeftRadius: 100,
                  bottomRightRadius: 100,
                  topLeftRadius: 100,
                  topRightRadius: 100,
                  paintingStyle: PaintingStyle.stroke,
                ),
                tabs: [
                  Tab(child: Text("${widget.user.role ?? "Visitor's"} Detail")),
                  //Tab(child: Text("User Boards")),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  buildDetailLayout(config),
                  /* buildBodyFrame(
                   Container()
                  ), */
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Adds scrolling and padding to the [content].
  Widget buildBodyFrame(Widget content) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: content,
      ),
    );
  }

  LayoutBuilder buildDetailLayout(ConfigurationProvider config) {
    return LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        width: constraints.maxWidth > 850 ? 800 : constraints.maxWidth,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(kDefaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "First Name: ${widget.user.firstName ?? "Not Updated"}\n\nLast Name: ${widget.user.lastName ?? "Not Updated"}\n\nRole: ${widget.user.role}\n\nGender: ${widget.user.gender ?? "Not Updated"}\n\nEmail: ${widget.user.email}\n\nHome Address: ${widget.user.address?.address1 ?? "Not Updated"}\n\nRegistration Date: ${DateFormat("EEE, d MMM yyyy hh:mm a").format((widget.user.regTimestamp as Timestamp).toDate())}\n\nLast Signed In: ${timeago.format((widget.user.lastSignedTimestamp as Timestamp).toDate())} [${DateFormat("EEE, d MMM yyyy hh:mm a").format((widget.user.lastSignedTimestamp as Timestamp).toDate())}]\n\nLast Visited In: ${widget.user.lastVisitedTimestamp == null ? 'No record.' : '${timeago.format((widget.user.lastVisitedTimestamp as Timestamp).toDate())} [${DateFormat("EEE, d MMM yyyy hh:mm a").format((widget.user.lastVisitedTimestamp as Timestamp).toDate())}]'}\n\nLast Checked In: ${widget.user.lastCheckedInTimestamp == null ? 'Never Checked In' : '${timeago.format((widget.user.lastCheckedInTimestamp as Timestamp).toDate())} [${DateFormat("EEE, d MMM yyyy hh:mm a").format((widget.user.lastCheckedInTimestamp as Timestamp).toDate())}]'}\n\nThe last time this profile was updated by ${widget.user.firstName ?? widget.user.email}: ${widget.user.lastModified != null ? timeago.format((widget.user.lastModified as Timestamp).toDate()) : 'Not updated yet'} [${widget.user.lastModified != null ? DateFormat("EEE, d MMM yyyy hh:mm a").format((widget.user.lastModified as Timestamp).toDate()) : ''}]\n\n",
                style: TextStyle(
                  height: 1.5,
                  color: config.darkThemeEnabled ? Colors.white : Color(0xFF4D5875),
                  fontWeight: FontWeight.w300,
                ),
              ),
              SizedBox(height: kDefaultPadding),
              Row(
                children: [
                  widget.user.images!.length != 0
                      ? Text(
                          "${widget.user.images!.length} ${widget.user.images!.length > 1 ? 'attachments' : 'attachment'}",
                          style: TextStyle(fontSize: 12),
                        )
                      : Text(
                          "No image attachments",
                          style: TextStyle(fontSize: 12),
                        ),
                  Spacer(),
                  widget.user.images!.length != 0
                      ? Text(
                          "Download All",
                          style: Theme.of(context).textTheme.caption,
                        )
                      : Container(),
                  SizedBox(width: kDefaultPadding / 4),
                  widget.user.images!.length != 0
                      ? WebsafeSvg.asset(
                          "assets/Icons/Download.svg",
                          height: 16,
                          color: kGrayColor,
                        )
                      : Container(),
                ],
              ),
              Divider(thickness: 1),
              SizedBox(height: kDefaultPadding / 2),
              widget.user.images!.length != 0
                  ? SizedBox(
                      height: 200,
                      child: StaggeredGridView.countBuilder(
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: 4,
                        itemCount: widget.user.images!.length,
                        itemBuilder: (BuildContext context, int index) => ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            widget.user.images![index],
                            fit: BoxFit.cover,
                          ),
                        ),
                        staggeredTileBuilder: (int index) => StaggeredTile.count(
                          2,
                          index.isOdd ? 2 : 1,
                        ),
                        mainAxisSpacing: kDefaultPadding,
                        crossAxisSpacing: kDefaultPadding,
                      ),
                    )
                  : Container(),
              SizedBox(
                height: Responsive.isMobile(context)
                    ? 1
                    : Responsive.isTablet(context)
                        ? 100
                        : 200,
                child: Container(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
